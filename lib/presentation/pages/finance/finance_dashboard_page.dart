import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../bloc/finance_dashboard/finance_dashboard_bloc.dart';
import '../../bloc/finance_dashboard/finance_dashboard_event.dart';
import '../../bloc/finance_dashboard/finance_dashboard_state.dart';
import '../../widget/core/card/basic_card.dart';
import '../../widget/core/chip/custom_chip.dart';
import '../../widget/core/textform/dropdown_field.dart';
import '../../../domain/entity/finance/invoice_entity.dart';
import '../../../domain/entity/finance/payment_entity.dart';
import '../../../domain/entity/finance/kpi_entity.dart';
import '../../../domain/entity/finance/revenue_entity.dart';
import '../../widget/core/table/table.dart';
import '../../../domain/entity/table/tabel_colum.dart';

// Mode filter dashboard
enum FilterMode { thisMonth, monthYear, yearOnly }

@RoutePage()
class FinanceDashboardPage extends StatefulWidget {
  const FinanceDashboardPage({super.key});

  @override
  State<FinanceDashboardPage> createState() => _FinanceDashboardPageState();
}

class _FinanceDashboardPageState extends State<FinanceDashboardPage> {
  late FinanceDashboardBloc _financeBloc;

  FilterMode _filterMode = FilterMode.thisMonth;
  int? _selectedMonth;
  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;

