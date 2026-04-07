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
import '../../../domain/entity/finance/invoice_entity.dart';
import '../../../domain/entity/finance/payment_entity.dart';
import '../../../domain/entity/finance/kpi_entity.dart';
import '../../../domain/entity/finance/revenue_entity.dart';

@RoutePage()
class FinanceDashboardPage extends StatefulWidget {
  const FinanceDashboardPage({Key? key}) : super(key: key);

  @override
  State<FinanceDashboardPage> createState() => _FinanceDashboardPageState();
}

class _FinanceDashboardPageState extends State<FinanceDashboardPage> {
  late FinanceDashboardBloc _financeBloc;

  @override
  void initState() {
    super.initState();
    _financeBloc = serviceLocator.get<FinanceDashboardBloc>();
    _financeBloc.add(FetchDashboardData());
  }

  @override
  void dispose() {
    _financeBloc.close();
    super.dispose();
  }

  String formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
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
              const Text(
                'Dashboard Keuangan',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pantau performa keuangan, tagihan, dan pembayaran di sini.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
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
                        // --- BAGIAN 1: KPI SUMMARY ---
                        _buildSectionTitle(
                          'Ringkasan Keuangan',
                          Icons.analytics_outlined,
                          Colors.purple,
                        ),
                        const SizedBox(height: 16),
                        _buildKpiSection(state.kpiSummary),
                        const SizedBox(height: 40),

                        // --- BAGIAN 2: GRAFIK PENDAPATAN ---
                        _buildSectionTitle(
                          'Pendapatan 6 Bulan Terakhir',
                          Icons.bar_chart_rounded,
                          Colors.green,
                        ),
                        const SizedBox(height: 16),
                        _buildRevenueChart(state.revenueChart),
                        const SizedBox(height: 40),

                        // --- BAGIAN 3: TAGIHAN JATUH TEMPO ---
                        _buildSectionTitle(
                          'Tagihan Jatuh Tempo',
                          Icons.warning_amber_rounded,
                          Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        _buildDueInvoicesList(state.dueInvoices),
                        const SizedBox(height: 40),

                        // --- BAGIAN 4: PEMBAYARAN TERTUNDA ---
                        _buildSectionTitle(
                          'Status Pembayaran Terakhir',
                          Icons.history_rounded,
                          Colors.blue,
                        ),
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

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // WIDGET BARU: KPI Cards
  Widget _buildKpiSection(KpiEntity kpi) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard(
          'Total Pendapatan',
          formatRupiah(kpi.totalRevenue),
          Icons.account_balance_wallet,
          Colors.green,
        ),
        _buildStatCard(
          'Pendapatan Bulanan',
          formatRupiah(kpi.revenueMonthlyRents),
          Icons.calendar_month,
          Colors.purple,
        ),
        _buildStatCard(
          'Pendapatan Harian',
          formatRupiah(kpi.revenueDailyRents),
          Icons.today,
          Colors.teal,
        ),
        _buildStatCard(
          'Total Tunggakan',
          formatRupiah(kpi.dueInvoicesTotal),
          Icons.money_off,
          Colors.red,
        ),
        _buildStatCard(
          'Tagihan Belum Dibayar',
          '${kpi.dueInvoicesCount} Tagihan',
          Icons.receipt,
          Colors.orange,
        ),
        _buildStatCard(
          'Pembayaran Diproses',
          '${kpi.pendingPaymentsCount} Transaksi',
          Icons.hourglass_top,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return SizedBox(
      width: 250,
      child: BasicCard(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET BARU: Simple Bar Chart (Sebagai *placeholder* sebelum memakai package grafik sungguhan)
  Widget _buildRevenueChart(List<RevenueEntity> chartData) {
    if (chartData.isEmpty) {
      return const BasicCard(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('Belum ada data pendapatan.'),
        ),
      );
    }

    // Mencari nilai tertinggi untuk skala grafik
    final maxRevenue = chartData
        .map((e) => e.total)
        .reduce((a, b) => a > b ? a : b);

    return BasicCard(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          height: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: chartData.map((data) {
              // Menghitung tinggi bar berdasarkan nilai tertinggi
              final barHeight = maxRevenue == 0
                  ? 0.0
                  : (data.total / maxRevenue) * 150.0;
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Tooltip(
                    message: "Total: ${formatRupiah(data.total)}\nBulanan: ${formatRupiah(data.monthlyRentTotal)}\nHarian: ${formatRupiah(data.dailyRentTotal)}",
                    child: Container(
                      width: 40,
                      height: barHeight == 0 ? 5 : barHeight,
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.month,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDueInvoicesList(List<InvoiceEntity> invoices) {
    if (invoices.isEmpty) {
      return const BasicCard(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Text('Tidak ada tagihan yang jatuh tempo. Bagus!'),
          ),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      CustomChip(label: 'Unpaid', color: Colors.red.shade100),
                    ],
                  ),
                  const Divider(height: 30),
                  const Text('Total Tagihan', style: TextStyle(fontSize: 12)),
                  Text(
                    formatRupiah(invoice.amount),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: const Text('Bayar Sekarang'),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPendingPaymentsList(List<PaymentEntity> payments) {
    if (payments.isEmpty) {
      return const BasicCard(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Text('Belum ada riwayat pembayaran yang sedang diproses.'),
          ),
        ),
      );
    }
    return Column(
      children: payments.map((payment) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: BasicCard(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              leading: const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.receipt_long, color: Colors.white),
              ),
              title: Text('Transaksi #${payment.transactionId ?? "Menunggu"}'),
              subtitle: Text('Metode: ${payment.paymentMethod.toUpperCase()}'),
              trailing: CustomChip(
                label: payment.status.toUpperCase(),
                color: payment.status == 'pending'
                    ? Colors.orange.shade100
                    : Colors.green.shade100,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
