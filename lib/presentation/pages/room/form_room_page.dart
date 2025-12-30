import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/presentation/bloc/room/room_bloc.dart';
import 'package:frontend/presentation/bloc/room/room_event.dart';
import 'package:frontend/presentation/bloc/room/room_state.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/textform/textform.dart';

@RoutePage()
class FormRoomPage extends StatefulWidget {
  final RoomEntity? room;

  const FormRoomPage({super.key, this.room});

  @override
  State<FormRoomPage> createState() => _FormRoomPageState();
}

class _FormRoomPageState extends State<FormRoomPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numberController;
  late TextEditingController _typeController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  String _selectedStatus = 'available';

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(text: widget.room?.number ?? '');
    _typeController = TextEditingController(text: widget.room?.type ?? '');
    String priceText = widget.room?.price.toString() ?? '';
    if (priceText.endsWith('.0')) {
      priceText = priceText.substring(0, priceText.length - 2);
    }
    _priceController = TextEditingController(text: priceText);
    _descController = TextEditingController(
      text: widget.room?.description ?? '',
    );
    if (widget.room != null) {
      const validStatuses = ['available', 'occupied', 'maintenance'];
      String incomingStatus = widget.room!.status;

      if (validStatuses.contains(incomingStatus)) {
        _selectedStatus = incomingStatus;
      } else {
        if (incomingStatus.toLowerCase() == 'tersedia') {
          _selectedStatus = 'available';
        } else if (incomingStatus.toLowerCase() == 'terisi') {
          _selectedStatus = 'occupied';
        } else if (incomingStatus.toLowerCase() == 'perbaikan') {
          _selectedStatus = 'maintenance';
        } else {
          _selectedStatus = 'available';
        }
      }
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _typeController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<RoomBloc>(),
      child: BlocConsumer<RoomBloc, RoomState>(
        listener: (context, state) {
          if (state.status == RoomStatus.success) {
            context.router.maybePop(true);
          }
          if (state.errorMessage != null) {
            AppSnackbar.showError(state.errorMessage!);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.room == null ? "Tambah Kamar" : "Edit Kamar"),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextForm(
                      controller: _numberController,
                      title: "Nomor Kamar", // PERBAIKAN: Gunakan title
                      hintText:
                          "Masukkan nomor kamar", // PERBAIKAN: Gunakan hintText
                      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextForm(
                      controller: _typeController,
                      title: "Tipe Kamar",
                      hintText: "Contoh: Deluxe, Standard",
                      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextForm(
                      controller: _priceController,
                      title: "Harga per Bulan",
                      hintText: "0",
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: "Status",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'available',
                          child: Text("Available"),
                        ),
                        DropdownMenuItem(
                          value: 'occupied',
                          child: Text("Occupied"),
                        ),
                        DropdownMenuItem(
                          value: 'maintenance',
                          child: Text("Maintenance"),
                        ),
                      ],
                      onChanged: (val) =>
                          setState(() => _selectedStatus = val!),
                    ),
                    const SizedBox(height: 16),
                    CustomTextForm(
                      controller: _descController,
                      title: "Deskripsi",
                      hintText: "Deskripsi fasilitas kamar (Opsional)",
                      maxLines: 3, // Sekarang sudah didukung
                    ),
                    const SizedBox(height: 24),
                    BasicButton(
                      isLoading: state.status == RoomStatus.loading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          String cleanPrice = _priceController.text.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );

                          final roomData = RoomEntity(
                            id: widget.room?.id ?? 0,
                            number: _numberController.text,
                            type: _typeController.text,
                            price: double.tryParse(cleanPrice) ?? 0,
                            status: _selectedStatus,
                            description: _descController.text,
                          );

                          if (widget.room == null) {
                            context.read<RoomBloc>().add(
                              AddRoomEvent(roomData),
                            );
                          } else {
                            context.read<RoomBloc>().add(
                              UpdateRoomEvent(widget.room!.id, roomData),
                            );
                          }
                        }
                      },
                      label: "Simpan Data",
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
