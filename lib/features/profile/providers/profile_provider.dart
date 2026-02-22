import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for the profile / my-page.
class ProfileState {
  final String displayName;
  final DateTime birthDate;
  final int lifePathNumber;
  final String subscriptionPlan;
  final bool isDarkMode;
  final bool isLoading;

  const ProfileState({
    this.displayName = '',
    required this.birthDate,
    this.lifePathNumber = 0,
    this.subscriptionPlan = 'free',
    this.isDarkMode = true,
    this.isLoading = false,
  });

  bool get isPremium => subscriptionPlan == 'premium';

  ProfileState copyWith({
    String? displayName,
    DateTime? birthDate,
    int? lifePathNumber,
    String? subscriptionPlan,
    bool? isDarkMode,
    bool? isLoading,
  }) {
    return ProfileState(
      displayName: displayName ?? this.displayName,
      birthDate: birthDate ?? this.birthDate,
      lifePathNumber: lifePathNumber ?? this.lifePathNumber,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      isDarkMode: isDarkMode ?? this.isDarkMode,
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
      isLoading: false,
    );
  }

  void updateDisplayName(String name) {
    state = state.copyWith(displayName: name);
  }

  void toggleTheme() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(),
);
