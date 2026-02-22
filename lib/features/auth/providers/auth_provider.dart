import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for the authentication / onboarding flow.
class AuthState {
  final bool isAuthenticated;
  final bool isOnboardingComplete;
  final DateTime? birthDate;
  final String? gender;
  final bool notificationEnabled;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isOnboardingComplete = false,
    this.birthDate,
    this.gender,
    this.notificationEnabled = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isOnboardingComplete,
    DateTime? birthDate,
    String? gender,
    bool? notificationEnabled,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isOnboardingComplete:
          isOnboardingComplete ?? this.isOnboardingComplete,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void setBirthDate(DateTime date) {
    state = state.copyWith(birthDate: date);
  }

  void setGender(String? gender) {
    state = state.copyWith(gender: gender);
  }

  void setNotificationEnabled(bool enabled) {
    state = state.copyWith(notificationEnabled: enabled);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: Save to local storage and Firebase
      await Future.delayed(const Duration(milliseconds: 300));
      state = state.copyWith(
        isOnboardingComplete: true,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Implement Google Sign-In
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Implement Apple Sign-In
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    state = const AuthState();
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
