import 'package:flutter/material.dart';
import 'package:frontend/presentation/widget/core/chip/custom_chip.dart';
import 'package:frontend/presentation/widget/core/wrapper/wrapper_tap_wrapper.dart';

class ReservationCard extends StatelessWidget {
  final String guestName;
  final String roomTitle;
  final String checkIn;
  final String checkOut;
  final String status;
  final VoidCallback? onTap;

  const ReservationCard({
    super.key,
    required this.guestName,
    required this.roomTitle,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    this.onTap,
  });

  Color _getStatusColor() {
    switch (status) {
      case 'Aktif':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Selesai':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HoverTapWrapper(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withAlpha(70),
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── ICON ──
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.book_online,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),

            // ── INFO ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guestName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    roomTitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$checkIn  →  $checkOut',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── STATUS CHIP ──
            CustomChip(
              label: status,
              color: _getStatusColor(),
            ),
          ],
        ),
      ),
    );
  }
}