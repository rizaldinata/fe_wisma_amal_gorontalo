import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Tipografi dasar yang mirip dengan contoh, menggunakan keluarga font umum.
class AppTypography {
  const AppTypography._();

  // Material 3 recommends using display, headline, title, body, label
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.darkSurface
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle labelSmallLight = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.black45,
  );

  static const TextStyle labelSmallDark = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );
}
