import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/constant/permission_key.dart';
import 'package:frontend/main.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/domain/entity/schedule_entity.dart';
import 'package:frontend/presentation/bloc/schedule/schedule_action_bloc.dart';
import 'package:frontend/presentation/bloc/schedule/schedule_action_event.dart';
import 'package:frontend/presentation/bloc/schedule/schedule_action_state.dart';
import 'package:frontend/presentation/bloc/schedule/schedule_list_bloc.dart';
import 'package:frontend/presentation/bloc/schedule/schedule_list_event.dart';
import 'package:frontend/presentation/bloc/schedule/schedule_list_state.dart';
import 'package:frontend/presentation/widget/core/appbar/app_topbar.dart';
import 'package:frontend/presentation/widget/core/chip/status_badge.dart';
import 'package:frontend/presentation/widget/core/table/app_data_table.dart';
import 'package:frontend/presentation/widget/core/wrapper/empty_state_widget.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';

@RoutePage()
class MaintanancePage extends StatelessWidget {
  const MaintanancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: serviceLocator<ScheduleListBloc>()..add(FetchSchedules()),
        ),
        BlocProvider.value(
          value: serviceLocator<ScheduleActionBloc>(),
        ),
      ],
      child: const _MaintananceView(),
    );
  }
}

class _MaintananceView extends StatefulWidget {
  const _MaintananceView();

  @override
  State<_MaintananceView> createState() => _MaintananceViewState();
}

enum _ViewMode { calendar, list }

class _MaintananceViewState extends State<_MaintananceView> {
  _ViewMode _currentView = _ViewMode.calendar;
  
