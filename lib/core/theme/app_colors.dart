import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // =====================
  // PRIMARY & STATUS
  // =====================
  static const Color primaryColor = Color(0xFF8B7FD7); // Purple from mockup
  static const Color secondaryColor = Color(0xFF6B5FBA); // Darker purple
  static const Color accentColor = Color(0xFFB8B0E8); // Lighter purple

  static const Color errorColor = Color(0xFFF25C5C); // Soft red
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color warningColor = Color(0xFFFFD54F); // Yellow
  static const Color infoColor = Color(0xFF4FC3F7); // Light blue

  // =====================
  // ACTION & CARD COLORS
  // =====================
  static const Color actionYellow = Color(
    0xFFD4E157,
  ); // Lime/yellow for Edit buttons
  static const Color actionBlue = Color(0xFF42A5F5); // Blue for primary actions

  static const Color cardRedBg = Color(0xFFFFCDD2); // Light red/pink
  static const Color cardYellowBg = Color(0xFFFFF9C4); // Light yellow
  static const Color cardGreenBg = Color(0xFFC8E6C9); // Light green

  // =====================
  // TEXT COLORS
  // =====================
  // Light
  static const Color textPrimaryLight = Color.fromARGB(255, 52, 52, 52);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textHintLight = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);
  // Dark
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);
  static const Color textHintDark = Color(0xFF757575);

  // =====================
  // SURFACE & BACKGROUND
  // =====================
  // Light
  static const Color backgroundLight = Color(
    0xFFF5F5F7,
  ); // Slightly off-white gray
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color sidebarLight = Color(0xFFFAFAFA); // Light sidebar
  // Dark
  static const Color backgroundDark = Color(
    0xFF0F0F1A,
  ); // Very dark blue-purple
  static const Color surfaceDark = Color(
    0xFF1A1A2E,
  ); // Dark blue-purple surface
  static const Color cardDark = Color(0xFF232340); // Lighter card
  static const Color sidebarDark = Color(0xFF16162A); // Dark sidebar

  // =====================
  // BORDER & DIVIDER
  // =====================
  // Light

  // Dark
  static const Color borderDark = Color(0xFF3A3A52);
  static const Color dividerDark = Color(0xFF2E2E42);

  // =====================
  // INPUT & SHADOW
  // =====================
  // Dark only
  static const Color inputFillDark = Color(0xFF2A2A45);

  // Light & Dark
  static const Color shadowLight = Color(0x0F000000); // 6% black shadow
  static const Color shadowDark = Color(0x29000000); // 16% black shadow

  // =====================
  // ALIASES FOR COLORSCHEME-BASED THEMING
  // =====================
  // Brand Colors
  static const Color primary = primaryColor;
  static const Color secondary = secondaryColor;

  // Status
  static const Color success = successColor;
  static const Color warning = warningColor;
  static const Color danger = errorColor;

  // LIGHT MODE aliases
  static const Color lightSurface = backgroundLight; // App background
  static const Color lightText = textPrimaryLight;
  static const Color lightOnSurface = textSecondaryLight;
  static const Color borderLight = Color(0xFFE8E8EA);
  static const Color dividerLight = Color(0xFFE0E0E0);

  // DARK MODE aliases
  static const Color darkSurface = backgroundDark;
  static const Color darkText = textPrimaryDark;
  static const Color darkOnSurface = textSecondaryDark;
  static const Color darkOutline = borderDark;

  // Card hierarchy (light)
  static const Color lightSurfaceContainerLow = cardLight; // parent card
  static const Color lightSurfaceContainerHigh = Color(
    0xFFF7F7FB,
  ); // child card
  static const Color lightSurfaceContainerHighest = borderLight; // table/hover
  // Card hierarchy (dark)
  static const Color darkSurfaceContainerLow = surfaceDark;
  static const Color darkSurfaceContainerHigh = cardDark;
  static const Color darkSurfaceContainerHighest = Color(0xFF2F3045);
  static const Color dividerColorDark = dividerDark;
}
