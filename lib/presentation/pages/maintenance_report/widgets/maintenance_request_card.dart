import 'package:flutter/material.dart';
import 'package:frontend/domain/entity/maintenance_request_entity.dart';
import 'package:frontend/presentation/pages/maintenance_report/widgets/maintenance_status_badge.dart';
import 'package:frontend/presentation/widget/core/wrapper/hover_wrapper.dart';
import 'package:intl/intl.dart';

/// A card for the maintenance list. Uses HoverTapWrapper for desktop hover effect.
class MaintenanceRequestCard extends StatelessWidget {
  const MaintenanceRequestCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  final MaintenanceRequestEntity request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    return HoverTapWrapper(
      effect: HoverEffectType.combine,
      borderRadius: BorderRadius.circular(12),
      normalColor: theme.colorScheme.surfaceContainerLow,
      hoverColor: theme.colorScheme.surfaceContainerHighest,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Row: Title + Status Badge ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    request.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                MaintenanceStatusBadge(status: request.status),
              ],
            ),
            const SizedBox(height: 8),

            // --- Description ---
            Text(
              request.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // --- Bottom Row: Meta info ---
            Row(
              children: [
                // Resident name (for admin view)
                Icon(
                  Icons.person_outline_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  request.residentName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (request.room != null) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.meeting_room_outlined,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Kamar ${request.room!.number}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const Spacer(),
                // Date
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  request.reportedAt != null
                      ? dateFormat.format(request.reportedAt!)
                      : dateFormat.format(request.createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                // Photo count badge
                if (request.images.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  _PhotoCountBadge(count: request.images.length),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoCountBadge extends StatelessWidget {
  const _PhotoCountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_outlined,
            size: 12,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 3),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
