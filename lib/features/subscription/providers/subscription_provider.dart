import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/constants/app_config.dart';
import '../../../data/models/subscription_status.dart';

enum SubscriptionPlan { monthly, yearly }

/// State for the subscription / paywall screen.
class SubscriptionState {
  final SubscriptionPlan selectedPlan;
  final bool isPurchasing;
  final bool isRestoring;
  final bool isInitialized;
  final SubscriptionStatus subscriptionStatus;
  final String? error;

  const SubscriptionState({
    this.selectedPlan = SubscriptionPlan.yearly,
    this.isPurchasing = false,
    this.isRestoring = false,
    this.isInitialized = false,
    this.subscriptionStatus = const SubscriptionStatus(),
    this.error,
  });

  SubscriptionState copyWith({
    SubscriptionPlan? selectedPlan,
    bool? isPurchasing,
    bool? isRestoring,
    bool? isInitialized,
    SubscriptionStatus? subscriptionStatus,
    String? error,
  }) {
    return SubscriptionState(
      selectedPlan: selectedPlan ?? this.selectedPlan,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      isRestoring: isRestoring ?? this.isRestoring,
      isInitialized: isInitialized ?? this.isInitialized,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      error: error,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier() : super(const SubscriptionState());

  bool _revenueCatConfigured = false;

  /// Initialize RevenueCat SDK. Call once at app startup.
  Future<void> init() async {
    if (state.isInitialized) return;

    try {
      final apiKey = _getApiKey();
      if (apiKey.isEmpty || apiKey.contains('placeholder')) {
        // RevenueCat not configured — treat as free plan gracefully.
        debugPrint(
          'RevenueCat: API key not configured. Running in free-plan mode.',
        );
        state = state.copyWith(
          isInitialized: true,
          subscriptionStatus: const SubscriptionStatus(plan: 'free'),
        );
        return;
      }

      final configuration = PurchasesConfiguration(apiKey);
      await Purchases.configure(configuration);
      _revenueCatConfigured = true;

      // Listen to customer info updates (e.g. subscription renewals/expirations).
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

      // Fetch initial entitlements.
      await checkSubscriptionStatus();

      state = state.copyWith(isInitialized: true);
    } catch (e) {
      debugPrint('RevenueCat init error: $e');
      state = state.copyWith(
        isInitialized: true,
        subscriptionStatus: const SubscriptionStatus(plan: 'free'),
        error: null, // Don't surface init errors to user
      );
    }
  }

  /// Returns the platform-appropriate RevenueCat API key.
  String _getApiKey() {
    if (kIsWeb) return '';
    try {
      if (Platform.isAndroid) return AppConfig.revenueCatApiKeyAndroid;
      if (Platform.isIOS) return AppConfig.revenueCatApiKeyiOS;
    } catch (_) {
      // Platform detection may fail in tests.
    }
    return '';
  }

  /// Callback for RevenueCat purchaseUpdated / customerInfo stream.
  void _onCustomerInfoUpdated(CustomerInfo customerInfo) {
    _updateStatusFromCustomerInfo(customerInfo);
  }

  /// Query RevenueCat for the current entitlement status.
  Future<void> checkSubscriptionStatus() async {
    if (!_revenueCatConfigured) {
      state = state.copyWith(
        subscriptionStatus: const SubscriptionStatus(plan: 'free'),
      );
      return;
    }

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _updateStatusFromCustomerInfo(customerInfo);
    } catch (e) {
      debugPrint('RevenueCat checkSubscriptionStatus error: $e');
      // Keep whatever status we had before; don't overwrite on transient error.
    }
  }

  /// Derive [SubscriptionStatus] from a [CustomerInfo] object.
  void _updateStatusFromCustomerInfo(CustomerInfo customerInfo) {
    final entitlement =
        customerInfo.entitlements.all[AppConfig.revenueCatEntitlementId];

    if (entitlement != null && entitlement.isActive) {
      state = state.copyWith(
        subscriptionStatus: SubscriptionStatus(
          plan: 'premium',
          expiresAt: entitlement.expirationDate != null
              ? DateTime.tryParse(entitlement.expirationDate!)
              : null,
          store: entitlement.store.name,
          revenuecatId: customerInfo.originalAppUserId,
        ),
      );
    } else {
      state = state.copyWith(
        subscriptionStatus: const SubscriptionStatus(plan: 'free'),
      );
    }
  }

  void selectPlan(SubscriptionPlan plan) {
    state = state.copyWith(selectedPlan: plan);
  }

  /// Purchase a subscription package via RevenueCat.
  ///
  /// [packageId] — pass `'monthly'` or `'yearly'` to select the package from
  /// the current offering. If omitted, the currently selected plan is used.
  Future<bool> purchaseSubscription({String? packageId}) async {
    if (!_revenueCatConfigured) {
      state = state.copyWith(
        error: 'ストアが設定されていません。', // "Store not configured."
      );
      return false;
    }

    state = state.copyWith(isPurchasing: true, error: null);
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;
      if (offering == null) {
        throw Exception('利用可能なプランがありません。'); // "No plans available."
      }

      final resolvedId = packageId ??
          (state.selectedPlan == SubscriptionPlan.monthly
              ? 'monthly'
              : 'yearly');

      Package? package;
      if (resolvedId == 'monthly') {
        package = offering.monthly;
      } else if (resolvedId == 'yearly') {
        package = offering.annual;
      } else {
        // Try to find by identifier.
        package = offering.availablePackages
            .cast<Package?>()
            .firstWhere(
              (p) => p?.identifier == resolvedId,
              orElse: () => null,
            );
      }

      if (package == null) {
        throw Exception(
          'パッケージが見つかりません。', // "Package not found."
        );
      }

      await Purchases.purchasePackage(package);

      // After a successful purchase the listener will fire, but we also
      // explicitly refresh to update the UI immediately.
      await checkSubscriptionStatus();

      state = state.copyWith(isPurchasing: false);
      return true;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        // User cancelled — not a real error.
        state = state.copyWith(isPurchasing: false);
        return false;
      }
      state = state.copyWith(
        isPurchasing: false,
        error: '購入に失敗しました: ${e.message}', // "Purchase failed: …"
      );
      return false;
    } catch (e) {
      state = state.copyWith(isPurchasing: false, error: e.toString());
      return false;
    }
  }

  /// Legacy purchase method — delegates to [purchaseSubscription].
  Future<bool> purchase() => purchaseSubscription();

  /// Restore previous purchases via RevenueCat.
  Future<bool> restorePurchases() async {
    if (!_revenueCatConfigured) {
      state = state.copyWith(
        error: 'ストアが設定されていません。',
      );
      return false;
    }

    state = state.copyWith(isRestoring: true, error: null);
    try {
      final customerInfo = await Purchases.restorePurchases();
      _updateStatusFromCustomerInfo(customerInfo);
      state = state.copyWith(isRestoring: false);
      return state.subscriptionStatus.isPremium;
    } on PlatformException catch (e) {
      state = state.copyWith(
        isRestoring: false,
        error: '復元に失敗しました: ${e.message}', // "Restore failed: …"
      );
      return false;
    } catch (e) {
      state = state.copyWith(isRestoring: false, error: e.toString());
      return false;
    }
  }

  /// Legacy restore method — delegates to [restorePurchases].
  Future<bool> restore() => restorePurchases();
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>(
  (ref) => SubscriptionNotifier(),
);
