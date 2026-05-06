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
    // Standard Midtrans Snap URL (Sandbox)
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
                  height: 500, // Fixed height for tab content
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
        if (state.summary == null || state.summary!.activeLease == null)
          return const SizedBox.shrink();

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
        final unpaid = state.summary?.totalUnpaid ?? 0.0;
        final leaseStatus = state.summary?.activeLease != null
            ? 'Aktif'
            : 'Tidak Ada';
        final endDate = state.summary?.activeLease != null
            ? DateFormat(
                'dd MMM yyyy',
              ).format(state.summary!.activeLease!.endDate)
            : '-';

        return Row(
          children: [
            Expanded(
              child: _summaryCard(
                'Total Tagihan',
                currencyFormat.format(unpaid),
                'Perlu segera dibayar',
                Icons.account_balance_wallet,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _summaryCard(
                'Status Sewa',
                leaseStatus.toUpperCase(),
                'Berakhir: $endDate',
                Icons.home,
                Colors.blue,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    String sub,
    IconData icon,
    Color color,
  ) {
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
            .where((i) => i.status.toLowerCase() != 'paid')
            .toList();

        return TableCard(
          title: 'Tagihan Belum Dibayar',
          columns: const [
            TableColumn(label: 'No. Invoice', flex: 3),
            TableColumn(label: 'Jatuh Tempo', flex: 2),
            TableColumn(label: 'Jumlah', flex: 2),
            TableColumn(label: 'Aksi', flex: 2, align: TextAlign.right),
          ],
          rows: unpaidInvoices.map((invoice) {
            return [
              Text(
                invoice.invoiceNumber,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(DateFormat('dd MMM yyyy').format(invoice.dueDate)),
              Text(
                currencyFormat.format(invoice.amount),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
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
                  child: const Text('Bayar', style: TextStyle(fontSize: 12)),
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
            TableColumn(label: 'Status', flex: 2, align: TextAlign.right),
          ],
          rows: state.payments.map((payment) {
            return [
              Text(
                DateFormat(
                  'dd MMM yyyy',
                ).format(DateTime.parse(payment.paymentDate)),
              ),
              Text(payment.paymentMethod.toUpperCase()),
              Text(currencyFormat.format(payment.amount)),
              Align(
                alignment: Alignment.centerRight,
                child: _buildStatusBadge(payment.status),
              ),
            ];
          }).toList(),
          emptyMessage: 'Belum ada riwayat pembayaran.',
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status.toLowerCase() == 'paid' || status.toLowerCase() == 'verified')
      color = Colors.green;
    if (status.toLowerCase() == 'pending') color = Colors.orange;
    if (status.toLowerCase() == 'failed' || status.toLowerCase() == 'rejected')
      color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
                child: const Column(
                  children: [
                    Text(
                      'Bank BSI',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '7123456789',
                      style: TextStyle(fontSize: 18, letterSpacing: 1.2),
                    ),
                    Text('a.n. Wisma Amal Gorontalo'),
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
