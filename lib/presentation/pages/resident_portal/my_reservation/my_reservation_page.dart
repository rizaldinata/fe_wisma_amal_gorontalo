import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/domain/entity/reservation_entity.dart';
import 'package:frontend/presentation/bloc/my_reservation/my_reservation_bloc.dart';
import 'package:frontend/presentation/bloc/my_reservation/my_reservation_event.dart';
import 'package:frontend/presentation/bloc/my_reservation/my_reservation_state.dart';
import 'package:intl/intl.dart';

@RoutePage()
class MyReservationPage extends StatefulWidget {
  const MyReservationPage({super.key});

  @override
  State<MyReservationPage> createState() => _MyReservationPageState();
}

class _MyReservationPageState extends State<MyReservationPage> {
  late final MyReservationBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = serviceLocator<MyReservationBloc>();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<MyReservationBloc, MyReservationState>(
        listenWhen: (prev, curr) =>
            prev.cancelStatus != curr.cancelStatus ||
            prev.pembatalanDpStatus != curr.pembatalanDpStatus,
        listener: (context, state) {
          if (state.cancelStatus == FormzSubmissionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Gagal membatalkan reservasi'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state.pembatalanDpStatus == FormzSubmissionStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permintaan pembatalan berhasil diajukan. Menunggu review admin.'),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state.pembatalanDpStatus == FormzSubmissionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Gagal mengajukan pembatalan'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Reservasi Saya'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _bloc.add(GetMyReservationsEvent()),
                tooltip: 'Refresh',
              ),
            ],
          ),
          body: BlocBuilder<MyReservationBloc, MyReservationState>(
            builder: (context, state) {
              if (state.status == FormzSubmissionStatus.inProgress ||
                  state.status == FormzSubmissionStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == FormzSubmissionStatus.failure) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.errorMessage ?? 'Terjadi kesalahan'),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () =>
                            context.read<MyReservationBloc>().add(GetMyReservationsEvent()),
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                );
              }

              if (state.reservations.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada reservasi',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<MyReservationBloc>().add(GetMyReservationsEvent()),
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: state.reservations.length,
                  itemBuilder: (context, index) {
                    return _ReservationCard(reservation: state.reservations[index]);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final ReservationEntity reservation;
  const _ReservationCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(reservation.status);
    final statusLabel = _statusLabel(reservation.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ikon + nama kamar + status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.meeting_room_outlined, color: Colors.deepPurple),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.roomTitle,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Kamar ${reservation.roomNumber}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Periode sewa
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mulai',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reservation.startDate,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: Colors.grey.shade400, size: 18),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Selesai',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            reservation.endDate,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info jika status terkonfirmasi (pembayaran lunas, menunggu tanggal masuk)
            if (reservation.status == 'terkonfirmasi') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pembayaran dikonfirmasi — Kamar siap pada tanggal masuk.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade800,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Info DP jika status dp_terbayar
            if (reservation.isDpTerbayar) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.payments_outlined, size: 16, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'DP Terbayar — Menunggu Pelunasan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                    if (reservation.dpAmount != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'DP dibayar: Rp ${_fmtNumber(reservation.dpAmount!)}',
                        style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Silakan lunasi sisa pembayaran sebelum tanggal masuk melalui halaman Tagihan.',
                      style: TextStyle(fontSize: 11, color: Colors.orange.shade700, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],

            // Action button (contextual berdasarkan status)
            if (reservation.status == 'pending' ||
                reservation.status == 'active' ||
                reservation.isDpTerbayar ||
                (reservation.status == 'terkonfirmasi' && reservation.isDp)) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (reservation.status == 'active')
                    OutlinedButton.icon(
                      onPressed: () => context.router.navigate(const MemberFinanceRoute()),
                      icon: const Icon(Icons.receipt_long_outlined, size: 16),
                      label: const Text('Lihat Tagihan'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        side: const BorderSide(color: Colors.deepPurple),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  if (reservation.isDpTerbayar) ...[
                    OutlinedButton.icon(
                      onPressed: () => context.router.navigate(const MemberFinanceRoute()),
                      icon: const Icon(Icons.receipt_long_outlined, size: 16),
                      label: const Text('Bayar Pelunasan'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                  if ((reservation.isDpTerbayar || reservation.status == 'terkonfirmasi') &&
                      reservation.isDp) ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _showAjukanPembatalanDialog(context, reservation),
                      icon: const Icon(Icons.cancel_schedule_send_outlined, size: 16),
                      label: const Text('Ajukan Pembatalan'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade700),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                  if (reservation.status == 'pending') ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _confirmCancel(context, reservation),
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Batalkan'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAjukanPembatalanDialog(BuildContext context, ReservationEntity reservation) {
    final bankCtrl = TextEditingController();
    final noRekCtrl = TextEditingController();
    final atasNamaCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return BlocProvider.value(
            value: context.read<MyReservationBloc>(),
            child: BlocListener<MyReservationBloc, MyReservationState>(
              listenWhen: (prev, curr) => prev.pembatalanDpStatus != curr.pembatalanDpStatus,
              listener: (_, state) {
                if (state.pembatalanDpStatus == FormzSubmissionStatus.success ||
                    state.pembatalanDpStatus == FormzSubmissionStatus.failure) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: AlertDialog(
                title: const Text('Ajukan Pembatalan DP'),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade300),
                          ),
                          child: Text(
                            'Pengajuan pembatalan akan direview oleh admin. '
                            'Jika disetujui dan berhak refund (lebih dari 3 hari sebelum tanggal masuk), '
                            'dana akan ditransfer ke rekening yang tertera.',
                            style: TextStyle(fontSize: 12, color: Colors.amber.shade900, height: 1.4),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: bankCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nama Bank',
                            hintText: 'Contoh: BRI, BCA, Mandiri',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: noRekCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Nomor Rekening',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: atasNamaCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Atas Nama',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Batal'),
                  ),
                  BlocBuilder<MyReservationBloc, MyReservationState>(
                    builder: (_, state) {
                      final isLoading =
                          state.pembatalanDpStatus == FormzSubmissionStatus.inProgress;
                      return ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (!formKey.currentState!.validate()) return;
                                context.read<MyReservationBloc>().add(
                                      AjukanPembatalanDpEvent(
                                        scheduleId: reservation.id,
                                        bankName: bankCtrl.text.trim(),
                                        accountNumber: noRekCtrl.text.trim(),
                                        accountHolderName: atasNamaCtrl.text.trim(),
                                      ),
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Kirim Pengajuan'),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmCancel(BuildContext context, ReservationEntity reservation) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batalkan Reservasi?'),
        content: Text(
          'Reservasi kamar ${reservation.roomNumber} akan dibatalkan. Tindakan ini tidak bisa diurungkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<MyReservationBloc>().add(CancelMyReservationEvent(reservation.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'dp_terbayar':
        return Colors.deepOrange;
      case 'terkonfirmasi':
        return Colors.blue;
      case 'finished':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'dp_terbayar':
        return 'DP Terbayar';
      case 'terkonfirmasi':
        return 'Terkonfirmasi';
      case 'finished':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String _fmtNumber(double value) {
    final parts = value.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buffer.write('.');
      buffer.write(parts[i]);
    }
    return buffer.toString();
  }
}
