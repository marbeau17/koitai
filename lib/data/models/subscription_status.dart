import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionStatus {
  final String plan;
  final DateTime? expiresAt;
  final String? store;
  final String? revenuecatId;

  const SubscriptionStatus({
    this.plan = 'free',
    this.expiresAt,
    this.store,
    this.revenuecatId,
  });

  bool get isPremium => plan == 'premium' && !isExpired;

  bool get isExpired {
    if (expiresAt == null) return true;
    return DateTime.now().isAfter(expiresAt!);
  }

  factory SubscriptionStatus.fromMap(Map<String, dynamic> map) {
    return SubscriptionStatus(
      plan: map['plan'] as String? ?? 'free',
      expiresAt: map['expiresAt'] != null
          ? (map['expiresAt'] as Timestamp).toDate()
          : null,
      store: map['store'] as String?,
      revenuecatId: map['revenuecatId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plan': plan,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'store': store,
      'revenuecatId': revenuecatId,
    };
  }

  SubscriptionStatus copyWith({
    String? plan,
    DateTime? expiresAt,
    String? store,
    String? revenuecatId,
  }) {
    return SubscriptionStatus(
      plan: plan ?? this.plan,
      expiresAt: expiresAt ?? this.expiresAt,
      store: store ?? this.store,
      revenuecatId: revenuecatId ?? this.revenuecatId,
    );
  }
}
