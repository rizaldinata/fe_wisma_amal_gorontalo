import 'package:flutter/material.dart';
import 'package:frontend/presentation/widget/core/hover/hover_tap.dart';
import 'package:frontend/presentation/widget/core/wrapper/hover_wrapper.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.icon,
    this.title,
    required this.onPressed,
    this.backgroundColor,
    this.borderColor,
    this.boxShadow,
    this.hoverColor,
  });
  final Widget icon;
  final String? title;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback onPressed;
  final List<BoxShadow>? boxShadow;
  final Color? hoverColor;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var colorScheme = theme.colorScheme;

    return HoverTapWrapper(
      borderRadius: BorderRadius.circular(15),
      normalColor: backgroundColor ?? colorScheme.surfaceContainerLow,
      onTap: onPressed,
      boxShadow:
          boxShadow ??
          [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
      effect: HoverEffectType.combine,
      hoverColor: hoverColor ?? colorScheme.primary.withAlpha(50),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
        ),

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
