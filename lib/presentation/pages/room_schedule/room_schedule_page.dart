import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/domain/entity/room/room_schedule_entity.dart';
import 'package:frontend/presentation/bloc/room/room_schedule/room_schedule_bloc.dart';
import 'package:frontend/presentation/bloc/room/room_schedule/room_schedule_event.dart';
import 'package:frontend/presentation/bloc/room/room_schedule/room_schedule_state.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/textform/dropdown_field.dart';
import 'package:intl/intl.dart';

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
  DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => serviceLocator.get<RoomScheduleBloc>()..add(FetchRoomSchedules()),
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BlocBuilder<RoomScheduleBloc, RoomScheduleState>(
            builder: (context, state) {
              if (state is RoomScheduleLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is RoomScheduleError) {
                return Center(child: Text('Error: ${state.message}'));
              }

              if (state is RoomScheduleLoaded) {
                final filteredRooms = _getFilteredRooms(state.schedules);
                final gridData = _convertToGridData(filteredRooms);

                return SingleChildScrollView(
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
                                  'Jadwal Kamar - ${DateFormat('MMMM yyyy').format(_currentMonth)}',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    _MonthNavigator(
                                      currentMonth: _currentMonth,
                                      onChanged: (newMonth) {
                                        setState(() => _currentMonth = newMonth);
                                      },
                                    ),
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
                                              items: [
                                                'Semua Kamar',
                                                ...state.schedules.map((e) => e.number),
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
                                _TotalBookingStat(count: _calculateTotalBookings(state.schedules)),
                              ],
                            ),
                            const SizedBox(height: 40),
                            // Room Schedule Grid
                            RoomAvailabilityGrid(
                              daysInMonth: DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day,
                              monthYear: DateFormat('MMMM yyyy').format(_currentMonth),
                              rooms: gridData,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  List<RoomScheduleEntity> _getFilteredRooms(List<RoomScheduleEntity> rooms) {
    return rooms.where((room) {
      if (_selectedRoom != 'Semua Kamar' && room.number != _selectedRoom) {
        return false;
      }
      // Status filter can be more complex if needed
      return true;
    }).toList();
  }

  List<RoomGridData> _convertToGridData(List<RoomScheduleEntity> rooms) {
    return rooms.map((room) {
      final Map<int, RoomDayStatus> dailyStatus = {};
      final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

      for (int day = 0; day < daysInMonth; day++) {
        final date = DateTime(_currentMonth.year, _currentMonth.month, day + 1);
        
        for (final lease in room.schedules) {
          final start = DateTime.parse(lease.startDate);
          final end = DateTime.parse(lease.endDate);

          // Check if date is between start and end (inclusive)
          if ((date.isAfter(start) || date.isAtSameMomentAs(start)) &&
              (date.isBefore(end) || date.isAtSameMomentAs(end))) {
            
            RoomDayStatus status;
            switch (lease.status.toLowerCase()) {
              case 'pending':
                status = RoomDayStatus.pending;
                break;
              case 'active':
                status = RoomDayStatus.ongoing;
                break;
              case 'expired':
                status = RoomDayStatus.completed;
                break;
              default:
                status = RoomDayStatus.available;
            }
            
            if (status != RoomDayStatus.available) {
              dailyStatus[day] = status;
              break; // One status per day per room for now
            }
          }
        }
      }

      return RoomGridData(
        roomNumber: room.number,
        roomType: room.title,
        dailyStatus: dailyStatus,
      );
    }).toList();
  }

  int _calculateTotalBookings(List<RoomScheduleEntity> rooms) {
    int total = 0;
    for (var room in rooms) {
      total += room.schedules.length;
    }
    return total;
  }
}

class _MonthNavigator extends StatelessWidget {
  final DateTime currentMonth;
  final Function(DateTime) onChanged;

  const _MonthNavigator({required this.currentMonth, required this.onChanged});

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
          IconButton(
            onPressed: () {
              onChanged(DateTime(currentMonth.year, currentMonth.month - 1));
            },
            icon: const Icon(Icons.chevron_left),
          ),
          const VerticalDivider(width: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              DateFormat('MMMM yyyy').format(currentMonth),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          IconButton(
            onPressed: () {
              onChanged(DateTime(currentMonth.year, currentMonth.month + 1));
            },
            icon: const Icon(Icons.chevron_right),
          ),
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
