import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/navigation/auto_route.gr.dart';
import '../../../domain/entity/reservation_entity.dart';
import '../../../domain/usecase/reservation/cancel_reservation_usecase.dart';
import '../../bloc/member_finance/member_finance_bloc.dart';
import '../../bloc/member_finance/member_finance_event.dart';
import '../../bloc/member_finance/member_finance_state.dart';
import '../../widget/core/appbar/custom_appbar.dart';
import '../../widget/core/botton/button.dart';
import '../../widget/core/card/basic_card.dart';

@RoutePage()
class PaymentUploadPage extends StatefulWidget {
  final ReservationEntity reservation;
  const PaymentUploadPage({super.key, required this.reservation});

  @override
  State<PaymentUploadPage> createState() => _PaymentUploadPageState();
}

class _PaymentUploadPageState extends State<PaymentUploadPage> {
  PlatformFile? _selectedFile;
  bool _isSubmitting = false;
  bool _isExpired = false;
  bool _isCancelling = false;
  int _remainingSeconds = 300; // 5 menit default
  Timer? _countdownTimer;

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
      _isExpired = true;
      return;
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
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
    super.dispose();
  }

  String get _timerDisplay {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
    } catch (_) {
      // Tidak perlu handle error, scheduler backend akan membatalkan otomatis
    } finally {
      if (mounted) {
        context.router.replaceAll([const LandingRoute()]);
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_isSubmitting) return false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Pemesanan?'),
        content: const Text(
          'Jika Anda meninggalkan halaman ini tanpa melakukan pembayaran, pemesanan akan dibatalkan dan kamar kembali tersedia untuk pengguna lain.',
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
    if (confirmed == true) {
      _countdownTimer?.cancel();
      await _cancelAndGoBack();
      return false;
    }
    return false;
  }

  void _showExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Waktu Pembayaran Habis'),
        content: const Text(
          'Batas waktu upload bukti pembayaran (5 menit) telah habis. Pemesanan dibatalkan secara otomatis dan kamar kembali tersedia.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cancelAndGoBack();
            },
            child: const Text('Kembali ke Beranda'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    _countdownTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            const Text('Bukti Terkirim'),
          ],
        ),
        content: const Text(
          'Bukti pembayaran Anda berhasil dikirim dan sedang menunggu konfirmasi dari admin. '
          'Anda akan menjadi penghuni resmi setelah pembayaran diverifikasi.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.router.replaceAll([const LandingRoute()]);
            },
            child: const Text('Kembali ke Beranda'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator.get<MemberFinanceBloc>(),
      child: BlocListener<MemberFinanceBloc, MemberFinanceState>(
        listener: (context, state) {
          if (state.status == MemberFinanceStatus.paymentSuccess) {
            setState(() => _isSubmitting = false);
            _showSuccessDialog();
          } else if (state.status == MemberFinanceStatus.failure) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Gagal mengunggah bukti pembayaran'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.status == MemberFinanceStatus.loading) {
            setState(() => _isSubmitting = true);
          }
        },
        child: WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            appBar: CustomAppbar(
              title: 'Pembayaran Manual',
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _onWillPop(),
            ),
            body: SingleChildScrollView(
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildInstructionSection()),
                          const SizedBox(width: 24),
                          Expanded(flex: 2, child: _buildSummarySection()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: _isExpired ? Colors.red.shade50 : _timerColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isExpired ? Colors.red : _timerColor,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isExpired ? Icons.timer_off : Icons.timer,
            color: _isExpired ? Colors.red : _timerColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isExpired
                      ? 'Waktu Pembayaran Habis'
                      : 'Batas Waktu Upload Bukti Pembayaran',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isExpired ? Colors.red : _timerColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isExpired
                      ? 'Pemesanan akan dibatalkan secara otomatis.'
                      : 'Upload bukti pembayaran sebelum waktu habis. Jika tidak, kamar akan tersedia kembali untuk pengguna lain.',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isExpired ? Colors.red.shade700 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (!_isExpired)
            Text(
              _timerDisplay,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _timerColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _stepCircle('1', 'Pemesanan', true, done: true),
        _stepLine(true),
        _stepCircle('2', 'Pembayaran', true),
        _stepLine(false),
        _stepCircle('3', 'Verifikasi', false),
      ],
    );
  }

  Widget _stepCircle(String num, String label, bool isActive, {bool done = false}) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    num,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.blue : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isActive ? Colors.blue : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildInstructionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Transfer Bank
        BasicCard(
          title: 'Pembayaran via Transfer Bank',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _instructionStep(
                1,
                'Lakukan Transfer ke Rekening Berikut',
                'Pastikan nominal transfer sesuai dengan total tagihan.',
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Rekening',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    _bankInfoRow('Bank', 'Bank Syariah Indonesia (BSI)'),
                    _bankInfoRow('No. Rekening', '7123456789'),
                    _bankInfoRow('Atas Nama', 'Wisma Amal Gorontalo'),
                    const SizedBox(height: 12),
                    if (widget.reservation.invoiceAmount != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Jumlah Transfer:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              currencyFormat.format(widget.reservation.invoiceAmount!),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _instructionStep(
                2,
                'Simpan Bukti Transfer',
                'Screenshot atau foto struk transfer dari mobile banking / ATM.',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Pembayaran Cash
        BasicCard(
          title: 'Pembayaran Cash (Tunai)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _instructionStep(
                1,
                'Datang ke Pengelola Wisma',
                'Kunjungi kantor pengelola Wisma Amal Gorontalo secara langsung.',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bankInfoRow('Alamat', 'Jl. Wisma Amal No. 1, Gorontalo'),
                    _bankInfoRow('Jam Operasional', 'Senin – Sabtu, 08.00 – 17.00 WITA'),
                    _bankInfoRow('Kontak', '0811-4300-XXX'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _instructionStep(
                2,
                'Bayar & Minta Kwitansi',
                'Lakukan pembayaran tunai dan minta kwitansi resmi dari pengelola.',
              ),
              const SizedBox(height: 12),
              _instructionStep(
                3,
                'Foto Kwitansi',
                'Foto kwitansi pembayaran dengan jelas sebagai bukti.',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Upload Bukti
        BasicCard(
          title: 'Upload Bukti Pembayaran',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _instructionStep(
                1,
                'Pilih File Bukti',
                'Pilih foto struk transfer atau kwitansi cash yang jelas dan terbaca.',
              ),
              const SizedBox(height: 16),
              _buildUploadArea(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _instructionStep(int num, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              num.toString(),
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 3),
              Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bankInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ),
          const Text(': ', style: TextStyle(fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea() {
    return Column(
      children: [
        if (_selectedFile != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'File terpilih: ${_selectedFile!.name}',
                    style: const TextStyle(fontSize: 13, color: Colors.green),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _selectedFile = null),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isExpired
                ? null
                : () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                      withData: true, // pastikan bytes tersedia di semua platform termasuk web
                    );
                    if (result != null) {
                      setState(() => _selectedFile = result.files.first);
                    }
                  },
            icon: const Icon(Icons.image_outlined),
            label: Text(_selectedFile == null ? 'Pilih Gambar Bukti' : 'Ganti Gambar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    return Column(
      children: [
        BasicCard(
          title: 'Ringkasan Pesanan',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryRow('Kamar', widget.reservation.roomTitle),
              _summaryRow('No. Kamar', widget.reservation.roomNumber),
              _summaryRow(
                'Tipe Sewa',
                widget.reservation.rentalType == 'monthly' ? 'Bulanan' : 'Harian',
              ),
              _summaryRow('Mulai', widget.reservation.startDate),
              _summaryRow('Selesai', widget.reservation.endDate),
              const Divider(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Bayar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.reservation.invoiceAmount != null
                        ? currencyFormat.format(widget.reservation.invoiceAmount!)
                        : 'Rp -',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (widget.reservation.invoiceId != null)
                Text(
                  'ID Invoice: #${widget.reservation.invoiceId}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tombol Kirim
        Builder(builder: (context) {
          return BasicButton(
            label: _isSubmitting ? 'Mengirim...' : 'Kirim Bukti Pembayaran',
            isLoading: _isSubmitting,
            onPressed: (_selectedFile == null || _isExpired || _isSubmitting)
                ? null
                : () {
                    final invoiceId = widget.reservation.invoiceId;
                    if (invoiceId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ID invoice tidak ditemukan. Hubungi admin.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    context.read<MemberFinanceBloc>().add(
                      PayInvoiceEvent(
                        invoiceId,
                        'manual',
                        paymentProofBytes: _selectedFile!.bytes,
                        paymentProofName: _selectedFile!.name,
                      ),
                    );
                  },
          );
        }),

        const SizedBox(height: 12),

        // Tombol Batalkan
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isCancelling || _isSubmitting
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Batalkan Pemesanan?'),
                        content: const Text(
                          'Pemesanan akan dibatalkan dan kamar kembali tersedia untuk pengguna lain.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Tidak'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text(
                              'Ya, Batalkan',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      _countdownTimer?.cancel();
                      await _cancelAndGoBack();
                    }
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isCancelling
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                  )
                : const Text('Batalkan Pemesanan'),
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Kamar ini sedang dikunci untuk Anda selama batas waktu pembayaran.',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          textAlign: TextAlign.center,
        ),
      ],
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
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
