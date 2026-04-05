// lib/presentation/pages/maintenance_report/widgets/maintenance_status_badge.dart
import 'package:flutter/material.dart';
import 'package:frontend/domain/entity/maintenance_status.dart';

class MaintenanceStatusBadge extends StatelessWidget {
  const MaintenanceStatusBadge({super.key, required this.status});

  final MaintenanceStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _label,
            style: TextStyle(
              color: _color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Color get _color {
    switch (status) {
      case MaintenanceStatus.pending:
        return const Color(0xFFF59E0B);
      case MaintenanceStatus.inProgress:
        return const Color(0xFF3B82F6);
      case MaintenanceStatus.completed:
        return const Color(0xFF10B981);
      case MaintenanceStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }

  String get _label {
    switch (status) {
      case MaintenanceStatus.pending:
        return 'Menunggu';
      case MaintenanceStatus.inProgress:
        return 'Dalam Proses';
      case MaintenanceStatus.completed:
        return 'Selesai';
      case MaintenanceStatus.cancelled:
        return 'Dibatalkan';
    }
  }
}
