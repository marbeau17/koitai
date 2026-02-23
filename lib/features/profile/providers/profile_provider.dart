import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/notification_service.dart';
import '../../../domain/services/numerology_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../subscription/providers/subscription_provider.dart';

/// State for the profile / my-page.
class ProfileState {
  final String displayName;
  final DateTime birthDate;
  final int lifePathNumber;
  final String subscriptionPlan;
  final bool isDarkMode;
  final bool notificationEnabled;
  final TimeOfDay notificationTime;
  final bool isLoading;

  const ProfileState({
    this.displayName = '',
    required this.birthDate,
    this.lifePathNumber = 0,
    this.subscriptionPlan = 'free',
    this.isDarkMode = true,
    this.notificationEnabled = false,
    this.notificationTime = const TimeOfDay(hour: 8, minute: 0),
    this.isLoading = false,
  });

  bool get isPremium => subscriptionPlan == 'premium';

  ProfileState copyWith({
    String? displayName,
    DateTime? birthDate,
    int? lifePathNumber,
    String? subscriptionPlan,
    bool? isDarkMode,
    bool? notificationEnabled,
    TimeOfDay? notificationTime,
    bool? isLoading,
  }) {
    return ProfileState(
      displayName: displayName ?? this.displayName,
      birthDate: birthDate ?? this.birthDate,
      lifePathNumber: lifePathNumber ?? this.lifePathNumber,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this._ref)
      : super(ProfileState(
          birthDate: DateTime(2000, 1, 1),
        )) {
    _loadProfile();
    _listenToAuthChanges();
  }

  final Ref _ref;

  /// Listen to auth provider changes so profile updates automatically.
  void _listenToAuthChanges() {
    _ref.listen<AuthState>(authProvider, (previous, next) {
      // Reload profile when auth state changes (e.g. birthDate updated).
      if (previous?.birthDate != next.birthDate ||
          previous?.gender != next.gender) {
        _loadProfile();
      }
    });
  }

  void _loadProfile() {
    state = state.copyWith(isLoading: true);

    // Read real data from authProvider.
    final authState = _ref.read(authProvider);
    final birthDate = authState.birthDate ?? DateTime(2000, 1, 1);

    // Calculate life path number dynamically from the real birth date.
    final lifePathNumber =
        NumerologyService.calculateLifePathNumber(birthDate);

    // Determine display name from Firebase user or fallback.
    String displayName = '\u30E6\u30FC\u30B6\u30FC'; // ユーザー (default)
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        if (firebaseUser.displayName != null &&
            firebaseUser.displayName!.isNotEmpty) {
          displayName = firebaseUser.displayName!;
        } else if (firebaseUser.email != null &&
            firebaseUser.email!.isNotEmpty) {
          displayName = firebaseUser.email!;
        }
      }
    } catch (_) {
      // Firebase may be unavailable; keep the default.
    }

    // Read subscription status.
    final subState = _ref.read(subscriptionProvider);
    final subscriptionPlan =
        subState.subscriptionStatus.isPremium ? 'premium' : 'free';

    state = state.copyWith(
      displayName: displayName,
      birthDate: birthDate,
      lifePathNumber: lifePathNumber,
      subscriptionPlan: subscriptionPlan,
      isLoading: false,
    );
  }

  /// Refresh profile data from current auth and subscription state.
  void refresh() {
    _loadProfile();
  }

  void updateDisplayName(String name) {
    state = state.copyWith(displayName: name);
  }

  void toggleTheme() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  /// Toggle notification on/off and schedule or cancel accordingly.
  Future<void> setNotificationEnabled(bool enabled) async {
    state = state.copyWith(notificationEnabled: enabled);
    final service = NotificationService();

    if (enabled) {
      final t = state.notificationTime;
      await service.scheduleDailyNotification(hour: t.hour, minute: t.minute);
    } else {
      await service.cancelAllNotifications();
    }
  }

  /// Update the scheduled notification time and reschedule if enabled.
  Future<void> setNotificationTime(TimeOfDay time) async {
    state = state.copyWith(notificationTime: time);

    if (state.notificationEnabled) {
      await NotificationService()
          .scheduleDailyNotification(hour: time.hour, minute: time.minute);
    }
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(ref),
);
