import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/presentation/widget/core/textform/textfield.dart';

class CustomTextForm extends StatelessWidget {
  const CustomTextForm({
    super.key,
    required this.title,
    required this.hintText,
    this.isRequired = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.fillColor,
    this.controller,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.inputFormatters,
  });
  final Color? fillColor;
  final String title;
  final String hintText;
  final bool isRequired;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: title,
            style: Theme.of(context).textTheme.titleMedium,

            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Colors.red.shade300,
                        fontSize: 12,
                      ),
                    ),
                  ]
                : [],
          ),
        ),
        SizedBox(height: 8),
        CustomTextField(
          inputFormatters: inputFormatters,
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          fillColor:
              fillColor ?? Theme.of(context).colorScheme.surfaceContainerLow,
          hintText: hintText,
          suffixIcon: suffixIcon,
        ),
      ],
    );
  }
}
