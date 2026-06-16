import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';

import 'package:frontend/presentation/bloc/reservation_detail_form/reservation_detail_form_bloc.dart';
import 'package:frontend/presentation/widget/core/appbar/custom_appbar.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/textform/textform.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/wrapper/hover_wrapper.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/core/constant/permission_key.dart';
import 'package:frontend/main.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/domain/usecase/resident/get_resident_profile_usecase.dart';
import 'package:frontend/domain/usecase/setting/get_public_settings_usecase.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';

@RoutePage()
class ReservationDetailFormPage extends StatelessWidget {
  final RoomEntity room;
  const ReservationDetailFormPage({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ReservationDetailFormBloc(
            getSettingsUseCase: serviceLocator.get<GetPublicSettingsUseCase>(),
            createReservationUseCase: serviceLocator.get(),
            getProfileUseCase: serviceLocator.get<GetResidentProfileUseCase>(),
          )..add(
            InitReservationEvent(
              room,
              isLoggedIn: context.read<AuthBloc>().state.isLoggedIn,
              userId: context.read<AuthBloc>().state.userInfo?.id,
              userName: context.read<AuthBloc>().state.userInfo?.name,
            ),
          ),
      child: const ReservationDetailFormView(),
    );
  }
}

class ReservationDetailFormView extends StatefulWidget {
  const ReservationDetailFormView({super.key});

  @override
  State<ReservationDetailFormView> createState() =>
      _ReservationDetailFormViewState();
}