    _financeBloc = serviceLocator.get<FinanceDashboardBloc>();
    _financeBloc.add(FetchDashboardData(month: _selectedMonth, year: _selectedYear));
  }

  @override
  void dispose() {
    _financeBloc.close();
    super.dispose();
  }

  void _applyFilter() {
    int? month;
    int? year;

    switch (_filterMode) {
      case FilterMode.thisMonth:
        final now = DateTime.now();
        month = now.month;
        year = now.year;
        break;
      case FilterMode.monthYear:
        month = _selectedMonth;
        year = _selectedYear;
        break;
      case FilterMode.yearOnly:
        month = null;
        year = _selectedYear;
        break;
    }

    _financeBloc.add(FetchDashboardData(month: month, year: year));
  }

  String formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  String get _periodLabel {
    switch (_filterMode) {
      case FilterMode.thisMonth:
        return 'Bulan ${DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now())}';
      case FilterMode.monthYear:
        final m = _selectedMonth ?? DateTime.now().month;
        final y = _selectedYear ?? DateTime.now().year;
        return 'Bulan ${DateFormat('MMMM yyyy', 'id_ID').format(DateTime(y, m))}';
      case FilterMode.yearOnly:
        return 'Tahun ${_selectedYear ?? DateTime.now().year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _financeBloc,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard Keuangan',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Periode: $_periodLabel',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filter section
              _buildFilterSection(),
              const SizedBox(height: 32),

              BlocBuilder<FinanceDashboardBloc, FinanceDashboardState>(
                builder: (context, state) {
                  if (state is FinanceDashboardLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(50.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is FinanceDashboardError) {
                    return Center(
                      child: Text(
                        'Gagal memuat data: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (state is FinanceDashboardLoaded) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Ringkasan Keuangan', Icons.analytics_outlined, Colors.purple),
                        const SizedBox(height: 16),
                        _buildKpiSection(state.kpiSummary),
                        const SizedBox(height: 40),

                        _buildSectionTitle('Pendapatan 6 Bulan Terakhir', Icons.bar_chart_rounded, Colors.green),
                        const SizedBox(height: 16),
                        _buildRevenueChart(state.revenueChart),
                        const SizedBox(height: 40),

                        _buildSectionTitle('Tagihan Jatuh Tempo', Icons.warning_amber_rounded, Colors.orange),
                        const SizedBox(height: 16),
                        _buildDueInvoicesList(state.dueInvoices),
                        const SizedBox(height: 40),

                        _buildSectionTitle('Status Pembayaran Terakhir', Icons.history_rounded, Colors.blue),
                        const SizedBox(height: 16),
                        _buildPendingPaymentsList(state.pendingPayments),
                      ],
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

  // ─── FILTER SECTION ────────────────────────────────────────────────────────

  Widget _buildFilterSection() {
    final months = List.generate(12, (i) => DateFormat('MMMM', 'id_ID').format(DateTime(2024, i + 1)));
    final years = List.generate(6, (i) => (DateTime.now().year - i).toString());

    return BasicCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Periode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 12),
            // Mode chips
            Row(
              children: [
                _buildModeChip('Bulan Ini', FilterMode.thisMonth),
                const SizedBox(width: 8),
                _buildModeChip('Bulan & Tahun', FilterMode.monthYear),
                const SizedBox(width: 8),
                _buildModeChip('Tahun Saja', FilterMode.yearOnly),
              ],
            ),
            // Conditional dropdowns
            if (_filterMode != FilterMode.thisMonth) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_filterMode == FilterMode.monthYear) ...[
                    SizedBox(
                      width: 170,
                      child: CustomDropdownField(
                        title: '',
                        hint: 'Pilih Bulan',
                        value: _selectedMonth != null
                            ? DateFormat('MMMM', 'id_ID').format(DateTime(2024, _selectedMonth!))
                            : null,
                        items: months,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedMonth = months.indexOf(val) + 1);
                            _applyFilter();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  SizedBox(
                    width: 130,
                    child: CustomDropdownField(
                      title: '',
                      hint: 'Pilih Tahun',
                      value: _selectedYear?.toString(),
                      items: years,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedYear = int.parse(val));
                          _applyFilter();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModeChip(String label, FilterMode mode) {
    final isSelected = _filterMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() => _filterMode = mode);
        _applyFilter();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ─── SECTION TITLE ─────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ─── KPI SECTION ───────────────────────────────────────────────────────────

  Widget _buildKpiSection(KpiEntity kpi) {
    final isProfit = kpi.netProfit >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1 – Pemasukan
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildFeaturedStatCard(
                title: 'Total Pendapatan',
                subtitle: _periodLabel,
                tooltip: 'Jumlah seluruh uang masuk dari pembayaran sewa yang telah dikonfirmasi pada periode ini.',
                value: formatRupiah(kpi.totalRevenue),
                icon: Icons.account_balance_wallet,
                iconColor: Colors.white,
                bgColor: Colors.green.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Sewa Bulanan',
                tooltip: 'Total pemasukan dari penghuni yang menggunakan kontrak sewa per bulan.',
                value: formatRupiah(kpi.revenueMonthlyRents),
                icon: Icons.calendar_month,
                iconColor: Colors.purple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Sewa Harian',
                tooltip: 'Total pemasukan dari tamu yang menggunakan paket sewa harian.',
                value: formatRupiah(kpi.revenueDailyRents),
                icon: Icons.today,
                iconColor: Colors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Row 2 – Pengeluaran & Laba
        Row(
          children: [
            Expanded(
              child: _buildWarningStatCard(
                title: 'Total Pengeluaran',
                tooltip: 'Jumlah semua biaya operasional yang dikeluarkan wisma pada periode ini, termasuk pembelian barang dan biaya rutin.',
                value: formatRupiah(kpi.totalExpense),
                icon: Icons.trending_down,
                textColor: Colors.deepOrange.shade700,
                bgColor: Colors.deepOrange.shade50,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildWarningStatCard(
                title: 'Laba Bersih',
                tooltip: 'Selisih antara total pendapatan dikurangi total pengeluaran. Positif berarti untung, negatif berarti rugi.',
                value: formatRupiah(kpi.netProfit),
                icon: isProfit ? Icons.trending_up : Icons.trending_down,
                textColor: isProfit ? Colors.green.shade700 : Colors.red.shade700,
                bgColor: isProfit ? Colors.green.shade50 : Colors.red.shade50,
                extraBadge: isProfit ? null : '⚠ Merugi',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildWarningStatCard(
                title: 'Tagihan Belum Dibayar',
                tooltip: 'Total nilai tagihan yang sudah jatuh tempo namun belum dilunasi oleh penghuni.',
                value: formatRupiah(kpi.dueInvoicesTotal),
                icon: Icons.money_off,
                textColor: Colors.red.shade700,
                bgColor: Colors.red.shade50,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Row 3 – Status
        Row(
          children: [
            Expanded(
              child: _buildWarningStatCard(
                title: 'Tagihan Jatuh Tempo',
                tooltip: 'Jumlah tagihan yang sudah melewati tanggal jatuh tempo dan belum dibayar.',
                value: '${kpi.dueInvoicesCount} Tagihan',
                icon: Icons.receipt_long,
                textColor: Colors.orange.shade800,
                bgColor: Colors.orange.shade50,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildWarningStatCard(
                title: 'Perlu Dikonfirmasi Admin',
                tooltip: 'Transaksi transfer bank yang sudah diunggah penghuni dan menunggu verifikasi dari admin.',
                value: '${kpi.pendingPaymentsCount} Transaksi',
                icon: Icons.hourglass_top,
                textColor: Colors.blue.shade700,
                bgColor: Colors.blue.shade50,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  // ─── CARD WIDGETS ──────────────────────────────────────────────────────────

  Widget _buildFeaturedStatCard({
    required String title,
    required String subtitle,
    required String tooltip,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: bgColor.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                      Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
                Tooltip(
                  message: tooltip,
                  preferBelow: false,
                  child: const Icon(Icons.info_outline, color: Colors.white54, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String tooltip,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return BasicCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                Tooltip(
                  message: tooltip,
                  preferBelow: false,
                  child: Icon(Icons.info_outline, color: Colors.grey.shade400, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningStatCard({
    required String title,
    required String tooltip,
    required String value,
    required IconData icon,
    required Color textColor,
    required Color bgColor,
    String? extraBadge,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                Tooltip(
                  message: tooltip,
                  preferBelow: false,
                  child: Icon(Icons.info_outline, color: textColor.withOpacity(0.5), size: 15),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            if (extraBadge != null) ...[
              const SizedBox(height: 4),
              Text(extraBadge, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 11)),
            ],
          ],
        ),
      ),
    );
  }

  // ─── REVENUE CHART ─────────────────────────────────────────────────────────

  Widget _buildRevenueChart(List<RevenueEntity> chartData) {
    if (chartData.isEmpty) {
      return const BasicCard(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('Belum ada data pendapatan.'),
        ),
      );
    }

    final maxRevenue = chartData.map((e) => e.total).reduce((a, b) => a > b ? a : b);

    return BasicCard(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          height: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: chartData.map((data) {
              final barHeight = maxRevenue == 0 ? 0.0 : (data.total / maxRevenue) * 150.0;
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Tooltip(
                    message: 'Total: ${formatRupiah(data.total)}\nBulanan: ${formatRupiah(data.monthlyRentTotal)}\nHarian: ${formatRupiah(data.dailyRentTotal)}',
                    child: Container(
                      width: 40,
                      height: barHeight == 0 ? 5 : barHeight,
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(data.month, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ─── DUE INVOICES ──────────────────────────────────────────────────────────

  Widget _buildDueInvoicesList(List<InvoiceEntity> invoices) {
    if (invoices.isEmpty) {
      return const BasicCard(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: Text('Tidak ada tagihan yang jatuh tempo. Bagus!')),
        ),
      );
    }
    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      children: invoices.map((invoice) {
        return SizedBox(
          width: 350,
          child: BasicCard(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        invoice.invoiceNumber,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      CustomChip(label: 'Belum Bayar', color: Colors.red.shade100),
                    ],
                  ),
                  const Divider(height: 30),
                  const Text('Total Tagihan', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    formatRupiah(invoice.amount),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur Kirim Pengingat via WhatsApp akan segera hadir')),
                      );
                    },
                    icon: const Icon(Icons.notifications_active, size: 18),
                    label: const Text('Kirim Pengingat WA'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                      backgroundColor: Colors.orange.shade50,
                      foregroundColor: Colors.orange.shade800,
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── PENDING PAYMENTS ──────────────────────────────────────────────────────

  Widget _buildPendingPaymentsList(List<PaymentEntity> payments) {
    if (payments.isEmpty) {
      return const BasicCard(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: Text('Belum ada pembayaran yang menunggu konfirmasi.')),
        ),
      );
    }
    return TableCard(
      title: 'Daftar Pembayaran',
      columns: const [
        TableColumn(label: 'Transaksi', flex: 3),
        TableColumn(label: 'Metode', flex: 2),
        TableColumn(label: 'Status', flex: 2, align: TextAlign.right),
      ],
      rows: payments.map((payment) {
        return [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                radius: 16,
                child: Icon(Icons.receipt_long, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Text('Transaksi #${payment.transactionId ?? "Menunggu ID"}', style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          Text(payment.paymentMethod.toUpperCase()),
          Align(
            alignment: Alignment.centerRight,
            child: CustomChip(
              label: payment.status == 'pending' ? 'Menunggu' : payment.status.toUpperCase(),
              color: payment.status == 'pending' ? Colors.orange.shade100 : Colors.green.shade100,
            ),
          ),
        ];
      }).toList(),
    );
  }
}
