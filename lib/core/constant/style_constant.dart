import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StyleConstant {
  static final Color _textColor = const Color.fromARGB(221, 7, 7, 7);
  static final TextStyle customTextStyle = GoogleFonts.roboto(
    textStyle: TextStyle(color: _textColor),
  );
}
