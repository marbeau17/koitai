import 'package:hive_flutter/hive_flutter.dart';

import '../models/fortune_result_model.dart';
import '../models/subscription_status.dart';
import '../models/user_model.dart';

class LocalStorageDatasource {
  static const String _fortuneBoxName = 'fortune_cache';
  static const String _userBoxName = 'user_profile_cache';

  Box<Map>? _fortuneBox;
  Box<Map>? _userBox;

  Future<void> init() async {
    _fortuneBox = await Hive.openBox<Map>(_fortuneBoxName);
    _userBox = await Hive.openBox<Map>(_userBoxName);
  }

  // -- Fortune cache --

  Future<void> saveFortune(FortuneResultModel fortune) async {
    final box = _fortuneBox;
    if (box == null) return;
    await box.put(fortune.date, fortune.toMap());
  }

  FortuneResultModel? getFortune(String date) {
    final box = _fortuneBox;
    if (box == null) return null;
    final raw = box.get(date);
    if (raw == null) return null;
    return FortuneResultModel.fromMap(Map<String, dynamic>.from(raw));
  }

  Future<List<FortuneResultModel>> getMonthlyFortunes(
      int year, int month) async {
    final box = _fortuneBox;
    if (box == null) return [];
    final prefix =
        '$year-${month.toString().padLeft(2, '0')}';
    final results = <FortuneResultModel>[];
    for (final key in box.keys) {
      if (key.toString().startsWith(prefix)) {
        final raw = box.get(key);
        if (raw != null) {
          results.add(
              FortuneResultModel.fromMap(Map<String, dynamic>.from(raw)));
        }
      }
    }
    return results;
  }

  // -- User profile cache --

  Future<void> saveUserProfile(UserModel user) async {
    final box = _userBox;
    if (box == null) return;
    await box.put(user.uid, _userToCache(user));
  }

  UserModel? getUserProfile(String uid) {
    final box = _userBox;
    if (box == null) return null;
    final raw = box.get(uid);
    if (raw == null) return null;
    return _userFromCache(uid, Map<String, dynamic>.from(raw));
  }

  // -- Clear --

  Future<void> clearCache() async {
    await _fortuneBox?.clear();
    await _userBox?.clear();
  }

  Future<void> clearFortuneCache() async {
    await _fortuneBox?.clear();
  }

  // -- Private helpers --

  Map<String, dynamic> _userToCache(UserModel user) {
    return {
      'displayName': user.displayName,
      'email': user.email,
      'birthDate': user.birthDate.toIso8601String(),
      'gender': user.gender,
      'zodiacSign': user.zodiacSign,
      'lifePathNumber': user.lifePathNumber,
      'fcmToken': user.fcmToken,
      'notificationEnabled': user.notificationEnabled,
      'notificationTime': user.notificationTime,
      'subscriptionPlan': user.subscription.plan,
      'subscriptionExpiresAt': user.subscription.expiresAt?.toIso8601String(),
      'createdAt': user.createdAt.toIso8601String(),
      'updatedAt': user.updatedAt.toIso8601String(),
    };
  }

  UserModel _userFromCache(String uid, Map<String, dynamic> map) {
    final expiresAtRaw = map['subscriptionExpiresAt'] as String?;
    return UserModel(
      uid: uid,
      displayName: map['displayName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      birthDate: DateTime.parse(map['birthDate'] as String),
      gender: map['gender'] as String? ?? 'other',
      zodiacSign: map['zodiacSign'] as String? ?? '',
      lifePathNumber: map['lifePathNumber'] as int? ?? 0,
      fcmToken: map['fcmToken'] as String?,
      notificationEnabled: map['notificationEnabled'] as bool? ?? false,
      notificationTime: map['notificationTime'] as String? ?? '08:00',
      subscription: SubscriptionStatus(
        plan: map['subscriptionPlan'] as String? ?? 'free',
        expiresAt:
            expiresAtRaw != null ? DateTime.parse(expiresAtRaw) : null,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
