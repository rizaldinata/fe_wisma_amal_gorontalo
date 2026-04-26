import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/presentation/bloc/reservation_detail_form/reservation_detail_form_bloc.dart';
import 'package:frontend/presentation/widget/core/appbar/custom_appbar.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/textform/textform.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/wrapper/hover_wrapper.dart';

@RoutePage()
class ReservationDetailFormPage extends StatelessWidget {
  const ReservationDetailFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReservationDetailFormBloc()..add(InitReservationEvent()),
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
  ) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      controller.text = '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReservationDetailFormBloc, ReservationDetailFormState>(
      builder: (context, state) {
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
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Kamar 105',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text('Lantai 1 • AC'),
                                      SizedBox(height: 8),
                                      Text(
                                        'Harian: Rp.150.000 | Bulanan: Rp.1.500.000',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              /// INFO BOX (FULL WIDTH)
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                    ),
                                  ),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Informasi Penting',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'Kamar ini sedang disewa hingga 15-02-2025. Pilih tanggal setelah itu.',
                                        style: TextStyle(color: Colors.red),
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
                                title: 'Sewa Harian',
                                subtitle: 'Fleksibel jangka pendek',
                                price: 'Rp. 150.000 / hari',
                                selected: state.rentType == 'Harian',
                                onTap: () => context
                                    .read<ReservationDetailFormBloc>()
                                    .add(RentTypeChanged('Harian')),
                              ),
                              _rentCard(
                                title: 'Sewa Bulanan',
                                subtitle: 'Hemat jangka panjang',
                                price: 'Rp. 1.500.000 / bulan',
                                selected: state.rentType == 'Bulanan',
                                onTap: () => context
                                    .read<ReservationDetailFormBloc>()
                                    .add(RentTypeChanged('Bulanan')),
                              ),
                              _rentCard(
                                title: 'Sewa Tahunan',
                                subtitle: 'Paling hemat',
                                price: 'Rp. 18.000.000 / tahun',
                                selected: state.rentType == 'Tahunan',
                                onTap: () => context
                                    .read<ReservationDetailFormBloc>()
                                    .add(RentTypeChanged('Tahunan')),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// DETAIL SEWA
                        BasicCard(
                          title: 'Detail Sewa',
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _pickDate(context, _startDateController),
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
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _pickDate(context, _endDateController),
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
                                const Text('Kamar 105'),
                                Text('${state.duration} Hari'),
                              ],
                            ),
                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text('Harga per hari'),
                                Text('Rp. 150.000'),
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
                          onPressed: () {},
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Setelah submit, Anda akan dihubungi untuk pembayaran',
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
