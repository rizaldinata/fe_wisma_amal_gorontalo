import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

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
import 'package:frontend/core/dependency_injection/dependency_injection.dart';

@RoutePage()
class ReservationDetailFormPage extends StatelessWidget {
  final RoomEntity room;
  const ReservationDetailFormPage({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReservationDetailFormBloc(
        getSettingsUseCase: serviceLocator.get(),
        createReservationUseCase: serviceLocator.get(),
      )..add(InitReservationEvent(room)),
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

        if (state.status == FormzSubmissionStatus.success) {
          AppSnackbar.showSuccess(
            'Pemesanan berhasil dibuat. Silakan selesaikan pembayaran.',
          );
          context.router.replace(const MemberFinanceRoute());
        } else if (state.status == FormzSubmissionStatus.failure) {
          AppSnackbar.showError(
            state.errorMessage ?? 'Gagal membuat pemesanan',
          );
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
                                        'Bulanan: ${room.priceFormatted}${room.priceDaily > 0 ? ' | Harian: ${room.priceDailyFormatted}' : ''}',
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
                              if (state.isDailyRentalEnabled &&
                                  room.priceDaily > 0)
                                _rentCard(
                                  title: 'Sewa Harian',
                                  subtitle: 'Fleksibel jangka pendek',
                                  price: '${room.priceDailyFormatted} / hari',
                                  selected: state.rentType == 'Harian',
                                  onTap: () => context
                                      .read<ReservationDetailFormBloc>()
                                      .add(const RentTypeChanged('Harian')),
                                ),
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
                                  if (state.rentType == 'Harian')
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _pickDate(
                                          context,
                                          _endDateController,
                                          (date) {
                                            context
                                                .read<
                                                  ReservationDetailFormBloc
                                                >()
                                                .add(EndDateChanged(date));
                                          },
                                        ),
                                        child: AbsorbPointer(
                                          child: CustomTextForm(
                                            title: 'Tanggal Selesai',
                                            hintText: 'Pilih tanggal',
                                            controller: _endDateController,
                                            isRequired: true,
                                            suffixIcon: const Icon(
                                              Icons.calendar_today,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (state.rentType == 'Bulanan')
                                    Expanded(
                                      child: CustomTextForm(
                                        title: 'Jumlah Bulan',
                                        hintText: 'Berapa bulan?',
                                        keyboardType: TextInputType.number,
                                        initialValue: state.durationMonths
                                            .toString(),
                                        onChanged: (val) {
                                          final months = int.tryParse(val) ?? 1;
                                          context
                                              .read<ReservationDetailFormBloc>()
                                              .add(
                                                DurationMonthsChanged(months),
                                              );
                                        },
                                        isRequired: true,
                                      ),
                                    ),
                                ],
                              ),
                              if (state.rentType == 'Bulanan') ...[
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
                              /// Payment Method Selection
                              Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  paymentMethodCard(
                                    title: 'Pembayaran Online',
                                    subtitle: 'Transfer Virtual Account',
                                    icon: Icons.account_balance_wallet,
                                    selected: state.paymentMethod == 'online',
                                    onTap: () => context
                                        .read<ReservationDetailFormBloc>()
                                        .add(
                                          const PaymentMethodChanged('online'),
                                        ),
                                  ),
                                  paymentMethodCard(
                                    title: 'Pembayaran Tunai',
                                    subtitle: 'Bayar langsung dengan bukti',
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
                                const Text(
                                  'Pilih Bank untuk Virtual Account',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    bankSelectionCard(
                                      bankName: 'Mandiri',
                                      bankCode: 'mandiri',
                                      icon: '🏦',
                                      selected: state.selectedBank == 'mandiri',
                                      onTap: () => context
                                          .read<ReservationDetailFormBloc>()
                                          .add(
                                            const SelectedBankChanged(
                                              'mandiri',
                                            ),
                                          ),
                                    ),
                                    bankSelectionCard(
                                      bankName: 'BCA',
                                      bankCode: 'bca',
                                      icon: '🏛️',
                                      selected: state.selectedBank == 'bca',
                                      onTap: () => context
                                          .read<ReservationDetailFormBloc>()
                                          .add(
                                            const SelectedBankChanged('bca'),
                                          ),
                                    ),
                                    bankSelectionCard(
                                      bankName: 'BRI',
                                      bankCode: 'bri',
                                      icon: '🏪',
                                      selected: state.selectedBank == 'bri',
                                      onTap: () => context
                                          .read<ReservationDetailFormBloc>()
                                          .add(
                                            const SelectedBankChanged('bri'),
                                          ),
                                    ),
                                  ],
                                ),
                              ] else if (state.paymentMethod == 'tunai') ...[
                                const SizedBox(height: 24),
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
                                              'Pembayaran Tunai',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Colors.orange.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Anda akan diminta untuk mengunggah bukti pembayaran setelah pemesanan.',
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
                                  '${state.duration} ${state.rentType == 'Bulanan' ? 'Bulan' : 'Hari'}',
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Harga / ${state.rentType == 'Bulanan' ? 'bulan' : 'hari'}',
                                ),
                                Text(
                                  state.rentType == 'Bulanan'
                                      ? room.priceFormatted
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
                            final authState = context.read<AuthBloc>().state;
                            if (!authState.isLoggedIn) {
                              AppSnackbar.showError(
                                'Silakan login terlebih dahulu',
                              );
                              context.router.push(LoginRoute());
                              return;
                            }

                            if (state.startDate == null) {
                              AppSnackbar.showError(
                                'Pilih tanggal mulai terlebih dahulu',
                              );
                              return;
                            }

                            if (state.rentType == 'Harian' &&
                                state.endDate == null) {
                              AppSnackbar.showError(
                                'Pilih tanggal selesai terlebih dahulu',
                              );
                              return;
                            }

                            if (state.rentType == 'Harian' &&
                                state.duration <= 0) {
                              AppSnackbar.showError(
                                'Tanggal selesai harus setelah tanggal mulai',
                              );
                              return;
                            }

                            final roles = authState.userInfo?.roles ?? [];
                            final isMember = roles.contains('member');
                            final isResident = roles.contains('resident');

                            if (context.can(
                                  PermissionKeys.completeResidentProfile,
                                ) &&
                                !isMember &&
                                !isResident) {
                              AppSnackbar.showError(
                                'Silakan lengkapi biodata Anda terlebih dahulu',
                              );
                              context.router.push(CompleteProfileRoute());
                              return;
                            }

                            context.read<ReservationDetailFormBloc>().add(
                              const SubmitReservation(),
                            );
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

/// BANK SELECTION CARD
Widget bankSelectionCard({
  required String bankName,
  required String bankCode,
  required String icon,
  required bool selected,
  required VoidCallback onTap,
}) {
  return HoverTapWrapper(
    onTap: onTap,

    borderRadius: BorderRadius.circular(12),

    hoverColor: Colors.blue.withOpacity(0.05),

    child: Container(
      width: 140,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: selected ? Colors.blue.shade50 : Colors.white,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: selected ? Colors.blue : Colors.grey.shade300,
        ),
      ),

      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),

          const SizedBox(height: 10),

          Text(
            bankName,
            style: TextStyle(
              fontWeight: FontWeight.bold,

              color: selected ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    ),
  );
}
