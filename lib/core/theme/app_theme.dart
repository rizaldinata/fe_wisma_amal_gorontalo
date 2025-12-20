import 'package:flutter/material.dart';
import 'package:frontend/core/theme/dark_theme.dart';
import 'package:frontend/core/theme/light_theme.dart';

class AppTheme {
  static ThemeData get lightTheme => LightTheme.theme;
  static ThemeData get darkTheme => DarkTheme.theme;
}
