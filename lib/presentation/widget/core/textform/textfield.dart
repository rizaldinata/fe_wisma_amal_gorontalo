import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.fillColor,
    this.hintText,
    this.suffixIcon,
  });

  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final Color? fillColor;
  final String? hintText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: (fillColor != null),
        fillColor:
            fillColor ?? Theme.of(context).colorScheme.surfaceContainerHigh,
        hintText: hintText,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }
}
