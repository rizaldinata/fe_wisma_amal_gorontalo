import 'package:flutter/material.dart';
import 'package:frontend/presentation/widget/core/hover/hover_tap.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.icon,
    this.title,
    required this.onPressed,
  });
  final Icon icon;
  final String? title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return HoverTap(
      borderRadius: BorderRadius.circular(15),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            icon,
            if (title != null) ...[const SizedBox(width: 8), Text(title!)],
          ],
        ),
      ),
    );
  }
}
