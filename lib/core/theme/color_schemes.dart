import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ColorScheme untuk light theme berdasarkan desain Wisma Amal
final ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.primary,
  onPrimary: AppColors.textWhite,
  secondary: AppColors.secondary,
  onSecondary: AppColors.textWhite,
  surface: AppColors.lightSurface,
  onSurface: AppColors.lightText,
  background: AppColors.backgroundLight,
  onBackground: AppColors.textPrimaryLight,
  error: AppColors.danger,
  onError: AppColors.textWhite,
  outline: AppColors.borderLight,
  onSurfaceVariant: AppColors.textSecondaryLight,
  surfaceContainerLow: AppColors.lightSurfaceContainerLow,
  surfaceContainerHigh: AppColors.lightSurfaceContainerHigh,
  surfaceContainerHighest: AppColors.lightSurfaceContainerHighest,
);

/// ColorScheme untuk dark theme berdasarkan desain Wisma Amal
final ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: AppColors.primary,
  onPrimary: AppColors.textWhite,
  secondary: AppColors.secondary,
  onSecondary: AppColors.textWhite,
  surface: AppColors.darkSurface,
  onSurface: AppColors.darkText,
  background: AppColors.backgroundDark,
  onBackground: AppColors.textPrimaryDark,
  error: AppColors.danger,
  onError: AppColors.textWhite,
  outline: AppColors.darkOutline,
  onSurfaceVariant: AppColors.textSecondaryDark,
  surfaceContainerLow: AppColors.darkSurfaceContainerLow,
  surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
  surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
);
