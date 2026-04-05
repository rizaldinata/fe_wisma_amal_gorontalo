import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/presentation/bloc/maintenance_action/maintenance_action_bloc.dart';
import 'package:frontend/presentation/bloc/maintenance_action/maintenance_action_event.dart';
import 'package:frontend/presentation/bloc/maintenance_action/maintenance_action_state.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';
import 'package:frontend/presentation/widget/core/textform/textform.dart';

@RoutePage()
class MaintenanceCreateReportPage extends StatelessWidget {
  const MaintenanceCreateReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<MaintenanceActionBloc>(),
      child: const _CreateReportView(),
    );
  }
}

class _CreateReportView extends StatefulWidget {
  const _CreateReportView();

  @override
  State<_CreateReportView> createState() => _CreateReportViewState();
}

class _CreateReportViewState extends State<_CreateReportView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  List<PlatformFile> _selectedImages = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true, // Load bytes for all platforms
    );
    if (result != null) {
      setState(() {
        // Prevent duplicates by checking name
        final newFiles = result.files;
        final currentNames = _selectedImages.map((f) => f.name).toSet();
        
        for (var file in newFiles) {
          if (!currentNames.contains(file.name)) {
            _selectedImages.add(file);
          }
        }
        
        if (_selectedImages.length > 6) {
          _selectedImages = _selectedImages.sublist(0, 6);
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  void _handleSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<MaintenanceActionBloc>().add(
      SubmitMaintenanceRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        images: _selectedImages.isEmpty ? null : _selectedImages,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<MaintenanceActionBloc, MaintenanceActionState>(
      listener: (context, state) {
        if (state is MaintenanceActionSuccess) {
          AppSnackbar.showSuccess(state.message);
          context.router.maybePop();
        } else if (state is MaintenanceActionFailure) {
          AppSnackbar.showError(state.message);
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.router.maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buat Laporan Kerusakan',
                        style: theme.textTheme.headlineLarge,
                      ),
                      Text(
                        'Laporkan kerusakan yang Anda temukan',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Form ──
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info card
                        BasicCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionTitle(
                                icon: Icons.info_outline_rounded,
                                label: 'Informasi Kerusakan',
                              ),
                              const SizedBox(height: 20),

                              // Title
                              CustomTextForm(
                                title: 'Judul Kerusakan',
                                hintText: 'contoh: AC kamar tidak berfungsi',
                                isRequired: true,
                                controller: _titleController,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Judul wajib diisi';
                                  }
                                  if (v.trim().length < 5) {
                                    return 'Judul minimal 5 karakter';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Location (optional)
                              CustomTextForm(
                                title: 'Lokasi Kerusakan',
                                hintText:
                                    'contoh: Kamar 301, Lorong Lt. 2, Kamar Mandi Umum',
                                controller: _locationController,
                              ),
                              const SizedBox(height: 16),

                              // Description
                              CustomTextForm(
                                title: 'Deskripsi Kerusakan',
                                hintText:
                                    'Jelaskan kerusakan secara detail agar lebih mudah ditangani...',
                                isRequired: true,
                                controller: _descriptionController,
                                maxLines: 5,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Deskripsi wajib diisi';
                                  }
                                  if (v.trim().length < 10) {
                                    return 'Deskripsi minimal 10 karakter';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Photo card
                        BasicCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _SectionTitle(
                                    icon: Icons.photo_library_outlined,
                                    label: 'Foto Bukti Kerusakan',
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${_selectedImages.length}/6',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                      color: _selectedImages.length >= 6
                                          ? theme.colorScheme.error
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tambahkan foto untuk memperjelas kondisi kerusakan (opsional, maks. 6 foto)',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Image grid
                              if (_selectedImages.isNotEmpty)
                                _ImageGrid(
                                  images: _selectedImages,
                                  onRemove: _removeImage,
                                ),

                              if (_selectedImages.length < 6)
                                _AddPhotoButton(onTap: _pickImages),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Note card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.25),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                size: 16,
                                color: Colors.blue.shade600,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Laporan akan segera diproses oleh tim pengelola. Periksa status laporan Anda secara berkala.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.blue.shade700,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Action buttons
                        BlocBuilder<MaintenanceActionBloc,
                            MaintenanceActionState>(
                          builder: (context, state) {
                            final isLoading =
                                state is MaintenanceActionSubmitting;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 140,
                                  height: 44,
                                  child: BasicButton(
                                    type: ButtonType.secondary,
                                    label: 'Batal',
                                    onPressed: isLoading
                                        ? null
                                        : () => context.router.maybePop(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 160,
                                  height: 44,
                                  child: BasicButton(
                                    label: 'Kirim Laporan',
                                    isLoading: isLoading,
                                    onPressed: isLoading
                                        ? null
                                        : () => _handleSubmit(context),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable Section Title widget
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ImageGrid extends StatelessWidget {
  const _ImageGrid({required this.images, required this.onRemove});
  final List<PlatformFile> images;
  final void Function(int) onRemove;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(images.length, (index) {
        return _ImageThumbnail(
          file: images[index],
          onRemove: () => onRemove(index),
        );
      }),
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  const _ImageThumbnail({required this.file, required this.onRemove});
  final PlatformFile file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: file.bytes != null
              ? Image.memory(
                  file.bytes!,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                )
              : Image.network(
                  // Fallback (though bytes should be here)
                  '',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_outlined, color: Colors.grey),
                  ),
                ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddPhotoButton extends StatelessWidget {
  const _AddPhotoButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.4),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(10),
          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Tambah Foto',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
