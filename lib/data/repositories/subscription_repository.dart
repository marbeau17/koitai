import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../models/subscription_status.dart';

class SubscriptionRepository {
  final FirebaseFirestore _firestore;

  SubscriptionRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  /// Get subscription status from Firestore
  Future<SubscriptionStatus> getSubscriptionStatus(String uid) async {
    final doc = await _userDoc(uid).get();
    final data = doc.data();
    if (data == null || data['subscription'] == null) {
      return const SubscriptionStatus();
    }
    return SubscriptionStatus.fromMap(
        data['subscription'] as Map<String, dynamic>);
  }

  /// Check if user has active premium
  Future<bool> isPremium(String uid) async {
    final status = await getSubscriptionStatus(uid);
    return status.isPremium;
  }

  /// Check RevenueCat entitlements and sync with Firestore
  Future<SubscriptionStatus> syncWithRevenueCat(String uid) async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all['premium'];

      if (entitlement != null && entitlement.isActive) {
        final status = SubscriptionStatus(
          plan: 'premium',
          expiresAt: entitlement.expirationDate != null
              ? DateTime.parse(entitlement.expirationDate!)
              : null,
          store: entitlement.store.name,
          revenuecatId: customerInfo.originalAppUserId,
        );

        await _userDoc(uid).update({
          'subscription': status.toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return status;
      } else {
        const status = SubscriptionStatus(plan: 'free');
        await _userDoc(uid).update({
          'subscription': status.toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return status;
      }
    } catch (_) {
      // If RevenueCat fails, fall back to Firestore data
      return getSubscriptionStatus(uid);
    }
  }

  /// Purchase premium subscription
  Future<SubscriptionStatus> purchasePremium(String uid) async {
    final offerings = await Purchases.getOfferings();
    final offering = offerings.current;
    if (offering == null) {
      throw Exception('No offerings available');
    }

    final package = offering.monthly;
    if (package == null) {
      throw Exception('No monthly package available');
    }

    await Purchases.purchasePackage(package);
    return syncWithRevenueCat(uid);
  }

  /// Restore purchases
  Future<SubscriptionStatus> restorePurchases(String uid) async {
    await Purchases.restorePurchases();
    return syncWithRevenueCat(uid);
  }
}
