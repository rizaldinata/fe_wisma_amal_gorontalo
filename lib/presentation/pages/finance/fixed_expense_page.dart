import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../domain/entity/finance/fixed_expense_entry_entity.dart';
import '../../bloc/fixed_expense/fixed_expense_bloc.dart';
import '../../bloc/fixed_expense/fixed_expense_event.dart';
import '../../bloc/fixed_expense/fixed_expense_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../widget/core/card/summary_stat_card.dart';
import '../../widget/core/appbar/search_and_filter_bar.dart';
import '../../widget/core/table/app_data_table.dart';
import '../../widget/core/wrapper/empty_state_widget.dart';

// ── Config visual per jenis (untuk icon & warna di dialog + tabel) ────────────
const _kJenisConfig = {
  'listrik': _JenisConfig(
    icon: Icons.bolt_rounded,
    label: 'Listrik',
    color: Color(0xFFD97706),
    colorLight: Color(0xFFFFFBEB),
    gradient: [Color(0xFFD97706), Color(0xFFF59E0B)],
  ),
  'air': _JenisConfig(
    icon: Icons.water_drop_rounded,
    label: 'Air',
    color: Color(0xFF2563EB),
    colorLight: Color(0xFFEFF6FF),
    gradient: [Color(0xFF2563EB), Color(0xFF3B82F6)],
  ),
  'wifi': _JenisConfig(
    icon: Icons.wifi_rounded,
    label: 'WiFi',
    color: Color(0xFF7C3AED),
    colorLight: Color(0xFFF5F3FF),
    gradient: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
  ),
};

class _JenisConfig {
  final IconData icon;
  final String label;
  final Color color;
  final Color colorLight;
  final List<Color> gradient;
  const _JenisConfig({
    required this.icon,
    required this.label,
    required this.color,
    required this.colorLight,
    required this.gradient,
  });
}

// ── Main Widget ───────────────────────────────────────────────────────────────
class FixedExpenseTabContent extends StatefulWidget {
  const FixedExpenseTabContent({super.key});

  @override
  State<FixedExpenseTabContent> createState() => _FixedExpenseTabContentState();
}

