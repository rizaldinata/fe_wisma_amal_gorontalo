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
import '../../widget/core/table/table.dart';
import '../../../domain/entity/table/tabel_colum.dart';

@RoutePage()
class PaymentVerificationPage extends StatefulWidget {
  const PaymentVerificationPage({super.key});

  @override
  State<PaymentVerificationPage> createState() => _PaymentVerificationPageState();
}

class _PaymentVerificationPageState extends State<PaymentVerificationPage> {
  late PaymentVerificationBloc _bloc;

  // Search & filter — tabel atas (pending)
  String _searchPending = '';
  final TextEditingController _searchPendingCtrl = TextEditingController();
  int _pagePending = 1;

  // Search & filter — tabel bawah (semua)
  String _searchAll = '';
  String _statusFilter = 'Semua';
  int? _filterYear;
  int? _filterMonth;
  final TextEditingController _searchAllCtrl = TextEditingController();
  int _pageAll = 1;

  static const int _perPage = 10;
  static const _statusOptions = ['Semua', 'Menunggu', 'Disetujui', 'Ditolak', 'Refund'];

  @override
  void initState() {
    super.initState();
    _bloc = serviceLocator<PaymentVerificationBloc>();
    _bloc.add(FetchAllPayments());
  }

  @override
  void dispose() {
    _searchPendingCtrl.dispose();
    _searchAllCtrl.dispose();
    super.dispose();
  }

  String formatRupiah(double v) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(v);

