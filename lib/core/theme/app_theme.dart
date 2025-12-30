import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_typography.dart';
import 'package:frontend/core/theme/color_schemes.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    primaryColor: lightColorScheme.primary,
    scaffoldBackgroundColor: lightColorScheme.surface,
    fontFamily: 'Inter',

    textTheme: const TextTheme(
      displayLarge: AppTypography.displayLarge,
      headlineMedium: AppTypography.headlineMedium,
      titleMedium: AppTypography.titleMedium,
      bodyMedium: AppTypography.bodyMedium,
      labelSmall: AppTypography.labelSmallLight,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: lightColorScheme.surface,
      foregroundColor: lightColorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        fixedSize: const Size.fromHeight(45),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        foregroundColor: lightColorScheme.onSurface.withAlpha(150),
        backgroundColor: lightColorScheme.surfaceContainerHigh,
        side: BorderSide(color: lightColorScheme.outline),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        fixedSize: const Size.fromHeight(45),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: lightColorScheme.onPrimary,
          inherit: true,
        ),
        foregroundColor: lightColorScheme.onPrimary,
        backgroundColor: lightColorScheme.primary,
      ),
    ),

    cardColor: AppColors.lightSurfaceContainerLow,
    dividerColor: AppColors.dividerLight,

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightColorScheme.surfaceContainerLow,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightColorScheme.primary),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
    ),

    dividerTheme: const DividerThemeData(),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    scaffoldBackgroundColor: darkColorScheme.surface,
    primaryColor: darkColorScheme.primary,
    fontFamily: 'Inter',

    textTheme: const TextTheme(
      displayLarge: AppTypography.displayLarge,
      headlineMedium: AppTypography.headlineMedium,
      titleMedium: AppTypography.titleMedium,
      bodyMedium: AppTypography.bodyMedium,
      labelSmall: AppTypography.labelSmallDark,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: darkColorScheme.surface,
      foregroundColor: darkColorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
    ),

    cardTheme: CardThemeData(color: AppColors.darkSurfaceContainerLow),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        fixedSize: const Size.fromHeight(45),
        elevation: 0,
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkColorScheme.onPrimary,
          inherit: true,
        ),
        foregroundColor: darkColorScheme.onPrimary,
        backgroundColor: darkColorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkColorScheme.surfaceContainerLow,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade800),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: darkColorScheme.primary),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade800),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        fixedSize: const Size.fromHeight(45),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        foregroundColor: darkColorScheme.onSurface.withAlpha(150),
        backgroundColor: darkColorScheme.surfaceContainerHigh,
        side: BorderSide(color: darkColorScheme.outline),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    cardColor: AppColors.darkSurfaceContainerLow,
    dividerTheme: DividerThemeData(color: AppColors.dividerColorDark),
    dividerColor: AppColors.dividerColorDark,
  );
}
