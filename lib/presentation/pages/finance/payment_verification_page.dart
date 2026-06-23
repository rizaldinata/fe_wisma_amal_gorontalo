import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entity/finance/payment_entity.dart';
import '../../bloc/payment_verification/payment_verification_bloc.dart';
import '../../bloc/payment_verification/payment_verification_event.dart';
import '../../bloc/payment_verification/payment_verification_state.dart';
import '../../widget/core/appbar/app_topbar.dart';
import '../../widget/core/card/summary_stat_card.dart';
import '../../widget/core/chip/status_badge.dart';
import '../../widget/core/table/app_data_table.dart';
import '../../widget/core/wrapper/empty_state_widget.dart';

@RoutePage()
class PaymentVerificationPage extends StatefulWidget {
  const PaymentVerificationPage({super.key});

  @override
  State<PaymentVerificationPage> createState() => _PaymentVerificationPageState();
}

class _PaymentVerificationPageState extends State<PaymentVerificationPage> {
  late PaymentVerificationBloc _bloc;

  // Filter — tabel pending
  String _searchPending = '';
  final TextEditingController _searchPendingCtrl = TextEditingController();
  int _pagePending = 1;

  // Filter — tabel semua pembayaran
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

  static final _currencyFmt =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static final _dateFmt = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

  String formatRupiah(double v) => _currencyFmt.format(v);

  String formatDate(String d) {
    final dt = DateTime.tryParse(d);
    return dt != null ? _dateFmt.format(dt) : '-';
  }

  String _methodLabel(String m) => m == 'midtrans' ? 'Midtrans / QRIS' : 'Transfer Manual';
  IconData _methodIcon(String m) => m == 'midtrans' ? Icons.qr_code : Icons.account_balance;
  Color _methodColor(String m, bool isDark) => m == 'midtrans'
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

  // ─── Section title ────────────────────────────────────────────────────────

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