class _ReservationDetailFormViewState extends State<ReservationDetailFormView> {
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    BuildContext context,
    TextEditingController controller,
    Function(DateTime) onDateSelected,
  ) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      final formatted = '${date.day}/${date.month}/${date.year}';
      controller.text = formatted;
      onDateSelected(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReservationDetailFormBloc, ReservationDetailFormState>(
      listener: (context, state) {
        if (state.startDate != null) {
          final date = state.startDate!;
          _startDateController.text = '${date.day}/${date.month}/${date.year}';
        }
        if (state.endDate != null) {
          final date = state.endDate!;
          _endDateController.text = '${date.day}/${date.month}/${date.year}';
        }

        if (state.readyToConfirm) {
          context.read<ReservationDetailFormBloc>().add(
            const ResetConfirmFlagEvent(),
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) _showConfirmReservationDialog(context);
          });
        }

        if (state.status == FormzSubmissionStatus.success) {
          AppSnackbar.showSuccess(
            'Pemesanan berhasil dibuat. Silakan selesaikan pembayaran.',
          );
          if (state.paymentMethod == 'tunai') {
            context.router.replace(
              PaymentUploadRoute(reservation: state.createdReservation!),
            );
          } else {
            context.router.replace(
              MidtransPaymentRoute(
                reservation: state.createdReservation!.copyWith(
                  selectedPaymentMethod: state.selectedMidtransMethod,
                ),
              ),
            );
          }
        } else if (state.status == FormzSubmissionStatus.failure) {
          final error = state.errorMessage ?? 'Gagal membuat pemesanan';
          AppSnackbar.showError(error);

          if (error.toLowerCase().contains('profil') ||
              error.toLowerCase().contains('biodata')) {
            context.router.push(const CompleteProfileRoute());
          }
        }
      },
      builder: (context, state) {
        final room = state.room;
        if (room == null)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );

        return Scaffold(
          appBar: CustomAppbar(
            icon: const Icon(Icons.arrow_back),
            title: 'Kembali',
            onPressed: () => context.router.pop(),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// LEFT
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        /// KAMAR
                        BasicCard(
                          title: 'Kamar yang dipilih',
                          child: Column(
                            children: [
                              /// BOX KAMAR (FULL WIDTH)
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.blue.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        room.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'No. ${room.number} • ${room.facilities.join(', ')}',
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Bulanan: ${room.priceFormatted} | Tahunan: Rp ${NumberFormat.decimalPattern('id').format((room.price * 12).toInt()).replaceAll(',', '.')}',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// RENT TYPE
                        BasicCard(
                          title: 'Pilih Jenis Sewa',
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              _rentCard(
                                title: 'Sewa Bulanan',
                                subtitle: 'Hemat jangka panjang',
                                price: '${room.priceFormatted} / bulan',
                                selected: state.rentType == 'Bulanan',
                                onTap: () => context
                                    .read<ReservationDetailFormBloc>()
                                    .add(const RentTypeChanged('Bulanan')),
                              ),

                              _rentCard(
                                title: 'Sewa Tahunan',
                                subtitle: 'Lebih hemat untuk jangka panjang',
                                price:
                                    'Rp ${NumberFormat.decimalPattern('id').format((room.price * 12).toInt()).replaceAll(',', '.')} / tahun',
                                selected: state.rentType == 'Tahunan',
                                onTap: () => context
                                    .read<ReservationDetailFormBloc>()
                                    .add(const RentTypeChanged('Tahunan')),
                              ),

                              // Daily logic (dipertahankan)
                              if (state.isDailyRentalEnabled &&
                                  room.priceDaily > 0)
                                const SizedBox.shrink(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// DETAIL SEWA
                        BasicCard(
                          title: 'Detail Sewa',
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _pickDate(
                                        context,
                                        _startDateController,
                                        (date) {
                                          context
                                              .read<ReservationDetailFormBloc>()
                                              .add(StartDateChanged(date));
                                        },
                                      ),
                                      child: AbsorbPointer(
                                        child: CustomTextForm(
                                          title: 'Tanggal Mulai',
                                          hintText: 'Pilih tanggal',
                                          controller: _startDateController,
                                          isRequired: true,
                                          suffixIcon: const Icon(
                                            Icons.calendar_today,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (state.rentType == 'Bulanan' ||
                                      state.rentType == 'Tahunan')
                                    Expanded(
                                      child: CustomTextForm(
                                        title: state.rentType == 'Bulanan'
                                            ? 'Jumlah Bulan'
                                            : 'Jumlah Tahun',
                                        hintText: state.rentType == 'Bulanan'
                                            ? 'Berapa bulan?'
                                            : 'Berapa tahun?',
                                        keyboardType: TextInputType.number,
                                        initialValue: state.durationMonths
                                            .toString(),
                                        onChanged: (val) {
                                          final value = int.tryParse(val) ?? 1;

                                          context
                                              .read<ReservationDetailFormBloc>()
                                              .add(
                                                DurationMonthsChanged(value),
                                              );
                                        },
                                        isRequired: true,
                                      ),
                                    ),
                                ],
                              ),
                              if (state.rentType == 'Bulanan' ||
                                  state.rentType == 'Tahunan') ...[
                                const SizedBox(height: 16),
                                CustomTextForm(
                                  title: 'Estimasi Tanggal Selesai',
                                  hintText: '-',
                                  controller: _endDateController,
                                  enabled: false,
                                  isRequired: false,
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// METODE PEMBAYARAN
                        BasicCard(
                          title: 'Metode Pembayaran',
                          child: Column(
                            children: [
                              Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  if (state.isMidtransEnabled)
                                    paymentMethodCard(
                                      title: 'Pembayaran Online',
                                      subtitle: _midtransSubtitle(
                                        state.midtransPaymentMethods,
                                      ),
                                      icon: Icons.account_balance_wallet,
                                      selected: state.paymentMethod == 'online',
                                      onTap: () => context
                                          .read<ReservationDetailFormBloc>()
                                          .add(
                                            const PaymentMethodChanged(
                                              'online',
                                            ),
                                          ),
                                    ),
                                  paymentMethodCard(
                                    title: 'Pembayaran Manual',
                                    subtitle: 'Transfer atau Cash dengan Bukti',
                                    icon: Icons.payments,
                                    selected: state.paymentMethod == 'tunai',
                                    onTap: () => context
                                        .read<ReservationDetailFormBloc>()
                                        .add(
                                          const PaymentMethodChanged('tunai'),
                                        ),
                                  ),
                                ],
                              ),

                              if (state.paymentMethod == 'online') ...[
                                const SizedBox(height: 24),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Pilih Metode Pembayaran',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Metode yang Anda pilih akan dibuka di halaman pembayaran Midtrans.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 8,
                                        crossAxisSpacing: 8,
                                        mainAxisExtent: 72,
                                      ),
                                  itemCount:
                                      state.midtransPaymentMethods.length,
                                  itemBuilder: (context, index) {
                                    final code =
                                        state.midtransPaymentMethods[index];
                                    final isSelected =
                                        state.selectedMidtransMethod == code;
                                    return _midtransMethodCard(
                                      code: code,
                                      selected: isSelected,
                                      onTap: () => context
                                          .read<ReservationDetailFormBloc>()
                                          .add(
                                            SelectedMidtransMethodChanged(
                                              isSelected ? null : code,
                                            ),
                                          ),
                                    );
                                  },
                                ),
                              ] else if (state.paymentMethod == 'tunai') ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.orange.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.orange.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Pembayaran Manual',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Colors.orange.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Lakukan transfer bank atau bayar cash, lalu unggah bukti pembayaran di langkah berikutnya.',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.orange.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                /// RIGHT
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      BasicCard(
                        title: 'Ringkasan Biaya',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(room.title),
                                Text(
                                  '${state.duration} '
                                  '${state.rentType == 'Bulanan'
                                      ? 'Bulan'
                                      : state.rentType == 'Tahunan'
                                      ? 'Tahun'
                                      : 'Hari'}',
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Harga / '
                                  '${state.rentType == 'Bulanan'
                                      ? 'bulan'
                                      : state.rentType == 'Tahunan'
                                      ? 'tahun'
                                      : 'hari'}',
                                ),
                                Text(
                                  state.rentType == 'Bulanan'
                                      ? room.priceFormatted
                                      : state.rentType == 'Tahunan'
                                      ? 'Rp ${NumberFormat.decimalPattern('id').format((room.price * 12).toInt()).replaceAll(',', '.')}'
                                      : room.priceDailyFormatted,
                                ),
                              ],
                            ),

                            const Divider(),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Biaya'),
                                Text(
                                  'Rp ${state.totalPrice}',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: BasicButton(
                          label: 'Pesan Kamar',
                          isLoading:
                              state.status == FormzSubmissionStatus.inProgress,
                          onPressed: () {
                            _showConfirmReservationDialog(context);
                          },
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Setelah submit, Anda akan diarahkan untuk melakukan pembayaran',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConfirmReservationDialog(BuildContext context) {
    final state = context.read<ReservationDetailFormBloc>().state;
    final authState = context.read<AuthBloc>().state;

    // 1. Pengecekan Login
    if (!authState.isLoggedIn) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Login Diperlukan'),
          content: const Text(
            'Untuk memesan kamar, Anda perlu login atau membuat akun terlebih dahulu.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Nanti Saja'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.router.push(LoginRoute(pendingRoom: state.room));
              },
              child: const Text('Login Sekarang'),
            ),
          ],
        ),
      );
      return;
    }

    // 2. Pengecekan Tanggal Mulai
    if (state.startDate == null) {
      AppSnackbar.showError('Pilih tanggal mulai terlebih dahulu');
      return;
    }

    // 3. Pengecekan Profil
    if (!state.isProfileComplete) {
      AppSnackbar.showInfo(
        'Silakan lengkapi biodata Anda (NIK, nomor telepon, dan alamat KTP) sebelum melanjutkan pemesanan.',
      );
      context.router.push(const CompleteProfileRoute()).then((_) {
        if (context.mounted) {
          context.read<ReservationDetailFormBloc>().add(
            const RefreshProfileStatusEvent(thenConfirm: true),
          );
        }
      });
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apakah Anda yakin ingin melakukan pemesanan kamar ini?',
            ),
            const SizedBox(height: 16),
            _infoRow('Kamar', state.room?.title ?? '-'),
            _infoRow(
              'Mulai',
              DateFormat('dd/MM/yyyy').format(state.startDate!),
            ),
            _infoRow('Total', 'Rp ${state.totalPrice}'),
            _infoRow(
              'Metode',
              state.paymentMethod == 'online'
                  ? (state.selectedMidtransMethod != null
                        ? 'Online · ${_kMidtransMethodMap[state.selectedMidtransMethod]?.name ?? state.selectedMidtransMethod!.toUpperCase()}'
                        : 'Online (Midtrans)')
                  : 'Manual',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ReservationDetailFormBloc>().add(
                const SubmitReservation(),
              );
            },
            child: const Text('Ya, Pesan Sekarang'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// RENT CARD
Widget _rentCard({
  required String title,
  required String subtitle,
  required String price,
  required bool selected,
  required VoidCallback onTap,
}) {
  return HoverTapWrapper(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    hoverColor: Colors.blue.withOpacity(0.05),
    child: Container(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 358),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? Colors.blue : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? Colors.blue : Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),
          Text(
            price,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.blue : Colors.green,
            ),
          ),
        ],
      ),
    ),
  );
}

