import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final Color? fillColor;
  final String? hintText;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final String? initialValue;
  final bool enabled;

  const CustomTextField({
    super.key,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.fillColor,
    this.hintText,
    this.suffixIcon,
    this.inputFormatters,
    this.onChanged,
    this.initialValue,
    this.enabled = true,
  }) : assert(initialValue == null || controller == null,
            'Cannot provide both a controller and an initialValue');

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      initialValue: initialValue,
      enabled: enabled,
      decoration: InputDecoration(
        filled: true,
        fillColor: enabled
            ? (fillColor ?? Theme.of(context).colorScheme.surfaceContainerLow)
            : Colors.grey.shade100,
        hintText: hintText,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: enabled ? Colors.grey.shade300 : Colors.grey.shade200,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }
}
