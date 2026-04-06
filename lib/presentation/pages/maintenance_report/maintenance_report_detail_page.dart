import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/services/network/api_config.dart';
import 'package:frontend/domain/entity/maintenance_request_entity.dart';
import 'package:frontend/domain/entity/maintenance_status.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/maintenance_action/maintenance_action_bloc.dart';
import 'package:frontend/presentation/bloc/maintenance_action/maintenance_action_event.dart';
import 'package:frontend/presentation/bloc/maintenance_action/maintenance_action_state.dart';
import 'package:frontend/presentation/bloc/maintenance_detail/maintenance_detail_bloc.dart';
import 'package:frontend/presentation/bloc/maintenance_detail/maintenance_detail_event.dart';
import 'package:frontend/presentation/bloc/maintenance_detail/maintenance_detail_state.dart';
import 'package:frontend/presentation/pages/maintenance_report/widgets/maintenance_status_badge.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';
import 'package:frontend/presentation/widget/core/textform/textform.dart';
import 'package:intl/intl.dart';

@RoutePage()
class MaintenanceReportDetailPage extends StatelessWidget {
  const MaintenanceReportDetailPage({super.key, @pathParam required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              serviceLocator<MaintenanceDetailBloc>()
                ..add(FetchMaintenanceDetail(id)),
        ),
        BlocProvider(create: (_) => serviceLocator<MaintenanceActionBloc>()),
      ],
      child: const _DetailView(),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<MaintenanceActionBloc, MaintenanceActionState>(
      listener: (context, state) {
        if (state is MaintenanceActionSuccess) {
          AppSnackbar.showSuccess(state.message);
          // Reload detail after successful update
          final detailBloc = context.read<MaintenanceDetailBloc>();
          final detailState = detailBloc.state;
          if (detailState is MaintenanceDetailLoaded) {
            detailBloc.add(FetchMaintenanceDetail(detailState.request.id));
          }
        } else if (state is MaintenanceActionFailure) {
          AppSnackbar.showError(state.message);
        }
      },
      child: Scaffold(
        body: BlocBuilder<MaintenanceDetailBloc, MaintenanceDetailState>(
          builder: (context, state) {
            if (state is MaintenanceDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MaintenanceDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 56,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat detail',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (state is MaintenanceDetailLoaded) {
              return _DetailContent(request: state.request);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.request});

  final MaintenanceRequestEntity request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');
    final authState = context.watch<AuthBloc>().state;
    final isAdmin =
        authState.isLoggedIn &&
        (authState.userInfo?.roles.any(
              (r) => r == 'admin' || r == 'super-admin',
            ) ??
            false);

    return Padding(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Laporan',
                      style: theme.textTheme.headlineLarge,
                    ),
                    Text(
                      'ID #${request.id}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              MaintenanceStatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Report Info Card ──
                  BasicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(
                          icon: Icons.report_problem_outlined,
                          label: 'Informasi Laporan',
                        ),
                        const SizedBox(height: 20),

                        // Title
                        Text(
                          request.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Meta info row
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            _MetaChip(
                              icon: Icons.person_outline_rounded,
                              label: request.residentName,
                            ),
                            if (request.room != null)
                              _MetaChip(
                                icon: Icons.meeting_room_outlined,
                                label: 'Kamar ${request.room!.number}',
                              ),
                            _MetaChip(
                              icon: Icons.calendar_today_outlined,
                              label: request.reportedAt != null
                                  ? dateFormat.format(request.reportedAt!)
                                  : dateFormat.format(request.createdAt),
                            ),
                          ],
                        ),
                        const Divider(height: 28),

                        // Description
                        Text(
                          'Deskripsi',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          request.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                        ),

                        // Photos
                        if (request.images.isNotEmpty) ...[
                          const Divider(height: 28),
                          Text(
                            'Foto Kerusakan (${request.images.length})',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _NetworkImageGrid(
                            imageUrls: request.images
                                .map((e) => ApiConfig.getStorageUrl(e))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Timeline Card ──
                  BasicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(
                          icon: Icons.timeline_rounded,
                          label: 'Riwayat Penanganan',
                        ),
                        const SizedBox(height: 20),

                        if (request.timeline.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Column(
                                children: [
                                  Opacity(
                                    opacity: 0.35,
                                    child: const Icon(
                                      Icons.pending_actions_outlined,
                                      size: 48,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Belum ada update dari tim pengelola',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          _Timeline(items: request.timeline),
                      ],
                    ),
                  ),

                  // ── Admin Reply Form ──
                  if (isAdmin) ...[
                    const SizedBox(height: 16),
                    BasicCard(child: _AdminReplyForm(requestId: request.id)),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.items});
  final List<MaintenanceTimelineEntity> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        final isLast = index == items.length - 1;

        final dotColor = item.status != null
            ? _statusColor(item.status!)
            : theme.colorScheme.primary;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line + dot
              Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: dotColor.withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status badge + name
                      Row(
                        children: [
                          if (item.status != null) ...[
                            MaintenanceStatusBadge(status: item.status!),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            item.userName,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            dateFormat.format(item.createdAt),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withOpacity(
                              0.5,
                            ),
                          ),
                        ),
                        child: Text(
                          item.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),

                      // Images
                      if (item.images.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _NetworkImageGrid(
                          imageUrls: item.images
                              .map((e) => ApiConfig.getStorageUrl(e))
                              .toList(),
                          maxWidth: 80,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Color _statusColor(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.pending:
        return const Color(0xFFF59E0B);
      case MaintenanceStatus.inProgress:
        return const Color(0xFF3B82F6);
      case MaintenanceStatus.completed:
        return const Color(0xFF10B981);
      case MaintenanceStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }
}

class _AdminReplyForm extends StatefulWidget {
  const _AdminReplyForm({required this.requestId});
  final int requestId;

  @override
  State<_AdminReplyForm> createState() => _AdminReplyFormState();
}

class _AdminReplyFormState extends State<_AdminReplyForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String? _selectedStatus;
  List<PlatformFile> _selectedImages = [];

  final _statusOptions = ['pending', 'in_progress', 'completed', 'cancelled'];

  final _statusLabels = {
    'pending': 'Menunggu',
    'in_progress': 'Dalam Proses',
    'completed': 'Selesai',
    'cancelled': 'Dibatalkan',
  };

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result != null) {
      setState(() {
        final newFiles = result.files;
        final currentNames = _selectedImages.map((f) => f.name).toSet();

        for (var file in newFiles) {
          if (!currentNames.contains(file.name)) {
            _selectedImages.add(file);
          }
        }

        if (_selectedImages.length > 4) {
          _selectedImages = _selectedImages.sublist(0, 4);
        }
      });
    }
  }

  void _handleSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<MaintenanceActionBloc>().add(
      SubmitMaintenanceUpdate(
        requestId: widget.requestId,
        description: _descriptionController.text.trim(),
        status: _selectedStatus,
        images: _selectedImages.isEmpty ? null : _selectedImages,
      ),
    );

    // Reset form after submit
    _descriptionController.clear();
    setState(() {
      _selectedStatus = null;
      _selectedImages = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.add_comment_outlined,
            label: 'Tambah Update Progres',
          ),
          const SizedBox(height: 16),

          // Status Selector (optional)
          Text('Perbarui Status (opsional)', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _statusOptions.map((s) {
              final label = _statusLabels[s] ?? s;
              final isSelected = _selectedStatus == s;
              return ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (v) =>
                    setState(() => _selectedStatus = v ? s : null),
                showCheckmark: false,
                selectedColor: _statusChipColor(s).withOpacity(0.15),
                labelStyle: TextStyle(
                  color: isSelected
                      ? _statusChipColor(s)
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected
                      ? _statusChipColor(s)
                      : theme.colorScheme.outlineVariant,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Description
          CustomTextForm(
            title: 'Catatan Update',
            hintText:
                'contoh: Tukang sedang dalam perjalanan, estimasi sampai jam 2 siang.',
            isRequired: true,
            controller: _descriptionController,
            maxLines: 4,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Catatan wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Photo
          if (_selectedImages.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_selectedImages.length, (i) {
                final file = _selectedImages[i];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: file.bytes != null
                          ? Image.memory(
                              file.bytes!,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_outlined),
                            ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedImages.removeAt(i)),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          if (_selectedImages.length < 4)
            TextButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.attach_file_rounded, size: 16),
              label: const Text('Lampirkan Foto'),
            ),
          const SizedBox(height: 20),

          // Submit
          BlocBuilder<MaintenanceActionBloc, MaintenanceActionState>(
            builder: (context, state) {
              final isLoading = state is MaintenanceActionSubmitting;
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 180,
                    height: 44,
                    child: BasicButton(
                      label: 'Kirim Update',
                      isLoading: isLoading,
                      leadIcon: isLoading
                          ? const SizedBox.shrink()
                          : const Icon(
                              Icons.send_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                      onPressed: isLoading
                          ? null
                          : () => _handleSubmit(context),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Color _statusChipColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'in_progress':
        return const Color(0xFF3B82F6);
      case 'completed':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }
}

// ── Shared Widgets ──

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _NetworkImageGrid extends StatelessWidget {
  const _NetworkImageGrid({required this.imageUrls, this.maxWidth = 100});
  final List<String> imageUrls;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: imageUrls.map((url) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            width: maxWidth,
            height: maxWidth,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: maxWidth,
              height: maxWidth,
              color: Colors.grey.shade200,
              child: const Icon(
                Icons.broken_image_outlined,
                color: Colors.grey,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
