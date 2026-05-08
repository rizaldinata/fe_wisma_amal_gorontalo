import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/navigation/auto_route.gr.dart';
import '../../../domain/entity/reservation_entity.dart';
import '../../../domain/usecase/finance/get_member_invoice_by_id_usecase.dart';
import '../../../domain/usecase/reservation/cancel_reservation_usecase.dart';
import '../../bloc/member_finance/member_finance_bloc.dart';
import '../../bloc/member_finance/member_finance_event.dart';
import '../../bloc/member_finance/member_finance_state.dart';
import '../../widget/core/appbar/custom_appbar.dart';
import '../../widget/core/card/basic_card.dart';

const bool _kMidtransProduction = false;
const int _kMaxPollAttempts = 10;
const Duration _kPollInterval = Duration(seconds: 3);

@RoutePage()
class MidtransPaymentPage extends StatefulWidget {
  final ReservationEntity reservation;
  const MidtransPaymentPage({super.key, required this.reservation});

  @override
  State<MidtransPaymentPage> createState() => _MidtransPaymentPageState();
}

class _MidtransPaymentPageState extends State<MidtransPaymentPage> {
  bool _isExpired = false;
  bool _isCancelling = false;
  bool _snapOpened = false;
  bool _isPolling = false;
  bool _paymentConfirmed = false;
  int _remainingSeconds = 300;
  int _pollAttempts = 0;
  Timer? _countdownTimer;
  Timer? _pollTimer;

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  void _initTimer() {
    final expiresAt = widget.reservation.paymentExpiresAt;
    if (expiresAt != null) {
      final expiry = DateTime.tryParse(expiresAt);
      if (expiry != null) {
        final remaining = expiry.difference(DateTime.now()).inSeconds;
        _remainingSeconds = remaining > 0 ? remaining : 0;
      }
    }

    if (_remainingSeconds <= 0) {
      setState(() => _isExpired = true);
      return;
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _isExpired = true;
          timer.cancel();
          _showExpiredDialog();
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  String get _timerDisplay {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color get _timerColor {
    if (_remainingSeconds <= 60) return Colors.red;
    if (_remainingSeconds <= 120) return Colors.orange;
    return Colors.green;
  }

  Future<void> _cancelAndGoBack() async {
    setState(() => _isCancelling = true);
    try {
      await serviceLocator.get<CancelReservationUseCase>().execute(widget.reservation.id);
    } catch (_) {}
    if (mounted) context.router.replaceAll([const LandingRoute()]);
  }

  void _showExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Waktu Pembayaran Habis'),
        content: const Text(
          'Batas waktu pembayaran (5 menit) telah habis. '
          'Pemesanan dibatalkan secara otomatis dan kamar kembali tersedia.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); _cancelAndGoBack(); },
            child: const Text('Kembali ke Beranda'),
          ),
        ],
      ),
    );
  }

  // ── Snap fallback (untuk metode yang tidak didukung Core API) ─────────────

  Future<void> _openSnapUrl(String snapToken) async {
    final env = _kMidtransProduction ? '' : 'sandbox.';
    final url = Uri.parse('https://app.${env}midtrans.com/snap/v2/vtweb/$snapToken');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      setState(() => _snapOpened = true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Tidak dapat membuka halaman pembayaran'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  // ── Polling setelah "Saya Sudah Bayar" ────────────────────────────────────

  void _startPaymentStatusPolling() {
    final invoiceId = widget.reservation.invoiceId;
    if (invoiceId == null) { _navigateToMemberFinance(); return; }

    setState(() { _isPolling = true; _pollAttempts = 0; });

    _pollTimer = Timer.periodic(_kPollInterval, (timer) async {
      if (!mounted) { timer.cancel(); return; }
      _pollAttempts++;
      try {
        final invoice = await serviceLocator
            .get<GetMemberInvoiceByIdUseCase>()
            .execute(invoiceId);
        if (invoice.status.toLowerCase() == 'paid') {
          timer.cancel();
          if (mounted) {
            setState(() { _isPolling = false; _paymentConfirmed = true; });
            _countdownTimer?.cancel();
          }
          return;
        }
      } catch (_) {}

      if (_pollAttempts >= _kMaxPollAttempts) {
        timer.cancel();
        if (mounted) {
          setState(() => _isPolling = false);
          _showPaymentPendingDialog();
        }
      }
    });
  }

  void _navigateToMemberFinance() =>
      context.router.replaceAll([const MemberFinanceRoute()]);

  void _showPaymentPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          const Icon(Icons.hourglass_top, color: Colors.orange, size: 28),
          const SizedBox(width: 8),
          const Text('Pembayaran Diproses'),
        ]),
        content: const Text(
          'Konfirmasi pembayaran belum diterima. '
          'Status akan diperbarui otomatis. '
          'Pantau di halaman keuangan Anda.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); _navigateToMemberFinance(); },
            child: const Text('Lihat Status Pembayaran'),
          ),
        ],
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    if (_isCancelling || _isPolling || _paymentConfirmed) return false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Pemesanan?'),
        content: const Text(
          'Jika Anda meninggalkan halaman ini tanpa melakukan pembayaran, '
          'pemesanan akan dibatalkan dan kamar kembali tersedia.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Lanjutkan Bayar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) { _countdownTimer?.cancel(); await _cancelAndGoBack(); }
    return false;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator.get<MemberFinanceBloc>()
        ..add(PayInvoiceEvent(
          widget.reservation.invoiceId!,
          'midtrans',
          preferredPaymentType: widget.reservation.selectedPaymentMethod,
        )),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (!didPop) await _onBackPressed();
        },
        child: Scaffold(
          appBar: _paymentConfirmed
              ? null
              : CustomAppbar(
                  title: 'Pembayaran Online',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _onBackPressed(),
                ),
          body: _paymentConfirmed
              ? _buildSuccessView()
              : BlocConsumer<MemberFinanceBloc, MemberFinanceState>(
                  listener: (context, state) {
                    if (state.status == MemberFinanceStatus.failure) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(state.errorMessage ?? 'Gagal menginisialisasi pembayaran'),
                        backgroundColor: Colors.red,
                      ));
                    }
                  },
                  builder: (context, state) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 900),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStepIndicator(),
                              const SizedBox(height: 24),
                              _buildTimerBanner(),
                              const SizedBox(height: 24),
                              if (state.status == MemberFinanceStatus.loading)
                                const Center(child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 48),
                                  child: CircularProgressIndicator(),
                                ))
                              else
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(flex: 3, child: _buildPaymentSection(state)),
                                    const SizedBox(width: 24),
                                    Expanded(flex: 2, child: _buildSummarySection()),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  // ── Halaman sukses ────────────────────────────────────────────────────────

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green.shade200, width: 2),
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 56),
            ),
            const SizedBox(height: 24),
            const Text('Pembayaran Berhasil!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'Pembayaran Anda telah dikonfirmasi.\nKamar Anda sekarang aktif.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            if (widget.reservation.invoiceId != null)
              Text('ID Invoice: #${widget.reservation.invoiceId}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToMemberFinance,
                icon: const Icon(Icons.home, color: Colors.white),
                label: const Text('Lihat Keuangan Saya',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Routing payment section ───────────────────────────────────────────────

  Widget _buildPaymentSection(MemberFinanceState state) {
    final paymentData = state.paymentData;
    final snapToken = state.snapToken;

    if (paymentData != null) {
      return _buildCoreApiPaymentUI(paymentData);
    }
    if (snapToken != null && snapToken.isNotEmpty) {
      return _buildSnapPaymentUI(snapToken, state);
    }
    if (state.status == MemberFinanceStatus.failure) {
      return _buildErrorCard(state.errorMessage);
    }
    return const SizedBox.shrink();
  }

  // ── Core API: tampilkan kode pembayaran langsung ──────────────────────────

  Widget _buildCoreApiPaymentUI(Map<String, dynamic> data) {
    final paymentType = data['payment_type'] as String? ?? '';

    Widget paymentWidget;
    if (_hasQrCode(data)) {
      paymentWidget = _buildQrCodeUI(data, paymentType);
    } else if (data.containsKey('va_numbers')) {
      paymentWidget = _buildVaNumberUI(data);
    } else if (data.containsKey('bill_key')) {
      paymentWidget = _buildMandiriBillUI(data);
    } else if (data.containsKey('payment_code')) {
      paymentWidget = _buildCStoreUI(data);
    } else {
      paymentWidget = _buildGenericPaymentUI(data);
    }

    return BasicCard(
      title: 'Kode Pembayaran',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          paymentWidget,
          const SizedBox(height: 24),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  bool _hasQrCode(Map<String, dynamic> data) {
    final actions = data['actions'] as List?;
    if (actions == null) return false;
    return actions.any((a) =>
        a is Map && (a['name'] == 'generate-qr-code' || a['name'] == 'get-qr-code'));
  }

  String? _getQrUrl(Map<String, dynamic> data) {
    final actions = data['actions'] as List?;
    if (actions == null) return null;
    for (final a in actions) {
      if (a is Map && (a['name'] == 'generate-qr-code' || a['name'] == 'get-qr-code')) {
        return a['url'] as String?;
      }
    }
    return null;
  }

  String? _getDeeplinkUrl(Map<String, dynamic> data) {
    final actions = data['actions'] as List?;
    if (actions == null) return null;
    for (final a in actions) {
      if (a is Map && a['name'] == 'deeplink-redirect') {
        return a['url'] as String?;
      }
    }
    return null;
  }

  Widget _buildQrCodeUI(Map<String, dynamic> data, String paymentType) {
    final qrUrl = _getQrUrl(data);
    final deeplinkUrl = _getDeeplinkUrl(data);
    final expiryTime = data['expiry_time'] as String?;
    final methodLabel = _paymentTypeLabel(paymentType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _infoBox(
          icon: Icons.qr_code_2,
          color: Colors.indigo,
          text: 'Scan QR Code berikut menggunakan aplikasi $methodLabel atau kamera ponsel Anda.',
        ),
        const SizedBox(height: 20),
        if (qrUrl != null)
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.network(
                qrUrl,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                loadingBuilder: (ctx, child, progress) => progress == null
                    ? child
                    : const SizedBox(
                        width: 200, height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                errorBuilder: (_, __, ___) => const SizedBox(
                  width: 200, height: 200,
                  child: Center(child: Text('Gagal memuat QR Code')),
                ),
              ),
            ),
          ),
        if (expiryTime != null) ...[
          const SizedBox(height: 12),
          _expiryChip(expiryTime),
        ],
        if (deeplinkUrl != null) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(deeplinkUrl);
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
              icon: const Icon(Icons.open_in_new),
              label: Text('Buka di $methodLabel'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVaNumberUI(Map<String, dynamic> data) {
    final vaNumbers = data['va_numbers'] as List? ?? [];
    final expiryTime = data['expiry_time'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoBox(
          icon: Icons.account_balance,
          color: Colors.blue,
          text: 'Transfer ke nomor Virtual Account berikut sebelum waktu kadaluarsa.',
        ),
        const SizedBox(height: 16),
        for (final va in vaNumbers)
          if (va is Map) ...[
            _vaCard(
              bank: (va['bank'] as String? ?? '').toUpperCase(),
              vaNumber: va['va_number'] as String? ?? '-',
            ),
            const SizedBox(height: 8),
          ],
        if (expiryTime != null) _expiryChip(expiryTime),
      ],
    );
  }

  Widget _vaCard({required String bank, required String vaNumber}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Virtual Account $bank',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Text(vaNumber,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: vaNumber));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nomor VA disalin'), duration: Duration(seconds: 2)),
              );
            },
            icon: const Icon(Icons.copy, color: Colors.blue),
            tooltip: 'Salin',
          ),
        ],
      ),
    );
  }

  Widget _buildMandiriBillUI(Map<String, dynamic> data) {
    final billKey = data['bill_key'] as String? ?? '-';
    final billerCode = data['biller_code'] as String? ?? '-';
    final expiryTime = data['expiry_time'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoBox(
          icon: Icons.account_balance,
          color: Colors.blue,
          text: 'Bayar melalui Mandiri Livin\' atau ATM Mandiri menggunakan kode berikut.',
        ),
        const SizedBox(height: 16),
        _codeCard(label: 'Biller Code', value: billerCode),
        const SizedBox(height: 8),
        _codeCard(label: 'Bill Key', value: billKey),
        if (expiryTime != null) ...[const SizedBox(height: 12), _expiryChip(expiryTime)],
      ],
    );
  }

  Widget _buildCStoreUI(Map<String, dynamic> data) {
    final paymentCode = data['payment_code'] as String? ?? '-';
    final store = data['store'] as String? ?? 'Minimarket';
    final expiryTime = data['expiry_time'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoBox(
          icon: Icons.store,
          color: Colors.red,
          text: 'Tunjukkan kode berikut ke kasir $store untuk menyelesaikan pembayaran.',
        ),
        const SizedBox(height: 16),
        _codeCard(label: 'Kode Pembayaran $store', value: paymentCode),
        if (expiryTime != null) ...[const SizedBox(height: 12), _expiryChip(expiryTime)],
      ],
    );
  }

  Widget _buildGenericPaymentUI(Map<String, dynamic> data) {
    return _infoBox(
      icon: Icons.payment,
      color: Colors.grey,
      text: 'Lanjutkan pembayaran dan klik "Saya Sudah Bayar" setelah selesai.',
    );
  }

  Widget _codeCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kode disalin'), duration: Duration(seconds: 2)),
              );
            },
            icon: const Icon(Icons.copy, color: Colors.blue),
            tooltip: 'Salin',
          ),
        ],
      ),
    );
  }

  Widget _expiryChip(String expiryTime) {
    return Row(
      children: [
        const Icon(Icons.schedule, size: 14, color: Colors.orange),
        const SizedBox(width: 6),
        Text('Berlaku hingga: $expiryTime',
            style: TextStyle(fontSize: 12, color: Colors.orange.shade700)),
      ],
    );
  }

  Widget _infoBox({required IconData icon, required Color color, required String text}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade700))),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    if (_isPolling) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue.shade700),
            ),
            const SizedBox(width: 12),
            Text('Memverifikasi pembayaran...',
                style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: (_isExpired) ? null : _startPaymentStatusPolling,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        label: const Text('Saya Sudah Bayar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  String _paymentTypeLabel(String paymentType) {
    const labels = {
      'qris': 'QRIS',
      'gopay': 'GoPay',
      'shopeepay': 'ShopeePay',
      'dana': 'DANA',
    };
    return labels[paymentType] ?? paymentType.toUpperCase();
  }

  // ── Snap fallback UI ──────────────────────────────────────────────────────

  Widget _buildSnapPaymentUI(String snapToken, MemberFinanceState state) {
    return BasicCard(
      title: 'Pembayaran via Midtrans',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoBox(
            icon: Icons.security,
            color: Colors.blue,
            text: 'Pembayaran diproses secara aman oleh Midtrans. '
                'Tersedia berbagai metode seperti QRIS, GoPay, ShopeePay, dan lainnya.',
          ),
          const SizedBox(height: 20),
          _instructionStep(1, 'Klik "Bayar Sekarang"',
              'Anda akan diarahkan ke halaman pembayaran Midtrans di browser.'),
          const SizedBox(height: 12),
          _instructionStep(2, 'Pilih Metode Pembayaran',
              'Pilih metode yang tersedia (QRIS, GoPay, ShopeePay, dsb).'),
          const SizedBox(height: 12),
          _instructionStep(3, 'Selesaikan Pembayaran',
              'Ikuti instruksi pada halaman Midtrans.'),
          const SizedBox(height: 12),
          _instructionStep(4, 'Kembali ke Aplikasi',
              'Setelah selesai bayar, kembali dan klik tombol konfirmasi.'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_isExpired || _isPolling) ? null : () => _openSnapUrl(snapToken),
              icon: const Icon(Icons.payment, color: Colors.white),
              label: const Text('Bayar Sekarang',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                disabledBackgroundColor: Colors.blue.shade200,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (_snapOpened) ...[
            const SizedBox(height: 12),
            _buildConfirmButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorCard(String? message) {
    return BasicCard(
      title: 'Pembayaran via Midtrans',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message ?? 'Gagal menginisialisasi pembayaran.',
                style: TextStyle(fontSize: 12, color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _instructionStep(int num, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.12), shape: BoxShape.circle,
          ),
          child: Center(child: Text(num.toString(),
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 3),
            Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        )),
      ],
    );
  }

  // ── Timer banner ──────────────────────────────────────────────────────────

  Widget _buildTimerBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: _isExpired ? Colors.red.shade50 : _timerColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isExpired ? Colors.red : _timerColor, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(_isExpired ? Icons.timer_off : Icons.timer,
              color: _isExpired ? Colors.red : _timerColor, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isExpired ? 'Waktu Pembayaran Habis' : 'Batas Waktu Pembayaran',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isExpired ? Colors.red : _timerColor, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                _isExpired
                    ? 'Pemesanan akan dibatalkan secara otomatis.'
                    : 'Selesaikan pembayaran sebelum waktu habis.',
                style: TextStyle(fontSize: 12,
                    color: _isExpired ? Colors.red.shade700 : Colors.grey.shade700),
              ),
            ],
          )),
          const SizedBox(width: 16),
          if (!_isExpired)
            Text(_timerDisplay, style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: _timerColor)),
        ],
      ),
    );
  }

  // ── Step indicator ────────────────────────────────────────────────────────

  Widget _buildStepIndicator() {
    return Row(children: [
      _stepCircle('1', 'Pemesanan', true, done: true),
      _stepLine(true),
      _stepCircle('2', 'Pembayaran', true),
      _stepLine(false),
      _stepCircle('3', 'Konfirmasi', false),
    ]);
  }

  Widget _stepCircle(String num, String label, bool isActive, {bool done = false}) {
    return Column(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey.shade300, shape: BoxShape.circle),
        child: Center(child: done
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : Text(num, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ),
      const SizedBox(height: 8),
      Text(label, style: TextStyle(
          fontSize: 12,
          color: isActive ? Colors.blue : Colors.grey,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
    ]);
  }

  Widget _stepLine(bool isActive) {
    return Expanded(child: Container(
        height: 2, margin: const EdgeInsets.only(bottom: 20),
        color: isActive ? Colors.blue : Colors.grey.shade300));
  }

  // ── Summary section ───────────────────────────────────────────────────────

  Widget _buildSummarySection() {
    return Column(children: [
      BasicCard(
        title: 'Ringkasan Pesanan',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _summaryRow('Kamar', widget.reservation.roomTitle),
          _summaryRow('No. Kamar', widget.reservation.roomNumber),
          _summaryRow('Tipe Sewa',
              widget.reservation.rentalType == 'monthly' ? 'Bulanan' : 'Harian'),
          _summaryRow('Mulai', widget.reservation.startDate),
          _summaryRow('Selesai', widget.reservation.endDate),
          const Divider(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Bayar', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                widget.reservation.invoiceAmount != null
                    ? currencyFormat.format(widget.reservation.invoiceAmount!)
                    : 'Rp -',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.reservation.invoiceId != null)
            Text('ID Invoice: #${widget.reservation.invoiceId}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ]),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: (_isCancelling || _isExpired || _isPolling) ? null : () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Batalkan Pemesanan?'),
                content: const Text('Pemesanan akan dibatalkan dan kamar kembali tersedia.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Tidak')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
            if (confirmed == true) { _countdownTimer?.cancel(); await _cancelAndGoBack(); }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red, side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isCancelling
              ? const SizedBox(height: 18, width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
              : const Text('Batalkan Pemesanan'),
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Kamar ini sedang dikunci untuk Anda selama batas waktu pembayaran.',
        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        textAlign: TextAlign.center,
      ),
    ]);
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Flexible(child: Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
