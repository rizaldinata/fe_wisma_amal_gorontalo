import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';

class AppTheme {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // Shorthand getter
  static dynamic colors(BuildContext context) =>
      isDark(context) ? AppColorsDark() : AppColorsLight();

  static TextTheme get _textTheme => GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
            fontSize: 32, fontWeight: FontWeight.w700),
        headlineMedium: GoogleFonts.plusJakartaSans(
            fontSize: 22, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.plusJakartaSans(
            fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.plusJakartaSans(
            fontSize: 15, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.plusJakartaSans(
            fontSize: 13, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.plusJakartaSans(
            fontSize: 15, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.plusJakartaSans(
            fontSize: 13, fontWeight: FontWeight.w400),
        bodySmall: GoogleFonts.plusJakartaSans(
            fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: GoogleFonts.plusJakartaSans(
            fontSize: 13, fontWeight: FontWeight.w500),
        labelSmall: GoogleFonts.plusJakartaSans(
            fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColorsLight.background,
        colorScheme: const ColorScheme.light(
          primary: AppColorsLight.primary,
          surface: AppColorsLight.surface,
          onPrimary: Colors.white,
          onSurface: AppColorsLight.textPrimary,
        ),
        textTheme: _textTheme.apply(
          bodyColor: AppColorsLight.textPrimary,
          displayColor: AppColorsLight.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColorsLight.surface,
          foregroundColor: AppColorsLight.textPrimary,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColorsLight.borderLight,
          thickness: 1,
          space: 1,
        ),
        dividerColor: AppColorsLight.borderLight,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColorsLight.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColorsLight.borderLight, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColorsLight.borderLight, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColorsLight.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColorsLight.statusCancelled, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColorsLight.statusCancelled, width: 2),
          ),
          hintStyle: const TextStyle(
            color: AppColorsLight.textHint,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          labelStyle: const TextStyle(
            color: AppColorsLight.textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: AppColorsLight.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColorsLight.borderLight,
            disabledForegroundColor: AppColorsLight.textHint,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
            textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            minimumSize: const Size(0, 48),
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColorsDark.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColorsDark.primary,
          surface: AppColorsDark.surface,
          onPrimary: Colors.white,
          onSurface: AppColorsDark.textPrimary,
        ),
        textTheme: _textTheme.apply(
          bodyColor: AppColorsDark.textPrimary,
          displayColor: AppColorsDark.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColorsDark.surface,
          foregroundColor: AppColorsDark.textPrimary,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColorsDark.borderLight,
          thickness: 1,
          space: 1,
        ),
        dividerColor: AppColorsDark.borderLight,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColorsDark.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColorsDark.borderLight, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColorsDark.borderLight, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColorsDark.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColorsDark.statusCancelled, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColorsDark.statusCancelled, width: 2),
          ),
          hintStyle: const TextStyle(
            color: AppColorsDark.textHint,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          labelStyle: const TextStyle(
            color: AppColorsDark.textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: AppColorsDark.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColorsDark.borderLight,
            disabledForegroundColor: AppColorsDark.textHint,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
            textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            minimumSize: const Size(0, 48),
          ),
        ),
      );
}
