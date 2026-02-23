import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/utils/analytics_service.dart';

/// State for the authentication / onboarding flow.
class AuthState {
  final bool isAuthenticated;
  final bool isOnboardingComplete;
  final DateTime? birthDate;
  final String? gender;
  final bool notificationEnabled;
  final bool isLoading;
  final String? error;
  final bool isInitializing;

  const AuthState({
    this.isAuthenticated = false,
    this.isOnboardingComplete = false,
    this.birthDate,
    this.gender,
    this.notificationEnabled = false,
    this.isLoading = false,
    this.error,
    this.isInitializing = true,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isOnboardingComplete,
    DateTime? birthDate,
    String? gender,
    bool? notificationEnabled,
    bool? isLoading,
    String? error,
    bool? isInitializing,
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
      isInitializing: isInitializing ?? this.isInitializing,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _init();
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final AnalyticsService _analytics = AnalyticsService();
  StreamSubscription<User?>? _authSub;

  /// Initialise: restore local profile, check Firebase user, listen to
  /// auth-state changes.
  Future<void> _init() async {
    try {
      // 1. Restore persisted profile from Hive
      _restoreProfileFromHive();

      // 2. Check current Firebase user (may throw if offline / misconfigured)
      await checkAuthState();

      // 3. Listen for future auth-state changes
      _authSub = _firebaseAuth.authStateChanges().listen(
        _onAuthStateChanged,
        onError: (_) {
          // Silently ignore stream errors so the app keeps working offline.
        },
      );
    } catch (_) {
      // If Firebase is unreachable the app still works in local-only mode.
      state = state.copyWith(isInitializing: false);
    }
  }

  // ── Hive helpers ──────────────────────────────────────────────────

  Box<dynamic> get _profileBox => Hive.box<dynamic>(AppConfig.hiveBoxProfile);

  void _restoreProfileFromHive() {
    try {
      final box = _profileBox;
      final birthMillis = box.get('birthDate') as int?;
      final gender = box.get('gender') as String?;
      final onboardingDone = box.get('isOnboardingComplete') as bool? ?? false;
      final notif = box.get('notificationEnabled') as bool? ?? false;

      state = state.copyWith(
        birthDate:
            birthMillis != null
                ? DateTime.fromMillisecondsSinceEpoch(birthMillis)
                : null,
        gender: gender,
        isOnboardingComplete: onboardingDone,
        notificationEnabled: notif,
      );
    } catch (e) {
      debugPrint('AuthNotifier: failed to restore profile from Hive – $e');
    }
  }

  Future<void> _saveProfileToHive() async {
    try {
      final box = _profileBox;
      await box.put(
        'birthDate',
        state.birthDate?.millisecondsSinceEpoch,
      );
      await box.put('gender', state.gender);
      await box.put('isOnboardingComplete', state.isOnboardingComplete);
      await box.put('notificationEnabled', state.notificationEnabled);
    } catch (e) {
      debugPrint('AuthNotifier: failed to save profile to Hive – $e');
    }
  }

  // ── Auth state ────────────────────────────────────────────────────

  /// Called on app start to see if the user is already signed in.
  Future<void> checkAuthState() async {
    try {
      final user = _firebaseAuth.currentUser;
      state = state.copyWith(
        isAuthenticated: user != null,
        isInitializing: false,
      );
    } catch (e) {
      // Firebase unavailable – fall back to local-only mode.
      debugPrint('AuthNotifier: checkAuthState failed – $e');
      state = state.copyWith(isInitializing: false);
    }
  }

  void _onAuthStateChanged(User? user) {
    state = state.copyWith(isAuthenticated: user != null);
  }

  // ── Public setters (onboarding) ───────────────────────────────────

  void setBirthDate(DateTime date) {
    state = state.copyWith(birthDate: date);
  }

  void setGender(String? gender) {
    state = state.copyWith(gender: gender);
  }

  /// Public wrapper to persist the current profile state to Hive.
  ///
  /// Call this after updating birthDate, gender, or other profile fields
  /// outside of the onboarding flow (e.g. from profile edit).
  Future<void> saveProfile() async {
    await _saveProfileToHive();
  }

  void setNotificationEnabled(bool enabled) {
    state = state.copyWith(notificationEnabled: enabled);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(isLoading: true);
    try {
      state = state.copyWith(
        isOnboardingComplete: true,
        isAuthenticated: true,
        isLoading: false,
      );
      await _saveProfileToHive();

      _analytics.logCompleteOnboarding();
      if (state.birthDate != null) {
        _analytics.setUserBirthYear(state.birthDate!.year);
      }
      if (state.gender != null) {
        _analytics.setUserGender(state.gender!);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (kIsWeb) {
        // On web, use Firebase Auth popup directly (google_sign_in doesn't
        // reliably return tokens on web).
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        await _firebaseAuth.signInWithPopup(provider);
      } else {
        // On mobile, use the google_sign_in package for native UX.
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          // User cancelled the sign-in flow.
          state = state.copyWith(isLoading: false);
          return;
        }

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _firebaseAuth.signInWithCredential(credential);
      }

      _analytics.logSignIn('google');
      _analytics.setUserAuthMethod('google');

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        // User closed the popup – not an error.
        state = state.copyWith(isLoading: false);
        return;
      }
      state = state.copyWith(
        isLoading: false,
        error: _friendlyFirebaseError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Googleサインインに失敗しました。もう一度お試しください。',
      );
      debugPrint('AuthNotifier: signInWithGoogle error – $e');
    }
  }

  // ── Apple Sign-In ─────────────────────────────────────────────────

  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Generate a nonce for security.
      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      await _firebaseAuth.signInWithCredential(oauthCredential);

      _analytics.logSignIn('apple');
      _analytics.setUserAuthMethod('apple');

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        // User cancelled – not an error.
        state = state.copyWith(isLoading: false);
        return;
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Appleサインインに失敗しました。もう一度お試しください。',
      );
      debugPrint('AuthNotifier: signInWithApple error – $e');
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _friendlyFirebaseError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Appleサインインに失敗しました。もう一度お試しください。',
      );
      debugPrint('AuthNotifier: signInWithApple error – $e');
    }
  }

  // ── Sign out ──────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('AuthNotifier: signOut error – $e');
    }
    state = const AuthState(isInitializing: false);
  }

  // ── Helpers ───────────────────────────────────────────────────────

  /// Generate a random nonce string for Apple Sign-In.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Map Firebase error codes to user-friendly Japanese messages.
  String _friendlyFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return '別のサインイン方法で登録済みのアカウントがあります。';
      case 'invalid-credential':
        return '認証情報が無効です。もう一度お試しください。';
      case 'network-request-failed':
        return 'ネットワークエラーが発生しました。接続を確認してください。';
      case 'user-disabled':
        return 'このアカウントは無効化されています。';
      default:
        return 'サインインに失敗しました。もう一度お試しください。';
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
