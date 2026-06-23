import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/finance_dashboard/finance_dashboard_bloc.dart';
import '../../bloc/finance_dashboard/finance_dashboard_event.dart';
import '../../bloc/finance_dashboard/finance_dashboard_state.dart';
import '../../bloc/midtrans_monitoring/midtrans_monitoring_cubit.dart';
import '../../widget/core/appbar/app_topbar.dart';
import '../../widget/core/card/basic_card.dart';
import '../../widget/core/card/summary_stat_card.dart';
import '../../widget/core/chip/status_badge.dart';
import '../../widget/core/table/app_data_table.dart';
import '../../widget/core/wrapper/empty_state_widget.dart';
import '../../../domain/entity/finance/invoice_entity.dart';
import '../../../domain/entity/finance/kpi_entity.dart';
import '../../../domain/entity/finance/payment_entity.dart';
import '../../../domain/entity/finance/revenue_entity.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
  late final MidtransMonitoringCubit _monitoringCubit;

  int? _selectedYear = DateTime.now().year;
  int? _selectedMonth = DateTime.now().month;

  static final _currencyFmt =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static final _dateFmt = DateFormat('d MMM yyyy', 'id_ID');

  String _formatRupiah(double amount) => _currencyFmt.format(amount);

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

  @override
  void initState() {
    super.initState();
    _financeBloc = serviceLocator.get<FinanceDashboardBloc>();
    _monitoringCubit = serviceLocator.get<MidtransMonitoringCubit>();
    _applyFilter();
  }

  @override
  void dispose() {
    _monitoringCubit.close();
    super.dispose();
  }

  void _applyFilter() {
    _financeBloc.add(FetchDashboardData(month: _selectedMonth, year: _selectedYear));
    _monitoringCubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final bgColor = isDark ? AppColorsDark.background : AppColorsLight.background;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _financeBloc),
        BlocProvider.value(value: _monitoringCubit),
      ],
      child: Scaffold(
        backgroundColor: bgColor,
        body: Column(
          children: [
            AppTopBar(
              title: 'Dashboard Keuangan',
              breadcrumb: 'Keuangan / Dashboard',
              action: ElevatedButton.icon(
                onPressed: _applyFilter,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ),
            Expanded(
              child: BlocBuilder<FinanceDashboardBloc, FinanceDashboardState>(
                builder: (context, state) {
                  if (state is FinanceDashboardLoading) {
                    return _buildSkeleton(isDark);
                  }
                  if (state is FinanceDashboardError) {
                    return EmptyStateWidget(
                      icon: Icons.error_outline_rounded,
                      title: 'Gagal memuat data',
                      subtitle: state.message,
                      action: ElevatedButton.icon(
                        onPressed: _applyFilter,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Coba Lagi'),
                      ),
                    );
                  }
                  final loaded = state is FinanceDashboardLoaded
                      ? state
                      : state is FinanceDashboardRefreshing
                          ? state.currentData
                          : null;
                  if (loaded != null) {
                    return Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(AppSpacing.xxxl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _DashboardContent(
                                kpi: loaded.kpiSummary,
                                revenueChart: loaded.revenueChart,
                                dueInvoices: loaded.dueInvoices,
                                pendingPayments: loaded.pendingPayments,
                                periodLabel: _periodLabel,
                                formatRupiah: _formatRupiah,
                                compact: _compact,
                                dateFmt: _dateFmt,
                                selectedYear: _selectedYear,
                                selectedMonth: _selectedMonth,
                                onYearChanged: (v) {
                                  setState(() { _selectedYear = v; _selectedMonth = null; });
                                  _applyFilter();
                                },
                                onMonthChanged: (v) {
                                  setState(() => _selectedMonth = v);
                                  _applyFilter();
                                },
                                onReset: () {
                                  setState(() {
                                    _selectedYear = DateTime.now().year;
                                    _selectedMonth = DateTime.now().month;
                                  });
                                  _applyFilter();
                                },
                              ),
                            ],
                          ),
                        ),
                        if (state is FinanceDashboardRefreshing)
                          const LinearProgressIndicator(),
                      ],
                    );
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

  Widget _buildSkeleton(bool isDark) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    Widget shimmerCard({double height = 100}) => Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
    );

    Widget cardRow(int count) => Row(
      children: List.generate(count, (i) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: i < count - 1 ? AppSpacing.lg : 0),
          child: shimmerCard(),
        ),
      )),
    );

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        children: [
          cardRow(4),
          const SizedBox(height: AppSpacing.lg),
          cardRow(4),
          const SizedBox(height: AppSpacing.lg),
          cardRow(2),
          const SizedBox(height: AppSpacing.xxxl),
          Expanded(child: shimmerCard(height: double.infinity)),
        ],
      ),
    );
  }
}

