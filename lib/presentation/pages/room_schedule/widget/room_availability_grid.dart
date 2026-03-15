import 'package:flutter/material.dart';

enum RoomDayStatus { available, pending, ongoing, completed }

class RoomAvailabilityGrid extends StatelessWidget {
  final List<RoomGridData> rooms;
  final int daysInMonth;
  final String monthYear;

  const RoomAvailabilityGrid({
    super.key,
    required this.rooms,
    required this.daysInMonth,
    required this.monthYear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed Room Column
        Column(
          children: [
            // Header
            Container(
              height: 48,
              width: 150,
              padding: const EdgeInsets.only(left: 20),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12)),
              ),
              child: Text(
                'Kamar',
                style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            // Body Rows (Room Info)
            ...rooms.map((room) => Container(
                  height: 56,
                  width: 150,
                  padding: const EdgeInsets.only(left: 20),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CompactRoomInfo(room: room),
                    ],
                  ),
                )),
          ],
        ),
        const VerticalDivider(width: 1),
        // Scrollable Days Matrix
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                // Days Header Row
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(12)),
                  ),
                  child: Row(
                    children: List.generate(daysInMonth, (index) {
                      return Container(
                        width: 40,
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const Divider(height: 1),
                // Grid Body Rows
                ...rooms.map((room) => SizedBox(
                      height: 56,
                      child: Row(
                        children: List.generate(daysInMonth, (dayIndex) {
                          final status = room.dailyStatus[dayIndex] ?? RoomDayStatus.available;
                          return _AvailabilityCell(status: status);
                        }),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactRoomInfo extends StatelessWidget {
  final RoomGridData room;
  const _CompactRoomInfo({required this.room});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          room.roomNumber,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          room.roomType,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}

class RoomGridData {
  final String roomNumber;
  final String roomType;
  final Map<int, RoomDayStatus> dailyStatus; // day index (0-based) to status

  RoomGridData({
    required this.roomNumber,
    required this.roomType,
    required this.dailyStatus,
  });
}

class _AvailabilityCell extends StatelessWidget {
  final RoomDayStatus status;

  const _AvailabilityCell({required this.status});

  @override
  Widget build(BuildContext context) {
    Color cellColor;
    switch (status) {
      case RoomDayStatus.pending:
        cellColor = const Color(0xFFFFF9C4);
        break;
      case RoomDayStatus.ongoing:
        cellColor = const Color(0xFFC8E6C9);
        break;
      case RoomDayStatus.completed:
        cellColor = const Color(0xFFBBDEFB);
        break;
      case RoomDayStatus.available:
        cellColor = Colors.transparent;
        break;
    }

    return Container(
      width: 40,
      height: 56,
      decoration: BoxDecoration(
        color: cellColor,
        border: Border(
          right: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: status != RoomDayStatus.available
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getStatusTagColor(status),
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }

  Color _getStatusTagColor(RoomDayStatus status) {
    switch (status) {
      case RoomDayStatus.pending:
        return Colors.amber.shade700;
      case RoomDayStatus.ongoing:
        return Colors.green.shade700;
      case RoomDayStatus.completed:
        return Colors.blue.shade700;
      default:
        return Colors.transparent;
    }
  }
}
