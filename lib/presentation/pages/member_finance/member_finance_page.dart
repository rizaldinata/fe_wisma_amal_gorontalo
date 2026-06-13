import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../domain/entity/table/tabel_colum.dart';
import '../../bloc/member_finance/member_finance_bloc.dart';
import '../../bloc/member_finance/member_finance_event.dart';
import '../../bloc/member_finance/member_finance_state.dart';
import '../../widget/core/table/table.dart';

@RoutePage()
class MemberFinancePage extends StatefulWidget {
  const MemberFinancePage({super.key});

  @override
  State<MemberFinancePage> createState() => _MemberFinancePageState();
}

class _MemberFinancePageState extends State<MemberFinancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchMidtrans(String token) async {
    final url = Uri.parse(
      'https://app.sandbox.midtrans.com/snap/v2/vtweb/$token',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka halaman pembayaran')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator.get<MemberFinanceBloc>()
        ..add(FetchMemberFinanceSummary())
        ..add(FetchMemberInvoices())
        ..add(FetchMemberPayments()),
      child: BlocListener<MemberFinanceBloc, MemberFinanceState>(
        listener: (context, state) {
          if (state.status == MemberFinanceStatus.paymentSuccess) {
            if (state.snapToken != null) {
              _launchMidtrans(state.snapToken!);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Bukti pembayaran berhasil diunggah. Menunggu verifikasi admin.',
                  ),
                ),
              );
            }
          } else if (state.status == MemberFinanceStatus.extensionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permintaan perpanjangan sewa berhasil dikirim'),
              ),
            );
          } else if (state.status == MemberFinanceStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Terjadi kesalahan'),
              ),
            );
          }
        },
        child: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Keuangan Saya',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    _buildExtendButton(),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSummaryCards(),
                const SizedBox(height: 32),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Tagihan Aktif'),
                    Tab(text: 'Riwayat Pembayaran'),
                  ],
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 500,
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildInvoiceList(), _buildPaymentHistory()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExtendButton() {
    return BlocBuilder<MemberFinanceBloc, MemberFinanceState>(
      builder: (context, state) {
        if (state.summary == null || state.summary!.activeLease == null) {
          return const SizedBox.shrink();
        }

        return ElevatedButton.icon(
          onPressed: () =>
              _showExtendDialog(context, state.summary!.activeLease!.id),
          icon: const Icon(Icons.add_circle_outline, size: 18),
          label: const Text('Perpanjang Sewa'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  void _showExtendDialog(BuildContext context, int leaseId) {
    int duration = 1;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Perpanjang Sewa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pilih durasi perpanjangan (bulan):'),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: duration,
              items: List.generate(12, (i) => i + 1)
                  .map(
                    (m) => DropdownMenuItem(value: m, child: Text('$m Bulan')),
                  )
                  .toList(),
              onChanged: (val) => duration = val ?? 1,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<MemberFinanceBloc>().add(
                ExtendLeaseEvent(leaseId, duration),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Kirim Permintaan'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<MemberFinanceBloc, MemberFinanceState>(
      builder: (context, state) {
        final lease = state.summary?.activeLease;
        final unpaid = state.summary?.totalUnpaid ?? 0.0;
        final unpaidCount = state.summary?.unpaidCount ?? 0;

        return Row(
          children: [
            // ── Kamar ──────────────────────────────────────────────
            Expanded(
              child: _summaryCard(
                title: 'Kamar Saya',
                value: lease != null ? 'No. ${lease.roomNumber}' : '-',
                sub: lease != null ? lease.rentalType.toUpperCase() : 'Belum ada kamar aktif',
                icon: Icons.meeting_room_outlined,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),

            // ── Status Sewa + Sisa Hari ─────────────────────────────
            Expanded(
              child: _buildLeaseStatusCard(lease),
            ),
            const SizedBox(width: 16),

            // ── Total Tagihan ───────────────────────────────────────
            Expanded(
              child: _summaryCard(
                title: 'Total Tagihan',
                value: currencyFormat.format(unpaid),
                sub: unpaidCount > 0
                    ? '$unpaidCount tagihan belum dibayar'
                    : 'Semua tagihan lunas',
                icon: Icons.account_balance_wallet_outlined,
                color: unpaid > 0 ? Colors.orange : Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLeaseStatusCard(dynamic lease) {
    if (lease == null) {
      return _summaryCard(
        title: 'Status Sewa',
        value: 'TIDAK AKTIF',
        sub: 'Belum ada sewa berjalan',
        icon: Icons.home_outlined,
        color: Colors.grey,
      );
    }

    final now = DateTime.now();
    final endDate = lease.endDate as DateTime;
    final daysLeft = endDate.difference(now).inDays;
    final endDateStr = DateFormat('dd MMM yyyy').format(endDate);

    Color statusColor;
    String daysLabel;
    if (daysLeft < 0) {
      statusColor = Colors.red;
      daysLabel = 'Masa sewa telah berakhir';
    } else if (daysLeft <= 7) {
      statusColor = Colors.red;
      daysLabel = 'Berakhir $daysLeft hari lagi';
    } else if (daysLeft <= 30) {
      statusColor = Colors.orange;
      daysLabel = 'Berakhir $daysLeft hari lagi';
    } else {
      statusColor = Colors.blue;
      daysLabel = 'Sisa $daysLeft hari';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.home_outlined, color: statusColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'Status Sewa',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'AKTIF',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Berakhir: $endDateStr',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              daysLabel,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceList() {
    return BlocBuilder<MemberFinanceBloc, MemberFinanceState>(
      builder: (context, state) {
        final unpaidInvoices = state.invoices
            .where((i) => i.status.toLowerCase() == 'unpaid')
            .toList();

        // Build set of invoiceIds that already have a pending payment
        final pendingInvoiceIds = state.payments
            .where((p) => p.status.toLowerCase() == 'pending')
            .map((p) => p.invoiceId)
            .toSet();

        return TableCard(
          title: 'Tagihan Belum Dibayar',
          columns: const [
            TableColumn(label: 'No. Invoice', flex: 3),
            TableColumn(label: 'Jatuh Tempo', flex: 2),
            TableColumn(label: 'Jumlah', flex: 2),
            TableColumn(label: 'Status', flex: 3, align: TextAlign.right),
          ],
          rows: unpaidInvoices.map((invoice) {
            final hasPendingPayment = pendingInvoiceIds.contains(invoice.id);
            final isOverdue = invoice.dueDate.isBefore(DateTime.now());

            return [
              Text(
                invoice.invoiceNumber,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                DateFormat('dd MMM yyyy').format(invoice.dueDate),
                style: TextStyle(
                  color: isOverdue && !hasPendingPayment
                      ? Colors.red
                      : null,
                  fontWeight: isOverdue && !hasPendingPayment
                      ? FontWeight.w600
                      : null,
                ),
              ),
              Text(
                currencyFormat.format(invoice.amount),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: hasPendingPayment
                    ? _buildStatusBadge('Menunggu Verifikasi', Colors.orange)
                    : ElevatedButton(
                        onPressed: () {
                          _showPaymentMethodDialog(context, invoice.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Bayar',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
              ),
            ];
          }).toList(),
          emptyMessage: 'Semua tagihan Anda sudah lunas. Luar biasa!',
        );
      },
    );
  }

  Widget _buildPaymentHistory() {
    return BlocBuilder<MemberFinanceBloc, MemberFinanceState>(
      builder: (context, state) {
        return TableCard(
          title: 'Riwayat Pembayaran',
          columns: const [
            TableColumn(label: 'Tanggal', flex: 2),
            TableColumn(label: 'Metode', flex: 2),
            TableColumn(label: 'Jumlah', flex: 2),
            TableColumn(label: 'Status', flex: 2),
            TableColumn(label: 'Aksi', flex: 1, align: TextAlign.right),
          ],
          rows: state.payments.map((payment) {
            return [
              Text(
                DateFormat('dd MMM yyyy').format(
                  DateTime.parse(payment.paymentDate),
                ),
              ),
              Text(
                payment.paymentMethod == 'midtrans'
                    ? 'Midtrans'
                    : 'Transfer Manual',
              ),
              Text(currencyFormat.format(payment.amount)),
              _buildPaymentStatusBadge(payment.status),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => _showPaymentDetailDialog(context, payment),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                    minimumSize: const Size(60, 32),
                  ),
                  child: const Text('Detail', style: TextStyle(fontSize: 12)),
                ),
              ),
            ];
          }).toList(),
          emptyMessage: 'Belum ada riwayat pembayaran.',
        );
      },
    );
  }

  void _showPaymentDetailDialog(BuildContext context, payment) {
    final status = (payment.status as String).toLowerCase();

    Color statusColor(String s) {
      switch (s) {
        case 'verified':
        case 'paid':
          return Colors.green.shade700;
        case 'pending':
          return Colors.orange.shade700;
        case 'rejected':
        case 'failed':
          return Colors.red.shade600;
        case 'refunded':
          return Colors.blue.shade600;
        default:
          return Colors.grey.shade600;
      }
    }

    Color statusBg(String s) {
      switch (s) {
        case 'verified':
        case 'paid':
          return Colors.green.shade50;
        case 'pending':
          return Colors.orange.shade50;
        case 'rejected':
        case 'failed':
          return Colors.red.shade50;
        case 'refunded':
          return Colors.blue.shade50;
        default:
          return Colors.grey.shade100;
      }
    }

    IconData statusIcon(String s) {
      switch (s) {
        case 'verified':
        case 'paid':
          return Icons.check_circle_outline;
        case 'pending':
          return Icons.hourglass_top;
        case 'rejected':
        case 'failed':
          return Icons.cancel_outlined;
        case 'refunded':
          return Icons.replay;
        default:
          return Icons.info_outline;
      }
    }

    String methodLabel(String m) =>
        m == 'midtrans' ? 'Midtrans / QRIS' : 'Transfer Manual';

    String formatDateTime(String d) {
      final dt = DateTime.tryParse(d);
      return dt != null
          ? DateFormat('dd MMM yyyy, HH:mm').format(dt)
          : '-';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusBg(status),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                statusIcon(status),
                color: statusColor(status),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Pembayaran',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    payment.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor(status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Info utama ────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'No. Invoice',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                Text(
                                  payment.invoiceNumber ?? '-',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (payment.roomNumber != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Kamar ${payment.roomNumber}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Nominal',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              Text(
                                currencyFormat.format(payment.amount),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                methodLabel(payment.paymentMethod),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: payment.paymentMethod == 'midtrans'
                                      ? Colors.indigo.shade600
                                      : Colors.teal.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tanggal Pembayaran',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              Text(
                                formatDateTime(payment.paymentDate),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          if (payment.updatedAt != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Tanggal Diproses',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                Text(
                                  formatDateTime(payment.updatedAt!),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (payment.transactionId != null) ...[
                        const Divider(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.tag,
                              size: 13,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'ID Transaksi: ${payment.transactionId}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Catatan admin (khususnya jika ditolak) ────────────
                if (payment.adminNotes != null &&
                    (payment.adminNotes as String).isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Catatan Admin',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: status == 'rejected'
                          ? Colors.red.shade50
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: status == 'rejected'
                            ? Colors.red.shade200
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Text(
                      payment.adminNotes as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],

                // ── Bukti transfer ────────────────────────────────────
                const SizedBox(height: 14),
                const Text(
                  'Bukti Transfer:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: (payment.paymentProofUrl != null &&
                          (payment.paymentProofUrl as String).isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            payment.paymentProofUrl as String,
                            fit: BoxFit.contain,
                            loadingBuilder: (_, child, progress) =>
                                progress == null
                                    ? child
                                    : const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                            errorBuilder: (_, __, ___) => Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.broken_image_outlined,
                                    size: 40,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Gambar tidak dapat dimuat',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                payment.paymentMethod == 'midtrans'
                                    ? 'Pembayaran dilakukan via Midtrans'
                                    : 'Tidak ada bukti transfer',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(String status) {
    Color color;
    String label;
    switch (status.toLowerCase()) {
      case 'verified':
      case 'paid':
        color = Colors.green;
        label = status.toUpperCase();
        break;
      case 'pending':
        color = Colors.orange;
        label = 'MENUNGGU';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'DITOLAK';
        break;
      case 'failed':
        color = Colors.red;
        label = 'GAGAL';
        break;
      case 'refunded':
        color = Colors.purple;
        label = 'DIKEMBALIKAN';
        break;
      default:
        color = Colors.grey;
        label = status.toUpperCase();
    }

    return _buildStatusBadge(label, color);
  }

  void _showPaymentMethodDialog(BuildContext context, int invoiceId) {
    final state = context.read<MemberFinanceBloc>().state;

    if (!state.isMidtransEnabled) {
      _showManualPaymentDialog(context, invoiceId);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pilih Metode Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code, color: Colors.indigo),
              title: const Text('Pembayaran Online (Midtrans)'),
              subtitle: const Text('Otomatis & Cepat'),
              onTap: () {
                Navigator.pop(ctx);
                context.read<MemberFinanceBloc>().add(
                  PayInvoiceEvent(invoiceId, 'midtrans'),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.teal),
              title: const Text('Transfer Manual'),
              subtitle: const Text('Upload bukti transfer'),
              onTap: () {
                Navigator.pop(ctx);
                _showManualPaymentDialog(context, invoiceId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showManualPaymentDialog(BuildContext context, int invoiceId) {
    PlatformFile? selectedFile;
    final state = context.read<MemberFinanceBloc>().state;

    final bankName = state.bankName.isNotEmpty ? state.bankName : 'Bank BSI';
    final bankAccount =
        state.bankAccount.isNotEmpty ? state.bankAccount : '—';
    final bankHolder = state.bankHolder.isNotEmpty
        ? state.bankHolder
        : 'Wisma Amal Gorontalo';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Upload Bukti Transfer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Silakan transfer ke rekening berikut:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      bankName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      bankAccount,
                      style: const TextStyle(
                        fontSize: 18,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text('a.n. $bankHolder'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (selectedFile != null) ...[
                Text(
                  'File terpilih: ${selectedFile!.name}',
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
                const SizedBox(height: 8),
              ],
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                    withData: true,
                  );
                  if (result != null) {
                    setState(() => selectedFile = result.files.first);
                  }
                },
                icon: const Icon(Icons.image),
                label: Text(
                  selectedFile == null ? 'Pilih Gambar Bukti' : 'Ganti Gambar',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: selectedFile == null
                  ? null
                  : () {
                      context.read<MemberFinanceBloc>().add(
                        PayInvoiceEvent(
                          invoiceId,
                          'manual',
                          paymentProofBytes: selectedFile!.bytes,
                          paymentProofName: selectedFile!.name,
                        ),
                      );
                      Navigator.pop(ctx);
                    },
              child: const Text('Kirim Bukti'),
            ),
          ],
        ),
      ),
    );
  }
}
