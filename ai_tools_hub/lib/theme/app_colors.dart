import 'package:flutter/material.dart';

const kPrimary   = Color(0xFF6366F1);
const kSecondary = Color(0xFF8B5CF6);

class AppColors {
  final Color bg;
  final Color card;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final bool isDark;

  const AppColors._({
    required this.bg,
    required this.card,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.isDark,
  });

  static AppColors of(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AppColors._(
      bg:            dark ? const Color(0xFF0A0E27) : const Color(0xFFF3F4F6),
      card:          dark ? const Color(0xFF1A1F3A) : Colors.white,
      surface:       dark ? const Color(0xFF131729) : Colors.white,
      border:        dark ? const Color(0xFF2A2F52) : const Color(0xFFE5E7EB),
      textPrimary:   dark ? Colors.white             : const Color(0xFF111827),
      textSecondary: dark ? const Color(0xB3FFFFFF)  : const Color(0xFF374151),
      textTertiary:  dark ? const Color(0x61FFFFFF)  : const Color(0xFF9CA3AF),
      isDark: dark,
    );
  }
}
