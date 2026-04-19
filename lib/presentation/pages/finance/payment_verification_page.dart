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

@RoutePage()
class PaymentVerificationPage extends StatefulWidget {
  const PaymentVerificationPage({super.key});

  @override
  State<PaymentVerificationPage> createState() => _PaymentVerificationPageState();
}

class _PaymentVerificationPageState extends State<PaymentVerificationPage> {
  late PaymentVerificationBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = serviceLocator.get<PaymentVerificationBloc>();
    _bloc.add(FetchPendingPayments());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  String formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  void _showRefundDialog(PaymentEntity payment) {
    if (Navigator.canPop(context)) Navigator.pop(context); // Menutup dialog verifikasi sebelumnya
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Proses Refund #${payment.transactionId ?? payment.id}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Perhatian: Fitur ini akan mengembalikan dana ke saldo rekening (Midtrans) pengguna secara otomatis.', style: TextStyle(fontSize: 12, color: Colors.red)),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Alasan Refund',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Alasan refund wajib diisi!'))
                  );
                  return;
                }
                _bloc.add(RefundPaymentEvent(
                  paymentId: payment.id, 
                  reason: reasonController.text,
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Kirim Refund', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showVerificationDialog(PaymentEntity payment) {
    final notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Verifikasi Pembayaran #${payment.transactionId ?? payment.id}'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bukti Transfer:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: (payment.paymentProofUrl != null && payment.paymentProofUrl!.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              payment.paymentProofUrl!, 
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 50)),
                            ),
                          )
                        : const Center(child: Text('Tidak ada gambar')),
                  ),
                  const SizedBox(height: 16),
                  Text('Nominal: ${formatRupiah(payment.amount)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Catatan Penolakan (Wajib jika ditolak):', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Misal: Bukti transfer buram...',
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                if (notesController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Catatan wajib diisi jika Anda menolak pembayaran!'))
                  );
                  return;
                }
                _bloc.add(VerifyPaymentEvent(
                  paymentId: payment.id, 
                  isApproved: false, // Set false untuk Reject
                  adminNotes: notesController.text,
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Tolak', style: TextStyle(color: Colors.white)),
            ),
            if (payment.paymentMethod == 'midtrans')
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () => _showRefundDialog(payment),
                child: const Text('Refund', style: TextStyle(color: Colors.white)),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                _bloc.add(VerifyPaymentEvent(
                  paymentId: payment.id, 
                  isApproved: true, // Set true untuk Approve
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Setujui', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<PaymentVerificationBloc, PaymentVerificationState>(
        listener: (context, state) {
          if (state is PaymentVerificationActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
          } else if (state is PaymentVerificationError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Verifikasi Pembayaran Manual'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: BlocBuilder<PaymentVerificationBloc, PaymentVerificationState>(
              buildWhen: (prev, current) => current is PaymentVerificationLoading || current is PaymentVerificationLoaded,
              builder: (context, state) {
                if (state is PaymentVerificationLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PaymentVerificationLoaded) {
                  if (state.pendingPayments.isEmpty) {
                    return const Center(child: Text('Tidak ada pembayaran yang menunggu verifikasi saat ini.'));
                  }

                  return ListView.builder(
                    itemCount: state.pendingPayments.length,
                    itemBuilder: (context, index) {
                      final payment = state.pendingPayments[index];
                      // Menghindari null pada tanggal jika terjadi kesalahan parsing
                      final dateString = payment.paymentDate;
                      final formattedDate = dateString.isNotEmpty 
                          ? DateFormat('dd MMM yyyy HH:mm').format(DateTime.tryParse(dateString) ?? DateTime.now())
                          : 'Tanggal tidak valid';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: BasicCard(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            leading: const CircleAvatar(
                              backgroundColor: Colors.orangeAccent,
                              child: Icon(Icons.access_time_filled, color: Colors.white),
                            ),
                            title: Text('Transaksi #${payment.transactionId ?? payment.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Nominal: ${formatRupiah(payment.amount)}'),
                                Text('Tanggal: $formattedDate'),
                              ],
                            ),
                            trailing: ElevatedButton.icon(
                              icon: const Icon(Icons.image_search, size: 18),
                              label: const Text('Cek Bukti'),
                              onPressed: () => _showVerificationDialog(payment),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}