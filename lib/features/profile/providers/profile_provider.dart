import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/notification_service.dart';

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
  ProfileNotifier()
      : super(ProfileState(
          birthDate: DateTime(2000, 1, 1),
        )) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    state = state.copyWith(isLoading: true);
    // TODO: Load from Hive / Firebase
    await Future.delayed(const Duration(milliseconds: 200));
    state = state.copyWith(
      displayName: '\u30E6\u30FC\u30B6\u30FC',
      birthDate: DateTime(1998, 3, 15),
      lifePathNumber: 9,
      subscriptionPlan: 'free',
      isDarkMode: true,
      notificationEnabled: false,
      notificationTime: const TimeOfDay(hour: 8, minute: 0),
      isLoading: false,
    );
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
  (ref) => ProfileNotifier(),
);
