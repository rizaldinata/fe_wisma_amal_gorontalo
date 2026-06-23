import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasource/finance_datasource.dart';
import '../../../domain/entity/finance/invoice_entity.dart';
import '../../bloc/invoice/invoice_bloc.dart';
import '../../bloc/invoice/invoice_event.dart';
import '../../bloc/invoice/invoice_state.dart';
import '../../widget/core/appbar/app_topbar.dart';
import '../../widget/core/card/summary_stat_card.dart';
import '../../widget/core/chip/status_badge.dart';
import '../../widget/core/table/app_data_table.dart';
import '../../widget/core/wrapper/empty_state_widget.dart';

@RoutePage()
class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({super.key});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  late InvoiceBloc _bloc;

  String _searchQuery = '';
  String _statusFilter = 'Semua';
  String _typeFilter = 'Semua';
  int? _filterYear;
  int? _filterMonth;
  final TextEditingController _searchCtrl = TextEditingController();

  int _currentPage = 1;
  static const int _perPage = 10;

  static const _statusOptions = ['Semua', 'Belum Bayar', 'Lunas', 'Dibatalkan'];
  static const _typeOptions   = ['Semua', 'Sewa', 'DP', 'Pelunasan', 'Perpanjangan', 'Denda'];

  static final _currencyFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static final _dateFmt     = DateFormat('dd MMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _bloc = serviceLocator.get<InvoiceBloc>();
    _bloc.add(FetchInvoices());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── Formatters ──────────────────────────────────────────────────────────────

  String formatRupiah(double v) => _currencyFmt.format(v);
  String formatDate(DateTime d) => _dateFmt.format(d);

  String _formatPeriod(InvoiceEntity inv) {
    if (inv.periodStart == null && inv.periodEnd == null) {
      return inv.createdAt != null
          ? DateFormat('MMMM yyyy', 'id_ID').format(inv.createdAt!)
          : '-';
    }
    final start = inv.periodStart != null
        ? _dateFmt.format(DateTime.parse(inv.periodStart!))
        : '-';
    final end = inv.periodEnd != null
        ? _dateFmt.format(DateTime.parse(inv.periodEnd!))
        : '-';
    return '$start – $end';
  }

  // ─── Label / Color helpers ───────────────────────────────────────────────────

  String _statusLabel(String s) {
    switch (s.toLowerCase()) {
      case 'paid':      return 'Lunas';
      case 'unpaid':    return 'Belum Bayar';
      case 'cancelled': return 'Dibatalkan';
      default:          return s;
    }
  }

  String _typeLabel(String? t) {
    switch (t) {
      case 'sewa':      return 'Sewa';
      case 'dp':        return 'DP';
      case 'pelunasan': return 'Pelunasan';
      case 'extension': return 'Perpanjangan';
      case 'fine':      return 'Denda';
      default:          return 'Lainnya';
    }
  }

  Color _statusColor(String s, bool isDark) {
    switch (s.toLowerCase()) {
      case 'paid':      return isDark ? AppColorsDark.statusDone      : AppColorsLight.statusDone;
      case 'unpaid':    return isDark ? AppColorsDark.statusWaiting   : AppColorsLight.statusWaiting;
      case 'cancelled': return isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled;
      default:          return isDark ? AppColorsDark.statusProcess   : AppColorsLight.statusProcess;
    }
  }

  Color _statusBg(String s, bool isDark) {
    switch (s.toLowerCase()) {
      case 'paid':      return isDark ? AppColorsDark.statusDoneBg      : AppColorsLight.statusDoneBg;
      case 'unpaid':    return isDark ? AppColorsDark.statusWaitingBg   : AppColorsLight.statusWaitingBg;
      case 'cancelled': return isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg;
      default:          return isDark ? AppColorsDark.statusProcessBg   : AppColorsLight.statusProcessBg;
    }
  }

  IconData _statusIcon(String s) {
    switch (s.toLowerCase()) {
      case 'paid':      return Icons.check_circle_outline;
      case 'unpaid':    return Icons.schedule;
      case 'cancelled': return Icons.cancel_outlined;
      default:          return Icons.info_outline;
    }
  }

  bool _isOverdue(InvoiceEntity inv) =>
      inv.status.toLowerCase() == 'unpaid' && inv.dueDate.isBefore(DateTime.now());

  // ─── Filter helpers ──────────────────────────────────────────────────────────

  List<int> _availableYears(List<InvoiceEntity> all) {
    return all
        .map((i) => i.createdAt?.year)
        .whereType<int>()
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
  }

  List<InvoiceEntity> _filtered(List<InvoiceEntity> all) {
    return all.where((inv) {
      if (_filterYear  != null && inv.createdAt?.year  != _filterYear)  return false;
      if (_filterMonth != null && inv.createdAt?.month != _filterMonth) return false;
      if (_statusFilter != 'Semua' && _statusLabel(inv.status) != _statusFilter) return false;
      if (_typeFilter   != 'Semua' && _typeLabel(inv.type)     != _typeFilter)   return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!(inv.invoiceNumber.toLowerCase().contains(q) ||
              (inv.residentName?.toLowerCase().contains(q) ?? false) ||
              (inv.roomNumber?.toLowerCase().contains(q) ?? false))) { return false; }
      }
      return true;
    }).toList();
  }

  List<InvoiceEntity> _paged(List<InvoiceEntity> list) {
    final start = (_currentPage - 1) * _perPage;
    if (start >= list.length) return [];
    return list.sublist(start, (start + _perPage).clamp(0, list.length));
  }

  int _totalPages(int count) => (count / _perPage).ceil().clamp(1, 9999);

  // ─── Actions ─────────────────────────────────────────────────────────────────

  Future<void> _printPdf(int invoiceId) async {
    try {
      final ds = serviceLocator<FinanceRemoteDatasource>();
      final url = await ds.getInvoicePrintLink(invoiceId);
      if (url.isEmpty) throw Exception('URL kosong');
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
        throw Exception('Tidak dapat membuka browser');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka cetak: $e'), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  // ─── Dialogs ─────────────────────────────────────────────────────────────────

  void _showDetailDialog(InvoiceEntity inv, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _statusBg(inv.status, isDark),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_statusIcon(inv.status), color: _statusColor(inv.status, isDark), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Detail Tagihan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(inv.invoiceNumber, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.normal)),
          ])),
        ]),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 460,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(children: [
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Penghuni', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      Text(inv.residentName ?? '-', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      if (inv.roomNumber != null)
                        Text('Kamar ${inv.roomNumber}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('Nominal', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      Text(formatRupiah(inv.amount), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (inv.type != null) ...[
                        const SizedBox(height: 4),
                        _invoiceTypeBadge(inv.type),
                      ],
                    ]),
                  ]),
                  const Divider(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Periode', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      Text(_formatPeriod(inv), style: const TextStyle(fontSize: 12)),
                    ]),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('Jatuh Tempo', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      Text(
                        formatDate(inv.dueDate),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: _isOverdue(inv) ? FontWeight.w600 : FontWeight.normal,
                          color: _isOverdue(inv) ? Colors.red.shade600 : null,
                        ),
                      ),
                      if (_isOverdue(inv))
                        Text(
                          '${DateTime.now().difference(inv.dueDate).inDays} hari lalu',
                          style: TextStyle(fontSize: 10, color: Colors.red.shade400),
                        ),
                    ]),
                  ]),
                  const Divider(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Status', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      const SizedBox(height: 4),
                      StatusBadge(status: inv.status),
                    ]),
                    if (inv.createdAt != null)
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('Tanggal Dibuat', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        Text(formatDate(inv.createdAt!), style: const TextStyle(fontSize: 12)),
                      ]),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
          FilledButton.icon(
            icon: const Icon(Icons.print_outlined, size: 16),
            label: const Text('Cetak PDF'),
            style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () { Navigator.pop(ctx); _printPdf(inv.id); },
          ),
        ],
      ),
    );
  }

  // ─── Section title ────────────────────────────────────────────────────────────

  Widget _sectionTitle(String title, bool isDark) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 6, height: 22,
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.primary : AppColorsLight.primary,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 10),
      Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
    ],
  );

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  Widget _invoiceTypeBadge(String? type) {
    if (type == null) return const SizedBox.shrink();
    final (label, color) = switch (type) {
      'dp'        => ('DP', Colors.amber.shade700),
      'pelunasan' => ('Pelunasan', Colors.teal.shade700),
      'sewa'      => ('Sewa Penuh', Colors.indigo.shade600),
      'extension' => ('Perpanjangan', Colors.blue.shade700),
      'fine'      => ('Denda', Colors.red.shade700),
      _           => (type, Colors.grey.shade600),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _colPenghuni(InvoiceEntity inv, bool isDark) => Row(children: [
    Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: _statusBg(inv.status, isDark), borderRadius: BorderRadius.circular(10)),
      child: Icon(_statusIcon(inv.status), color: _statusColor(inv.status, isDark), size: 20),
    ),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        inv.residentName ?? 'Penghuni tidak diketahui',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
      Row(children: [
        if (inv.roomNumber != null) ...[
          Icon(Icons.meeting_room_outlined, size: 12, color: isDark ? AppColorsDark.textHint : AppColorsLight.textHint),
          const SizedBox(width: 3),
          Text('Kamar ${inv.roomNumber}', style: TextStyle(fontSize: 12, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary)),
          const SizedBox(width: 8),
        ],
        Icon(Icons.receipt_outlined, size: 12, color: isDark ? AppColorsDark.textHint : AppColorsLight.textHint),
        const SizedBox(width: 3),
        Text(inv.invoiceNumber, style: TextStyle(fontSize: 12, color: isDark ? AppColorsDark.textHint : AppColorsLight.textHint)),
        if (inv.type != null) ...[
          const SizedBox(width: 6),
          _invoiceTypeBadge(inv.type),
        ],
      ]),
      if (_isOverdue(inv))
        Text('Sudah Jatuh Tempo', style: TextStyle(fontSize: 11, color: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled, fontWeight: FontWeight.w600)),
    ])),
  ]);

  Widget _emptyTable(String message, bool isDark) => Container(
    padding: const EdgeInsets.all(AppSpacing.xxxl),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: isDark ? AppColorsDark.surface : AppColorsLight.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      border: Border.all(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight),
    ),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
    ),
  );

  Widget _chipGroupLabel(String text, bool isDark) => Text(
    text,
    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
  );

  Widget _buildPaginationRow({
    required int shown, required int total,
    required int currentPage, required int totalPages,
    required ValueChanged<int> onPageChanged, required bool isDark,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    child: Row(children: [
      Text(
        'Menampilkan $shown dari $total tagihan',
        style: TextStyle(fontSize: 13, color: isDark ? AppColorsDark.textHint : AppColorsLight.textHint),
      ),
      const Spacer(),
      _PaginationBar(currentPage: currentPage, totalPages: totalPages, onPageChanged: onPageChanged),
    ]),
  );

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final bgColor = isDark ? AppColorsDark.background : AppColorsLight.background;

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Column(children: [
          AppTopBar(
            title: 'Daftar Tagihan',
            breadcrumb: 'Keuangan / Tagihan',
            action: ElevatedButton.icon(
              onPressed: () => _bloc.add(FetchInvoices()),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
            ),
          ),
          Expanded(
            child: BlocBuilder<InvoiceBloc, InvoiceState>(
              builder: (context, state) {
                if (state is InvoiceLoading || state is InvoiceInitial) return _buildSkeleton(isDark);
                if (state is InvoiceError) {
                  return EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'Gagal Memuat Data',
                    subtitle: state.message,
                    action: ElevatedButton(onPressed: () => _bloc.add(FetchInvoices()), child: const Text('Coba Lagi')),
                  );
                }
                if (state is! InvoiceLoaded) return const SizedBox.shrink();

                final all      = state.invoices;
                final years    = _availableYears(all);
                final paid     = all.where((i) => i.status.toLowerCase() == 'paid').toList();
                final unpaid   = all.where((i) => i.status.toLowerCase() == 'unpaid').toList();
                final overdue  = all.where(_isOverdue).toList();

                final filtered   = _filtered(all);
                final totalPages = _totalPages(filtered.length);
                final page       = _currentPage.clamp(1, totalPages);
                final paged      = _paged(filtered);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xxxl),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    // ── Summary cards ──────────────────────────────────────────
                    IntrinsicHeight(
                      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Expanded(child: SummaryStatCard(
                          label: 'Total Tagihan',
                          value: '${all.length} Tagihan',
                          icon: Icons.receipt_long,
                          iconColor: isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess,
                          iconBg:    isDark ? AppColorsDark.statusProcessBg : AppColorsLight.statusProcessBg,
                          trend: 'Semua periode',
                        )),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(child: SummaryStatCard(
                          label: 'Sudah Lunas',
                          value: '${paid.length} Tagihan',
                          icon: Icons.check_circle_outline,
                          iconColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
                          iconBg:    isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg,
                          trend: formatRupiah(paid.fold(0.0, (s, i) => s + i.amount)),
                          trendColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
                        )),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(child: SummaryStatCard(
                          label: 'Belum Dibayar',
                          value: '${unpaid.length} Tagihan',
                          icon: Icons.schedule,
                          iconColor: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting,
                          iconBg:    isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg,
                          trend: formatRupiah(unpaid.fold(0.0, (s, i) => s + i.amount)),
                          trendColor: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting,
                        )),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(child: SummaryStatCard(
                          label: 'Sudah Jatuh Tempo',
                          value: '${overdue.length} Tagihan',
                          icon: Icons.warning_amber_rounded,
                          iconColor: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
                          iconBg:    isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg,
                          trend: 'Perlu tindak lanjut',
                          trendColor: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
                        )),
                      ]),
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms),
                    const SizedBox(height: AppSpacing.xxxl),

                    // ── Section title + date filter ────────────────────────────
                    Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      _sectionTitle('Data Tagihan', isDark),
                      const Spacer(),
                      _FilterDropdown<int?>(
                        hint: 'Tahun',
                        value: _filterYear,
                        items: [null, ...years],
                        labelBuilder: (v) => v == null ? 'Semua Tahun' : '$v',
                        onChanged: (v) => setState(() { _filterYear = v; _filterMonth = null; _currentPage = 1; }),
                        isDark: isDark,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _FilterDropdown<int?>(
                        hint: 'Bulan',
                        value: _filterMonth,
                        items: [null, ...List.generate(12, (i) => i + 1)],
                        labelBuilder: (v) => v == null ? 'Semua Bulan' : DateFormat('MMMM', 'id_ID').format(DateTime(0, v)),
                        onChanged: (v) => setState(() { _filterMonth = v; _currentPage = 1; }),
                        isDark: isDark,
                      ),
                      if (_filterYear != null || _filterMonth != null) ...[
                        const SizedBox(width: AppSpacing.xs),
                        IconButton(
                          onPressed: () => setState(() { _filterYear = null; _filterMonth = null; _currentPage = 1; }),
                          icon: const Icon(Icons.close_rounded, size: 16),
                          tooltip: 'Reset filter tanggal',
                          style: IconButton.styleFrom(foregroundColor: Colors.grey.shade500, visualDensity: VisualDensity.compact),
                        ),
                      ],
                    ]).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                    const SizedBox(height: AppSpacing.md),

                    // ── Search ────────────────────────────────────────────────
                    SizedBox(
                      height: 40,
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() { _searchQuery = v; _currentPage = 1; }),
                        decoration: InputDecoration(
                          hintText: 'Cari nomor tagihan, nama penghuni, atau kamar...',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ).animate().fadeIn(delay: 120.ms, duration: 300.ms),
                    const SizedBox(height: AppSpacing.sm),

                    // ── Filter chips ──────────────────────────────────────────
                    Wrap(
                      spacing: 0,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _chipGroupLabel('Status:', isDark),
                        const SizedBox(width: AppSpacing.sm),
                        ..._statusOptions.map((opt) => _FilterChip(
                          label: opt,
                          selected: _statusFilter == opt,
                          isDark: isDark,
                          onTap: () => setState(() { _statusFilter = opt; _currentPage = 1; }),
                        )),
                        const SizedBox(width: AppSpacing.lg),
                        _chipGroupLabel('Jenis:', isDark),
                        const SizedBox(width: AppSpacing.sm),
                        ..._typeOptions.map((opt) => _FilterChip(
                          label: opt,
                          selected: _typeFilter == opt,
                          isDark: isDark,
                          onTap: () => setState(() { _typeFilter = opt; _currentPage = 1; }),
                        )),
                      ],
                    ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Table ─────────────────────────────────────────────────
                    if (paged.isEmpty)
                      _emptyTable(
                        _searchQuery.isNotEmpty
                            ? 'Tidak ada hasil untuk "$_searchQuery".'
                            : 'Tidak ada tagihan pada kategori ini.',
                        isDark,
                      )
                    else
                      AppDataTable(
                        dataRowMinHeight: 64,
                        dataRowMaxHeight: double.infinity,
                        columns: const [
                          DataColumn(label: Text('Penghuni & Tagihan')),
                          DataColumn(label: Text('Periode')),
                          DataColumn(label: Text('Nominal'), numeric: true),
                          DataColumn(label: Text('Jatuh Tempo')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Aksi')),
                        ],
                        rows: paged.map((inv) {
                          final overdueSingle = _isOverdue(inv);
                          return DataRow(cells: [
                            DataCell(_colPenghuni(inv, isDark)),
                            DataCell(Text(
                              _formatPeriod(inv),
                              style: TextStyle(fontSize: 13, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
                            )),
                            DataCell(Text(formatRupiah(inv.amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                            DataCell(Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatDate(inv.dueDate),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: overdueSingle ? FontWeight.w600 : FontWeight.normal,
                                    color: overdueSingle
                                        ? (isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled)
                                        : (isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
                                  ),
                                ),
                                if (overdueSingle)
                                  Text(
                                    '${DateTime.now().difference(inv.dueDate).inDays} hari lalu',
                                    style: TextStyle(fontSize: 11, color: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled),
                                  ),
                              ],
                            )),
                            DataCell(StatusBadge(status: inv.status)),
                            DataCell(Row(children: [
                              OutlinedButton(
                                onPressed: () => _showDetailDialog(inv, isDark),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  side: BorderSide(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight),
                                  minimumSize: const Size(72, 36),
                                ),
                                child: const Text('Detail', style: TextStyle(fontSize: 12)),
                              ),
                              const SizedBox(width: 8),
                              Tooltip(
                                message: 'Cetak Nota PDF',
                                child: IconButton(
                                  icon: Icon(Icons.print_outlined, size: 18, color: isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess),
                                  splashRadius: 20,
                                  onPressed: () => _printPdf(inv.id),
                                ),
                              ),
                            ])),
                          ]);
                        }).toList(),
                      ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

                    const SizedBox(height: AppSpacing.sm),
                    _buildPaginationRow(
                      shown: paged.length, total: filtered.length,
                      currentPage: page, totalPages: totalPages,
                      onPageChanged: (p) => setState(() => _currentPage = p),
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  // ─── Skeleton ─────────────────────────────────────────────────────────────────

  Widget _buildSkeleton(bool isDark) {
    final base      = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlight = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    Widget shimmer({double height = 100}) => Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        height: height,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(children: [
        Row(children: List.generate(4, (i) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 3 ? AppSpacing.lg : 0),
            child: shimmer(),
          ),
        ))),
        const SizedBox(height: AppSpacing.xxxl),
        shimmer(height: 44),
        const SizedBox(height: AppSpacing.lg),
        shimmer(height: 36),
        const SizedBox(height: AppSpacing.lg),
        Expanded(child: shimmer(height: double.infinity)),
      ]),
    );
  }
}

