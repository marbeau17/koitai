import 'package:flutter/material.dart';

/// Application color palette based on the UI/UX specification.
abstract final class AppColors {
  // ── Primary ──────────────────────────────────────────────
  static const Color primary = Color(0xFF6C3FE0);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF4C1D95);

  // ── Accent ───────────────────────────────────────────────
  static const Color accent = Color(0xFFF472B6);
  static const Color accentLight = Color(0xFFFBCFE8);
  static const Color gold = Color(0xFFFBBF24);

  // ── Background (Dark) ────────────────────────────────────
  static const Color bgPrimary = Color(0xFF0F0A1A);
  static const Color bgSecondary = Color(0xFF1A1128);
  static const Color bgCard = Color(0xFF241B35);

  // ── Background (Light) ───────────────────────────────────
  static const Color bgLight = Color(0xFFFDF4FF);
  static const Color bgCardLight = Color(0xFFFFFFFF);

  // ── Text (Dark theme) ────────────────────────────────────
  static const Color textPrimary = Color(0xFFF5F3FF);
  static const Color textSecondary = Color(0xFFC4B5FD);

  // ── Text (Light theme) ───────────────────────────────────
  static const Color textDark = Color(0xFF1F1535);

  // ── Semantic: Fortune Ranks ──────────────────────────────
  static const Color bestDay = Color(0xFFFBBF24);
  static const Color goodDay = Color(0xFFA78BFA);
  static const Color normalDay = Color(0xFF6B7280);
  static const Color cautionDay = Color(0xFF94A3B8);

  // ── UI Elements ──────────────────────────────────────────
  static const Color disabledBg = Color(0xFF3A3450);
  static const Color disabledText = Color(0xFF6B6380);
  static const Color border = Color(0xFF3A3450);
  static const Color borderLight = Color(0xFFE5E7EB);

  // ── Light-mode overrides ─────────────────────────────────
  static const Color accentLightMode = Color(0xFFEC4899);
}
