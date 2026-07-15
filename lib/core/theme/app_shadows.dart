import 'package:flutter/material.dart';

class AppShadows {
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0A0F172A),
    blurRadius: 8,
    offset: Offset(0, 2),
  );
  
  static const BoxShadow cardShadowHover = BoxShadow(
    color: Color(0x140F172A),
    blurRadius: 16,
    offset: Offset(0, 4),
  );
}
