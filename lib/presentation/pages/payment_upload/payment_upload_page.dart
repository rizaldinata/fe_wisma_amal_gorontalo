import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/navigation/auto_route.gr.dart';
import '../../../domain/entity/reservation_entity.dart';
import '../../bloc/member_finance/member_finance_bloc.dart';
import '../../bloc/member_finance/member_finance_event.dart';
import '../../bloc/member_finance/member_finance_state.dart';
import '../../widget/core/card/basic_card.dart';
import '../../widget/core/botton/button.dart';
import '../../widget/core/appbar/custom_appbar.dart';

@RoutePage()
class PaymentUploadPage extends StatefulWidget {
  final ReservationEntity reservation;
  const PaymentUploadPage({super.key, required this.reservation});

  @override
  State<PaymentUploadPage> createState() => _PaymentUploadPageState();
}

class _PaymentUploadPageState extends State<PaymentUploadPage> {
  PlatformFile? _selectedFile;
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator.get<MemberFinanceBloc>(),
      child: BlocListener<MemberFinanceBloc, MemberFinanceState>(
        listener: (context, state) {
          if (state.status == MemberFinanceStatus.paymentSuccess) {
            _showSuccessDialog();
          } else if (state.status == MemberFinanceStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Gagal mengunggah bukti')),
            );
          }
        },
        child: Scaffold(
          appBar: CustomAppbar(
            title: 'Pembayaran Manual',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.router.pop(),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepIndicator(),
                    const SizedBox(height: 32),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildInstructionSection()),
                        const SizedBox(width: 24),
                        Expanded(flex: 1, child: _buildSummarySection()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _stepCircle('1', 'Pemesanan', true),
        _stepLine(true),
        _stepCircle('2', 'Pembayaran', true),
        _stepLine(false),
        _stepCircle('3', 'Verifikasi', false),
      ],
    );
  }

  Widget _stepCircle(String num, String label, bool isActive) {
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
            child: Text(
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
        BasicCard(
          title: 'Langkah-Langkah Pembayaran',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _instructionStep(
                1,
                'Lakukan Transfer atau Pembayaran Tunai',
                'Silakan melakukan transfer ke rekening bank di bawah atau membayar tunai ke pengelola.',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Rekening (Jika Transfer):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    _bankInfoRow('Bank', 'Bank Syariah Indonesia (BSI)'),
                    _bankInfoRow('No. Rekening', '7123456789'),
                    _bankInfoRow('Atas Nama', 'Wisma Amal Gorontalo'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _instructionStep(
                2,
                'Foto Bukti Pembayaran',
                'Pastikan foto bukti transfer atau kwitansi pembayaran tunai terlihat jelas.',
              ),
              const SizedBox(height: 24),
              _instructionStep(
                3,
                'Unggah Bukti',
                'Pilih file gambar bukti pembayaran melalui tombol di bawah ini.',
              ),
              const SizedBox(height: 24),
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
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              num.toString(),
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bankInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 13))),
          Text(': ', style: const TextStyle(fontSize: 13)),
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
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 12),
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
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(type: FileType.image);
              if (result != null) {
                setState(() => _selectedFile = result.files.first);
              }
            },
            icon: const Icon(Icons.image_outlined),
            label: Text(_selectedFile == null ? 'Pilih Gambar Bukti' : 'Ganti Gambar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
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
              _summaryRow('Tipe Sewa', widget.reservation.rentalType == 'monthly' ? 'Bulanan' : 'Harian'),
              _summaryRow('Mulai', widget.reservation.startDate),
              _summaryRow('Selesai', widget.reservation.endDate),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Bayar', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text(
                    'Rp -', // We need total price here, might need to fetch invoice
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Builder(builder: (context) {
                return BasicButton(
                  label: 'Kirim Bukti Pembayaran',
                  onPressed: _selectedFile == null
                      ? null
                      : () {
                          // We need the actual invoice ID. Assuming reservation ID for now
                          // In a real app, we should fetch the invoice for this reservation
                          context.read<MemberFinanceBloc>().add(
                            PayInvoiceEvent(
                              widget.reservation.id, // Using reservation ID as fallback
                              'manual',
                              paymentProofPath: _selectedFile!.path,
                            ),
                          );
                        },
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Berhasil Diunggah'),
        content: const Text(
          'Bukti pembayaran Anda telah berhasil dikirim. Menunggu konfirmasi dari admin. Anda akan menjadi penghuni resmi setelah pembayaran diverifikasi.',
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
}
