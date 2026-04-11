import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/domain/entity/schedule_entity.dart';
import 'package:frontend/domain/entity/table/tabel_colum.dart';
import 'package:frontend/presentation/bloc/schedule/schedule_action_bloc.dart';
import 'package:frontend/presentation/bloc/schedule/schedule_action_event.dart';
import 'package:frontend/presentation/bloc/schedule/schedule_action_state.dart';
import 'package:frontend/presentation/bloc/schedule/schedule_list_bloc.dart';
import 'package:frontend/presentation/bloc/schedule/schedule_list_event.dart';
import 'package:frontend/presentation/bloc/schedule/schedule_list_state.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';
import 'package:frontend/presentation/widget/core/table/table.dart';
import 'package:intl/intl.dart';

@RoutePage()
class MaintanancePage extends StatelessWidget {
  const MaintanancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              serviceLocator<ScheduleListBloc>()..add(FetchSchedules()),
        ),
        BlocProvider(create: (_) => serviceLocator<ScheduleActionBloc>()),
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

class _MaintananceViewState extends State<_MaintananceView> {
  // ─── Filter state ───
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedWeek;

  static const _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _selectedWeek = _weekOfMonth(now);
  }

  static int _weekOfMonth(DateTime dt) {
    final firstDay = DateTime(dt.year, dt.month, 1);
    return ((dt.day + firstDay.weekday - 1) / 7).ceil();
  }

  int get _weeksInMonth {
    final lastDay = DateTime(_selectedYear, _selectedMonth + 1, 0);
    return _weekOfMonth(lastDay);
  }

  List<ScheduleEntity> _filter(List<ScheduleEntity> all) {
    return all.where((item) {
      final dt = item.startTime;
      return dt.year == _selectedYear &&
          dt.month == _selectedMonth &&
          _weekOfMonth(dt) == _selectedWeek;
    }).toList();
  }

  static String _fmtDt(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(dt);
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'done':
        return const Color(0xFF10B981);
      case 'in_progress':
        return const Color(0xFFF59E0B);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'done':
        return 'Selesai';
      case 'in_progress':
        return 'Dalam Proses';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  static String _typeLabel(String type) {
    switch (type) {
      case 'pembersihan':
        return 'Pembersihan';
      case 'perawatan':
        return 'Perawatan';
      default:
        return type;
    }
  }

  static String _subtypeLabel(String s) {
    switch (s) {
      case 'rutin':
        return 'Rutin';
      case 'deep_cleaning':
        return 'Deep Cleaning';
      case 'darurat':
        return 'Darurat';
      case 'perbaikan':
        return 'Perbaikan';
      case 'maintenance':
        return 'Maintenance';
      default:
        return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScheduleActionBloc, ScheduleActionState>(
      listener: (context, state) {
        if (state is ScheduleActionSuccess) {
          AppSnackbar.showSuccess(state.message);
          context.read<ScheduleListBloc>().add(FetchSchedules());
        } else if (state is ScheduleActionFailure) {
          AppSnackbar.showError(state.message);
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: BlocBuilder<ScheduleListBloc, ScheduleListState>(
            builder: (context, state) {
              if (state is ScheduleListLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ScheduleListError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 56,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => context.read<ScheduleListBloc>().add(
                          FetchSchedules(),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }

              final all = state is ScheduleListLoaded
                  ? state.schedules
                  : <ScheduleEntity>[];
              final filtered = _filter(all);

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perawatan & Pembersihan',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 24),
                    TableCard(
                      title: 'Jadwal Perawatan & Pembersihan',
                      emptyMessage: 'Tidak ada jadwal untuk minggu ini',
                      actions: _buildFilters(context),
                      columns: _columns,
                      onRowTap: (index) {
                        context.router.push(
                          MaintananceDetailRoute(schedule: filtered[index]),
                        );
                      },
                      rows: filtered.map((item) {
                        return [
                          item.technicianName,
                          item.location,
                          _typeLabel(item.type),
                          _subtypeLabel(item.subtype),
                          _fmtDt(item.startTime),
                          _fmtDt(item.endTime),
                          Text(
                            _statusLabel(item.status),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: _statusColor(item.status),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  final result = await context.router.push(
                                    MaintananceFormRoute(scheduleData: item),
                                  );
                                  if (result == true && context.mounted) {
                                    context.read<ScheduleListBloc>().add(
                                      FetchSchedules(),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                onPressed: () =>
                                    _confirmDelete(context, item.id!),
                                icon: Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                tooltip: 'Hapus',
                              ),
                            ],
                          ),
                        ];
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
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
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ScheduleActionBloc>().add(DeleteSchedule(id));
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  static const _columns = [
    TableColumn(label: 'Nama Teknisi', flex: 2),
    TableColumn(label: 'Lokasi', flex: 2),
    TableColumn(label: 'Tipe'),
    TableColumn(label: 'Subtipe'),
    TableColumn(label: 'Waktu Mulai', flex: 2),
    TableColumn(label: 'Waktu Selesai', flex: 2),
    TableColumn(label: 'Status'),
    TableColumn(label: 'Aksi', flex: 1),
  ];

  Widget _buildFilters(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _FilterDropdown<int>(
          value: _selectedYear,
          items: List.generate(5, (i) => DateTime.now().year - 2 + i),
          labelBuilder: (v) => v.toString(),
          onChanged: (v) => setState(() {
            _selectedYear = v!;
            if (_selectedWeek > _weeksInMonth) _selectedWeek = 1;
          }),
        ),
        _FilterDropdown<int>(
          value: _selectedMonth,
          items: List.generate(12, (i) => i + 1),
          labelBuilder: (v) => _monthNames[v - 1],
          onChanged: (v) => setState(() {
            _selectedMonth = v!;
            if (_selectedWeek > _weeksInMonth) _selectedWeek = 1;
          }),
        ),
        _FilterDropdown<int>(
          value: _selectedWeek,
          items: List.generate(_weeksInMonth, (i) => i + 1),
          labelBuilder: (v) => 'Minggu $v',
          onChanged: (v) => setState(() => _selectedWeek = v!),
        ),
        FilledButton.icon(
          onPressed: () async {
            final result = await context.router.push(MaintananceFormRoute());
            if (result == true && context.mounted) {
              context.read<ScheduleListBloc>().add(FetchSchedules());
            }
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Tambah Jadwal'),
        ),
      ],
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          style: theme.textTheme.bodyMedium,
          items: items
              .map(
                (e) => DropdownMenuItem(value: e, child: Text(labelBuilder(e))),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
