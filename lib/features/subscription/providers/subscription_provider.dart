import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SubscriptionPlan { monthly, yearly }

/// State for the subscription / paywall screen.
class SubscriptionState {
  final SubscriptionPlan selectedPlan;
  final bool isPurchasing;
  final bool isRestoring;
  final String? error;

  const SubscriptionState({
    this.selectedPlan = SubscriptionPlan.yearly,
    this.isPurchasing = false,
    this.isRestoring = false,
    this.error,
  });

  SubscriptionState copyWith({
    SubscriptionPlan? selectedPlan,
    bool? isPurchasing,
    bool? isRestoring,
    String? error,
  }) {
    return SubscriptionState(
      selectedPlan: selectedPlan ?? this.selectedPlan,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      isRestoring: isRestoring ?? this.isRestoring,
      error: error,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier() : super(const SubscriptionState());

  void selectPlan(SubscriptionPlan plan) {
    state = state.copyWith(selectedPlan: plan);
  }

  Future<bool> purchase() async {
    state = state.copyWith(isPurchasing: true, error: null);
    try {
      // TODO: Integrate RevenueCat purchase flow
      await Future.delayed(const Duration(milliseconds: 1000));
      state = state.copyWith(isPurchasing: false);
      return true;
    } catch (e) {
      state = state.copyWith(isPurchasing: false, error: e.toString());
      return false;
    }
  }

  Future<bool> restore() async {
    state = state.copyWith(isRestoring: true, error: null);
    try {
      // TODO: Integrate RevenueCat restore
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(isRestoring: false);
      return true;
    } catch (e) {
      state = state.copyWith(isRestoring: false, error: e.toString());
      return false;
    }
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>(
  (ref) => SubscriptionNotifier(),
);
