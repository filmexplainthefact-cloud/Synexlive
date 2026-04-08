import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/live_model.dart';
import '../models/chat_model.dart';
import '../models/live_request_model.dart';
import '../utils/app_constants.dart';
import 'notification_service.dart';

class LiveService {
  static final _db = FirebaseFirestore.instance;

  // â”€â”€ Start / End Live â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static Future<String?> startLive({
    required String hostId, required String hostName,
    String? hostPhotoUrl, required String title, String? description,
  }) async {
    try {
      final ref = _db.collection(AppConstants.livesCollection).doc();
      final live = LiveModel(
        id: ref.id, hostId: hostId, hostName: hostName,
        hostPhotoUrl: hostPhotoUrl, title: title, description: description,
        startedAt: DateTime.now(), isLive: true,
      );
      await ref.set(live.toFirestore());
      await NotificationService.sendLiveStartNotification(
        liveId: ref.id, hostName: hostName, title: title);
      return ref.id;
    } catch (e) { debugPrint('startLive error: $e'); return null; }
  }

  static Future<void> endLive(String liveId) async {
    await _db.collection(AppConstants.livesCollection).doc(liveId).update({
      'isLive': false, 'endedAt': FieldValue.serverTimestamp(),
    });
  }

  // â”€â”€ Streams â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static Stream<List<LiveModel>> getLiveSessions() =>
    _db.collection(AppConstants.livesCollection)
      .where('isLive', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
        final list = snapshot.docs.map((doc) => LiveModel.fromFirestore(doc)).toList();
        list.sort((a, b) => b.startedAt.compareTo(a.startedAt));
        return list;
      });

  static Stream<LiveModel?> getLiveSession(String liveId) =>
    _db.collection(AppConstants.livesCollection).doc(liveId).snapshots()
      .map((d) => d.exists ? LiveModel.fromFirestore(d) : null);

  // â”€â”€ Viewer count â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static Future<void> incrementViewer(String liveId) =>
    _db.collection(AppConstants.livesCollection).doc(liveId)
      .update({'viewerCount': FieldValue.increment(1)});

  static Future<void> decrementViewer(String liveId) =>
    _db.collection(AppConstants.livesCollection).doc(liveId)
      .update({'viewerCount': FieldValue.increment(-1)});

  // â”€â”€ Speaker management â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static Future<bool> addSpeaker(String liveId, String uid) async {
    try {
      final doc = await _db.collection(AppConstants.livesCollection).doc(liveId).get();
      final live = LiveModel.fromFirestore(doc);
      if (live.speakers.length >= AppConstants.maxSpeakers) return false;
      await _db.collection(AppConstants.livesCollection).doc(liveId)
        .update({'speakers': FieldValue.arrayUnion([uid])});
      return true;
    } catch (_) { return false; }
  }

  static Future<void> removeSpeaker(String liveId, String uid) =>
    _db.collection(AppConstants.livesCollection).doc(liveId).update({
      'speakers': FieldValue.arrayRemove([uid]),
      'mutedSpeakers': FieldValue.arrayRemove([uid]),
    });

  static Future<void> muteSpeaker(String liveId, String uid) =>
    _db.collection(AppConstants.livesCollection).doc(liveId)
      .update({'mutedSpeakers': FieldValue.arrayUnion([uid])});

  static Future<void> unmuteSpeaker(String liveId, String uid) =>
    _db.collection(AppConstants.livesCollection).doc(liveId)
      .update({'mutedSpeakers': FieldValue.arrayRemove([uid])});

  // â”€â”€ Block â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static Future<void> blockUser(String liveId, String uid) =>
    _db.collection(AppConstants.livesCollection).doc(liveId).update({
      'blockedUsers': FieldValue.arrayUnion([uid]),
      'speakers': FieldValue.arrayRemove([uid]),
    });

  static Future<bool> isBlocked(String liveId, String uid) async {
    final doc = await _db.collection(AppConstants.livesCollection).doc(liveId).get();
    if (!doc.exists) return false;
    return LiveModel.fromFirestore(doc).blockedUsers.contains(uid);
  }

  // â”€â”€ Chat â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static Future<void> sendChat({
    required String liveId, required String userId,
    required String userName, String? userPhotoUrl,
    required String message, bool isHost = false,
  }) async {
    final ref = _db.collection(AppConstants.chatsCollection)
      .doc(liveId).collection('messages').doc();
    final chat = ChatModel(
      id: ref.id, liveId: liveId, userId: userId, userName: userName,
      userPhotoUrl: userPhotoUrl, message: message.trim(),
      timestamp: DateTime.now(), isHost: isHost,
    );
    await ref.set(chat.toFirestore());
  }

  static Stream<List<ChatModel>> getChatStream(String liveId) =>
    _db.collection(AppConstants.chatsCollection).doc(liveId)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .limitToLast(AppConstants.maxChatHistory)
      .snapshots()
      .map((s) => s.docs.map(ChatModel.fromFirestore).toList());

  // â”€â”€ Raise Hand â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static Future<void> raiseHand({
    required String liveId, required String userId,
    required String userName, String? userPhotoUrl,
  }) async {
    await _db.collection(AppConstants.requestsCollection).doc(liveId).set({
      userId: {
        'name': userName, 'photoUrl': userPhotoUrl,
        'status': AppConstants.statusPending,
        'requestedAt': FieldValue.serverTimestamp(),
      }
    }, SetOptions(merge: true));
  }

  static Future<void> acceptRequest({required String liveId, required String userId}) async {
    await _db.collection(AppConstants.requestsCollection).doc(liveId)
      .update({'$userId.status': AppConstants.statusAccepted});
    await addSpeaker(liveId, userId);
    await NotificationService.sendRequestAcceptedNotification(userId: userId, liveId: liveId);
  }

  static Future<void> rejectRequest({required String liveId, required String userId}) =>
    _db.collection(AppConstants.requestsCollection).doc(liveId)
      .update({'$userId.status': AppConstants.statusRejected});

  static Stream<List<LiveRequestModel>> getRequestsStream(String liveId) =>
    _db.collection(AppConstants.requestsCollection).doc(liveId).snapshots().map((doc) {
      if (!doc.exists) return [];
      final data = doc.data() as Map<String, dynamic>;
      return data.entries
        .where((e) => e.value is Map && e.value['status'] == AppConstants.statusPending)
        .map((e) => LiveRequestModel.fromMap(e.key, e.value as Map<String, dynamic>))
        .toList();
    });

  static Stream<String?> getUserRequestStatus(String liveId, String userId) =>
    _db.collection(AppConstants.requestsCollection).doc(liveId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      return data[userId]?['status'] as String?;
    });

  static Future<void> clearRequest(String liveId, String userId) async {
    try {
      await _db.collection(AppConstants.requestsCollection).doc(liveId)
        .update({userId: FieldValue.delete()});
    } catch (_) {}
  }
}