/// PAYMENT METHOD CARD
Widget paymentMethodCard({
  required String title,
  required String subtitle,
  required IconData icon,
  required bool selected,
  required VoidCallback onTap,
}) {
  return HoverTapWrapper(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    hoverColor: Colors.blue.withOpacity(0.05),

    child: Container(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 358),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: selected ? Colors.blue.shade50 : Colors.white,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: selected ? Colors.blue : Colors.grey.shade300,
        ),
      ),

      child: Row(
        children: [
          Icon(icon, color: selected ? Colors.blue : Colors.grey),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,

            color: selected ? Colors.blue : Colors.grey,
          ),
        ],
      ),
    ),
  );
}

// ── Midtrans payment method metadata ─────────────────────────────────────────

class _MidtransMethodInfo {
  const _MidtransMethodInfo(this.name, this.desc, this.icon);
  final String name;
  final String desc;
  final IconData icon;
}

const Map<String, _MidtransMethodInfo> _kMidtransMethodMap = {
  'qris': _MidtransMethodInfo(
    'QRIS',
    'Scan QR dari semua e-wallet & bank',
    Icons.qr_code,
  ),
  'gopay': _MidtransMethodInfo(
    'GoPay',
    'Bayar dengan saldo GoPay',
    Icons.account_balance_wallet,
  ),
  'shopeepay': _MidtransMethodInfo(
    'ShopeePay',
    'Bayar dengan saldo ShopeePay',
    Icons.shopping_bag,
  ),
  'dana': _MidtransMethodInfo(
    'DANA',
    'Bayar dengan saldo DANA',
    Icons.account_balance_wallet,
  ),
  'linkaja': _MidtransMethodInfo(
    'LinkAja',
    'Bayar dengan LinkAja',
    Icons.account_balance_wallet,
  ),
  'ovo': _MidtransMethodInfo(
    'OVO',
    'Bayar dengan saldo OVO',
    Icons.account_balance_wallet,
  ),
  'bca_va': _MidtransMethodInfo(
    'BCA Virtual Account',
    'Transfer via ATM / m-BCA',
    Icons.account_balance,
  ),
  'bni_va': _MidtransMethodInfo(
    'BNI Virtual Account',
    'Transfer via ATM / BNI Mobile',
    Icons.account_balance,
  ),
  'bri_va': _MidtransMethodInfo(
    'BRI Virtual Account',
    'Transfer via ATM / BRImo',
    Icons.account_balance,
  ),
  'mandiri_va': _MidtransMethodInfo(
    'Mandiri Virtual Account',
    'Transfer via Mandiri Livin\'',
    Icons.account_balance,
  ),
  'echannel': _MidtransMethodInfo(
    'Mandiri Bill',
    'Bayar via Mandiri Livin\'',
    Icons.account_balance,
  ),
  'permata_va': _MidtransMethodInfo(
    'Permata Virtual Account',
    'Transfer via ATM Permata',
    Icons.account_balance,
  ),
  'other_va': _MidtransMethodInfo(
    'Virtual Account',
    'Transfer via bank lain',
    Icons.account_balance,
  ),
  'alfamart': _MidtransMethodInfo(
    'Alfamart',
    'Bayar di kasir Alfamart',
    Icons.store,
  ),
  'indomaret': _MidtransMethodInfo(
    'Indomaret',
    'Bayar di kasir Indomaret',
    Icons.store,
  ),
  'credit_card': _MidtransMethodInfo(
    'Kartu Kredit/Debit',
    'Visa, Mastercard, JCB',
    Icons.credit_card,
  ),
  'akulaku': _MidtransMethodInfo(
    'Akulaku',
    'Cicilan 0% via Akulaku',
    Icons.credit_card,
  ),
  'kredivo': _MidtransMethodInfo(
    'Kredivo',
    'Cicilan via Kredivo',
    Icons.credit_card,
  ),
};

