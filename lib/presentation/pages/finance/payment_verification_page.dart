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
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../widget/core/appbar/app_topbar.dart';
import '../../widget/core/card/summary_stat_card.dart';

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
  String _methodFilter = 'Semua';
  int? _filterYear;
  int? _filterMonth;
  final TextEditingController _searchAllCtrl = TextEditingController();
  int _pageAll = 1;

  static const int _perPage = 10;
  static const _statusOptions = ['Semua', 'Menunggu', 'Disetujui', 'Ditolak', 'Refund'];
  static const _methodOptions = ['Semua', 'Manual', 'Midtrans'];

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
  Color _methodColor(String m, bool isDark) =>
      m == 'midtrans'
          ? (isDark ? AppColorsDark.primary : AppColorsLight.primary)
          : (isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone);

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

  Color _statusColor(String s, bool isDark) {
    switch (s.toLowerCase()) {
      case 'pending':           return isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;
      case 'verified':
      case 'paid':              return isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone;
      case 'rejected':
      case 'failed':            return isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled;
      case 'refunded':          return isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess;
      default:                  return isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    }
  }

  Color _statusBg(String s, bool isDark) {
    switch (s.toLowerCase()) {
      case 'pending':           return isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg;
      case 'verified':
      case 'paid':              return isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg;
      case 'rejected':
      case 'failed':            return isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg;
      case 'refunded':          return isDark ? AppColorsDark.statusProcessBg : AppColorsLight.statusProcessBg;
      default:                  return isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
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
    if (_methodFilter != 'Semua') parts.add(_methodFilter);
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
        if (_methodFilter != 'Semua') {
          final isManual = p.paymentMethod != 'midtrans';
          if (_methodFilter == 'Manual' && !isManual) return false;
          if (_methodFilter == 'Midtrans' && isManual) return false;
        }
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
    final isDark = AppTheme.isDark(context);

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
                          style: TextStyle(fontSize: 12, color: _methodColor(payment.paymentMethod, isDark), fontWeight: FontWeight.w600)),
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
    final isDark = AppTheme.isDark(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _statusBg(payment.status, isDark), borderRadius: BorderRadius.circular(8)),
            child: Icon(_statusIcon(payment.status), color: _statusColor(payment.status, isDark), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Detail Pembayaran', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(_statusLabel(payment.status),
                style: TextStyle(fontSize: 12, color: _statusColor(payment.status, isDark), fontWeight: FontWeight.w600)),
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
                          style: TextStyle(fontSize: 12, color: _methodColor(payment.paymentMethod, isDark), fontWeight: FontWeight.w600)),
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
    final isDark = AppTheme.isDark(context);
    final bgColor = isDark ? AppColorsDark.background : AppColorsLight.background;

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
          backgroundColor: bgColor,
          body: Column(
            children: [
              AppTopBar(
                title: 'Manajemen Pembayaran',
                breadcrumb: 'Keuangan / Pembayaran',
                action: ElevatedButton.icon(
                  onPressed: () => _bloc.add(FetchAllPayments()),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xxxl),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                      Expanded(child: SummaryStatCard(
                        label: 'Menunggu Verifikasi',
                        value: '$pendingCount Transaksi',
                        icon: Icons.hourglass_top,
                        iconColor: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting,
                        iconBg: isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg,
                        trend: 'Perlu tindak lanjut',
                        trendColor: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting,
                      )),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: SummaryStatCard(
                        label: 'Disetujui',
                        value: '$verifiedCount Transaksi',
                        icon: Icons.check_circle_outline,
                        iconColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
                        iconBg: isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg,
                        trend: formatRupiah(totalVerified),
                        trendColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
                      )),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: SummaryStatCard(
                        label: 'Ditolak / Gagal',
                        value: '$rejectedCount Transaksi',
                        icon: Icons.cancel_outlined,
                        iconColor: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
                        iconBg: isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg,
                        trend: 'Perlu perhatian',
                        trendColor: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
                      )),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: SummaryStatCard(
                        label: 'Total Transaksi',
                        value: '${all.length} Transaksi',
                        icon: Icons.receipt_long,
                        iconColor: isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess,
                        iconBg: isDark ? AppColorsDark.statusProcessBg : AppColorsLight.statusProcessBg,
                        trend: 'Semua status',
                      )),
                    ]),
                    const SizedBox(height: AppSpacing.xxxl),

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
                        _colPenghuni(payment, isDark),
                        _colMetode(payment, isDark),
                        Text(formatRupiah(payment.amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(formatDate(payment.paymentDate), style: TextStyle(fontSize: 12, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary)),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          FilledButton(
                            onPressed: () => _showVerificationDialog(payment),
                            style: FilledButton.styleFrom(
                              backgroundColor: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting,
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
                            style: TextStyle(fontSize: 13, color: isDark ? AppColorsDark.textHint : AppColorsLight.textHint)),
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
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight)),
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
                                style: TextButton.styleFrom(foregroundColor: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
                              ),
                            ],
                          ]),
                          const SizedBox(height: 10),
                          // Row 2: metode + status chips
                          Row(children: [
                            Text('Metode:', style: TextStyle(fontSize: 12, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary, fontWeight: FontWeight.w500)),
                            const SizedBox(width: 8),
                            ..._methodOptions.map((opt) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: GestureDetector(
                                onTap: () => setState(() { _methodFilter = opt; _pageAll = 1; }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _methodFilter == opt ? Theme.of(context).primaryColor : (isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: _methodFilter == opt ? Theme.of(context).primaryColor : (isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight)),
                                  ),
                                  child: Text(opt, style: TextStyle(fontSize: 12, fontWeight: _methodFilter == opt ? FontWeight.w600 : FontWeight.normal, color: _methodFilter == opt ? Colors.white : (isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary))),
                                ),
                              ),
                            )),
                            const SizedBox(width: 16),
                            Text('Status:', style: TextStyle(fontSize: 12, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary, fontWeight: FontWeight.w500)),
                            const SizedBox(width: 8),
                            ..._statusOptions.map((opt) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: GestureDetector(
                                onTap: () => setState(() { _statusFilter = opt; _pageAll = 1; }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _statusFilter == opt ? Theme.of(context).primaryColor : (isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: _statusFilter == opt ? Theme.of(context).primaryColor : (isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight)),
                                  ),
                                  child: Text(opt, style: TextStyle(fontSize: 12, fontWeight: _statusFilter == opt ? FontWeight.w600 : FontWeight.normal, color: _statusFilter == opt ? Colors.white : (isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary))),
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
                        _colPenghuni(payment, isDark),
                        _colMetode(payment, isDark),
                        Text(formatRupiah(payment.amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(formatDate(payment.paymentDate), style: TextStyle(fontSize: 12, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: _statusBg(payment.status, isDark), borderRadius: BorderRadius.circular(20), border: Border.all(color: _statusColor(payment.status, isDark).withValues(alpha: 0.3))),
                          child: Text(_statusLabel(payment.status), style: TextStyle(color: _statusColor(payment.status, isDark), fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          if (_isPending(payment))
                            FilledButton(
                              onPressed: () => _showVerificationDialog(payment),
                              style: FilledButton.styleFrom(backgroundColor: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), minimumSize: const Size(90, 36)),
                              child: const Text('Verifikasi', style: TextStyle(fontSize: 12)),
                            )
                          else
                            OutlinedButton(
                              onPressed: () => _showDetailDialog(payment),
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), side: BorderSide(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight), minimumSize: const Size(80, 36)),
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
                            style: TextStyle(fontSize: 13, color: isDark ? AppColorsDark.textHint : AppColorsLight.textHint)),
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
        ],
      ),
    ),
  ),
    );
  }

  Widget _colPenghuni(PaymentEntity p, bool isDark) => Row(children: [
    Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: _statusBg(p.status, isDark), borderRadius: BorderRadius.circular(10)),
      child: Icon(_statusIcon(p.status), color: _statusColor(p.status, isDark), size: 20),
    ),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(p.residentName ?? '-', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
      Row(children: [
        if (p.roomNumber != null) ...[
          Icon(Icons.meeting_room_outlined, size: 12, color: isDark ? AppColorsDark.textHint : AppColorsLight.textHint),
          const SizedBox(width: 3),
          Text('Kamar ${p.roomNumber}', style: TextStyle(fontSize: 12, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary)),
          const SizedBox(width: 8),
        ],
        if (p.invoiceNumber != null) ...[
          Icon(Icons.receipt_outlined, size: 12, color: isDark ? AppColorsDark.textHint : AppColorsLight.textHint),
          const SizedBox(width: 3),
          Text(p.invoiceNumber!, style: TextStyle(fontSize: 12, color: isDark ? AppColorsDark.textHint : AppColorsLight.textHint)),
        ],
      ]),
    ])),
  ]);

  Widget _colMetode(PaymentEntity p, bool isDark) => Row(children: [
    Icon(_methodIcon(p.paymentMethod), size: 15, color: _methodColor(p.paymentMethod, isDark)),
    const SizedBox(width: 6),
    Flexible(child: Text(_methodLabel(p.paymentMethod),
        style: TextStyle(fontSize: 12, color: _methodColor(p.paymentMethod, isDark), fontWeight: FontWeight.w600))),
  ]);

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
