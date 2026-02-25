import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/domain/entity/maintenance_entity.dart';
import 'package:frontend/domain/entity/table/tabel_colum.dart';
import 'package:frontend/presentation/widget/core/table/table.dart';

@RoutePage()
class MaintanancePage extends StatelessWidget {
  const MaintanancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaintananceView();
  }
}

class MaintananceView extends StatefulWidget {
  const MaintananceView({super.key});

  @override
  State<MaintananceView> createState() => _MaintananceViewState();
}

class _MaintananceViewState extends State<MaintananceView> {
  // ─── Filter state ───
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedWeek;

  final List<MaintenanceEntity> _data = [
    MaintenanceEntity(
      namaTeknisi: 'Ahmad saroni',
      ruangan: 'Lorong lt 2',
      tipe: MaintenanceType.pembersihan,
      subtipe: MaintenanceSubtype.rutin,
      waktuMulai: DateTime(2026, 2, 23, 12, 0),
      waktuSelesai: null,
      status: MaintenanceStatus.inProgress,
    ),
    MaintenanceEntity(
      namaTeknisi: 'Ahmad saroni',
      ruangan: 'Dapur',
      tipe: MaintenanceType.pembersihan,
      subtipe: MaintenanceSubtype.deepCleaning,
      waktuMulai: DateTime(2026, 2, 24, 13, 0),
      waktuSelesai: DateTime(2026, 2, 25, 10, 0),
      status: MaintenanceStatus.done,
    ),
    MaintenanceEntity(
      namaTeknisi: 'Ahmad saroni',
      ruangan: 'Rooftop',
      tipe: MaintenanceType.pembersihan,
      subtipe: MaintenanceSubtype.darurat,
      waktuMulai: DateTime(2026, 2, 22, 13, 0),
      waktuSelesai: DateTime(2026, 2, 22, 16, 0),
      status: MaintenanceStatus.done,
    ),
    MaintenanceEntity(
      namaTeknisi: 'Ahmad saroni',
      ruangan: 'Kamar mandi Lt 2',
      tipe: MaintenanceType.perawatan,
      subtipe: MaintenanceSubtype.perbaikan,
      waktuMulai: DateTime(2026, 2, 24, 8, 0),
      waktuSelesai: DateTime(2026, 2, 24, 11, 0),
      status: MaintenanceStatus.done,
    ),
    MaintenanceEntity(
      namaTeknisi: 'Ahmad saroni',
      ruangan: 'kamar A301',
      tipe: MaintenanceType.perawatan,
      subtipe: MaintenanceSubtype.maintenance,
      waktuMulai: DateTime(2026, 2, 25, 9, 0),
      waktuSelesai: DateTime(2026, 2, 25, 12, 0),
      status: MaintenanceStatus.done,
    ),
  ];

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
    _selectedWeek = MaintenanceEntity.weekOfMonth(now);
  }

  /// Filter data berdasarkan tahun, bulan, dan minggu
  List<MaintenanceEntity> get _filteredData {
    return _data.where((item) {
      final dt = item.waktuMulai;
      return dt.year == _selectedYear &&
          dt.month == _selectedMonth &&
          MaintenanceEntity.weekOfMonth(dt) == _selectedWeek;
    }).toList();
  }

  /// Jumlah minggu dalam bulan yang dipilih
  int get _weeksInMonth {
    final lastDay = DateTime(_selectedYear, _selectedMonth + 1, 0);
    return MaintenanceEntity.weekOfMonth(lastDay);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredData;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: SingleChildScrollView(
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
                rows: filtered.map((item) {
                  return [
                    item.namaTeknisi,
                    item.ruangan,
                    item.tipe.displayName,
                    item.subtipe.displayName,
                    MaintenanceEntity.formatDateTime(item.waktuMulai),
                    MaintenanceEntity.formatDateTime(item.waktuSelesai),
                    Text(
                      item.status.displayName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: item.status.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () {
                          context.router.push(
                            MaintananceFormRoute(maintenanceData: item),
                          );
                        },
                        icon: const Icon(Icons.chevron_right),
                        tooltip: 'Lihat detail',
                      ),
                    ),
                  ];
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _columns = [
    TableColumn(label: 'Nama Teknisi', flex: 2),
    TableColumn(label: 'Ruangan', flex: 2),
    TableColumn(label: 'Tipe'),
    TableColumn(label: 'Subtipe'),
    TableColumn(label: 'Waktu Mulai', flex: 2),
    TableColumn(label: 'Waktu Selesai', flex: 2),
    TableColumn(label: 'Status'),
    TableColumn(label: 'Lihat Detail', flex: 1),
  ];

  Widget _buildFilters(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Year filter
        _FilterDropdown<int>(
          value: _selectedYear,
          items: List.generate(5, (i) => DateTime.now().year - 2 + i),
          labelBuilder: (v) => v.toString(),
          onChanged: (v) => setState(() {
            _selectedYear = v!;
            if (_selectedWeek > _weeksInMonth) _selectedWeek = 1;
          }),
        ),
        // Month filter
        _FilterDropdown<int>(
          value: _selectedMonth,
          items: List.generate(12, (i) => i + 1),
          labelBuilder: (v) => _monthNames[v - 1],
          onChanged: (v) => setState(() {
            _selectedMonth = v!;
            if (_selectedWeek > _weeksInMonth) _selectedWeek = 1;
          }),
        ),
        // Week filter
        _FilterDropdown<int>(
          value: _selectedWeek,
          items: List.generate(_weeksInMonth, (i) => i + 1),
          labelBuilder: (v) => 'Minggu $v',
          onChanged: (v) => setState(() => _selectedWeek = v!),
        ),
        // Add button
        ElevatedButton.icon(
          onPressed: () async {
            final result = await context.router.push(MaintananceFormRoute());
            if (result is MaintenanceEntity) {
              setState(() => _data.add(result));
            }
          },
          icon: const Icon(Icons.calendar_month, size: 18),
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