  String formatDate(String d) {
    final dt = DateTime.tryParse(d);
    return dt != null ? DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt) : '-';
  }

  String _methodLabel(String m) => m == 'midtrans' ? 'Midtrans / QRIS' : 'Transfer Manual';
  IconData _methodIcon(String m) => m == 'midtrans' ? Icons.qr_code : Icons.account_balance;
  Color _methodColor(String m) =>
      m == 'midtrans' ? Colors.indigo.shade600 : Colors.teal.shade600;

  String _statusLabel(String s) {
    switch (s.toLowerCase()) {
      case 'pending':    return 'Menunggu';
      case 'verified':   return 'Disetujui';
      case 'rejected':   return 'Ditolak';
      case 'refunded':   return 'Refund';
      case 'paid':       return 'Disetujui';
      case 'failed':     return 'Gagal';
      default:           return s;
    }
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'pending':           return Colors.orange.shade700;
      case 'verified':
      case 'paid':              return Colors.green.shade700;
      case 'rejected':
      case 'failed':            return Colors.red.shade600;
      case 'refunded':          return Colors.blue.shade600;
      default:                  return Colors.grey.shade600;
    }
  }

  Color _statusBg(String s) {
    switch (s.toLowerCase()) {
      case 'pending':           return Colors.orange.shade50;
      case 'verified':
      case 'paid':              return Colors.green.shade50;
      case 'rejected':
      case 'failed':            return Colors.red.shade50;
      case 'refunded':          return Colors.blue.shade50;
      default:                  return Colors.grey.shade100;
    }
  }

  IconData _statusIcon(String s) {
    switch (s.toLowerCase()) {
      case 'pending':           return Icons.hourglass_top;
      case 'verified':
      case 'paid':              return Icons.check_circle_outline;
      case 'rejected':
      case 'failed':            return Icons.cancel_outlined;
      case 'refunded':          return Icons.replay;
      default:                  return Icons.info_outline;
    }
  }

  bool _isPending(PaymentEntity p) => p.status.toLowerCase() == 'pending';

  bool _matchSearch(PaymentEntity p, String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return (p.residentName?.toLowerCase().contains(q) ?? false) ||
        (p.roomNumber?.toLowerCase().contains(q) ?? false) ||
        (p.invoiceNumber?.toLowerCase().contains(q) ?? false) ||
        (p.transactionId?.toLowerCase().contains(q) ?? false);
  }

  List<PaymentEntity> _filteredPending(List<PaymentEntity> all) =>
      all.where((p) => _isPending(p) && _matchSearch(p, _searchPending)).toList();

  String _allTableTitle() {
    final parts = <String>[];
    if (_filterMonth != null && _filterYear != null) {
      parts.add(DateFormat('MMMM yyyy', 'id_ID').format(DateTime(_filterYear!, _filterMonth!)));
    } else if (_filterYear != null) {
      parts.add('Tahun $_filterYear');
    } else if (_filterMonth != null) {
      parts.add(DateFormat('MMMM', 'id_ID').format(DateTime(0, _filterMonth!)));
    }
    if (_statusFilter != 'Semua') parts.add(_statusFilter);
    return parts.isEmpty ? 'Semua Pembayaran' : 'Pembayaran — ${parts.join(' · ')}';
  }

  List<int> _availableYears(List<PaymentEntity> all) {
    final years = all
        .map((p) => DateTime.tryParse(p.paymentDate)?.year)
        .whereType<int>()
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    return years;
  }

  List<PaymentEntity> _filteredAll(List<PaymentEntity> all) => all.where((p) {
        if (_filterYear != null) {
          final dt = DateTime.tryParse(p.paymentDate);
          if (dt == null || dt.year != _filterYear) return false;
        }
        if (_filterMonth != null) {
          final dt = DateTime.tryParse(p.paymentDate);
          if (dt == null || dt.month != _filterMonth) return false;
        }
        if (_statusFilter != 'Semua' && _statusLabel(p.status) != _statusFilter) return false;
        return _matchSearch(p, _searchAll);
      }).toList();

  List<PaymentEntity> _paged(List<PaymentEntity> list, int page) {
    final start = (page - 1) * _perPage;
    if (start >= list.length) return [];
    return list.sublist(start, (start + _perPage).clamp(0, list.length));
  }

  int _totalPages(int count) => (count / _perPage).ceil().clamp(1, 9999);

  // ─── Dialog Verifikasi (untuk payment pending) ────────────────────────────
  void _showVerificationDialog(PaymentEntity payment) {
    final notesCtrl = TextEditingController(text: payment.adminNotes ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.verified_user_outlined, color: Colors.orange.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Verifikasi Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(payment.invoiceNumber ?? 'ID #${payment.id}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.normal)),
          ])),
        ]),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 460,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Info penghuni + nominal
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                child: Column(children: [
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Penghuni', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      Text(payment.residentName ?? '-', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      if (payment.roomNumber != null)
                        Text('Kamar ${payment.roomNumber}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('Nominal', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      Text(formatRupiah(payment.amount), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(_methodLabel(payment.paymentMethod),
                          style: TextStyle(fontSize: 12, color: _methodColor(payment.paymentMethod), fontWeight: FontWeight.w600)),
                    ]),
                  ]),
                  if (payment.transactionId != null) ...[
                    const Divider(height: 16),
                    Row(children: [
                      Icon(Icons.tag, size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text('ID Transaksi: ${payment.transactionId}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ]),
                  ],
                ]),
              ),
              const SizedBox(height: 14),

              // Bukti transfer
              const Text('Bukti Transfer:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                child: (payment.paymentProofUrl != null && payment.paymentProofUrl!.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          payment.paymentProofUrl!,
                          fit: BoxFit.contain,
                          loadingBuilder: (_, child, progress) =>
                              progress == null ? child : const Center(child: CircularProgressIndicator()),
                          errorBuilder: (_, __, ___) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text('Gambar tidak dapat dimuat', style: TextStyle(color: Colors.grey.shade500)),
                          ])),
                        ),
                      )
                    : Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text('Tidak ada bukti transfer', style: TextStyle(color: Colors.grey.shade500)),
                      ])),
              ),
              const SizedBox(height: 14),

              // Catatan penolakan
              Text('Catatan Penolakan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
              const SizedBox(height: 2),
              Text('Wajib diisi jika pembayaran ditolak', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              const SizedBox(height: 8),
              TextField(
                controller: notesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Contoh: Bukti transfer buram, nominal tidak sesuai...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
          OutlinedButton.icon(
            icon: Icon(Icons.close, size: 16, color: Colors.red.shade600),
            label: Text('Tolak', style: TextStyle(color: Colors.red.shade600)),
            style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.red.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              if (notesCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Catatan wajib diisi jika menolak!'), backgroundColor: Colors.red));
                return;
              }
              _bloc.add(VerifyPaymentEvent(paymentId: payment.id, isApproved: false, adminNotes: notesCtrl.text));
              Navigator.pop(ctx);
            },
          ),
          if (payment.paymentMethod == 'midtrans')
            OutlinedButton.icon(
              icon: Icon(Icons.replay, size: 16, color: Colors.orange.shade700),
              label: Text('Refund', style: TextStyle(color: Colors.orange.shade700)),
              style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.orange.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () { Navigator.pop(ctx); _showRefundDialog(payment); },
            ),
          FilledButton.icon(
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Setujui'),
            style: FilledButton.styleFrom(backgroundColor: Colors.green.shade600, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              _bloc.add(VerifyPaymentEvent(paymentId: payment.id, isApproved: true));
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  // ─── Dialog Detail (untuk payment yang sudah diproses) ────────────────────
  void _showDetailDialog(PaymentEntity payment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _statusBg(payment.status), borderRadius: BorderRadius.circular(8)),
            child: Icon(_statusIcon(payment.status), color: _statusColor(payment.status), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Detail Pembayaran', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(_statusLabel(payment.status),
                style: TextStyle(fontSize: 12, color: _statusColor(payment.status), fontWeight: FontWeight.w600)),
          ])),
        ]),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 460,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Info penghuni + nominal
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                child: Column(children: [
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Penghuni', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      Text(payment.residentName ?? '-', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      if (payment.roomNumber != null)
                        Text('Kamar ${payment.roomNumber}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      if (payment.invoiceNumber != null) ...[
                        const SizedBox(height: 2),
                        Text(payment.invoiceNumber!, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('Nominal', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      Text(formatRupiah(payment.amount), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(_methodLabel(payment.paymentMethod),
                          style: TextStyle(fontSize: 12, color: _methodColor(payment.paymentMethod), fontWeight: FontWeight.w600)),
                    ]),
                  ]),
                  const Divider(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Tanggal Pembayaran', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      Text(formatDate(payment.paymentDate), style: const TextStyle(fontSize: 12)),
                    ]),
                    if (payment.updatedAt != null)
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('Tanggal Diproses', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        Text(formatDate(payment.updatedAt!), style: const TextStyle(fontSize: 12)),
                      ]),
                  ]),
                ]),
              ),
              const SizedBox(height: 14),

              // Catatan admin (jika ada)
              if (payment.adminNotes != null && payment.adminNotes!.isNotEmpty) ...[
                Text('Catatan Admin', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: payment.status.toLowerCase() == 'rejected' ? Colors.red.shade50 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: payment.status.toLowerCase() == 'rejected' ? Colors.red.shade200 : Colors.grey.shade200),
                  ),
                  child: Text(payment.adminNotes!, style: TextStyle(fontSize: 13, color: Colors.grey.shade800)),
                ),
                const SizedBox(height: 14),
              ],

              // Bukti transfer
              const Text('Bukti Transfer:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                child: (payment.paymentProofUrl != null && payment.paymentProofUrl!.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          payment.paymentProofUrl!,
                          fit: BoxFit.contain,
                          loadingBuilder: (_, child, progress) =>
                              progress == null ? child : const Center(child: CircularProgressIndicator()),
                          errorBuilder: (_, __, ___) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text('Gambar tidak dapat dimuat', style: TextStyle(color: Colors.grey.shade500)),
                          ])),
                        ),
                      )
                    : Center(child: Text('Tidak ada bukti transfer', style: TextStyle(color: Colors.grey.shade500))),
              ),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        ],
      ),
    );
  }

  // ─── Dialog Refund ────────────────────────────────────────────────────────
  void _showRefundDialog(PaymentEntity payment) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(Icons.replay, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          const Text('Proses Refund', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
        content: SizedBox(
          width: 380,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
              child: Row(children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red.shade600, size: 18),
                const SizedBox(width: 8),
                const Expanded(child: Text('Fitur ini akan mengembalikan dana ke rekening pengguna secara otomatis melalui Midtrans.', style: TextStyle(fontSize: 12))),
              ]),
            ),
            const SizedBox(height: 14),
            const Text('Alasan Refund', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: reasonCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Jelaskan alasan refund...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton.icon(
            icon: const Icon(Icons.replay, size: 16),
            label: const Text('Kirim Refund'),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange.shade700, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              if (reasonCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alasan refund wajib diisi!')));
                return;
              }
              _bloc.add(RefundPaymentEvent(paymentId: payment.id, reason: reasonCtrl.text));
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
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
          } else if (state is PaymentVerificationError) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── Header ──────────────────────────────────────────────
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Verifikasi Pembayaran', style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 6),
                  const Text('Tinjau, konfirmasi, dan pantau riwayat seluruh pembayaran penghuni.',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ])),
                OutlinedButton.icon(
                  onPressed: () => _bloc.add(FetchAllPayments()),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ]),
              const SizedBox(height: 28),

              BlocBuilder<PaymentVerificationBloc, PaymentVerificationState>(
                buildWhen: (p, c) => c is PaymentVerificationLoading || c is PaymentVerificationLoaded,
                builder: (ctx, state) {
                  if (state is PaymentVerificationLoading) {
                    return const Center(child: Padding(padding: EdgeInsets.all(60), child: CircularProgressIndicator()));
                  }
                  if (state is! PaymentVerificationLoaded) return const SizedBox.shrink();

                  final all = state.payments;
                  final years = _availableYears(all);
                  final pendingCount  = all.where((p) => p.status.toLowerCase() == 'pending').length;
                  final verifiedCount = all.where((p) => ['verified', 'paid'].contains(p.status.toLowerCase())).length;
                  final rejectedCount = all.where((p) => ['rejected', 'failed'].contains(p.status.toLowerCase())).length;
                  final totalVerified = all.where((p) => ['verified', 'paid'].contains(p.status.toLowerCase())).fold(0.0, (s, p) => s + p.amount);

                  // Data tabel atas (pending)
                  final filteredPending = _filteredPending(all);
                  final totalPagesPending = _totalPages(filteredPending.length);
                  final pagePending = _pagePending.clamp(1, totalPagesPending);
                  final pagedPending = _paged(filteredPending, pagePending);

                  // Data tabel bawah (semua)
                  final filteredAll = _filteredAll(all);
                  final totalPagesAll = _totalPages(filteredAll.length);
                  final pageAll = _pageAll.clamp(1, totalPagesAll);
                  final pagedAll = _paged(filteredAll, pageAll);

                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // ── Summary cards ────────────────────────────────
                    Row(children: [
                      Expanded(child: _summaryCard('Menunggu Verifikasi', '$pendingCount Transaksi', 'Perlu tindak lanjut', Icons.hourglass_top, Colors.orange.shade700, Colors.orange.shade50)),
                      const SizedBox(width: 16),
                      Expanded(child: _summaryCard('Disetujui', '$verifiedCount Transaksi', formatRupiah(totalVerified), Icons.check_circle_outline, Colors.green.shade700, Colors.green.shade50)),
                      const SizedBox(width: 16),
                      Expanded(child: _summaryCard('Ditolak / Gagal', '$rejectedCount Transaksi', 'Perlu perhatian', Icons.cancel_outlined, Colors.red.shade600, Colors.red.shade50)),
                      const SizedBox(width: 16),
                      Expanded(child: _summaryCard('Total Transaksi', '${all.length} Transaksi', 'Semua status', Icons.receipt_long, Colors.blue.shade700, Colors.blue.shade50)),
                    ]),
                    const SizedBox(height: 24),

                    // ════════════════════════════════════════════════
                    // TABEL ATAS — Menunggu Verifikasi
                    // ════════════════════════════════════════════════
                    BasicCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: TextField(
                          controller: _searchPendingCtrl,
                          onChanged: (v) => setState(() { _searchPending = v; _pagePending = 1; }),
                          decoration: InputDecoration(
                            hintText: 'Cari pada pembayaran menunggu verifikasi...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: _searchPending.isNotEmpty
                                ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchPendingCtrl.clear(); setState(() { _searchPending = ''; _pagePending = 1; }); })
                                : null,
                            border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TableCard(
                      title: 'Menunggu Verifikasi',
                      emptyMessage: _searchPending.isEmpty
                          ? 'Tidak ada pembayaran yang menunggu verifikasi.\nSemua pembayaran sudah diproses!'
                          : 'Tidak ada hasil untuk "$_searchPending".',
                      columns: const [
                        TableColumn(label: 'Penghuni & Tagihan', flex: 4),
                        TableColumn(label: 'Metode', flex: 2),
                        TableColumn(label: 'Nominal', flex: 2),
                        TableColumn(label: 'Tanggal Upload', flex: 2),
                        TableColumn(label: 'Aksi', flex: 2, align: TextAlign.right),
                      ],
                      rows: pagedPending.map((payment) => [
                        _colPenghuni(payment),
                        _colMetode(payment),
                        Text(formatRupiah(payment.amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(formatDate(payment.paymentDate), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          FilledButton(
                            onPressed: () => _showVerificationDialog(payment),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.orange.shade600,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              minimumSize: const Size(90, 36),
                            ),
                            child: const Text('Verifikasi', style: TextStyle(fontSize: 12)),
                          ),
                        ]),
                      ]).toList(),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Row(children: [
                        Text('Menampilkan ${pagedPending.length} dari ${filteredPending.length} transaksi pending',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                        const Spacer(),
                        _PaginationBar(currentPage: pagePending, totalPages: totalPagesPending, onPageChanged: (p) => setState(() => _pagePending = p)),
                      ]),
                    ),
                    const SizedBox(height: 28),

                    // ════════════════════════════════════════════════
                    // TABEL BAWAH — Semua Pembayaran
                    // ════════════════════════════════════════════════
                    BasicCard(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          // Row 1: search + tahun + bulan
                          Row(children: [
                            Expanded(
                              child: TextField(
                                controller: _searchAllCtrl,
                                onChanged: (v) => setState(() { _searchAll = v; _pageAll = 1; }),
                                decoration: InputDecoration(
                                  hintText: 'Cari nama penghuni, kamar, nomor invoice, ID transaksi...',
                                  prefixIcon: const Icon(Icons.search, size: 20),
                                  suffixIcon: _searchAll.isNotEmpty
                                      ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchAllCtrl.clear(); setState(() { _searchAll = ''; _pageAll = 1; }); })
                                      : null,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _YearMonthDropdown(
                              hint: 'Tahun',
                              value: _filterYear,
                              items: [null, ...years],
                              labelBuilder: (v) => v == null ? 'Semua Tahun' : '$v',
                              onChanged: (v) => setState(() { _filterYear = v; _filterMonth = null; _pageAll = 1; }),
                            ),
                            const SizedBox(width: 8),
                            _YearMonthDropdown(
                              hint: 'Bulan',
                              value: _filterMonth,
                              items: [null, ...List.generate(12, (i) => i + 1)],
                              labelBuilder: (v) => v == null ? 'Semua Bulan' : DateFormat('MMMM', 'id_ID').format(DateTime(0, v)),
                              onChanged: (v) => setState(() { _filterMonth = v; _pageAll = 1; }),
                            ),
                            if (_filterYear != null || _filterMonth != null) ...[
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () => setState(() { _filterYear = null; _filterMonth = null; _pageAll = 1; }),
                                icon: const Icon(Icons.close, size: 14),
                                label: const Text('Reset', style: TextStyle(fontSize: 12)),
                                style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
                              ),
                            ],
                          ]),
                          const SizedBox(height: 10),
                          // Row 2: status chips
                          Row(children: [
                            Text('Status:', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                            const SizedBox(width: 8),
                            ..._statusOptions.map((opt) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: GestureDetector(
                                onTap: () => setState(() { _statusFilter = opt; _pageAll = 1; }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _statusFilter == opt ? Theme.of(context).primaryColor : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: _statusFilter == opt ? Theme.of(context).primaryColor : Colors.grey.shade300),
                                  ),
                                  child: Text(opt, style: TextStyle(fontSize: 12, fontWeight: _statusFilter == opt ? FontWeight.w600 : FontWeight.normal, color: _statusFilter == opt ? Colors.white : Colors.grey.shade700)),
                                ),
                              ),
                            )),
                          ]),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TableCard(
                      title: _allTableTitle(),
                      emptyMessage: _searchAll.isEmpty
                          ? 'Tidak ada pembayaran pada kategori ini.'
                          : 'Tidak ada hasil untuk "$_searchAll".',
                      columns: const [
                        TableColumn(label: 'Penghuni & Tagihan', flex: 4),
                        TableColumn(label: 'Metode', flex: 2),
                        TableColumn(label: 'Nominal', flex: 2),
                        TableColumn(label: 'Tanggal', flex: 2),
                        TableColumn(label: 'Status', flex: 2),
                        TableColumn(label: 'Aksi', flex: 2, align: TextAlign.right),
                      ],
                      rows: pagedAll.map((payment) => [
                        _colPenghuni(payment),
                        _colMetode(payment),
                        Text(formatRupiah(payment.amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(formatDate(payment.paymentDate), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: _statusBg(payment.status), borderRadius: BorderRadius.circular(20), border: Border.all(color: _statusColor(payment.status).withOpacity(0.3))),
                          child: Text(_statusLabel(payment.status), style: TextStyle(color: _statusColor(payment.status), fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          if (_isPending(payment))
                            FilledButton(
                              onPressed: () => _showVerificationDialog(payment),
                              style: FilledButton.styleFrom(backgroundColor: Colors.orange.shade600, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), minimumSize: const Size(90, 36)),
                              child: const Text('Verifikasi', style: TextStyle(fontSize: 12)),
                            )
                          else
                            OutlinedButton(
                              onPressed: () => _showDetailDialog(payment),
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), side: BorderSide(color: Colors.grey.shade300), minimumSize: const Size(80, 36)),
                              child: const Text('Detail', style: TextStyle(fontSize: 12)),
                            ),
                        ]),
                      ]).toList(),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Row(children: [
                        Text('Menampilkan ${pagedAll.length} dari ${filteredAll.length} transaksi',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                        const Spacer(),
                        _PaginationBar(currentPage: pageAll, totalPages: totalPagesAll, onPageChanged: (p) => setState(() => _pageAll = p)),
                      ]),
                    ),
                  ]);
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _colPenghuni(PaymentEntity p) => Row(children: [
    Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: _statusBg(p.status), borderRadius: BorderRadius.circular(10)),
      child: Icon(_statusIcon(p.status), color: _statusColor(p.status), size: 20),
    ),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(p.residentName ?? '-', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
      Row(children: [
        if (p.roomNumber != null) ...[
          Icon(Icons.meeting_room_outlined, size: 12, color: Colors.grey.shade500),
          const SizedBox(width: 3),
          Text('Kamar ${p.roomNumber}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(width: 8),
        ],
        if (p.invoiceNumber != null) ...[
          Icon(Icons.receipt_outlined, size: 12, color: Colors.grey.shade400),
          const SizedBox(width: 3),
          Text(p.invoiceNumber!, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
      ]),
    ])),
  ]);

  Widget _colMetode(PaymentEntity p) => Row(children: [
    Icon(_methodIcon(p.paymentMethod), size: 15, color: _methodColor(p.paymentMethod)),
    const SizedBox(width: 6),
    Flexible(child: Text(_methodLabel(p.paymentMethod),
        style: TextStyle(fontSize: 12, color: _methodColor(p.paymentMethod), fontWeight: FontWeight.w600))),
  ]);

  Widget _summaryCard(String title, String value, String sub, IconData icon, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: textColor.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: textColor, size: 20), const SizedBox(width: 8), Expanded(child: Text(title, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)))]),
        const SizedBox(height: 10),
        Text(value, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(sub, style: TextStyle(color: textColor.withOpacity(0.65), fontSize: 11)),
      ]),
    );
  }
}

// ── Year / Month Dropdown ──────────────────────────────────────────────────
class _YearMonthDropdown<T> extends StatelessWidget {
  final String hint;
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;

  const _YearMonthDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          items: items.map((item) => DropdownMenuItem<T>(value: item, child: Text(labelBuilder(item), style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: (v) { if (v != null || null is T) onChanged(v as T); },
          icon: Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey.shade500),
        ),
      ),
    );
  }
}

// ── Pagination Bar ──────────────────────────────────────────────────────────
class _PaginationBar extends StatelessWidget {
  final int currentPage, totalPages;
  final ValueChanged<int> onPageChanged;
  const _PaginationBar({required this.currentPage, required this.totalPages, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    int start = (currentPage - 2).clamp(1, totalPages);
    int end   = (start + 4).clamp(1, totalPages);
    start = (end - 4).clamp(1, totalPages);
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

  Widget _btn(BuildContext ctx, int page, bool active) {
    return GestureDetector(
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
  }

  Widget _nav(BuildContext ctx, IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: enabled ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
    );
  }
}