class _FixedExpenseTabContentState extends State<FixedExpenseTabContent> {
  late FixedExpenseBloc _bloc;
  int? _filterBulan;
  int? _filterTahun;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _bloc = serviceLocator.get<FixedExpenseBloc>();
    _bloc.add(FetchFixedExpenses());
  }

  String _fmt(double v) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(v);

  String _bulanLabel(int b) => DateFormat('MMMM', 'id_ID').format(DateTime(0, b));

  void _applyFilter() =>
      _bloc.add(FetchFixedExpenses(bulan: _filterBulan, tahun: _filterTahun));

  List<FixedExpenseEntryEntity> _filtered(List<FixedExpenseEntryEntity> entries) {
    if (_searchQuery.isEmpty) return entries;
    final q = _searchQuery.toLowerCase();
    return entries.where((e) {
      final label = (_kJenisConfig[e.jenis]?.label ?? e.jenisLabel).toLowerCase();
      return label.contains(q) || e.jenis.contains(q);
    }).toList();
  }

  void _showFillDialog(FixedExpenseEntryEntity entry) {
    final isDark = AppTheme.isDark(context);
    final cfg = _kJenisConfig[entry.jenis];
    final amountCtrl = TextEditingController(
      text: entry.isFilled ? entry.amount.toStringAsFixed(0) : '',
    );
    final notesCtrl = TextEditingController(text: entry.notes ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? AppColorsDark.surface : AppColorsLight.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
        child: SizedBox(
          width: 420,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColorsDark.surfaceVariant
                    : (cfg?.colorLight ?? AppColorsLight.surfaceVariant),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusXl)),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight,
                  ),
                ),
              ),
              child: Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: cfg != null
                        ? LinearGradient(colors: cfg.gradient)
                        : LinearGradient(colors: [
                            isDark ? AppColorsDark.primary : AppColorsLight.primary,
                            isDark ? AppColorsDark.primaryDark : AppColorsLight.primaryDark,
                          ]),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: (cfg?.color ??
                                (isDark ? AppColorsDark.primary : AppColorsLight.primary))
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(cfg?.icon ?? Icons.receipt_long_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.isFilled ? 'Ubah Pengeluaran' : 'Isi Nominal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColorsDark.textPrimary
                                : AppColorsLight.textPrimary,
                          ),
                        ),
                        Text(
                          '${cfg?.label ?? entry.jenisLabel} — ${_bulanLabel(entry.bulan)} ${entry.tahun}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColorsDark.textSecondary
                                : AppColorsLight.textSecondary,
                          ),
                        ),
                      ]),
                ),
              ]),
            ),

            // Form
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, AppSpacing.sm),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Nominal (Rp)', isDark),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: isDark
                            ? AppColorsDark.textPrimary
                            : AppColorsLight.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        prefixIcon: Icon(
                          Icons.payments_outlined,
                          size: 18,
                          color: cfg?.color ??
                              (isDark ? AppColorsDark.primary : AppColorsLight.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _FieldLabel('Catatan (opsional)', isDark),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: notesCtrl,
                      maxLines: 2,
                      style: TextStyle(
                        color: isDark
                            ? AppColorsDark.textPrimary
                            : AppColorsLight.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Misal: Tagihan PLN bulan Juni...',
                        prefixIcon: Icon(Icons.notes_outlined, size: 18),
                      ),
                    ),
                  ]),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl, AppSpacing.sm, AppSpacing.xxl, AppSpacing.xl),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: AppSpacing.md),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountCtrl.text
                            .replaceAll('.', '')
                            .replaceAll(',', '')) ??
                        0;
                    if (amount <= 0) return;
                    _bloc.add(UpdateFixedExpense(
                      id: entry.id,
                      amount: amount,
                      notes: notesCtrl.text.trim().isEmpty
                          ? null
                          : notesCtrl.text.trim(),
                    ));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Simpan'),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildSkeleton(bool isDark) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Column(children: [
      Row(
        children: List.generate(3, (i) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? AppSpacing.lg : 0),
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
            ),
          ),
        )),
      ),
      const SizedBox(height: AppSpacing.xxxl),
      Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final now = DateTime.now();

    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<FixedExpenseBloc, FixedExpenseState>(
        listener: (ctx, state) {
          if (state is FixedExpenseOperationSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Row(children: [
                Icon(Icons.check_circle_rounded,
                    color: isDark
                        ? AppColorsDark.statusDone
                        : AppColorsLight.statusDone,
                    size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(state.message),
              ]),
              backgroundColor:
                  isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
              margin: const EdgeInsets.all(AppSpacing.lg),
            ));
            _bloc.add(FetchFixedExpenses(bulan: _filterBulan, tahun: _filterTahun));
          } else if (state is FixedExpenseError) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Row(children: [
                Icon(Icons.error_outline,
                    color: isDark
                        ? AppColorsDark.statusCancelled
                        : AppColorsLight.statusCancelled,
                    size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(state.message),
              ]),
              backgroundColor: isDark
                  ? AppColorsDark.statusCancelledBg
                  : AppColorsLight.statusCancelledBg,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
              margin: const EdgeInsets.all(AppSpacing.lg),
            ));
          }
        },
        builder: (ctx, state) {
          final isLoading = state is FixedExpenseLoading;
          final entries =
              state is FixedExpenseLoaded ? state.entries : <FixedExpenseEntryEntity>[];
          final status = state is FixedExpenseLoaded ? state.status : null;
          final filtered = _filtered(entries);
          final detailEntries = status?.detail.entries.toList() ?? [];

          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Status Summary Cards ─────────────────────────────────────
            if (status != null) ...[
              Row(
                children: List.generate(detailEntries.length, (i) {
                  final kv = detailEntries[i];
                  final jenis = kv.key;
                  final s = kv.value;
                  final cfg = _kJenisConfig[jenis];
                  if (cfg == null) return const Expanded(child: SizedBox.shrink());

                  final entry = s.entryId != null
                      ? entries.where((e) => e.id == s.entryId).firstOrNull
                      : null;
                  final isFilled = s.filled;
                  final iconColor = isFilled
                      ? (isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone)
                      : cfg.color;
                  final iconBg = isFilled
                      ? (isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg)
                      : cfg.colorLight;
                  final trend = isFilled
                      ? '✓ Sudah diisi'
                      : (entry != null ? 'Tap untuk isi nominal' : '—');
                  final trendColor = isFilled
                      ? (isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone)
                      : (isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting);

                  return Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.only(right: i < detailEntries.length - 1 ? AppSpacing.lg : 0),
                      child: GestureDetector(
                        onTap: entry != null ? () => _showFillDialog(entry) : null,
                        child: SummaryStatCard(
                          label: cfg.label,
                          value: isFilled ? _fmt(s.amount ?? 0) : 'Belum Diisi',
                          icon: cfg.icon,
                          iconColor: iconColor,
                          iconBg: iconBg,
                          trend: trend,
                          trendColor: trendColor,
                        ),
                      ),
                    ),
                  );
                }),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms),
              const SizedBox(height: AppSpacing.xxxl),
            ],

            // ── Filter & Search ──────────────────────────────────────────
            SearchAndFilterBar(
              searchHint: 'Cari jenis pengeluaran...',
              onSearchChanged: (v) => setState(() => _searchQuery = v),
              dropdownFilter: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DropdownChip<int?>(
                    value: _filterBulan,
                    hint: 'Semua Bulan',
                    isDark: isDark,
                    items: [
                      const DropdownMenuItem<int?>(
                          value: null, child: Text('Semua Bulan')),
                      ...List.generate(12, (i) => DropdownMenuItem<int?>(
                            value: i + 1,
                            child: Text(_bulanLabel(i + 1)),
                          )),
                    ],
                    onChanged: (v) =>
                        setState(() { _filterBulan = v; _applyFilter(); }),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _DropdownChip<int?>(
                    value: _filterTahun,
                    hint: 'Semua Tahun',
                    isDark: isDark,
                    items: [
                      const DropdownMenuItem<int?>(
                          value: null, child: Text('Semua Tahun')),
                      ...List.generate(5, (i) {
                        final y = now.year - 1 + i;
                        return DropdownMenuItem<int?>(
                            value: y, child: Text('$y'));
                      }),
                    ],
                    onChanged: (v) =>
                        setState(() { _filterTahun = v; _applyFilter(); }),
                  ),
                  if (_filterBulan != null || _filterTahun != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: () => setState(() {
                        _filterBulan = null;
                        _filterTahun = null;
                        _applyFilter();
                      }),
                      icon: const Icon(Icons.close, size: 14),
                      label: const Text('Reset',
                          style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
            const SizedBox(height: AppSpacing.lg),

            // ── Content ──────────────────────────────────────────────────
            if (isLoading)
              _buildSkeleton(isDark)
            else if (filtered.isEmpty)
              EmptyStateWidget(
                icon: Icons.receipt_long_outlined,
                title: 'Belum ada data pengeluaran tetap',
                subtitle: _searchQuery.isNotEmpty
                    ? 'Tidak ada hasil untuk "$_searchQuery".'
                    : 'Data akan muncul setelah entri bulan ini dibuat oleh sistem.',
              ).animate().fadeIn()
            else
              AppDataTable(
                columns: const [
                  DataColumn(label: Text('Jenis')),
                  DataColumn(label: Text('Periode')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Nominal')),
                  DataColumn(label: Text('')),
                ],
                rows: filtered.map((entry) {
                  final cfg = _kJenisConfig[entry.jenis];
                  final isDone = entry.isFilled;

                  return DataRow(cells: [
                    // Jenis
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            gradient: isDone && cfg != null
                                ? LinearGradient(colors: cfg.gradient)
                                : null,
                            color: isDone
                                ? null
                                : (isDark
                                    ? AppColorsDark.surfaceVariant
                                    : AppColorsLight.surfaceVariant),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          child: Icon(
                            cfg?.icon ?? Icons.receipt_long_rounded,
                            size: 16,
                            color: isDone
                                ? Colors.white
                                : (isDark
                                    ? AppColorsDark.textHint
                                    : AppColorsLight.textHint),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          cfg?.label ?? entry.jenisLabel,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ],
                    )),

                    // Periode
                    DataCell(Text(
                      '${_bulanLabel(entry.bulan)} ${entry.tahun}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColorsDark.textSecondary
                            : AppColorsLight.textSecondary,
                      ),
                    )),

                    // Status
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: isDone
                            ? (isDark
                                ? AppColorsDark.statusDoneBg
                                : AppColorsLight.statusDoneBg)
                            : (isDark
                                ? AppColorsDark.statusWaitingBg
                                : AppColorsLight.statusWaitingBg),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        border: Border.all(
                          color: isDone
                              ? (isDark
                                  ? AppColorsDark.statusDoneBorder
                                  : AppColorsLight.statusDoneBorder)
                              : (isDark
                                  ? AppColorsDark.statusWaitingBorder
                                  : AppColorsLight.statusWaitingBorder),
                        ),
                      ),
                      child: Text(
                        isDone ? 'Sudah Diisi' : 'Belum Diisi',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDone
                              ? (isDark
                                  ? AppColorsDark.statusDone
                                  : AppColorsLight.statusDone)
                              : (isDark
                                  ? AppColorsDark.statusWaiting
                                  : AppColorsLight.statusWaiting),
                        ),
                      ),
                    )),

                    // Nominal
                    DataCell(Text(
                      isDone ? _fmt(entry.amount) : '—',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDone
                            ? (isDark
                                ? AppColorsDark.textPrimary
                                : AppColorsLight.textPrimary)
                            : (isDark
                                ? AppColorsDark.textHint
                                : AppColorsLight.textHint),
                      ),
                    )),

                    // Aksi
                    DataCell(IconButton(
                      icon: Icon(
                        isDone ? Icons.edit_outlined : Icons.add_rounded,
                        size: 18,
                        color: isDone
                            ? (isDark
                                ? AppColorsDark.textSecondary
                                : AppColorsLight.textSecondary)
                            : (cfg?.color ??
                                (isDark
                                    ? AppColorsDark.primary
                                    : AppColorsLight.primary)),
                      ),
                      tooltip: isDone ? 'Ubah nominal' : 'Isi nominal',
                      onPressed: () => _showFillDialog(entry),
                    )),
                  ]);
                }).toList(),
              ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

            const SizedBox(height: AppSpacing.xxxl),
          ]);
        },
      ),
    );
  }
}

// ── Dropdown Chip helper ──────────────────────────────────────────────────────
class _DropdownChip<T> extends StatelessWidget {
  final T value;
  final String hint;
  final bool isDark;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const _DropdownChip({
    required this.value,
    required this.hint,
    required this.isDark,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor:
              isDark ? AppColorsDark.surface : AppColorsLight.surface,
          hint: Text(
            hint,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColorsDark.textHint : AppColorsLight.textHint,
            ),
          ),
          items: items,
          onChanged: onChanged,
          isDense: true,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Field label helper ────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _FieldLabel(this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
        letterSpacing: 0.2,
      ),
    );
  }
}
