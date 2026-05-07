import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../bloc/finance_dashboard/finance_dashboard_bloc.dart';
import '../../bloc/finance_dashboard/finance_dashboard_event.dart';
import '../../bloc/finance_dashboard/finance_dashboard_state.dart';
import '../../widget/core/card/basic_card.dart';
import '../../../domain/entity/finance/invoice_entity.dart';
import '../../../domain/entity/finance/payment_entity.dart';
import '../../../domain/entity/finance/kpi_entity.dart';
import '../../../domain/entity/finance/revenue_entity.dart';
import '../../widget/core/table/table.dart';
import '../../../domain/entity/table/tabel_colum.dart';

// ─── Semantic colors ────────────────────────────────────────────────────────

const _kColorRevenue = Color(0xFF059669);
const _kColorExpense = Color(0xFFDC2626);
const _kColorWarning = Color(0xFFF59E0B);
const _kColorInfo = Color(0xFF3B82F6);
const _kColorMonthly = Color(0xFF8B5CF6);
const _kColorDaily = Color(0xFF14B8A6);

// ─── Page ───────────────────────────────────────────────────────────────────

@RoutePage()
class FinanceDashboardPage extends StatefulWidget {
  const FinanceDashboardPage({super.key});

  @override
  State<FinanceDashboardPage> createState() => _FinanceDashboardPageState();
}

class _FinanceDashboardPageState extends State<FinanceDashboardPage> {
  late final FinanceDashboardBloc _financeBloc;

  int? _selectedYear = DateTime.now().year;
  int? _selectedMonth = DateTime.now().month;

  // ─── Formatters ───────────────────────────────────────────────────────────

  static final _currencyFmt =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static final _dateFmt = DateFormat('d MMM yyyy', 'id_ID');

  String _formatRupiah(double amount) => _currencyFmt.format(amount);

  /// Returns compact form: 1.2jt, 500rb, 50rb, etc.
  String _compact(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}M';
    } else if (value >= 1000000) {
      final v = value / 1000000;
      return '${v % 1 == 0 ? v.toInt() : v.toStringAsFixed(1)}jt';
    } else if (value >= 1000) {
      final v = value / 1000;
      return '${v % 1 == 0 ? v.toInt() : v.toStringAsFixed(0)}rb';
    }
    return value.toInt().toString();
  }

  String get _periodLabel {
    if (_selectedYear != null && _selectedMonth != null) {
      return 'Bulan ${DateFormat('MMMM yyyy', 'id_ID').format(DateTime(_selectedYear!, _selectedMonth!))}';
    } else if (_selectedYear != null) {
      return 'Tahun $_selectedYear';
    }
    return 'Semua Periode';
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _financeBloc = serviceLocator.get<FinanceDashboardBloc>();
    _applyFilter();
  }

  void _applyFilter() {
    _financeBloc.add(FetchDashboardData(month: _selectedMonth, year: _selectedYear));
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _financeBloc,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard Keuangan',
                          style: theme.textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Periode: $_periodLabel',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Muat Ulang',
                    onPressed: _applyFilter,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Filter ──────────────────────────────────────────────────
              BasicCard(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  _DashboardFilterDropdown<int?>(
                    hint: 'Semua Tahun',
                    value: _selectedYear,
                    items: [null, ...List.generate(6, (i) => DateTime.now().year - i)],
                    labelBuilder: (v) => v == null ? 'Semua Tahun' : '$v',
                    onChanged: (v) { setState(() { _selectedYear = v; _selectedMonth = null; }); _applyFilter(); },
                  ),
                  const SizedBox(width: 8),
                  _DashboardFilterDropdown<int?>(
                    hint: 'Semua Bulan',
                    value: _selectedMonth,
                    items: [null, ...List.generate(12, (i) => i + 1)],
                    labelBuilder: (v) => v == null ? 'Semua Bulan' : DateFormat('MMMM', 'id_ID').format(DateTime(0, v)),
                    onChanged: (v) { setState(() => _selectedMonth = v); _applyFilter(); },
                  ),
                  if (_selectedYear != DateTime.now().year || _selectedMonth != DateTime.now().month) ...[
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () { setState(() { _selectedYear = DateTime.now().year; _selectedMonth = DateTime.now().month; }); _applyFilter(); },
                      icon: const Icon(Icons.close, size: 14),
                      label: const Text('Reset', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
                    ),
                  ],
                ]),
              ),
              const SizedBox(height: 28),

              // ── Body ────────────────────────────────────────────────────
              BlocBuilder<FinanceDashboardBloc, FinanceDashboardState>(
                builder: (context, state) {
                  if (state is FinanceDashboardLoading) {
                    return const _LoadingView();
                  }
                  if (state is FinanceDashboardError) {
                    return _ErrorView(
                      message: state.message,
                      onRetry: _applyFilter,
                    );
                  }
                  if (state is FinanceDashboardLoaded) {
                    return _DashboardContent(
                      kpi: state.kpiSummary,
                      revenueChart: state.revenueChart,
                      dueInvoices: state.dueInvoices,
                      pendingPayments: state.pendingPayments,
                      periodLabel: _periodLabel,
                      formatRupiah: _formatRupiah,
                      compact: _compact,
                      dateFmt: _dateFmt,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Filter dropdown (same style as other finance pages) ────────────────────

class _DashboardFilterDropdown<T> extends StatelessWidget {
  const _DashboardFilterDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  final String hint;
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          items: items.map((item) => DropdownMenuItem<T>(
            value: item,
            child: Text(labelBuilder(item), style: const TextStyle(fontSize: 13)),
          )).toList(),
          onChanged: (v) { if (v != null || null is T) onChanged(v as T); },
          icon: Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey.shade500),
        ),
      ),
    );
  }
}

