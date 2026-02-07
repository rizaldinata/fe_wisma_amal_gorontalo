import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/domain/entity/permission_entity.dart';
import 'package:frontend/domain/entity/table/tabel_colum.dart';
import 'package:frontend/presentation/bloc/permission/permission_bloc.dart';
import 'package:frontend/presentation/bloc/permission/permission_event.dart';
import 'package:frontend/presentation/bloc/permission/permission_state.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/dialog/app_dialog.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';
import 'package:frontend/presentation/widget/core/table/table.dart';
import 'package:frontend/presentation/widget/core/textform/textform.dart';

@RoutePage()
class PermissionPage extends StatelessWidget {
  const PermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          serviceLocator<PermissionBloc>()..add(GetPermissionsEvent()),
      child: const PermissionView(),
    );
  }
}

class PermissionView extends StatelessWidget {
  const PermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manajemen Izin (Permission)',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                BasicButton(
                  onPressed: () => _showPermissionForm(context),
                  label: 'Tambah Izin',
                  leadIcon: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            BlocConsumer<PermissionBloc, PermissionState>(
              listener: (context, state) {
                if (state.status.isSuccess && state.successMessage != null) {
                  AppSnackbar.showSuccess(state.successMessage!);
                }
              },
              builder: (context, state) {
                if (state.status.isInProgress) {
                  return const Center(child: CircularProgressIndicator());
                }

                return TableCard(
                  title: 'Daftar Permission Sistem',
                  columns: const [
                    TableColumn(label: 'Nama Izin', flex: 2),
                    TableColumn(label: 'Target', flex: 1),
                    TableColumn(label: 'Deskripsi', flex: 3),
                    TableColumn(
                      label: 'Aksi',
                      flex: 1,
                      align: TextAlign.center,
                    ),
                  ],
                  rows: state.permissions.map((p) {
                    return [
                      p.name,
                      p.target ?? '-',
                      p.description ?? '-',
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.visibility,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              context.router.navigate(
                                PermissionDetailRoute(id: p.id),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () =>
                                _showPermissionForm(context, permission: p),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await AppDialog.show(
                                context,
                                title: 'Hapus Izin',
                                message:
                                    'Apakah Anda yakin ingin menghapus izin "${p.name}"?',
                                type: AppDialogType.danger,
                                confirmLabel: 'Hapus',
                              );

                              if (confirm == true) {
                                context.read<PermissionBloc>().add(
                                  DeletePermissionEvent(p.id),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ];
                  }).toList(),
                  // Note: Karena TableCard Anda saat ini hanya menerima List<String>,
                  // kita perlu sedikit modifikasi atau membungkus tombol aksi.
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionForm(
    BuildContext context, {
    PermissionEntity? permission,
  }) {
    final nameController = TextEditingController(text: permission?.name);
    final targetController = TextEditingController(text: permission?.target);
    final descController = TextEditingController(text: permission?.description);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(permission == null ? 'Tambah Izin' : 'Edit Izin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextForm(
              title: 'Nama Izin',
              hintText: 'misal: manage-users',
              controller: nameController,
            ),
            const SizedBox(height: 16),
            CustomTextForm(
              title: 'Target',
              hintText: 'admin / user',
              controller: targetController,
            ),
            const SizedBox(height: 16),
            CustomTextForm(
              title: 'Deskripsi',
              hintText: 'Penjelasan fungsi izin',
              controller: descController,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          BasicButton(
            onPressed: () {
              final entity = PermissionEntity(
                id: permission?.id ?? 0,
                name: nameController.text,
                target: targetController.text,
                description: descController.text,
              );
              if (permission == null) {
                context.read<PermissionBloc>().add(AddPermissionEvent(entity));
              } else {
                context.read<PermissionBloc>().add(
                  UpdatePermissionEvent(entity),
                );
              }
              Navigator.pop(dialogContext);
            },
            label: 'Simpan',
          ),
        ],
      ),
    );
  }
}
