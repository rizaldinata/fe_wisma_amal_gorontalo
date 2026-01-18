import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_typography.dart';
import 'package:frontend/core/theme/color_schemes.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    primaryColor: lightColorScheme.primary,
    scaffoldBackgroundColor: AppColors.surfaceLight,
    fontFamily: 'Inter',

    textTheme: const TextTheme(
      displayLarge: AppTypography.displayLarge,
      headlineMedium: AppTypography.headlineMedium,
      titleMedium: AppTypography.titleMedium,
      bodyMedium: AppTypography.bodyMedium,
      labelSmall: AppTypography.labelSmallLight,
    ),

    // AppBar - Clean minimal design seperti mockup
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceLight,
      foregroundColor: AppColors.textPrimaryLight,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryLight,
        fontFamily: 'Inter',
      ),
    ),

    // // Card - White dengan shadow halus seperti mockup
    // cardTheme: CardTheme(
    //   color: AppColors.surfaceLight,
    //   elevation: 0,
    //   shadowColor: AppColors.shadowLight,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(12),
    //   ),
    //   margin: const EdgeInsets.all(0),
    // ),

    // Elevated Button - Primary action
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: lightColorScheme.primary,
        foregroundColor: AppColors.textWhite,
        disabledBackgroundColor: AppColors.borderLight,
        disabledForegroundColor: AppColors.textHintLight,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        minimumSize: const Size(0, 48),
      ),
    ),

    // Outlined Button - Secondary action
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryLight,
        disabledForegroundColor: AppColors.textHintLight,
        side: BorderSide(color: AppColors.borderLight, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        minimumSize: const Size(0, 48),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: lightColorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    ),

    // Input Fields - Clean design
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.borderLight, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.borderLight, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightColorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.errorColor, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.dividerLight, width: 1.5),
      ),
      hintStyle: TextStyle(
        color: AppColors.textHintLight,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(
        color: AppColors.textSecondaryLight,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: AppColors.dividerLight,
      thickness: 1,
      space: 1,
    ),
    dividerColor: AppColors.dividerLight,

    // List Tile - untuk sidebar dan list items
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      selectedTileColor: AppColors.sidebarActiveLight,
      selectedColor: AppColors.textPrimaryLight,
      iconColor: AppColors.textSecondaryLight,
      textColor: AppColors.textPrimaryLight,
    ),

    // Data Table
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStateProperty.all(AppColors.tableHeaderLight),
      dataRowColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return AppColors.tableRowHoverLight;
        }
        return Colors.transparent;
      }),
      headingTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondaryLight,
        fontFamily: 'Inter',
      ),
      dataTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryLight,
        fontFamily: 'Inter',
      ),
      dividerThickness: 1,
      horizontalMargin: 16,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceContainerHighestLight,
      deleteIconColor: AppColors.textSecondaryLight,
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryLight,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),

    // IconButton
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.textSecondaryLight,
        iconSize: 20,
      ),
    ),

    // Tooltip
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.textPrimaryLight.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: const TextStyle(
        fontSize: 13,
        color: AppColors.textWhite,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    scaffoldBackgroundColor: AppColors.surfaceDark,
    primaryColor: darkColorScheme.primary,
    fontFamily: 'Inter',

    textTheme: const TextTheme(
      displayLarge: AppTypography.displayLarge,
      headlineMedium: AppTypography.headlineMedium,
      titleMedium: AppTypography.titleMedium,
      bodyMedium: AppTypography.bodyMedium,
      labelSmall: AppTypography.labelSmallDark,
    ),

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textPrimaryDark,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryDark,
        fontFamily: 'Inter',
      ),
    ),

    // // Card
    // cardTheme: CardTheme(
    //   color: AppColors.surfaceDark,
    //   elevation: 0,
    //   shadowColor: AppColors.shadowDark,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(12),
    //   ),
    //   margin: const EdgeInsets.all(0),
    // ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: darkColorScheme.primary,
        foregroundColor: AppColors.textWhite,
        disabledBackgroundColor: AppColors.borderDark,
        disabledForegroundColor: AppColors.textHintDark,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        minimumSize: const Size(0, 48),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryDark,
        disabledForegroundColor: AppColors.textHintDark,
        side: BorderSide(color: AppColors.borderDark, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        minimumSize: const Size(0, 48),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkColorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    ),

    // Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainerDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.borderDark, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.borderDark, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: darkColorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.errorColorDark, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.errorColorDark, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.dividerDark, width: 1.5),
      ),
      hintStyle: TextStyle(
        color: AppColors.textHintDark,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(
        color: AppColors.textSecondaryDark,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: AppColors.dividerDark,
      thickness: 1,
      space: 1,
    ),
    dividerColor: AppColors.dividerDark,

    // List Tile
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      selectedTileColor: AppColors.sidebarActiveDark,
      selectedColor: AppColors.textPrimaryDark,
      iconColor: AppColors.textSecondaryDark,
      textColor: AppColors.textPrimaryDark,
    ),

    // Data Table
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStateProperty.all(AppColors.tableHeaderDark),
      dataRowColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return AppColors.tableRowHoverDark;
        }
        return Colors.transparent;
      }),
      headingTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondaryDark,
        fontFamily: 'Inter',
      ),
      dataTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryDark,
        fontFamily: 'Inter',
      ),
      dividerThickness: 1,
      horizontalMargin: 16,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceContainerDark,
      deleteIconColor: AppColors.textSecondaryDark,
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryDark,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),

    // IconButton
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.textSecondaryDark,
        iconSize: 20,
      ),
    ),

    // Tooltip
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.textPrimaryDark.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: const TextStyle(
        fontSize: 13,
        color: AppColors.textPrimaryLight,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  );
}
