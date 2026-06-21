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
      case 'dp_terbayar':
        return Colors.deepOrange.shade600;
      case 'terkonfirmasi':
        return Colors.blue.shade600;
      case 'cancelled':
        return Colors.red.shade700;
      case 'finished':
        return Colors.grey.shade500;
      default:
        return Colors.grey.shade600;
    }
  }

  String _getStatusLabel() {
    switch (status.toLowerCase()) {
      case 'active':         return 'Aktif';
      case 'pending':        return 'Menunggu';
      case 'dp_terbayar':   return 'DP Terbayar';
      case 'terkonfirmasi': return 'Terkonfirmasi';
      case 'cancelled':      return 'Dibatalkan';
      case 'finished':       return 'Selesai';
      default:               return status;
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
        _getStatusLabel(),

        style: theme.textTheme.labelMedium?.copyWith(
          color: Colors.white,

          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
