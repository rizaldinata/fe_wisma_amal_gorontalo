import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BasicButton extends StatelessWidget {
  const BasicButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.style = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    this.leadIcon = const SizedBox.shrink(),
    this.trailIcon = const SizedBox.shrink(),
    this.isLoading = false,
  });
  final String label;
  final void Function()? onPressed;
  final TextStyle style;
  final Widget leadIcon;
  final Widget trailIcon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(

      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                leadIcon,
                const SizedBox(width: 8),
                Text(label, style: style),
                const SizedBox(width: 8),
                trailIcon,
              ],
            ),
    );
  }
}
