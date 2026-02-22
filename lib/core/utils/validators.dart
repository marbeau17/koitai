import '../constants/app_config.dart';
import '../extensions/datetime_ext.dart';

/// Validation utilities for user input.
abstract final class Validators {
  /// Validates a birth date.
  ///
  /// Returns `null` when valid, otherwise a descriptive error message.
  static String? validateBirthDate(DateTime? date) {
    if (date == null) {
      return '生年月日を入力してください';
    }

    final now = DateTime.now();

    if (date.isAfter(now)) {
      return '未来の日付は指定できません';
    }

    final age = now.ageFrom(date);
    if (age < AppConfig.minimumAge) {
      return '${AppConfig.minimumAge}歳以上の方のみご利用いただけます';
    }

    if (age > 120) {
      return '正しい生年月日を入力してください';
    }

    return null;
  }

  /// Validates a partner's birth date for pair fortune.
  static String? validatePartnerBirthDate(DateTime? date) {
    if (date == null) {
      return 'お相手の生年月日を入力してください';
    }

    final now = DateTime.now();
    if (date.isAfter(now)) {
      return '未来の日付は指定できません';
    }

    final age = now.ageFrom(date);
    if (age < AppConfig.minimumAge) {
      return '${AppConfig.minimumAge}歳以上の方の生年月日を入力してください';
    }

    if (age > 120) {
      return '正しい生年月日を入力してください';
    }

    return null;
  }

  /// Validates a nickname string (optional field).
  /// Returns `null` when valid.
  static String? validateNickname(String? value) {
    if (value == null || value.isEmpty) {
      return null; // nickname is optional
    }
    if (value.length > 20) {
      return 'ニックネームは20文字以内で入力してください';
    }
    return null;
  }

  /// Validates a date string in "yyyy-MM-dd" format.
  static bool isValidDateString(String value) {
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!regex.hasMatch(value)) return false;

    try {
      final parts = value.split('-');
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final d = int.parse(parts[2]);
      final date = DateTime(y, m, d);
      // DateTime auto-adjusts invalid dates (e.g. Feb 30 -> Mar 2),
      // so verify the round-trip.
      return date.year == y && date.month == m && date.day == d;
    } catch (_) {
      return false;
    }
  }
}
