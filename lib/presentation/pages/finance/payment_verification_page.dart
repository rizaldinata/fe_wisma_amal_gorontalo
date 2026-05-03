import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../domain/entity/finance/payment_entity.dart';
import '../../bloc/payment_verification/payment_verification_bloc.dart';
import '../../bloc/payment_verification/payment_verification_event.dart';
import '../../bloc/payment_verification/payment_verification_state.dart';
import '../../widget/core/card/basic_card.dart';

// @RoutePage()
// class PaymentVerificationPage extends StatelessWidget {
//   const PaymentVerificationPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) =>
//           serviceLocator<PaymentVerificationBloc>()
//             ..add(FetchPendingPayments()),
//       child: const PaymentVerificationView(),
//     );
//   }
// }

@RoutePage()
class PaymentVerificationPage extends StatefulWidget {
  const PaymentVerificationPage({super.key});

  @override
  State<PaymentVerificationPage> createState() =>
      _PaymentVerificationPageState();
}

class _PaymentVerificationPageState extends State<PaymentVerificationPage> {
  late PaymentVerificationBloc _bloc;

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  static const int _perPage = 10;

  // @override
  // void initState() {
  //   super.initState();
  // }
  @override
  void initState() {
    super.initState();

    _bloc = serviceLocator<PaymentVerificationBloc>();

    _bloc.add(FetchPendingPayments());
  }

  @override
  void dispose() {
    _bloc.close();
    _searchController.dispose();
    super.dispose();
  }

  String formatRupiah(double v) => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(v);

