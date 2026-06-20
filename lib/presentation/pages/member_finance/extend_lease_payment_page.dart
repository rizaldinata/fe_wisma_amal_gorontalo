import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/navigation/auto_route.gr.dart';
import '../../../domain/usecase/finance/get_member_invoice_by_id_usecase.dart';

const bool _kMidtransProduction = false;
const int _kMaxPollAttempts = 10;
const Duration _kPollInterval = Duration(seconds: 3);

@RoutePage()
class ExtendLeasePaymentPage extends StatefulWidget {
  const ExtendLeasePaymentPage({
    super.key,
    required this.invoiceId,
    required this.roomNumber,
    required this.amount,
    this.snapToken,
    this.paymentData,
  });

  final int invoiceId;
  final String roomNumber;
  final double amount;
  final String? snapToken;
  final Map<String, dynamic>? paymentData;

  @override
  State<ExtendLeasePaymentPage> createState() => _ExtendLeasePaymentPageState();
}

class _ExtendLeasePaymentPageState extends State<ExtendLeasePaymentPage> {
  bool _snapOpened = false;
  bool _isPolling = false;
  bool _paymentConfirmed = false;
  int _pollAttempts = 0;
  Timer? _pollTimer;

  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _openSnapUrl(String snapToken) async {
    final env = _kMidtransProduction ? '' : 'sandbox.';
    final url = Uri.parse('https://app.${env}midtrans.com/snap/v2/vtweb/$snapToken');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      setState(() => _snapOpened = true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka halaman pembayaran')),
        );
      }
    }
  }

  void _startPolling() {
    setState(() { _isPolling = true; _pollAttempts = 0; });

    _pollTimer = Timer.periodic(_kPollInterval, (timer) async {
      if (!mounted) { timer.cancel(); return; }
      _pollAttempts++;

      try {
        final invoice = await serviceLocator
            .get<GetMemberInvoiceByIdUseCase>()
            .execute(widget.invoiceId);
        if (invoice.status.toLowerCase() == 'paid') {
          timer.cancel();
          if (mounted) {
            setState(() { _isPolling = false; _paymentConfirmed = true; });
          }
          return;
        }
      } catch (_) {}

      if (_pollAttempts >= _kMaxPollAttempts) {
        timer.cancel();
        if (mounted) {
          setState(() => _isPolling = false);
          _showPendingDialog();
        }
      }
    });
  }

  void _showPendingDialog() {
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
            onPressed: () {
              Navigator.pop(ctx);
              context.router.replaceAll([const MemberFinanceRoute()]);
            },
            child: const Text('Lihat Status Pembayaran'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isPolling && !_paymentConfirmed,
      child: Scaffold(
        appBar: _paymentConfirmed
            ? null
            : AppBar(
                title: const Text('Pembayaran Perpanjangan'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _isPolling ? null : () => context.router.maybePop(),
                ),
              ),
        body: _paymentConfirmed ? _buildSuccessView() : _buildPaymentView(),
      ),
    );
  }

  Widget _buildPaymentView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildPaymentSection()),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: _buildSummarySection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    final paymentData = widget.paymentData;
    final snapToken = widget.snapToken;

    if (paymentData != null) {
      return _buildCoreApiCard(paymentData);
    }
    if (snapToken != null && snapToken.isNotEmpty) {
      return _buildSnapCard(snapToken);
    }
    return const SizedBox.shrink();
  }

  // ── Core API: QR / VA / Bill / Store ─────────────────────────────────────

  Widget _buildCoreApiCard(Map<String, dynamic> data) {
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
      paymentWidget = _buildGenericUI();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kode Pembayaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            paymentWidget,
            const SizedBox(height: 24),
            _buildConfirmButton(),
          ],
        ),
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
                width: 220,
                height: 220,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const SizedBox(
                        width: 220, height: 220,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                errorBuilder: (_, __, ___) => const SizedBox(
                  width: 220, height: 220,
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
          text: "Bayar melalui Mandiri Livin' atau ATM Mandiri menggunakan kode berikut.",
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

  Widget _buildGenericUI() {
    return _infoBox(
      icon: Icons.payment,
      color: Colors.grey,
      text: 'Lanjutkan pembayaran dan klik "Saya Sudah Bayar" setelah selesai.',
    );
  }

  // ── Snap fallback UI ──────────────────────────────────────────────────────

  Widget _buildSnapCard(String snapToken) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pembayaran via Midtrans',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _infoBox(
              icon: Icons.security,
              color: Colors.blue,
              text: 'Pembayaran diproses secara aman oleh Midtrans. '
                  'Tersedia berbagai metode seperti QRIS, GoPay, ShopeePay, dan lainnya.',
            ),
            const SizedBox(height: 20),
            _instructionStep(1, 'Klik "Bayar Sekarang"',
                'Anda akan diarahkan ke halaman pembayaran Midtrans di browser.'),
            const SizedBox(height: 10),
            _instructionStep(2, 'Pilih Metode Pembayaran',
                'Pilih metode yang tersedia (QRIS, GoPay, VA Bank, dsb).'),
            const SizedBox(height: 10),
            _instructionStep(3, 'Selesaikan Pembayaran', 'Ikuti instruksi di halaman Midtrans.'),
            const SizedBox(height: 10),
            _instructionStep(4, 'Kembali ke Aplikasi',
                'Setelah selesai bayar, kembali dan klik konfirmasi.'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isPolling ? null : () => _openSnapUrl(snapToken),
                icon: const Icon(Icons.payment, color: Colors.white),
                label: const Text('Bayar Sekarang',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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
            Text('Memverifikasi pembayaran…',
                style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _startPolling,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        label: const Text('Saya Sudah Bayar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ── Summary panel ─────────────────────────────────────────────────────────

  Widget _buildSummarySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Perpanjangan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _summaryRow('Kamar', widget.roomNumber),
            _summaryRow('No. Invoice', '#${widget.invoiceId}'),
            const Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Bayar', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  _currencyFormat.format(widget.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Flexible(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  // ── Success view ──────────────────────────────────────────────────────────

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              'Perpanjangan sewa kamar ${widget.roomNumber} telah dikonfirmasi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.router.replaceAll([const MemberFinanceRoute()]),
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

  // ── Helpers ───────────────────────────────────────────────────────────────

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
                Text(value,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
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
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          ),
        ],
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
          child: Center(
            child: Text(num.toString(),
                style: const TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 3),
              Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
      ],
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
}
