import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/domain/entity/room/room_schedule_entity.dart';
import 'package:frontend/presentation/bloc/room/room_schedule/room_schedule_bloc.dart';
import 'package:frontend/presentation/bloc/room/room_schedule/room_schedule_event.dart';
import 'package:frontend/presentation/bloc/room/room_schedule/room_schedule_state.dart';
import 'package:frontend/presentation/widget/core/card/summary_stat_card.dart';
import 'package:frontend/presentation/widget/core/appbar/app_topbar.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/app_spacing.dart';
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
    final isDark = AppTheme.isDark(context);

    return BlocProvider.value(
      value: serviceLocator.get<RoomScheduleBloc>()..add(FetchRoomSchedules()),
      child: Scaffold(
        backgroundColor: isDark ? AppColorsDark.background : AppColorsLight.background,
        body: Column(
          children: [
            AppTopBar(
              title: 'Jadwal Kamar',
              breadcrumb: 'Kamar & Reservasi / Jadwal Kamar',
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: BlocBuilder<RoomScheduleBloc, RoomScheduleState>(
                  builder: (context, state) {
                    if (state is RoomScheduleLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is RoomScheduleError) {
                      return Center(
                        child: Text(
                          'Error: ${state.message}',
                          style: TextStyle(color: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled),
                        ),
                      );
                    }

                    if (state is RoomScheduleLoaded) {
                      final filteredRooms = _getFilteredRooms(state.schedules);
                      final gridData = _convertToGridData(filteredRooms);

                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.xxxl),
                              decoration: BoxDecoration(
                                color: isDark ? AppColorsDark.surface : AppColorsLight.surface,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                                border: Border.all(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Jadwal Kamar - ${DateFormat('MMMM yyyy').format(_currentMonth)}',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      _MonthNavigator(
                                        currentMonth: _currentMonth,
                                        onChanged: (newMonth) {
                                          setState(() {
                                            _currentMonth = newMonth;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xxxl),

                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                // Dropdown Filter Kamar
                                                Container(
                                                  height: 40,
                                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                                    border: Border.all(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight),
                                                  ),
                                                  child: DropdownButtonHideUnderline(
                                                    child: DropdownButton<String>(
                                                      value: _selectedRoom,
                                                      items: [
                                                        'Semua Kamar',
                                                        ...state.schedules.map((e) => e.number),
                                                      ].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
                                                      onChanged: (v) => setState(() => _selectedRoom = v),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: AppSpacing.lg),
                                                // Dropdown Filter Status
                                                Container(
                                                  height: 40,
                                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                                    border: Border.all(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight),
                                                  ),
                                                  child: DropdownButtonHideUnderline(
                                                    child: DropdownButton<String>(
                                                      value: _selectedStatus,
                                                      items: [
                                                        'Semua Status',
                                                        'Menunggu',
                                                        'Aktif',
                                                        'Selesai',
                                                      ].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
                                                      onChanged: (v) => setState(() => _selectedStatus = v),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: AppSpacing.xxxl),
                                            _StatusLegend(),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xxxl),
                                      SizedBox(
                                        width: 250,
                                        child: SummaryStatCard(
                                          label: 'Total Sewa Aktif',
                                          value: _calculateTotalBookings(filteredRooms).toString(),
                                          icon: Icons.calendar_month_outlined,
                                          iconColor: isDark ? AppColorsDark.primary : AppColorsLight.primary,
                                          iconBg: isDark ? AppColorsDark.primaryLight : AppColorsLight.primaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xxxl),
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
          ],
        ),
      ),
    );
  }

  List<RoomScheduleEntity> _getFilteredRooms(List<RoomScheduleEntity> rooms) {
    return rooms.where((room) {
      if (_selectedRoom != 'Semua Kamar' && room.number != _selectedRoom) {
        return false;
      }
      if (_selectedStatus != 'Semua Status') {
        final hasMatchingStatus = room.schedules.any((schedule) {
          final status = schedule.status.toLowerCase();
          switch (_selectedStatus) {
            case 'Menunggu':
              return status == 'pending' || status == 'dp_terbayar' || status == 'terkonfirmasi';
            case 'Aktif':
              return status == 'active';
            case 'Selesai':
              return status == 'finished';
            default:
              return true;
          }
        });
        if (!hasMatchingStatus) {
          return false;
        }
      }
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

          if ((date.isAfter(start) || date.isAtSameMomentAs(start)) &&
              (date.isBefore(end) || date.isAtSameMomentAs(end))) {
            RoomDayStatus status;
            switch (lease.status.toLowerCase()) {
              case 'pending':
              case 'dp_terbayar':
              case 'terkonfirmasi':
                status = RoomDayStatus.pending;
                break;
              case 'active':
                status = RoomDayStatus.ongoing;
                break;
              case 'finished':
                status = RoomDayStatus.completed;
                break;
              default:
                status = RoomDayStatus.available;
            }
            if (status != RoomDayStatus.available) {
              dailyStatus[day] = status;
              break;
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
      total += room.schedules.where((schedule) {
        final status = schedule.status.toLowerCase();
        return status == 'pending' || status == 'dp_terbayar' || status == 'terkonfirmasi' || status == 'active';
      }).length;
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
    final isDark = AppTheme.isDark(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight),
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
          Container(
            width: 1,
            height: 24,
            color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              DateFormat('MMMM yyyy').format(currentMonth),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight,
          ),
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

class _StatusLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendItem(
            color: isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg,
            borderColor: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting,
            label: 'Menunggu'
          ),
          const SizedBox(width: 32),
          _LegendItem(
            color: isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg,
            borderColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
            label: 'Aktif'
          ),
          const SizedBox(width: 32),
          _LegendItem(
            color: isDark ? AppColorsDark.statusProcessBg : AppColorsLight.statusProcessBg,
            borderColor: isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess,
            label: 'Selesai'
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String label;

  const _LegendItem({required this.color, required this.borderColor, required this.label});

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
              color: borderColor,
              width: 1,
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
