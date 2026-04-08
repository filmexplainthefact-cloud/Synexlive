class AppConstants {
  static const String appName              = 'Synex Live';
  static const String usersCollection      = 'users';
  static const String livesCollection      = 'lives';
  static const String chatsCollection      = 'live_chats';
  static const String requestsCollection   = 'live_requests';
  static const String notificationsCol     = 'notifications';
  static const String signalingCollection  = 'signaling';

  static const int maxSpeakers    = 6;
  static const int maxChatHistory = 100;

  static const Map<String, dynamic> iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ]
  };

  static const String statusPending  = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusRejected = 'rejected';

  static const String roleHost     = 'host';
  static const String roleSpeaker  = 'speaker';
  static const String roleAudience = 'audience';

  static const String errorGeneric    = 'Something went wrong. Please try again.';
  static const String errorNetwork    = 'Network error. Check your connection.';
  static const String errorBlocked    = 'You have been blocked from this live.';
  static const String errorMaxSpeakers = 'Maximum speakers limit (6) reached.';
}