  // ─── Dialogs ──────────────────────────────────────────────────────────────

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
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.verified_user_outlined, color: Colors.orange.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Verifikasi Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              payment.invoiceNumber ?? 'ID #${payment.id}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.normal),
            ),
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
                      Text(payment.residentName ?? '-', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      if (payment.roomNumber != null)
                        Text('Kamar ${payment.roomNumber}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('Nominal', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      Text(formatRupiah(payment.amount), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        _methodLabel(payment.paymentMethod),
                        style: TextStyle(fontSize: 12, color: _methodColor(payment.paymentMethod, isDark), fontWeight: FontWeight.w600),
                      ),
                    ]),
                  ]),
                  if (payment.invoiceType != null) ...[
                    const Divider(height: 16),
                    Row(children: [
                      Icon(Icons.label_outline, size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 6),
                      Text('Jenis Tagihan:', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      const SizedBox(width: 6),
                      _invoiceTypeBadge(payment.invoiceType),
                    ]),
                  ],
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
              const Text('Bukti Transfer:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              _proofImage(payment),
              const SizedBox(height: 14),
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
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.red.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (notesCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Catatan wajib diisi jika menolak!'),
                  backgroundColor: Colors.red,
                ));
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
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.orange.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () { Navigator.pop(ctx); _showRefundDialog(payment); },
            ),
          FilledButton.icon(
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Setujui'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              _bloc.add(VerifyPaymentEvent(paymentId: payment.id, isApproved: true));
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(PaymentEntity payment) {
    final isDark = AppTheme.isDark(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _statusBg(payment.status, isDark),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_statusIcon(payment.status), color: _statusColor(payment.status, isDark), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Detail Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              _statusLabel(payment.status),
              style: TextStyle(fontSize: 12, color: _statusColor(payment.status, isDark), fontWeight: FontWeight.w600),
            ),
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
                      Text(payment.residentName ?? '-', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      if (payment.roomNumber != null)
                        Text('Kamar ${payment.roomNumber}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      if (payment.invoiceNumber != null) ...[
                        const SizedBox(height: 2),
                        Row(children: [
                          Text(payment.invoiceNumber!, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                          if (payment.invoiceType != null) ...[
                            const SizedBox(width: 6),
                            _invoiceTypeBadge(payment.invoiceType),
                          ],
                        ]),
                      ],
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('Nominal', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      Text(formatRupiah(payment.amount), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        _methodLabel(payment.paymentMethod),
                        style: TextStyle(fontSize: 12, color: _methodColor(payment.paymentMethod, isDark), fontWeight: FontWeight.w600),
                      ),
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
              if (payment.adminNotes != null && payment.adminNotes!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text('Catatan Admin', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: payment.status.toLowerCase() == 'rejected' ? Colors.red.shade50 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: payment.status.toLowerCase() == 'rejected' ? Colors.red.shade200 : Colors.grey.shade200,
                    ),
                  ),
                  child: Text(payment.adminNotes!, style: TextStyle(fontSize: 13, color: Colors.grey.shade800)),
                ),
              ],
              const SizedBox(height: 14),
              const Text('Bukti Transfer:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              _proofImage(payment),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        ],
      ),
    );
  }

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
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red.shade600, size: 18),
                const SizedBox(width: 8),
                const Expanded(child: Text(
                  'Fitur ini akan mengembalikan dana ke rekening pengguna secara otomatis melalui Midtrans.',
                  style: TextStyle(fontSize: 12),
                )),
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
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (reasonCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alasan refund wajib diisi!')),
                );
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

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final bgColor = isDark ? AppColorsDark.background : AppColorsLight.background;

    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<PaymentVerificationBloc, PaymentVerificationState>(
        listener: (ctx, state) {
          if (state is PaymentVerificationActionSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
            ));
          } else if (state is PaymentVerificationError) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
            ));
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
                child: BlocBuilder<PaymentVerificationBloc, PaymentVerificationState>(
                  buildWhen: (p, c) =>
                      c is PaymentVerificationLoading ||
                      c is PaymentVerificationRefreshing ||
                      c is PaymentVerificationLoaded ||
                      c is PaymentVerificationError,
                  builder: (ctx, state) {
                    if (state is PaymentVerificationLoading) return _buildSkeleton(isDark);
                    if (state is PaymentVerificationError) {
                      return EmptyStateWidget(
                        icon: Icons.error_outline,
                        title: 'Gagal Memuat Data',
                        subtitle: state.message,
                        action: ElevatedButton(
                          onPressed: () => _bloc.add(FetchAllPayments()),
                          child: const Text('Coba Lagi'),
                        ),
                      );
                    }
                    final all = state is PaymentVerificationLoaded
                        ? state.payments
                        : state is PaymentVerificationRefreshing
                            ? state.currentPayments
                            : null;
                    if (all == null) return const SizedBox.shrink();
                    final years = _availableYears(all);

                    final pendingCount  = all.where((p) => p.status.toLowerCase() == 'pending').length;
                    final verifiedCount = all.where((p) => ['verified', 'paid'].contains(p.status.toLowerCase())).length;
                    final rejectedCount = all.where((p) => ['rejected', 'failed'].contains(p.status.toLowerCase())).length;
                    final totalVerified = all
                        .where((p) => ['verified', 'paid'].contains(p.status.toLowerCase()))
                        .fold(0.0, (s, p) => s + p.amount);

                    final filteredPending   = _filteredPending(all);
                    final totalPagesPending = _totalPages(filteredPending.length);
                    final pagePending       = _pagePending.clamp(1, totalPagesPending);
                    final pagedPending      = _paged(filteredPending, pagePending);

                    final filteredAll    = _filteredAll(all);
                    final totalPagesAll  = _totalPages(filteredAll.length);
                    final pageAll        = _pageAll.clamp(1, totalPagesAll);
                    final pagedAll       = _paged(filteredAll, pageAll);

                    return Stack(
                      children: [
                        SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.xxxl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ── Ringkasan Statistik ─────────────────────────
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
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
                              ],
                            ),
                          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms),
                          const SizedBox(height: AppSpacing.xxxl),

                          // ══════════════════════════════════════════════
                          // TABEL ATAS — Menunggu Verifikasi
                          // ══════════════════════════════════════════════
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _sectionTitle(context, 'Menunggu Verifikasi', isDark),
                              const Spacer(),
                              SizedBox(
                                height: 40,
                                width: 300,
                                child: TextField(
                                  controller: _searchPendingCtrl,
                                  onChanged: (v) => setState(() { _searchPending = v; _pagePending = 1; }),
                                  decoration: InputDecoration(
                                    hintText: 'Cari nama, kamar, invoice...',
                                    prefixIcon: const Icon(Icons.search, size: 18),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                          const SizedBox(height: AppSpacing.lg),

                          _buildPendingTable(pagedPending, isDark),

                          const SizedBox(height: AppSpacing.sm),
                          _buildPaginationRow(
                            shown: pagedPending.length,
                            total: filteredPending.length,
                            label: 'transaksi pending',
                            currentPage: pagePending,
                            totalPages: totalPagesPending,
                            onPageChanged: (p) => setState(() => _pagePending = p),
                            isDark: isDark,
                          ),
                          const SizedBox(height: AppSpacing.xxxl),

                          // ══════════════════════════════════════════════
                          // TABEL BAWAH — Semua Pembayaran
                          // ══════════════════════════════════════════════
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _sectionTitle(context, 'Semua Pembayaran', isDark),
                              const Spacer(),
                              _FilterDropdown<int?>(
                                hint: 'Tahun',
                                value: _filterYear,
                                items: [null, ...years],
                                labelBuilder: (v) => v == null ? 'Semua Tahun' : '$v',
                                onChanged: (v) => setState(() { _filterYear = v; _filterMonth = null; _pageAll = 1; }),
                                isDark: isDark,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _FilterDropdown<int?>(
                                hint: 'Bulan',
                                value: _filterMonth,
                                items: [null, ...List.generate(12, (i) => i + 1)],
                                labelBuilder: (v) => v == null ? 'Semua Bulan' : DateFormat('MMMM', 'id_ID').format(DateTime(0, v)),
                                onChanged: (v) => setState(() { _filterMonth = v; _pageAll = 1; }),
                                isDark: isDark,
                              ),
                              if (_filterYear != null || _filterMonth != null) ...[
                                const SizedBox(width: AppSpacing.xs),
                                IconButton(
                                  onPressed: () => setState(() { _filterYear = null; _filterMonth = null; _pageAll = 1; }),
                                  icon: const Icon(Icons.close_rounded, size: 16),
                                  tooltip: 'Reset filter tanggal',
                                  style: IconButton.styleFrom(
                                    foregroundColor: Colors.grey.shade500,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ],
                            ],
                          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
                          const SizedBox(height: AppSpacing.md),

                          // Search + filter chips
                          Row(children: [
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: TextField(
                                  controller: _searchAllCtrl,
                                  onChanged: (v) => setState(() { _searchAll = v; _pageAll = 1; }),
                                  decoration: InputDecoration(
                                    hintText: 'Cari nama penghuni, kamar, nomor invoice, ID transaksi...',
                                    prefixIcon: const Icon(Icons.search, size: 18),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ]).animate().fadeIn(delay: 220.ms, duration: 300.ms),
                          const SizedBox(height: AppSpacing.sm),

                          // Method + Status chips
                          Row(children: [
                            _chipGroupLabel('Metode:', isDark),
                            const SizedBox(width: AppSpacing.sm),
                            ..._methodOptions.map((opt) => _FilterChip(
                              label: opt,
                              selected: _methodFilter == opt,
                              isDark: isDark,
                              onTap: () => setState(() { _methodFilter = opt; _pageAll = 1; }),
                            )),
                            const SizedBox(width: AppSpacing.lg),
                            _chipGroupLabel('Status:', isDark),
                            const SizedBox(width: AppSpacing.sm),
                            ..._statusOptions.map((opt) => _FilterChip(
                              label: opt,
                              selected: _statusFilter == opt,
                              isDark: isDark,
                              onTap: () => setState(() { _statusFilter = opt; _pageAll = 1; }),
                            )),
                          ]).animate().fadeIn(delay: 240.ms, duration: 300.ms),
                          const SizedBox(height: AppSpacing.lg),

                          _buildAllTable(pagedAll, isDark),

                          const SizedBox(height: AppSpacing.sm),
                          _buildPaginationRow(
                            shown: pagedAll.length,
                            total: filteredAll.length,
                            label: 'transaksi',
                            currentPage: pageAll,
                            totalPages: totalPagesAll,
                            onPageChanged: (p) => setState(() => _pageAll = p),
                            isDark: isDark,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
                    ),
                        if (state is PaymentVerificationRefreshing)
                          const LinearProgressIndicator(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Tables ───────────────────────────────────────────────────────────────

  Widget _buildPendingTable(List<PaymentEntity> rows, bool isDark) {
    if (rows.isEmpty) {
      return _emptyTable(
        _searchPending.isEmpty
            ? 'Tidak ada pembayaran yang menunggu verifikasi.\nSemua pembayaran sudah diproses!'
            : 'Tidak ada hasil untuk "$_searchPending".',
        isDark,
      );
    }

    return AppDataTable(
      dataRowMinHeight: 64,
      dataRowMaxHeight: double.infinity,
      columns: const [
        DataColumn(label: Text('Penghuni & Tagihan')),
        DataColumn(label: Text('Metode')),
        DataColumn(label: Text('Nominal'), numeric: true),
        DataColumn(label: Text('Tanggal Upload')),
        DataColumn(label: Text('Aksi')),
      ],
      rows: rows.map((p) => DataRow(cells: [
        DataCell(_colPenghuni(p, isDark)),
        DataCell(_colMetode(p, isDark)),
        DataCell(Text(
          formatRupiah(p.amount),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        )),
        DataCell(Text(
          formatDate(p.paymentDate),
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
          ),
        )),
        DataCell(FilledButton(
          onPressed: () => _showVerificationDialog(p),
          style: FilledButton.styleFrom(
            backgroundColor: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            minimumSize: const Size(90, 36),
          ),
          child: const Text('Verifikasi', style: TextStyle(fontSize: 12)),
        )),
      ])).toList(),
    ).animate().fadeIn(delay: 150.ms, duration: 300.ms);
  }

  Widget _buildAllTable(List<PaymentEntity> rows, bool isDark) {
    if (rows.isEmpty) {
      return _emptyTable(
        _searchAll.isEmpty
            ? 'Tidak ada pembayaran pada kategori ini.'
            : 'Tidak ada hasil untuk "$_searchAll".',
        isDark,
      );
    }

    return AppDataTable(
      dataRowMinHeight: 64,
      dataRowMaxHeight: double.infinity,
      columns: const [
        DataColumn(label: Text('Penghuni & Tagihan')),
        DataColumn(label: Text('Metode')),
        DataColumn(label: Text('Nominal'), numeric: true),
        DataColumn(label: Text('Tanggal')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Aksi')),
      ],
      rows: rows.map((p) => DataRow(cells: [
        DataCell(_colPenghuni(p, isDark)),
        DataCell(_colMetode(p, isDark)),
        DataCell(Text(
          formatRupiah(p.amount),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        )),
        DataCell(Text(
          formatDate(p.paymentDate),
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
          ),
        )),
        DataCell(StatusBadge(status: p.status)),
        DataCell(_isPending(p)
            ? FilledButton(
                onPressed: () => _showVerificationDialog(p),
                style: FilledButton.styleFrom(
                  backgroundColor: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  minimumSize: const Size(90, 36),
                ),
                child: const Text('Verifikasi', style: TextStyle(fontSize: 12)),
              )
            : OutlinedButton(
                onPressed: () => _showDetailDialog(p),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight),
                  minimumSize: const Size(80, 36),
                ),
                child: const Text('Detail', style: TextStyle(fontSize: 12)),
              )),
      ])).toList(),
    ).animate().fadeIn(delay: 280.ms, duration: 300.ms);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

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

  Widget _buildPaginationRow({
    required int shown,
    required int total,
    required String label,
    required int currentPage,
    required int totalPages,
    required ValueChanged<int> onPageChanged,
    required bool isDark,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(children: [
          Text(
            'Menampilkan $shown dari $total $label',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColorsDark.textHint : AppColorsLight.textHint,
            ),
          ),
          const Spacer(),
          _PaginationBar(
            currentPage: currentPage,
            totalPages: totalPages,
            onPageChanged: onPageChanged,
          ),
        ]),
      );

  Widget _chipGroupLabel(String text, bool isDark) => Text(
    text,
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
    ),
  );

  Widget _proofImage(PaymentEntity payment) => Container(
    height: 280,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: payment.paymentProofUrl != null && payment.paymentProofUrl!.isNotEmpty
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
  );

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

  Widget _colPenghuni(PaymentEntity p, bool isDark) => Row(children: [
    Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: _statusBg(p.status, isDark),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(_statusIcon(p.status), color: _statusColor(p.status, isDark), size: 20),
    ),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        p.residentName ?? '-',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
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
          const SizedBox(width: 6),
        ],
        _invoiceTypeBadge(p.invoiceType),
      ]),
    ])),
  ]);

  Widget _colMetode(PaymentEntity p, bool isDark) => Row(children: [
    Icon(_methodIcon(p.paymentMethod), size: 15, color: _methodColor(p.paymentMethod, isDark)),
    const SizedBox(width: 6),
    Flexible(child: Text(
      _methodLabel(p.paymentMethod),
      style: TextStyle(fontSize: 12, color: _methodColor(p.paymentMethod, isDark), fontWeight: FontWeight.w600),
    )),
  ]);

  // ─── Skeleton ─────────────────────────────────────────────────────────────

  Widget _buildSkeleton(bool isDark) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    Widget shimmer({double height = 100}) => Shimmer.fromColors(
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
            border: Border.all(
              color: selected ? primary : (isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight),
            ),
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
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

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
      child: Text('$page', style: TextStyle(
        fontWeight: active ? FontWeight.bold : FontWeight.normal,
        color: active ? Colors.white : Colors.grey.shade700,
        fontSize: 13,
      )),
    ),
  );

  Widget _nav(BuildContext ctx, IconData icon, bool enabled, VoidCallback onTap) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 18, color: enabled ? Colors.grey.shade700 : Colors.grey.shade300),
    ),
  );
}
