import 'package:cloud_firestore/cloud_firestore.dart';

import 'subscription_status.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final DateTime birthDate;
  final String gender;
  final String zodiacSign;
  final int lifePathNumber;
  final String? fcmToken;
  final bool notificationEnabled;
  final String notificationTime;
  final SubscriptionStatus subscription;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.birthDate,
    required this.gender,
    required this.zodiacSign,
    required this.lifePathNumber,
    this.fcmToken,
    this.notificationEnabled = false,
    this.notificationTime = '08:00',
    this.subscription = const SubscriptionStatus(),
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      gender: data['gender'] as String? ?? 'other',
      zodiacSign: data['zodiacSign'] as String? ?? '',
      lifePathNumber: data['lifePathNumber'] as int? ?? 0,
      fcmToken: data['fcmToken'] as String?,
      notificationEnabled: data['notificationEnabled'] as bool? ?? false,
      notificationTime: data['notificationTime'] as String? ?? '08:00',
      subscription: data['subscription'] != null
          ? SubscriptionStatus.fromMap(
              data['subscription'] as Map<String, dynamic>)
          : const SubscriptionStatus(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'birthDate': Timestamp.fromDate(birthDate),
      'gender': gender,
      'zodiacSign': zodiacSign,
      'lifePathNumber': lifePathNumber,
      'fcmToken': fcmToken,
      'notificationEnabled': notificationEnabled,
      'notificationTime': notificationTime,
      'subscription': subscription.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    DateTime? birthDate,
    String? gender,
    String? zodiacSign,
    int? lifePathNumber,
    String? fcmToken,
    bool? notificationEnabled,
    String? notificationTime,
    SubscriptionStatus? subscription,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      lifePathNumber: lifePathNumber ?? this.lifePathNumber,
      fcmToken: fcmToken ?? this.fcmToken,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      subscription: subscription ?? this.subscription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
