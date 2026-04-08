import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';

class UserService {
  static final _db = FirebaseFirestore.instance;

  static Future<UserModel?> getById(String uid) async {
    try {
      final doc = await _db.collection(AppConstants.usersCollection).doc(uid).get();
      return doc.exists ? UserModel.fromFirestore(doc) : null;
    } catch (_) { return null; }
  }

  static Stream<UserModel?> streamById(String uid) =>
    _db.collection(AppConstants.usersCollection).doc(uid).snapshots()
      .map((d) => d.exists ? UserModel.fromFirestore(d) : null);

  static Future<List<UserModel>> getByIds(List<String> uids) async {
    if (uids.isEmpty) return [];
    final futures = uids.map(getById);
    final results = await Future.wait(futures);
    return results.whereType<UserModel>().toList();
  }
}