  String formatDate(String d) {
    final dt = DateTime.tryParse(d);
    return dt != null
        ? DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt)
        : '-';
  }

  String _methodLabel(String m) =>
      m == 'midtrans' ? 'Midtrans / QRIS' : 'Transfer Manual';
  IconData _methodIcon(String m) =>
      m == 'midtrans' ? Icons.qr_code : Icons.account_balance;
  Color _methodColor(String m) =>
      m == 'midtrans' ? Colors.indigo.shade600 : Colors.teal.shade600;

  List<PaymentEntity> _filtered(List<PaymentEntity> all) {
    if (_searchQuery.isEmpty) return all;
    final q = _searchQuery.toLowerCase();
    return all
        .where(
          (p) =>
              (p.transactionId?.toLowerCase().contains(q) ?? false) ||
              p.id.toString().contains(q) ||
              p.invoiceId.toString().contains(q),
        )
        .toList();
  }

  List<PaymentEntity> _paged(List<PaymentEntity> list) {
    final start = (_currentPage - 1) * _perPage;
    if (start >= list.length) return [];
    return list.sublist(start, (start + _perPage).clamp(0, list.length));
  }

  int _totalPages(int count) => (count / _perPage).ceil().clamp(1, 9999);

  // ─── Dialog Verifikasi ─────────────────────────────────────────────────────
  void _showVerificationDialog(PaymentEntity payment) {
    final notesCtrl = TextEditingController(text: payment.adminNotes ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.verified_user_outlined,
                color: Colors.orange.shade700,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verifikasi Pembayaran',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'ID #${payment.transactionId ?? payment.id}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info pembayaran
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nominal',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            Text(
                              formatRupiah(payment.amount),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Metode',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          Text(
                            _methodLabel(payment.paymentMethod),
                            style: TextStyle(
                              fontSize: 13,
                              color: _methodColor(payment.paymentMethod),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Invoice #${payment.invoiceId}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Bukti transfer
                const Text(
                  'Bukti Transfer:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child:
                      (payment.paymentProofUrl != null &&
                          payment.paymentProofUrl!.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            payment.paymentProofUrl!,
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
                                'Tidak ada bukti transfer',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 14),

                // Catatan
                Text(
                  'Catatan Penolakan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Wajib diisi jika pembayaran ditolak',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText:
                        'Contoh: Bukti transfer buram, nominal tidak sesuai...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.all(12),
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
          // Tolak
          OutlinedButton.icon(
            icon: Icon(Icons.close, size: 16, color: Colors.red.shade600),
            label: Text('Tolak', style: TextStyle(color: Colors.red.shade600)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.red.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (notesCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Catatan wajib diisi jika menolak!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              _bloc.add(
                VerifyPaymentEvent(
                  paymentId: payment.id,
                  isApproved: false,
                  adminNotes: notesCtrl.text,
                ),
              );
              Navigator.pop(ctx);
            },
          ),
          // Refund (hanya Midtrans)
          if (payment.paymentMethod == 'midtrans')
            OutlinedButton.icon(
              icon: Icon(Icons.replay, size: 16, color: Colors.orange.shade700),
              label: Text(
                'Refund',
                style: TextStyle(color: Colors.orange.shade700),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.orange.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _showRefundDialog(payment);
              },
            ),
          // Setujui
          FilledButton.icon(
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Setujui'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              _bloc.add(
                VerifyPaymentEvent(paymentId: payment.id, isApproved: true),
              );
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  // ─── Dialog Refund ─────────────────────────────────────────────────────────
  void _showRefundDialog(PaymentEntity payment) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.replay, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text(
              'Proses Refund',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Fitur ini akan mengembalikan dana ke rekening pengguna secara otomatis melalui Midtrans.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Alasan Refund',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: reasonCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Jelaskan alasan refund...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.replay, size: 16),
            label: const Text('Kirim Refund'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (reasonCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alasan refund wajib diisi!')),
                );
                return;
              }
              _bloc.add(
                RefundPaymentEvent(
                  paymentId: payment.id,
                  reason: reasonCtrl.text,
                ),
              );
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<PaymentVerificationBloc, PaymentVerificationState>(
        listener: (ctx, state) {
          if (state is PaymentVerificationActionSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            _bloc.add(FetchPendingPayments());
          } else if (state is PaymentVerificationError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verifikasi Pembayaran',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Tinjau dan konfirmasi bukti transfer pembayaran dari penghuni.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _bloc.add(FetchPendingPayments()),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Refresh'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                BlocBuilder<PaymentVerificationBloc, PaymentVerificationState>(
                  buildWhen: (p, c) =>
                      c is PaymentVerificationLoading ||
                      c is PaymentVerificationLoaded,
                  builder: (ctx, state) {
                    if (state is PaymentVerificationLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(60),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (state is! PaymentVerificationLoaded)
                      return const SizedBox.shrink();

                    final all = state.pendingPayments;
                    final manual = all
                        .where((p) => p.paymentMethod != 'midtrans')
                        .length;
                    final midtrans = all
                        .where((p) => p.paymentMethod == 'midtrans')
                        .length;
                    final totalNominal = all.fold(0.0, (s, p) => s + p.amount);

                    final filtered = _filtered(all);
                    final totalPages = _totalPages(filtered.length);
                    final page = _currentPage.clamp(1, totalPages);
                    final paged = _paged(filtered);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Summary cards ────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: _summaryCard(
                                'Menunggu Verifikasi',
                                '${all.length} Transaksi',
                                'Perlu tindak lanjut admin',
                                Icons.hourglass_top,
                                Colors.orange.shade700,
                                Colors.orange.shade50,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _summaryCard(
                                'Transfer Manual',
                                '$manual Transaksi',
                                'Upload bukti transfer',
                                Icons.account_balance,
                                Colors.teal.shade700,
                                Colors.teal.shade50,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _summaryCard(
                                'Midtrans / QRIS',
                                '$midtrans Transaksi',
                                'Pembayaran digital',
                                Icons.qr_code,
                                Colors.indigo.shade700,
                                Colors.indigo.shade50,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _summaryCard(
                                'Total Nominal',
                                formatRupiah(totalNominal),
                                'Dari semua transaksi pending',
                                Icons.account_balance_wallet_outlined,
                                Colors.purple.shade700,
                                Colors.purple.shade50,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ── Search ───────────────────────────────────────
                        BasicCard(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) => setState(() {
                                _searchQuery = v;
                                _currentPage = 1;
                              }),
                              decoration: InputDecoration(
                                hintText:
                                    'Cari berdasarkan ID transaksi atau nomor invoice...',
                                prefixIcon: const Icon(Icons.search, size: 20),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _searchQuery = '';
                                            _currentPage = 1;
                                          });
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Table ────────────────────────────────────────
                        BasicCard(
                          child: Column(
                            children: [
                              // Header
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: _th('ID Transaksi'),
                                    ),
                                    Expanded(flex: 2, child: _th('Invoice')),
                                    Expanded(flex: 2, child: _th('Nominal')),
                                    Expanded(flex: 2, child: _th('Metode')),
                                    Expanded(
                                      flex: 2,
                                      child: _th('Tanggal Upload'),
                                    ),
                                    const SizedBox(width: 100),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),

                              if (paged.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(48),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.task_alt,
                                          size: 56,
                                          color: Colors.green.shade300,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _searchQuery.isEmpty
                                              ? 'Tidak ada pembayaran yang menunggu verifikasi.'
                                              : 'Tidak ada hasil untuk "$_searchQuery".',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 15,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        if (_searchQuery.isEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Semua pembayaran sudah diproses!',
                                            style: TextStyle(
                                              color: Colors.grey.shade400,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ...paged.asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final payment = entry.value;
                                  final isLast = i == paged.length - 1;
                                  final hasProof =
                                      payment.paymentProofUrl != null &&
                                      payment.paymentProofUrl!.isNotEmpty;

                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 14,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // ID Transaksi
                                            Expanded(
                                              flex: 3,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 38,
                                                    height: 38,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.orange.shade50,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      Icons.pending_actions,
                                                      color: Colors
                                                          .orange
                                                          .shade700,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        payment.transactionId ??
                                                            'ID #${payment.id}',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            hasProof
                                                                ? Icons.image
                                                                : Icons
                                                                      .image_not_supported_outlined,
                                                            size: 13,
                                                            color: hasProof
                                                                ? Colors
                                                                      .green
                                                                      .shade600
                                                                : Colors
                                                                      .grey
                                                                      .shade400,
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Text(
                                                            hasProof
                                                                ? 'Ada bukti'
                                                                : 'Tanpa bukti',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color: hasProof
                                                                  ? Colors
                                                                        .green
                                                                        .shade600
                                                                  : Colors
                                                                        .grey
                                                                        .shade400,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Invoice
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                '#${payment.invoiceId}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ),

                                            // Nominal
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                formatRupiah(payment.amount),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),

                                            // Metode
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    _methodIcon(
                                                      payment.paymentMethod,
                                                    ),
                                                    size: 16,
                                                    color: _methodColor(
                                                      payment.paymentMethod,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Flexible(
                                                    child: Text(
                                                      _methodLabel(
                                                        payment.paymentMethod,
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: _methodColor(
                                                          payment.paymentMethod,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Tanggal
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                formatDate(payment.paymentDate),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ),

                                            // Aksi
                                            SizedBox(
                                              width: 100,
                                              child: FilledButton(
                                                onPressed: () =>
                                                    _showVerificationDialog(
                                                      payment,
                                                    ),
                                                style: FilledButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.orange.shade600,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  minimumSize: const Size(
                                                    90,
                                                    36,
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Cek Bukti',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!isLast)
                                        const Divider(height: 1, indent: 70),
                                    ],
                                  );
                                }),

                              const Divider(height: 1),

                              // Footer + pagination
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Menampilkan ${paged.length} dari ${filtered.length} transaksi',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    const Spacer(),
                                    _PaginationBar(
                                      currentPage: page,
                                      totalPages: totalPages,
                                      onPageChanged: (p) =>
                                          setState(() => _currentPage = p),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _th(String label) => Text(
    label,
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Colors.grey.shade600,
      letterSpacing: 0.5,
    ),
  );

  Widget _summaryCard(
    String title,
    String value,
    String sub,
    IconData icon,
    Color textColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(color: textColor.withOpacity(0.65), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── Pagination Bar ──────────────────────────────────────────────────────────
class _PaginationBar extends StatelessWidget {
  final int currentPage, totalPages;
  final ValueChanged<int> onPageChanged;
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    int start = (currentPage - 2).clamp(1, totalPages);
    int end = (start + 4).clamp(1, totalPages);
    start = (end - 4).clamp(1, totalPages);
    final pages = List.generate(end - start + 1, (i) => start + i);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _nav(
          context,
          Icons.chevron_left,
          currentPage > 1,
          () => onPageChanged(currentPage - 1),
        ),
        const SizedBox(width: 4),
        if (start > 1) ...[
          _btn(context, 1, false),
          if (start > 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('...', style: TextStyle(color: Colors.grey.shade500)),
            ),
        ],
        ...pages.map(
          (p) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _btn(context, p, p == currentPage),
          ),
        ),
        if (end < totalPages) ...[
          if (end < totalPages - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('...', style: TextStyle(color: Colors.grey.shade500)),
            ),
          _btn(context, totalPages, false),
        ],
        const SizedBox(width: 4),
        _nav(
          context,
          Icons.chevron_right,
          currentPage < totalPages,
          () => onPageChanged(currentPage + 1),
        ),
      ],
    );
  }

  Widget _btn(BuildContext ctx, int page, bool active) {
    return GestureDetector(
      onTap: () => onPageChanged(page),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: active ? Theme.of(ctx).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: active ? null : Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: Text(
          '$page',
          style: TextStyle(
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? Colors.white : Colors.grey.shade700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _nav(
    BuildContext ctx,
    IconData icon,
    bool enabled,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: enabled ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
    );
  }
}
