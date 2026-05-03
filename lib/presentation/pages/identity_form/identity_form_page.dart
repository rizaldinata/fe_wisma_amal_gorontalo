import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/presentation/bloc/resident/complete_profile/complete_profile_bloc.dart';
import 'package:frontend/presentation/bloc/resident/complete_profile/complete_profile_event.dart';
import 'package:frontend/presentation/bloc/resident/complete_profile/complete_profile_state.dart';
import 'package:frontend/presentation/widget/core/appbar/custom_appbar.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';
import 'package:frontend/presentation/widget/core/textform/textform.dart';

@RoutePage()
class IdentityFormPage extends StatelessWidget {
  const IdentityFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<CompleteProfileBloc>(),
      child: const IdentityFormView(),
    );
  }
}

class IdentityFormView extends StatefulWidget {
  const IdentityFormView({super.key});

  @override
  State<IdentityFormView> createState() => _IdentityFormViewState();
}

class _IdentityFormViewState extends State<IdentityFormView> {
  final _formKey = GlobalKey<FormState>();

  final _idCardController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jobController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  String? _selectedGender;
  PlatformFile? _ktpPhoto;

  @override
  void dispose() {
    _idCardController.dispose();
    _phoneController.dispose();
    _jobController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickKtpPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      setState(() {
        _ktpPhoto = result.files.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CompleteProfileBloc, CompleteProfileState>(
      listener: (context, state) {
        if (state is CompleteProfileSuccess) {
          AppSnackbar.showSuccess('Biodata berhasil disimpan');
          context.router.pop();
        }

        if (state is CompleteProfileFailure) {
          AppSnackbar.showError(state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is CompleteProfileLoading;

        return Scaffold(
          appBar: CustomAppbar(
            icon: const Icon(Icons.arrow_back),
            title: 'Kembali',
          ),

          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),

            child: SingleChildScrollView(
              child: BasicCard(
                title: 'Form Biodata Penghuni',

                child: Form(
                  key: _formKey,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Upload Foto KTP',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _ktpPhoto?.name ?? 'Belum ada file dipilih',
                            ),
                          ),

                          ElevatedButton(
                            onPressed: _pickKtpPhoto,
                            child: const Text('Upload'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      CustomTextForm(
                        title: 'Nomor KTP',
                        hintText: 'Masukkan nomor KTP',
                        controller: _idCardController,
                        isRequired: true,

                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Nomor KTP wajib diisi';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      CustomTextForm(
                        title: 'Nomor Telepon',
                        hintText: 'Masukkan nomor telepon',
                        controller: _phoneController,
                        isRequired: true,
                        keyboardType: TextInputType.phone,

                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Nomor telepon wajib diisi';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      Text(
                        'Jenis Kelamin',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),

                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: _selectedGender,

                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),

                        hint: const Text('Pilih jenis kelamin'),

                        items: const [
                          DropdownMenuItem(
                            value: 'male',
                            child: Text('Laki-laki'),
                          ),

                          DropdownMenuItem(
                            value: 'female',
                            child: Text('Perempuan'),
                          ),
                        ],

                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },

                        validator: (v) {
                          if (v == null) {
                            return 'Jenis kelamin wajib dipilih';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      CustomTextForm(
                        title: 'Pekerjaan',
                        hintText: 'Masukkan pekerjaan',
                        controller: _jobController,
                      ),

                      const SizedBox(height: 30),

                      CustomTextForm(
                        title: 'Alamat KTP',
                        hintText: 'Masukkan alamat sesuai KTP',
                        controller: _addressController,
                        isRequired: true,
                        maxLines: 3,

                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Alamat wajib diisi';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      CustomTextForm(
                        title: 'Nama Kontak Darurat',
                        hintText: 'Masukkan nama kontak darurat',
                        controller: _emergencyNameController,
                      ),

                      const SizedBox(height: 30),

                      CustomTextForm(
                        title: 'Nomor Kontak Darurat',
                        hintText: 'Masukkan nomor kontak darurat',
                        controller: _emergencyPhoneController,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 40),

                      Align(
                        alignment: Alignment.centerRight,

                        child: SizedBox(
                          width: 220,

                          child: BasicButton(
                            label: 'Simpan Biodata',

                            isLoading: isLoading,

                            onPressed: () {
                              final valid =
                                  _formKey.currentState?.validate() ?? false;

                              if (!valid) {
                                AppSnackbar.showError(
                                  'Lengkapi data terlebih dahulu',
                                );

                                return;
                              }

                              context.read<CompleteProfileBloc>().add(
                                SubmitProfileEvent(
                                  idCardNumber: _idCardController.text.trim(),

                                  phoneNumber: _phoneController.text.trim(),

                                  gender: _selectedGender!,

                                  job: _jobController.text.trim().isEmpty
                                      ? null
                                      : _jobController.text.trim(),

                                  addressKtp: _addressController.text.trim(),

                                  emergencyContactName:
                                      _emergencyNameController.text
                                          .trim()
                                          .isEmpty
                                      ? null
                                      : _emergencyNameController.text.trim(),

                                  emergencyContactPhone:
                                      _emergencyPhoneController.text
                                          .trim()
                                          .isEmpty
                                      ? null
                                      : _emergencyPhoneController.text.trim(),

                                  ktpPhoto: _ktpPhoto,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
