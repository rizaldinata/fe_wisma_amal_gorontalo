import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import 'package:frontend/presentation/bloc/identity_form/identity_form_bloc.dart';
import 'package:frontend/presentation/widget/core/appbar/custom_appbar.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/textform/textform.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

@RoutePage()
class IdentityFormPage extends StatelessWidget {
  const IdentityFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => IdentityFormBloc()..add(const LoadIdentityFormEvent()),
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

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  static const _genderOptions = ['Laki Laki', 'Perempuan', 'Lain lain'];
  static const _statusOptions = [
    'Mahasiswa',
    'Karyawan',
    'Wirausaha',
    'Lainnya',
  ];

  String? _selectedGender;
  String? _selectedStatus;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IdentityFormBloc, IdentityFormState>(
      listener: (context, state) {
        if (state.submitStatus.isSuccess) {
          AppSnackbar.showSuccess('Identitas berhasil disimpan');
          context.router.pop();
        } else if (state.submitStatus.isFailure) {
          AppSnackbar.showError(
            state.errorMessage ?? 'Gagal menyimpan identitas',
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppbar(
            icon: const Icon(Icons.arrow_back),
            title: 'Back',
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: BasicCard(
                title: 'Form Identitas',
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Foto Profil',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: state.profileImageBytes != null
                                ? MemoryImage(state.profileImageBytes!)
                                : null,
                            child: state.profileImageBytes == null
                                ? const Icon(Icons.person_outline)
                                : null,
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              context.read<IdentityFormBloc>().add(
                                PickProfileImageEvent(),
                              );
                            },
                            child: const Text('Upload Foto'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      CustomTextForm(
                        title: 'Nama Lengkap',
                        hintText: 'Masukkan nama lengkap',
                        controller: _nameController,
                        isRequired: true,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      CustomTextForm(
                        title: 'Email',
                        hintText: 'Masukkan email',
                        controller: _emailController,
                        isRequired: true,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      CustomTextForm(
                        title: 'No Telepon',
                        hintText: 'Masukkan nomor telepon',
                        controller: _phoneController,
                        isRequired: true,
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Nomor telepon tidak boleh kosong';
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

                      Row(
                        children: _genderOptions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final option = entry.value;
                          final selected = _selectedGender == option;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedGender = option;
                                });
                              },
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: selected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.horizontal(
                                    left: index == 0
                                        ? const Radius.circular(8)
                                        : Radius.zero,
                                    right: index == _genderOptions.length - 1
                                        ? const Radius.circular(8)
                                        : Radius.zero,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Radio<String>(
                                      value: option,
                                      groupValue: _selectedGender,
                                      onChanged: (v) {
                                        setState(() {
                                          _selectedGender = v;
                                        });
                                      },
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        option,
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 30),

                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        hint: const Text('Pilih status'),
                        items: _statusOptions
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            _selectedStatus = v;
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 40),

                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 200,
                          child: BasicButton(
                            label: 'Simpan Data',
                            isLoading: state.submitStatus.isInProgress,
                            onPressed: () {
                              final valid =
                                  _formKey.currentState?.validate() ?? false;

                              if (!valid) {
                                AppSnackbar.showError(
                                  'Periksa kembali input Anda',
                                );
                                return;
                              }

                              if (_selectedGender == null ||
                                  _selectedStatus == null) {
                                AppSnackbar.showError('Lengkapi semua data');
                                return;
                              }

                              context.read<IdentityFormBloc>().add(
                                SubmitIdentityFormEvent(
                                  name: _nameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  phone: _phoneController.text.trim(),
                                  gender: _selectedGender!,
                                  status: _selectedStatus!,
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
