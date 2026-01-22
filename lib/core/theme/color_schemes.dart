import 'package:flutter/material.dart';

final ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.primary,
  onPrimary: AppColors.textWhite,
  secondary: AppColors.secondary,
  onSecondary: AppColors.textWhite,
  surface: AppColors.surfaceLight,
  onSurface: AppColors.textPrimaryLight,
  error: AppColors.errorColor,
  onError: AppColors.textWhite,
  outline: AppColors.borderLight,
  onSurfaceVariant: AppColors.textSecondaryLight,
  surfaceContainerLow: AppColors.surfaceContainerLowLight,
  surfaceContainerHigh: AppColors.surfaceContainerHighLight,
  surfaceContainerHighest: AppColors.borderLight,
);

final ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: AppColors.primaryDark,
  onPrimary: AppColors.textWhite,
  secondary: AppColors.secondaryDark,
  onSecondary: AppColors.textWhite,
  surface: AppColors.surfaceDark,
  onSurface: AppColors.textPrimaryDark,
  error: AppColors.errorColorDark,
  onError: AppColors.textWhite,
  outline: AppColors.borderDark,
  onSurfaceVariant: AppColors.textSecondaryDark,
  surfaceContainerLow: AppColors.surfaceContainerDark,
  surfaceContainerHigh: AppColors.surfaceContainerHighDark,
  surfaceContainerHighest: AppColors.surfaceContainerHighestDark,
);

class AppColors {
  const AppColors._();

  // Primary Colors - Based on mockup sidebar active state
  static const Color primary = Color(0xFF8B7FD7);
  static const Color primaryDark = Color(0xFF9E8FE5);
  static const Color secondary = Color(0xFF6B5FBA);
  static const Color secondaryDark = Color(0xFF7D6FC9);

  // Background Colors
  static const Color surfaceLight = Color(0xFFF4F4F4);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  //survace container
  static const Color surfaceContainerDark = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighDark = Color(0xFF353535);
  static const Color surfaceContainerHighestDark = Color(0xFF404040);

  static const Color surfaceContainerLowLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerHighLight = Color(0xFFefefef);
  static const Color surfaceContainerHighestLight = Color(0xFFd9d9d9);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF666666);
  static const Color textHintLight = Color(0xFF999999);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textPrimaryDark = Color(0xFFE5E5E5);
  static const Color textSecondaryDark = Color(0xFFAAAAAA);
  static const Color textHintDark = Color(0xFF707070);

  // Border & Divider
  static const Color borderLight = Color(0xFFE8E8E8);
  static const Color dividerLight = Color.fromARGB(255, 203, 203, 203);
  static const Color borderDark = Color(0xFF404040);
  static const Color dividerDark = Color(0xFF2A2A2A);

  // Status Colors - Dari mockup cards
  static const Color errorColor = Color(0xFFF25C5C);
  static const Color errorColorDark = Color(0xFFFF6B6B);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color successColorDark = Color(0xFF5FBF63);
  static const Color warningColor = Color(0xFFFFA726);
  static const Color warningColorDark = Color(0xFFFFB74D);
  static const Color infoColor = Color(0xFF42A5F5);
  static const Color infoColorDark = Color(0xFF64B5F6);

  // Card Background Colors - Dari mockup dashboard cards
  static const Color cardRedBg = Color(0xFFFFCDD2); // Laporan Kerusakan
  static const Color cardRedBgDark = Color(0xFF5C2E2E);
  static const Color cardYellowBg = Color(0xFFFFF9C4); // Stock kritis
  static const Color cardYellowBgDark = Color(0xFF5C5530);
  static const Color cardGreenBg = Color(0xFFC8E6C9); // Jadwal Pembersihan
  static const Color cardGreenBgDark = Color(0xFF2E5C30);

  // Icon Background Colors
  static const Color iconRedBg = Color(0xFFFFE5E8);
  static const Color iconRedBgDark = Color(0xFF3D2626);
  static const Color iconYellowBg = Color(0xFFFFF8DC);
  static const Color iconYellowBgDark = Color(0xFF3D3A26);
  static const Color iconGreenBg = Color(0xFFE8F5E9);
  static const Color iconGreenBgDark = Color(0xFF263D28);
  static const Color iconPurpleBg = Color(0xFFF3E5F5);
  static const Color iconPurpleBgDark = Color(0xFF372640);

  // Shadow
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowDark = Color(0x1A000000);

  // Sidebar specific
  static const Color sidebarActiveLight = Color(0xFFF0F0F0); // Active menu item
  static const Color sidebarActiveDark = Color(0xFF2A2A2A);

  // Table/List specific
  static const Color tableHeaderLight = Color(0xFFF8F8F8);
  static const Color tableHeaderDark = Color(0xFF262626);
  static const Color tableRowHoverLight = Color(0xFFFAFAFA);
  static const Color tableRowHoverDark = Color(0xFF232323);
}