// ─── Filter Dropdown ──────────────────────────────────────────────────────────

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    required this.isDark,
  });

  final String hint;
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final hintColor   = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: TextStyle(fontSize: 13, color: hintColor)),
          items: items.map((item) => DropdownMenuItem<T>(
            value: item,
            child: Text(labelBuilder(item), style: const TextStyle(fontSize: 13)),
          )).toList(),
          onChanged: (v) { if (v != null || null is T) onChanged(v as T); },
          icon: Icon(Icons.keyboard_arrow_down, size: 18, color: hintColor),
        ),
      ),
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? primary : (isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? primary : (isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? Colors.white : (isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Pagination Bar ───────────────────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({required this.currentPage, required this.totalPages, required this.onPageChanged});

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    int start = (currentPage - 2).clamp(1, totalPages);
    int end   = (start + 4).clamp(1, totalPages);
    start     = (end - 4).clamp(1, totalPages);
    final pages = List.generate(end - start + 1, (i) => start + i);

    return Row(mainAxisSize: MainAxisSize.min, children: [
      _nav(context, Icons.chevron_left, currentPage > 1, () => onPageChanged(currentPage - 1)),
      const SizedBox(width: 4),
      if (start > 1) ...[
        _btn(context, 1, false),
        if (start > 2) Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text('...', style: TextStyle(color: Colors.grey.shade500))),
      ],
      ...pages.map((p) => Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: _btn(context, p, p == currentPage))),
      if (end < totalPages) ...[
        if (end < totalPages - 1) Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text('...', style: TextStyle(color: Colors.grey.shade500))),
        _btn(context, totalPages, false),
      ],
      const SizedBox(width: 4),
      _nav(context, Icons.chevron_right, currentPage < totalPages, () => onPageChanged(currentPage + 1)),
    ]);
  }

  Widget _btn(BuildContext ctx, int page, bool active) => GestureDetector(
    onTap: () => onPageChanged(page),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 34, height: 34,
      decoration: BoxDecoration(
        color: active ? Theme.of(ctx).primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: active ? null : Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.center,
      child: Text('$page', style: TextStyle(fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? Colors.white : Colors.grey.shade700, fontSize: 13)),
    ),
  );

  Widget _nav(BuildContext ctx, IconData icon, bool enabled, VoidCallback onTap) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: Container(
      width: 34, height: 34,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
      alignment: Alignment.center,
      child: Icon(icon, size: 18, color: enabled ? Colors.grey.shade700 : Colors.grey.shade300),
    ),
  );
}
