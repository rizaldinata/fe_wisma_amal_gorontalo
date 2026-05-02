import 'package:flutter/material.dart';

class ReservationStatusBadge extends StatelessWidget {
  final String status;

  final Color? color;

  const ReservationStatusBadge({super.key, required this.status, this.color});

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green.shade700;

      case 'pending':
        return Colors.orange.shade700;

      case 'cancelled':
        return Colors.red.shade700;

      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final badgeColor = color ?? _getStatusColor();

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