/// Subtitle dinamis berdasarkan metode yang tersedia
String _midtransSubtitle(List<String> methods) {
  if (methods.isEmpty) return 'QRIS, GoPay, dan lainnya';
  final names = methods
      .map((c) => _kMidtransMethodMap[c]?.name ?? c.toUpperCase())
      .take(3)
      .join(', ');
  return methods.length > 3 ? '$names, +${methods.length - 3} lainnya' : names;
}

/// Kartu metode pembayaran Midtrans — list-tile style, tinggi tetap 72px
Widget _midtransMethodCard({
  required String code,
  required bool selected,
  required VoidCallback onTap,
}) {
  final info =
      _kMidtransMethodMap[code] ??
      _MidtransMethodInfo(code.toUpperCase(), 'Metode Midtrans', Icons.payment);

  return HoverTapWrapper(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    hoverColor: Colors.blue.withValues(alpha: 0.04),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: selected ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? Colors.blue : Colors.grey.shade300,
          width: selected ? 1.5 : 1.0,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ikon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.blue.withValues(alpha: 0.12)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                info.icon,
                size: 20,
                color: selected ? Colors.blue : Colors.grey.shade500,
              ),
            ),
            const SizedBox(width: 10),
            // Nama + deskripsi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    info.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                      height: 1.3,
                      color: selected ? Colors.blue.shade800 : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    info.desc,
                    style: TextStyle(
                      fontSize: 10.5,
                      height: 1.2,
                      color: Colors.grey.shade500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            // Indikator pilih
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              size: 18,
              color: selected ? Colors.blue : Colors.grey.shade300,
            ),
          ],
        ),
      ),
    ),
  );
}
