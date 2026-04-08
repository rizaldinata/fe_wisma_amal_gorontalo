import 'package:flutter/material.dart';
import 'package:frontend/presentation/widget/core/botton/icon_button.dart';

class CustomChip extends StatelessWidget {
  CustomChip({
    super.key,
    required this.label,
    required this.color,
    this.onPressed,
  });
  final String label;
  final Color color;
  void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: (onPressed != null)
              ? const EdgeInsets.only(right: 15, top: 15)
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (onPressed != null)
          Positioned(
            right: 0,
            top: 0,
            child: Transform.scale(
              scale: 0.7,
              child: IconButton(
                // backgroundColor: Colors.red,
                hoverColor: Colors.red.withAlpha(50),
                onPressed: onPressed,
                icon: Icon(Icons.close, size: 18, color: Colors.red),
              ),
            ),
          ),
      ],
    );
  }
}
