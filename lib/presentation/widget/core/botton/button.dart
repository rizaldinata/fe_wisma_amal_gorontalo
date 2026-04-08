import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ButtonType { primary, secondary, danger }

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
    this.type = ButtonType.primary,
    this.foregroundColor,
  });
  final String label;
  final void Function()? onPressed;
  final TextStyle style;
  final Widget leadIcon;
  final Widget trailIcon;
  final bool isLoading;
  final ButtonType type;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (type == ButtonType.secondary) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  leadIcon,
                  // const SizedBox(width: 8),
                  Text(
                    label,
                    style: style.copyWith(
                      color: foregroundColor ?? colorScheme.primary,
                    ),
                  ),
                  // const SizedBox(width: 8),
                  trailIcon,
                ],
              ),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: type == ButtonType.danger
          ? ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: Colors.white,
            )
          : null,
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                leadIcon,
                const SizedBox(width: 8),
                Text(
                  label,
                  style: style.copyWith(color: foregroundColor ?? Colors.white),
                ),
                const SizedBox(width: 8),
                trailIcon,
              ],
            ),
    );
  }
}