// ─── Filter dropdown ─────────────────────────────────────────────────────────

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
    final isDark = AppTheme.isDark(context);
    final borderColor = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final hintColor = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
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

// ─── Dashboard content ───────────────────────────────────────────────────────

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
    required this.selectedYear,
    required this.selectedMonth,
    required this.onYearChanged,
    required this.onMonthChanged,
    required this.onReset,
  });

  final KpiEntity kpi;
  final List<RevenueEntity> revenueChart;
  final List<InvoiceEntity> dueInvoices;
  final List<PaymentEntity> pendingPayments;
  final String periodLabel;
  final String Function(double) formatRupiah;
  final String Function(double) compact;
  final DateFormat dateFmt;
  final int? selectedYear;
  final int? selectedMonth;
  final ValueChanged<int?> onYearChanged;
  final ValueChanged<int?> onMonthChanged;
  final VoidCallback onReset;

  bool get _isDefaultPeriod =>
      selectedYear == DateTime.now().year &&
      selectedMonth == DateTime.now().month;

  Widget _sectionTitle(BuildContext context, String title, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 22,
          decoration: BoxDecoration(
            color: isDark ? AppColorsDark.primary : AppColorsLight.primary,
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
    final isDark = AppTheme.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── KPI + Midtrans Section ────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _sectionTitle(context, 'Ringkasan Keuangan', isDark),
            const Spacer(),
            _DashboardFilterDropdown<int?>(
              hint: 'Semua Tahun',
              value: selectedYear,
              items: [null, ...List.generate(6, (i) => DateTime.now().year - i)],
              labelBuilder: (v) => v == null ? 'Semua Tahun' : '$v',
              onChanged: onYearChanged,
            ),
            const SizedBox(width: AppSpacing.sm),
            _DashboardFilterDropdown<int?>(
              hint: 'Semua Bulan',
              value: selectedMonth,
              items: [null, ...List.generate(12, (i) => i + 1)],
              labelBuilder: (v) => v == null
                  ? 'Semua Bulan'
                  : DateFormat('MMMM', 'id_ID').format(DateTime(0, v)),
              onChanged: onMonthChanged,
            ),
            if (!_isDefaultPeriod) ...[
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                onPressed: onReset,
                icon: const Icon(Icons.close_rounded, size: 16),
                tooltip: 'Reset filter',
                style: IconButton.styleFrom(
                  foregroundColor: Colors.grey.shade500,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ],
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: AppSpacing.lg),
        _KpiGrid(
          kpi: kpi,
          formatRupiah: formatRupiah,
          periodLabel: periodLabel,
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms),
        const SizedBox(height: AppSpacing.xxxl),

        // ── Revenue Chart ─────────────────────────────────────────────────
        _sectionTitle(context, 'Pendapatan 6 Bulan Terakhir', isDark),
        const SizedBox(height: AppSpacing.lg),
        _RevenueChart(chartData: revenueChart, compact: compact)
            .animate().fadeIn(delay: 100.ms, duration: 300.ms),
        const SizedBox(height: AppSpacing.xxxl),

        // ── Due Invoices ──────────────────────────────────────────────────
        _sectionTitle(context, 'Tagihan Jatuh Tempo', isDark),
        const SizedBox(height: AppSpacing.lg),
        _DueInvoicesTable(
          invoices: dueInvoices,
          formatRupiah: formatRupiah,
          dateFmt: dateFmt,
          isDark: isDark,
        ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
        const SizedBox(height: AppSpacing.xxxl),

        // ── Pending Payments ──────────────────────────────────────────────
        _sectionTitle(context, 'Pembayaran Perlu Konfirmasi', isDark),
        const SizedBox(height: AppSpacing.lg),
        _PendingPaymentsTable(
          payments: pendingPayments,
          formatRupiah: formatRupiah,
          isDark: isDark,
        ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

// ─── KPI Grid ────────────────────────────────────────────────────────────────
// Row 1: 4 main financial KPIs
// Row 2: 2 operational KPIs + 2 Midtrans count KPIs
// Row 3: 2 Midtrans amount KPIs

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({
    required this.kpi,
    required this.formatRupiah,
    required this.periodLabel,
  });

  final KpiEntity kpi;
  final String Function(double) formatRupiah;
  final String periodLabel;

  static const _bulanNames = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final isProfit = kpi.netProfit >= 0;

    final profitIconColor = isProfit
        ? (isDark ? AppColorsDark.conditionGood : AppColorsLight.conditionGood)
        : (isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled);
    final profitIconBg = isProfit
        ? (isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg)
        : (isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg);

    return BlocBuilder<MidtransMonitoringCubit, MidtransMonitoringState>(
      builder: (context, midtransState) {
        final midtrans = midtransState is MidtransMonitoringLoaded
            ? midtransState.data
            : null;
        final isLoading = midtransState is MidtransMonitoringInitial ||
            midtransState is MidtransMonitoringLoading;

        final bulanLabel = midtrans != null &&
                midtrans.bulan > 0 &&
                midtrans.bulan <= 12
            ? _bulanNames[midtrans.bulan]
            : '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: Main financial KPIs ────────────────────────────────
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: SummaryStatCard(
                    label: 'Total Pendapatan',
                    value: formatRupiah(kpi.totalRevenue),
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: isDark ? AppColorsDark.conditionGood : AppColorsLight.conditionGood,
                    iconBg: isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg,
                    trend: periodLabel,
                  )),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: SummaryStatCard(
                    label: 'Total Pengeluaran',
                    value: formatRupiah(kpi.totalExpense),
                    icon: Icons.trending_down_rounded,
                    iconColor: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
                    iconBg: isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg,
                    trend: periodLabel,
                  )),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: SummaryStatCard(
                    label: 'Laba Bersih',
                    value: formatRupiah(kpi.netProfit),
                    icon: isProfit ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    iconColor: profitIconColor,
                    iconBg: profitIconBg,
                    trend: isProfit ? 'Surplus' : 'Defisit',
                    trendColor: profitIconColor,
                    valueColor: profitIconColor,
                  )),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: SummaryStatCard(
                    label: 'Tagihan Belum Bayar',
                    value: formatRupiah(kpi.dueInvoicesTotal),
                    icon: Icons.money_off_rounded,
                    iconColor: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
                    iconBg: isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg,
                  )),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Row 2: Operational + Midtrans counts ──────────────────────
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: SummaryStatCard(
                    label: 'Jatuh Tempo',
                    value: '${kpi.dueInvoicesCount} Tagihan',
                    icon: Icons.receipt_long_rounded,
                    iconColor: isDark ? AppColorsDark.conditionFair : AppColorsLight.conditionFair,
                    iconBg: isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg,
                  )),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: SummaryStatCard(
                    label: 'Perlu Konfirmasi',
                    value: '${kpi.pendingPaymentsCount} Transaksi',
                    icon: Icons.hourglass_top_rounded,
                    iconColor: isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess,
                    iconBg: isDark ? AppColorsDark.statusProcessBg : AppColorsLight.statusProcessBg,
                  )),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: SummaryStatCard(
                    label: 'Settlement Midtrans',
                    value: isLoading ? '–' : (midtrans != null ? '${midtrans.jumlahSettlement}×' : '–'),
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: isDark ? AppColorsDark.conditionGood : AppColorsLight.conditionGood,
                    iconBg: isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg,
                  )),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: SummaryStatCard(
                    label: 'Pending Midtrans',
                    value: isLoading ? '–' : (midtrans != null ? '${midtrans.jumlahPending}×' : '–'),
                    icon: Icons.hourglass_empty_rounded,
                    iconColor: isDark ? AppColorsDark.conditionFair : AppColorsLight.conditionFair,
                    iconBg: isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg,
                  )),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Row 3: Midtrans amounts ───────────────────────────────────
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: SummaryStatCard(
                    label: 'Total Terkumpul (Midtrans)',
                    value: isLoading ? '–' : (midtrans != null ? formatRupiah(midtrans.totalSettlement) : '–'),
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: isDark ? AppColorsDark.conditionGood : AppColorsLight.conditionGood,
                    iconBg: isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg,
                    valueColor: midtrans != null
                        ? (isDark ? AppColorsDark.conditionGood : AppColorsLight.conditionGood)
                        : null,
                  )),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: SummaryStatCard(
                    label: bulanLabel.isNotEmpty && midtrans != null
                        ? 'Settlement $bulanLabel ${midtrans.tahun}'
                        : 'Settlement Bulan Ini',
                    value: isLoading
                        ? '–'
                        : (midtrans != null && bulanLabel.isNotEmpty
                            ? formatRupiah(midtrans.settlementBulanIni)
                            : '–'),
                    icon: Icons.calendar_today_outlined,
                    iconColor: isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess,
                    iconBg: isDark ? AppColorsDark.statusProcessBg : AppColorsLight.statusProcessBg,
                  )),
                  // Fill remaining 2 slots with invisible spacers to maintain grid alignment
                  const SizedBox(width: AppSpacing.lg),
                  const Expanded(child: SizedBox()),
                  const SizedBox(width: AppSpacing.lg),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
          ],
        );
      },
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
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.map((data) {
                return Expanded(
                  child: _RevenueBar(data: data, maxVal: maxVal, compact: compact),
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
    const double chartHeight = 160.0;
    final barHeight = data.total == 0
        ? 4.0
        : (ratio * chartHeight).clamp(4.0, chartHeight);

    return Tooltip(
      message: 'Total: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(data.total)}'
          '\nBulanan: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(data.monthlyRentTotal)}'
          '\nHarian: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(data.dailyRentTotal)}',
      preferBelow: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              compact(data.total),
              style: theme.textTheme.labelSmall?.copyWith(
                color: _kColorRevenue,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
              child: SizedBox(
                height: barHeight,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    return Row(
                      children: [
                        if (data.total > 0)
                          SizedBox(
                            width: w * (data.monthlyRentTotal / data.total).clamp(0.0, 1.0),
                            height: barHeight,
                            child: const ColoredBox(color: _kColorMonthly),
                          ),
                        Expanded(
                          child: SizedBox(
                            height: barHeight,
                            child: ColoredBox(
                              color: data.total == 0
                                  ? _kColorRevenue.withOpacity(0.15)
                                  : _kColorDaily,
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
    required this.isDark,
  });

  final List<InvoiceEntity> invoices;
  final String Function(double) formatRupiah;
  final DateFormat dateFmt;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.surface : AppColorsLight.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight,
          ),
        ),
        child: Text(
          'Tidak ada tagihan yang jatuh tempo. Semua lancar!',
          style: TextStyle(
            color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
          ),
        ),
      );
    }

    return AppDataTable(
      columns: const [
        DataColumn(label: Text('No Tagihan')),
        DataColumn(label: Text('Jumlah')),
        DataColumn(label: Text('Jatuh Tempo')),
        DataColumn(label: Text('Aksi')),
      ],
      rows: invoices.map((inv) {
        final isOverdue = inv.dueDate.isBefore(DateTime.now());
        return DataRow(cells: [
          DataCell(Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _kColorExpense.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.receipt_outlined, size: 16, color: _kColorExpense),
            ),
            const SizedBox(width: 10),
            Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
          ])),
          DataCell(Text(
            formatRupiah(inv.amount),
            style: const TextStyle(fontWeight: FontWeight.w700, color: _kColorExpense),
          )),
          DataCell(Row(children: [
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
                fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ])),
          DataCell(_RemindButton(invoiceNumber: inv.invoiceNumber)),
        ]);
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
            content: Text('Pengingat untuk $invoiceNumber akan segera hadir.'),
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
    required this.isDark,
  });

  final List<PaymentEntity> payments;
  final String Function(double) formatRupiah;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.surface : AppColorsLight.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight,
          ),
        ),
        child: Text(
          'Belum ada pembayaran yang menunggu konfirmasi.',
          style: TextStyle(
            color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
          ),
        ),
      );
    }

    return AppDataTable(
      columns: const [
        DataColumn(label: Text('ID Transaksi')),
        DataColumn(label: Text('Invoice')),
        DataColumn(label: Text('Metode')),
        DataColumn(label: Text('Jumlah')),
        DataColumn(label: Text('Status')),
      ],
      rows: payments.map((p) => DataRow(cells: [
        DataCell(Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _kColorInfo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.receipt_long_rounded, size: 16, color: _kColorInfo),
          ),
          const SizedBox(width: 10),
          Text(
            p.transactionId ?? '–',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ])),
        DataCell(Text(
          '#${p.invoiceId}',
          style: TextStyle(
            color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
            fontSize: 13,
          ),
        )),
        DataCell(Text(
          p.paymentMethod.toUpperCase(),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        )),
        DataCell(Text(
          formatRupiah(p.amount),
          style: const TextStyle(fontWeight: FontWeight.w700),
        )),
        DataCell(StatusBadge(status: p.status)),
      ])).toList(),
    );
  }
}
