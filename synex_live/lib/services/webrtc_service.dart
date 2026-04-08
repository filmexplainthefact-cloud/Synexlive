import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_constants.dart';

/// WebRTC service â€” mesh P2P for â‰¤6 speakers.
/// For production at scale, swap with an SFU (e.g. LiveKit, mediasoup).
class WebRTCService {
  MediaStream? _localStream;
  final Map<String, RTCPeerConnection> _peers = {};
  final Map<String, MediaStream> _remoteStreams = {};

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final Map<String, RTCVideoRenderer> remoteRenderers = {};

  Function(String uid, MediaStream stream)? onRemoteStreamAdded;
  Function(String uid)? onRemoteStreamRemoved;

  bool _audioEnabled = true;
  bool _videoEnabled = false;
  bool get isAudioEnabled => _audioEnabled;
  bool get isVideoEnabled => _videoEnabled;
  MediaStream? get localStream => _localStream;

  // â”€â”€ Init â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> initialize({bool enableVideo = false}) async {
    await localRenderer.initialize();
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': {'echoCancellation': true, 'noiseSuppression': true, 'autoGainControl': true},
      'video': enableVideo
        ? {'facingMode': 'user', 'width': {'ideal': 640}, 'height': {'ideal': 480}}
        : false,
    });
    localRenderer.srcObject = _localStream;
    _audioEnabled = true;
    _videoEnabled = enableVideo;
    debugPrint('[WebRTC] initialized â€” video=$enableVideo');
  }

  // â”€â”€ Peer connection â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<RTCPeerConnection> _createPc(String remoteUid) async {
    final pc = await createPeerConnection(AppConstants.iceServers);
    _localStream?.getTracks().forEach((t) => pc.addTrack(t, _localStream!));

    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteStreams[remoteUid] = event.streams[0];
        onRemoteStreamAdded?.call(remoteUid, event.streams[0]);
        _initRemoteRenderer(remoteUid, event.streams[0]);
      }
    };

    pc.onIceCandidate = (c) => _sendIce(remoteUid, c);

    pc.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        _handleDisconnect(remoteUid);
      }
    };

    _peers[remoteUid] = pc;
    return pc;
  }

  Future<void> _initRemoteRenderer(String uid, MediaStream stream) async {
    if (!remoteRenderers.containsKey(uid)) {
      remoteRenderers[uid] = RTCVideoRenderer();
      await remoteRenderers[uid]!.initialize();
    }
    remoteRenderers[uid]!.srcObject = stream;
  }

  // â”€â”€ Signaling via Firestore â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> callPeer({
    required String liveId, required String localUid, required String remoteUid,
  }) async {
    try {
      final pc = await _createPc(remoteUid);
      final offer = await pc.createOffer({'offerToReceiveAudio': true, 'offerToReceiveVideo': _videoEnabled});
      await pc.setLocalDescription(offer);

      final connRef = FirebaseFirestore.instance
        .collection(AppConstants.signalingCollection).doc(liveId)
        .collection('connections').doc('${localUid}_$remoteUid');

      await connRef.set({'offer': {'type': offer.type, 'sdp': offer.sdp},
        'caller': localUid, 'callee': remoteUid,
        'timestamp': FieldValue.serverTimestamp()});

      connRef.snapshots().listen((snap) async {
        if (!snap.exists) return;
        final data = snap.data()!;
        if (data['answer'] != null &&
            pc.signalingState == RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
          await pc.setRemoteDescription(
            RTCSessionDescription(data['answer']['sdp'], data['answer']['type']));
        }
      });

      _listenIce(liveId, localUid, remoteUid, pc);
    } catch (e) { debugPrint('[WebRTC] callPeer error: $e'); }
  }

  Future<void> answerCall({
    required String liveId, required String localUid,
    required String callerUid, required Map<String, dynamic> offerData,
  }) async {
    try {
      final pc = await _createPc(callerUid);
      await pc.setRemoteDescription(RTCSessionDescription(offerData['sdp'], offerData['type']));
      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);

      await FirebaseFirestore.instance
        .collection(AppConstants.signalingCollection).doc(liveId)
        .collection('connections').doc('${callerUid}_$localUid')
        .update({'answer': {'type': answer.type, 'sdp': answer.sdp}});

      _listenIce(liveId, localUid, callerUid, pc);
    } catch (e) { debugPrint('[WebRTC] answerCall error: $e'); }
  }

  Future<void> _sendIce(String remoteUid, RTCIceCandidate c) async {
    // Store ICE candidate in Firestore for remote peer to collect
    debugPrint('[WebRTC] ICE for $remoteUid: ${c.candidate?.substring(0, 30)}...');
  }

  void _listenIce(String liveId, String localUid, String remoteUid, RTCPeerConnection pc) {
    FirebaseFirestore.instance
      .collection(AppConstants.signalingCollection).doc(liveId)
      .collection('ice_candidates').doc(remoteUid).collection(localUid)
      .snapshots().listen((snap) {
        for (final ch in snap.docChanges) {
          if (ch.type == DocumentChangeType.added) {
            final d = ch.doc.data()!;
            pc.addCandidate(RTCIceCandidate(d['candidate'], d['sdpMid'], d['sdpMLineIndex']));
          }
        }
      });
  }

  void _handleDisconnect(String uid) {
    _peers.remove(uid);
    _remoteStreams.remove(uid);
    remoteRenderers[uid]?.dispose();
    remoteRenderers.remove(uid);
    onRemoteStreamRemoved?.call(uid);
  }

  // â”€â”€ Media controls â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void toggleAudio() {
    _audioEnabled = !_audioEnabled;
    _localStream?.getAudioTracks().forEach((t) => t.enabled = _audioEnabled);
  }

  void toggleVideo() {
    _videoEnabled = !_videoEnabled;
    _localStream?.getVideoTracks().forEach((t) => t.enabled = _videoEnabled);
  }

  void forceMute() {
    _audioEnabled = false;
    _localStream?.getAudioTracks().forEach((t) => t.enabled = false);
  }

  Future<void> switchCamera() async {
    final tracks = _localStream?.getVideoTracks() ?? [];
    if (tracks.isNotEmpty && _videoEnabled) await Helper.switchCamera(tracks[0]);
  }

  // â”€â”€ Cleanup â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> dispose() async {
    _localStream?.getTracks().forEach((t) => t.stop());
    await _localStream?.dispose();
    for (final pc in _peers.values) await pc.close();
    _peers.clear();
    await localRenderer.dispose();
    for (final r in remoteRenderers.values) await r.dispose();
    remoteRenderers.clear();
    debugPrint('[WebRTC] disposed');
  }
}
