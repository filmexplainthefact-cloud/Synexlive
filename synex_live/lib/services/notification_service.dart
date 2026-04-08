import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_constants.dart';

@pragma('vm:entry-point')
Future<void> _bgHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background: ${message.messageId}');
}

class NotificationService {
  static final _fcm = FirebaseMessaging.instance;
  static final _db  = FirebaseFirestore.instance;

  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_bgHandler);
    await _fcm.requestPermission(alert: true, badge: true, sound: true);
    FirebaseMessaging.onMessage.listen((msg) {
      debugPrint('[FCM] Foreground: ${msg.notification?.title}');
    });
    _fcm.onTokenRefresh.listen((t) => debugPrint('[FCM] Token refresh: $t'));
  }

  static Future<String?> getToken() => _fcm.getToken();

  static Future<void> sendLiveStartNotification({
    required String liveId, required String hostName, required String title,
  }) async {
    try {
      await _db.collection(AppConstants.notificationsCol).add({
        'type': 'live_start', 'liveId': liveId, 'hostName': hostName,
        'title': title, 'message': '$hostName is now live: $title',
        'timestamp': FieldValue.serverTimestamp(), 'sent': false,
      });
    } catch (e) { debugPrint('[FCM] sendLiveStart error: $e'); }
  }

  static Future<void> sendRequestAcceptedNotification({
    required String userId, required String liveId,
  }) async {
    try {
      final doc = await _db.collection(AppConstants.usersCollection).doc(userId).get();
      if (!doc.exists) return;
      final token = doc.data()?['fcmToken'] as String?;
      await _db.collection(AppConstants.notificationsCol).add({
        'type': 'request_accepted', 'targetUserId': userId,
        'targetFcmToken': token, 'liveId': liveId,
        'message': 'Your raise hand request was accepted! You can now speak.',
        'timestamp': FieldValue.serverTimestamp(), 'sent': false,
      });
    } catch (e) { debugPrint('[FCM] sendRequestAccepted error: $e'); }
  }
}