  // Calendar State
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _confirmDelete(BuildContext context, int id) {
    final isDark = AppTheme.isDark(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: const Text('Apakah Anda yakin ingin menghapus jadwal ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ScheduleActionBloc>().add(DeleteSchedule(id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'done': return 'Selesai';
      case 'in_progress': return 'Dalam Proses';
      case 'cancelled': return 'Dibatalkan';
      default: return 'Terjadwal';
    }
  }


  String _fmtDt(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return BlocListener<ScheduleActionBloc, ScheduleActionState>(
      listener: (context, state) {
        if (state is ScheduleActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [
              Icon(Icons.check_circle, color: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone),
              const SizedBox(width: 8),
              Text(state.message, style: const TextStyle(color: Colors.white)),
            ]),
            backgroundColor: isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ));
          context.read<ScheduleListBloc>().add(FetchSchedules());
        } else if (state is ScheduleActionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [
              Icon(Icons.error, color: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled),
              const SizedBox(width: 8),
              Text(state.message, style: const TextStyle(color: Colors.white)),
            ]),
            backgroundColor: isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ));
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColorsDark.background : AppColorsLight.background,
        body: Column(
          children: [
            AppTopBar(
            title: 'Jadwal Pemeliharaan',
            breadcrumb: 'Operasional / Jadwal Pemeliharaan',
            action: context.can(PermissionKeys.createMaintenance) ? ElevatedButton.icon(
              onPressed: () async {
                final result = await context.router.push(MaintananceFormRoute());
                if (result == true && context.mounted) {
                  context.read<ScheduleListBloc>().add(FetchSchedules());
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah Jadwal'),
            ) : const SizedBox.shrink(),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl, vertical: AppSpacing.lg),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: isDark ? AppColorsDark.surface : AppColorsLight.surface,
              border: Border(bottom: BorderSide(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight)),
            ),
            child: SegmentedButton<_ViewMode>(
              segments: const [
                ButtonSegment(value: _ViewMode.calendar, icon: Icon(Icons.calendar_month), label: Text('Kalender')),
                ButtonSegment(value: _ViewMode.list, icon: Icon(Icons.list), label: Text('List')),
              ],
              selected: {_currentView},
              onSelectionChanged: (set) => setState(() => _currentView = set.first),
              style: SegmentedButton.styleFrom(
                selectedForegroundColor: Colors.white,
                selectedBackgroundColor: isDark ? AppColorsDark.primary : AppColorsLight.primary,
              ),
            ),
          ),
          
          Expanded(
            child: BlocBuilder<ScheduleListBloc, ScheduleListState>(
              builder: (context, state) {
                if (state is ScheduleListLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ScheduleListError) {
                  return EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'Gagal Memuat Data',
                    subtitle: state.message,
                    action: ElevatedButton(
                      onPressed: () => context.read<ScheduleListBloc>().add(FetchSchedules()),
                      child: const Text('Coba Lagi'),
                    ),
                  );
                }

                if (state is ScheduleListLoaded) {
                  final allSchedules = state.schedules;
                  
                  if (_currentView == _ViewMode.calendar) {
                    return _buildCalendarView(allSchedules, isDark);
                  } else {
                    return _buildListView(allSchedules, isDark);
                  }
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildCalendarView(List<ScheduleEntity> schedules, bool isDark) {
    final selectedDaySchedules = schedules.where((s) => isSameDay(s.startTime, _selectedDay)).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: isDark ? AppColorsDark.surface : AppColorsLight.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight),
              ),
              child: TableCalendar<ScheduleEntity>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Bulan',
                  CalendarFormat.twoWeeks: '2 Minggu',
                  CalendarFormat.week: 'Minggu',
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() => _calendarFormat = format);
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: (day) {
                  return schedules.where((s) => isSameDay(s.startTime, day)).toList();
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: (isDark ? AppColorsDark.primary : AppColorsLight.primary).withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: isDark ? AppColorsDark.primary : AppColorsLight.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(width: 1, color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight),
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4, height: 16,
                      decoration: BoxDecoration(
                        color: isDark ? AppColorsDark.primary : AppColorsLight.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      _selectedDay != null ? DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDay!) : 'Pilih Tanggal',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                if (selectedDaySchedules.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.event_busy_outlined, size: 48, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
                          const SizedBox(height: AppSpacing.md),
                          Text('Tidak ada jadwal pada tanggal ini', style: TextStyle(color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary)),
                        ],
                      ),
                    ),
                  )
                else
                  ...selectedDaySchedules.map((s) => _buildScheduleCard(s, isDark)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(ScheduleEntity schedule, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.surface : AppColorsLight.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(status: _statusLabel(schedule.status)),
              Text(
                '${DateFormat('HH:mm').format(schedule.startTime)} - ${schedule.endTime != null ? DateFormat('HH:mm').format(schedule.endTime!) : '?'}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Icon(Icons.person_outline, size: 16, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Text(schedule.technicianName, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Text(schedule.location),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.build_circle_outlined, size: 16, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Text('${schedule.type} - ${schedule.subtype}'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () async {
                  await context.router.push(MaintananceDetailRoute(schedule: schedule));
                },
                child: const Text('Detail'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<ScheduleEntity> schedules, bool isDark) {
    if (schedules.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.calendar_today_outlined,
        title: 'Tidak ada jadwal',
        subtitle: 'Belum ada jadwal pemeliharaan yang ditambahkan.',
      );
    }

    // Sort by newest start time first
    final sortedSchedules = List<ScheduleEntity>.from(schedules)..sort((a, b) => b.startTime.compareTo(a.startTime));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: AppDataTable(
        columns: const [
          DataColumn(label: Text('TEKNISI')),
          DataColumn(label: Text('LOKASI')),
          DataColumn(label: Text('TIPE')),
          DataColumn(label: Text('STATUS')),
          DataColumn(label: Text('MULAI')),
          DataColumn(label: Text('SELESAI')),
          DataColumn(label: Text('')),
        ],
        rows: sortedSchedules.map((item) => DataRow(
          cells: [
            DataCell(Text(item.technicianName, style: const TextStyle(fontWeight: FontWeight.w600))),
            DataCell(Text(item.location)),
            DataCell(Text('${item.type} (${item.subtype})')),
            DataCell(StatusBadge(status: _statusLabel(item.status))),
            DataCell(Text(_fmtDt(item.startTime))),
            DataCell(Text(_fmtDt(item.endTime))),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () async {
                      final result = await context.router.push(MaintananceFormRoute(scheduleData: item));
                      if (result == true && context.mounted) {
                        context.read<ScheduleListBloc>().add(FetchSchedules());
                      }
                    },
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 18, color: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled),
                    onPressed: () => _confirmDelete(context, item.id!),
                    tooltip: 'Hapus',
                  ),
                ],
              ),
            ),
          ],
        )).toList(),
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}
