import 'package:flutter/material.dart';

class ReservationStatusBadge extends StatelessWidget {
  final String status;
  final Color? color;

  const ReservationStatusBadge({
    super.key,
    required this.status,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Default to green for "Lunas" as seen in the screenshot
    final theme = Theme.of(context);
    final badgeColor = color ?? Colors.green.shade800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: theme.textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
