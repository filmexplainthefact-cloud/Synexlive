import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid, name, email;
  final String? photoUrl, bio, fcmToken;
  final int followersCount, followingCount;
  final DateTime createdAt;

  const UserModel({
    required this.uid, required this.name, required this.email,
    this.photoUrl, this.bio, this.fcmToken,
    this.followersCount = 0, this.followingCount = 0,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id, name: d['name'] ?? '', email: d['email'] ?? '',
      photoUrl: d['photoUrl'], bio: d['bio'], fcmToken: d['fcmToken'],
      followersCount: d['followersCount'] ?? 0,
      followingCount: d['followingCount'] ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name, 'email': email, 'photoUrl': photoUrl,
    'bio': bio, 'fcmToken': fcmToken,
    'followersCount': followersCount, 'followingCount': followingCount,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  UserModel copyWith({String? name, String? bio, String? photoUrl, String? fcmToken}) =>
    UserModel(
      uid: uid, name: name ?? this.name, email: email,
      photoUrl: photoUrl ?? this.photoUrl, bio: bio ?? this.bio,
      fcmToken: fcmToken ?? this.fcmToken,
      followersCount: followersCount, followingCount: followingCount,
      createdAt: createdAt,
    );
}