// ─── Loading & Error views ───────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 300,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 340,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text('Gagal memuat data', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard content (Loaded state) ───────────────────────────────────────

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.kpi,
    required this.revenueChart,
    required this.dueInvoices,
    required this.pendingPayments,
    required this.periodLabel,
    required this.formatRupiah,
    required this.compact,
    required this.dateFmt,
  });

  final KpiEntity kpi;
  final List<RevenueEntity> revenueChart;
  final List<InvoiceEntity> dueInvoices;
  final List<PaymentEntity> pendingPayments;
  final String periodLabel;
  final String Function(double) formatRupiah;
  final String Function(double) compact;
  final DateFormat dateFmt;

  // ─── Section title helper ──────────────────────────────────────────────

  Widget _sectionTitle(BuildContext context, String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 22,
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isProfit = kpi.netProfit >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── KPI Section ───────────────────────────────────────────────────
        _sectionTitle(context, 'Ringkasan Keuangan'),
        const SizedBox(height: 16),
        _KpiGrid(
          kpi: kpi,
          isProfit: isProfit,
          formatRupiah: formatRupiah,
          periodLabel: periodLabel,
        ),
        const SizedBox(height: 32),

        // ── Revenue Chart ─────────────────────────────────────────────────
        _sectionTitle(context, 'Pendapatan 6 Bulan Terakhir'),
        const SizedBox(height: 16),
        _RevenueChart(chartData: revenueChart, compact: compact),
        const SizedBox(height: 32),

        // ── Due Invoices ──────────────────────────────────────────────────
        _sectionTitle(context, 'Tagihan Jatuh Tempo'),
        const SizedBox(height: 16),
        _DueInvoicesTable(invoices: dueInvoices, formatRupiah: formatRupiah, dateFmt: dateFmt),
        const SizedBox(height: 32),

        // ── Pending Payments ──────────────────────────────────────────────
        _sectionTitle(context, 'Pembayaran Perlu Konfirmasi'),
        const SizedBox(height: 16),
        _PendingPaymentsTable(payments: pendingPayments, formatRupiah: formatRupiah),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── KPI Grid (2 rows × 4 cards) ────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({
    required this.kpi,
    required this.isProfit,
    required this.formatRupiah,
    required this.periodLabel,
  });

  final KpiEntity kpi;
  final bool isProfit;
  final String Function(double) formatRupiah;
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    final netProfitColor = isProfit ? _kColorRevenue : _kColorExpense;

    return Column(
      children: [
        // Row 1
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon: Icons.account_balance_wallet_rounded,
                iconColor: _kColorRevenue,
                title: 'Total Pendapatan',
                tooltip: 'Jumlah seluruh uang masuk dari pembayaran sewa yang telah dikonfirmasi pada periode ini.',
                value: formatRupiah(kpi.totalRevenue),
                valueColor: _kColorRevenue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                icon: Icons.trending_down_rounded,
                iconColor: _kColorExpense,
                title: 'Total Pengeluaran',
                tooltip: 'Jumlah semua biaya operasional yang dikeluarkan wisma pada periode ini.',
                value: formatRupiah(kpi.totalExpense),
                valueColor: _kColorExpense,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                icon: isProfit
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                iconColor: netProfitColor,
                title: 'Laba Bersih',
                tooltip: 'Selisih antara total pendapatan dikurangi total pengeluaran. Positif berarti untung, negatif berarti rugi.',
                value: formatRupiah(kpi.netProfit),
                valueColor: netProfitColor,
                badge: isProfit ? null : 'Merugi',
                badgeColor: _kColorExpense,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                icon: Icons.money_off_rounded,
                iconColor: _kColorExpense,
                title: 'Tagihan Belum Bayar',
                tooltip: 'Total nilai tagihan yang sudah jatuh tempo namun belum dilunasi.',
                value: formatRupiah(kpi.dueInvoicesTotal),
                valueColor: _kColorExpense,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Row 2
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon: Icons.calendar_month_rounded,
                iconColor: _kColorMonthly,
                title: 'Sewa Bulanan',
                tooltip: 'Total pemasukan dari penghuni yang menggunakan kontrak sewa per bulan.',
                value: formatRupiah(kpi.revenueMonthlyRents),
                valueColor: _kColorMonthly,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                icon: Icons.today_rounded,
                iconColor: _kColorDaily,
                title: 'Sewa Harian',
                tooltip: 'Total pemasukan dari tamu yang menggunakan paket sewa harian.',
                value: formatRupiah(kpi.revenueDailyRents),
                valueColor: _kColorDaily,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                icon: Icons.receipt_long_rounded,
                iconColor: _kColorWarning,
                title: 'Jatuh Tempo',
                tooltip: 'Jumlah tagihan yang sudah melewati tanggal jatuh tempo dan belum dibayar.',
                value: '${kpi.dueInvoicesCount} Tagihan',
                valueColor: _kColorWarning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                icon: Icons.hourglass_top_rounded,
                iconColor: _kColorInfo,
                title: 'Perlu Konfirmasi',
                tooltip: 'Transaksi transfer bank yang sudah diunggah penghuni dan menunggu verifikasi dari admin.',
                value: '${kpi.pendingPaymentsCount} Transaksi',
                valueColor: _kColorInfo,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Single KPI Card ─────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.tooltip,
    required this.value,
    required this.valueColor,
    this.badge,
    this.badgeColor,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String tooltip;
  final String value;
  final Color valueColor;
  final String? badge;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BasicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon bubble
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Spacer(),
              Tooltip(
                message: tooltip,
                preferBelow: false,
                triggerMode: TooltipTriggerMode.tap,
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (badge != null) ...[
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (badgeColor ?? _kColorExpense).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge!,
                style: TextStyle(
                  color: badgeColor ?? _kColorExpense,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Revenue Bar Chart ───────────────────────────────────────────────────────

class _RevenueChart extends StatelessWidget {
  const _RevenueChart({required this.chartData, required this.compact});

  final List<RevenueEntity> chartData;
  final String Function(double) compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (chartData.isEmpty) {
      return BasicCard(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Center(
          child: Text(
            'Belum ada data pendapatan.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final maxVal =
        chartData.map((e) => e.total).reduce((a, b) => a > b ? a : b);

    return BasicCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legend row
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              _ChartLegendDot(color: _kColorRevenue, label: 'Total'),
              _ChartLegendDot(color: _kColorMonthly, label: 'Sewa Bulanan'),
              _ChartLegendDot(color: _kColorDaily, label: 'Sewa Harian'),
            ],
          ),
          const SizedBox(height: 16),
          // Chart area
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.map((data) {
                return Expanded(
                  child: _RevenueBar(
                    data: data,
                    maxVal: maxVal,
                    compact: compact,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartLegendDot extends StatelessWidget {
  const _ChartLegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _RevenueBar extends StatelessWidget {
  const _RevenueBar({
    required this.data,
    required this.maxVal,
    required this.compact,
  });

  final RevenueEntity data;
  final double maxVal;
  final String Function(double) compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = maxVal == 0 ? 0.0 : (data.total / maxVal).clamp(0.0, 1.0);
    // minimum visual bar height of 4px when there's data
    const double chartHeight = 160.0;
    final barHeight = data.total == 0 ? 4.0 : (ratio * chartHeight).clamp(4.0, chartHeight);

    return Tooltip(
      message:
          'Total: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(data.total)}'
          '\nBulanan: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(data.monthlyRentTotal)}'
          '\nHarian: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(data.dailyRentTotal)}',
      preferBelow: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Value label
            Text(
              compact(data.total),
              style: theme.textTheme.labelSmall?.copyWith(
                color: _kColorRevenue,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            // Bar
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
              child: SizedBox(
                height: barHeight,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    return Row(
                      children: [
                        // Monthly
                        if (data.total > 0)
                          SizedBox(
                            width: w * (data.monthlyRentTotal / data.total).clamp(0.0, 1.0),
                            height: barHeight,
                            child: ColoredBox(color: _kColorMonthly),
                          ),
                        // Daily
                        Expanded(
                          child: SizedBox(
                            height: barHeight,
                            child: ColoredBox(
                              color: data.total == 0 ? _kColorRevenue.withOpacity(0.15) : _kColorDaily,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Month label
            Text(
              data.month,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Due Invoices Table ──────────────────────────────────────────────────────

class _DueInvoicesTable extends StatelessWidget {
  const _DueInvoicesTable({
    required this.invoices,
    required this.formatRupiah,
    required this.dateFmt,
  });

  final List<InvoiceEntity> invoices;
  final String Function(double) formatRupiah;
  final DateFormat dateFmt;

  @override
  Widget build(BuildContext context) {
    return TableCard(
      title: 'Daftar Tagihan Jatuh Tempo',
      emptyMessage: 'Tidak ada tagihan yang jatuh tempo. Semua lancar!',
      columns: const [
        TableColumn(label: 'NO TAGIHAN', flex: 3),
        TableColumn(label: 'JUMLAH', flex: 3),
        TableColumn(label: 'JATUH TEMPO', flex: 3),
        TableColumn(label: 'AKSI', flex: 2, align: TextAlign.center),
      ],
      rows: invoices.map((inv) {
        final isOverdue = inv.dueDate.isBefore(DateTime.now());
        return [
          // No tagihan
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _kColorExpense.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_outlined,
                  size: 16,
                  color: _kColorExpense,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  inv.invoiceNumber,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Jumlah
          Text(
            formatRupiah(inv.amount),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: _kColorExpense,
            ),
          ),
          // Jatuh tempo
          Row(
            children: [
              Icon(
                Icons.event_rounded,
                size: 14,
                color: isOverdue ? _kColorExpense : _kColorWarning,
              ),
              const SizedBox(width: 4),
              Text(
                dateFmt.format(inv.dueDate),
                style: TextStyle(
                  fontSize: 13,
                  color: isOverdue ? _kColorExpense : null,
                  fontWeight:
                      isOverdue ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
          // Aksi
          Align(
            alignment: Alignment.center,
            child: _RemindButton(invoiceNumber: inv.invoiceNumber),
          ),
        ];
      }).toList(),
    );
  }
}

class _RemindButton extends StatelessWidget {
  const _RemindButton({required this.invoiceNumber});
  final String invoiceNumber;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pengingat untuk $invoiceNumber akan segera hadir.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        visualDensity: const VisualDensity(vertical: -2),
        side: const BorderSide(color: _kColorWarning),
        foregroundColor: _kColorWarning,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('Ingatkan'),
    );
  }
}

// ─── Pending Payments Table ──────────────────────────────────────────────────

class _PendingPaymentsTable extends StatelessWidget {
  const _PendingPaymentsTable({
    required this.payments,
    required this.formatRupiah,
  });

  final List<PaymentEntity> payments;
  final String Function(double) formatRupiah;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _kColorWarning;
      case 'confirmed':
      case 'success':
        return _kColorRevenue;
      case 'rejected':
      case 'failed':
        return _kColorExpense;
      default:
        return _kColorInfo;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'success':
        return 'Berhasil';
      case 'rejected':
        return 'Ditolak';
      case 'failed':
        return 'Gagal';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TableCard(
      title: 'Daftar Pembayaran Menunggu',
      emptyMessage: 'Belum ada pembayaran yang menunggu konfirmasi.',
      columns: const [
        TableColumn(label: 'ID TRANSAKSI', flex: 3),
        TableColumn(label: 'INVOICE', flex: 2),
        TableColumn(label: 'METODE', flex: 2),
        TableColumn(label: 'JUMLAH', flex: 3),
        TableColumn(label: 'STATUS', flex: 2, align: TextAlign.center),
      ],
      rows: payments.map((p) {
        final color = _statusColor(p.status);
        return [
          // ID Transaksi
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _kColorInfo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 16,
                  color: _kColorInfo,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  p.transactionId ?? '–',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Invoice ID
          Text(
            '#${p.invoiceId}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          // Metode
          Text(
            p.paymentMethod.toUpperCase(),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          // Jumlah
          Text(
            formatRupiah(p.amount),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          // Status badge
          Align(
            alignment: Alignment.center,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusLabel(p.status),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ];
      }).toList(),
    );
  }
}
