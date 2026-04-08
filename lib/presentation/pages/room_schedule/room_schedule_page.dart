import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/textform/dropdown_field.dart';

import 'package:frontend/presentation/pages/room_schedule/widget/room_availability_grid.dart';

@RoutePage()
class RoomSchedulePage extends StatefulWidget {
  const RoomSchedulePage({super.key});

  @override
  State<RoomSchedulePage> createState() => _RoomSchedulePageState();
}

class _RoomSchedulePageState extends State<RoomSchedulePage> {
  String? _selectedRoom = 'Semua Kamar';
  String? _selectedStatus = 'Semua Status';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jadwal Kamar',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Kelola Sistem Kost Anda dengan Mudah',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              BasicCard(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jadwal Kamar - Januari 2025',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            _MonthNavigator(),
                            const SizedBox(width: 16),
                            _FilterToggleButton(),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Filters and Stats Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 200,
                                    child: CustomDropdownField(
                                      title: 'Filter Kamar',
                                      hint: 'Semua Kamar',
                                      value: _selectedRoom,
                                      items: const [
                                        'Semua Kamar',
                                        'Kamar 101',
                                        'Kamar 102',
                                      ],
                                      onChanged: (v) =>
                                          setState(() => _selectedRoom = v),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 200,
                                    child: CustomDropdownField(
                                      title: 'Status Reservasi',
                                      hint: 'Semua Status',
                                      value: _selectedStatus,
                                      items: const [
                                        'Semua Status',
                                        'Pending',
                                        'Ongoing',
                                        'Completed',
                                      ],
                                      onChanged: (v) =>
                                          setState(() => _selectedStatus = v),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _StatusLegend(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        _TotalBookingStat(count: 15),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Room Schedule Grid
                    RoomAvailabilityGrid(
                      daysInMonth: 31,
                      monthYear: 'Januari 2025',
                      rooms: [
                        RoomGridData(
                          roomNumber: 'Kamar 101',
                          roomType: 'AC - Lantai 1',
                          dailyStatus: {
                            0: RoomDayStatus.pending,
                            1: RoomDayStatus.pending,
                            2: RoomDayStatus.pending,
                          },
                        ),
                        RoomGridData(
                          roomNumber: 'Kamar 102',
                          roomType: 'AC - Lantai 1',
                          dailyStatus: {
                            5: RoomDayStatus.ongoing,
                            6: RoomDayStatus.ongoing,
                            7: RoomDayStatus.ongoing,
                            8: RoomDayStatus.ongoing,
                          },
                        ),
                        RoomGridData(
                          roomNumber: 'Kamar 103',
                          roomType: 'Kipas - Lantai 1',
                          dailyStatus: {
                            10: RoomDayStatus.completed,
                            11: RoomDayStatus.completed,
                            12: RoomDayStatus.completed,
                          },
                        ),
                        RoomGridData(
                          roomNumber: 'Kamar 104',
                          roomType: 'Kipas - Lantai 1',
                          dailyStatus: {},
                        ),
                        RoomGridData(
                          roomNumber: 'Kamar 105',
                          roomType: 'AC - Lantai 1',
                          dailyStatus: {
                            15: RoomDayStatus.ongoing,
                            16: RoomDayStatus.ongoing,
                            20: RoomDayStatus.pending,
                          },
                        ),
                        RoomGridData(
                          roomNumber: 'Kamar 106',
                          roomType: 'AC - Lantai 1',
                          dailyStatus: {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
          const VerticalDivider(width: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Januari 2025',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
        ],
      ),
    );
  }
}

class _FilterToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.filter_list, size: 18),
      label: const Text('Filter'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
    );
  }
}

class _StatusLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _LegendItem(color: Color(0xFFFFF9C4), label: 'Pending'),
          SizedBox(width: 24),
          _LegendItem(color: Color(0xFFC8E6C9), label: 'Ongoing'),
          SizedBox(width: 24),
          _LegendItem(color: Color(0xFFBBDEFB), label: 'Completed'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _TotalBookingStat extends StatelessWidget {
  final int count;

  const _TotalBookingStat({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Total Booking',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
