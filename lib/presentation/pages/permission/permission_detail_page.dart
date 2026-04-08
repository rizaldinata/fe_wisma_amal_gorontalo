import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/presentation/bloc/permission/permission_bloc.dart';
import 'package:frontend/presentation/bloc/permission/permission_event.dart';
import 'package:frontend/presentation/bloc/permission/permission_state.dart';
import 'package:frontend/presentation/widget/core/appbar/custom_appbar.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/chip/custom_chip.dart';
import 'package:frontend/domain/entity/permission_entity.dart';

@RoutePage()
class PermissionDetailPage extends StatelessWidget {
  final int id;

  const PermissionDetailPage({super.key, @PathParam('id') required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          serviceLocator<PermissionBloc>()..add(GetPermissionsEvent()),
      child: Scaffold(
        appBar: CustomAppbar(
          icon: const Icon(Icons.arrow_back),
          title: 'Detail Izin',
          onPressed: () => context.router.back(),
        ),
        body: BlocBuilder<PermissionBloc, PermissionState>(
          builder: (context, state) {
            // Menampilkan loading saat data sedang dimuat
            if (state.status == FormzSubmissionStatus.inProgress) {
              return const Center(child: CircularProgressIndicator());
            }

            // Mencari data permission secara aman (nullable)
            final PermissionEntity? permission = state.permissions
                .cast<PermissionEntity?>()
                .firstWhere((p) => p?.id == id, orElse: () => null);

            // Jika data tidak ditemukan, tampilkan pesan error yang informatif
            if (permission == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Data izin dengan ID $id tidak ditemukan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 200,
                      child: BasicButton(
                        onPressed: () => context.router.back(),
                        label: 'Kembali',
                        type: ButtonType.secondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Tampilkan UI Detail jika data ditemukan
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: BasicCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            permission.name,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        CustomChip(
                          label: permission.target ?? 'Semua',
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),

                    _buildDetailItem(
                      context,
                      'Target Modul',
                      permission.target ?? '-',
                    ),
                    const SizedBox(height: 24),
                    _buildDetailItem(
                      context,
                      'Deskripsi Izin',
                      permission.description ??
                          'Tidak ada deskripsi untuk izin ini.',
                    ),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: BasicButton(
                        onPressed: () => context.router.back(),
                        label: 'Kembali',
                        type: ButtonType.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
