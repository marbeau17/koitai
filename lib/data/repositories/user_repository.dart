import 'package:cloud_firestore/cloud_firestore.dart';

import '../datasources/local_storage_datasource.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;
  final LocalStorageDatasource _localStorage;

  UserRepository({
    FirebaseFirestore? firestore,
    required LocalStorageDatasource localStorage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _localStorage = localStorage;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  Future<UserModel?> getUser(String uid) async {
    // Try local cache first
    final cached = _localStorage.getUserProfile(uid);
    if (cached != null) return cached;

    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;

    final user = UserModel.fromFirestore(doc);
    await _localStorage.saveUserProfile(user);
    return user;
  }

  Future<UserModel> createUser(UserModel user) async {
    await _usersRef.doc(user.uid).set(user.toFirestore());
    await _localStorage.saveUserProfile(user);
    return user;
  }

  Future<UserModel> updateUser(UserModel user) async {
    final updated = user.copyWith(updatedAt: DateTime.now());
    await _usersRef.doc(updated.uid).update(updated.toFirestore());
    await _localStorage.saveUserProfile(updated);
    return updated;
  }

  Future<void> updateFcmToken(String uid, String token) async {
    await _usersRef.doc(uid).update({
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update local cache if present
    final cached = _localStorage.getUserProfile(uid);
    if (cached != null) {
      await _localStorage.saveUserProfile(
        cached.copyWith(fcmToken: token, updatedAt: DateTime.now()),
      );
    }
  }
}
