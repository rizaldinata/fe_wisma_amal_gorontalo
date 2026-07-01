import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/services/network/api_config.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/domain/entity/maintenance_request_entity.dart';
import 'package:frontend/domain/entity/maintenance_status.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/maintenance_action/maintenance_action_bloc.dart';
import 'package:frontend/presentation/bloc/maintenance_action/maintenance_action_event.dart';
import 'package:frontend/presentation/bloc/maintenance_action/maintenance_action_state.dart';
import 'package:frontend/presentation/bloc/maintenance_detail/maintenance_detail_bloc.dart';
import 'package:frontend/presentation/bloc/maintenance_detail/maintenance_detail_event.dart';
import 'package:frontend/presentation/bloc/maintenance_detail/maintenance_detail_state.dart';
import 'package:frontend/presentation/widget/core/appbar/app_topbar.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/chip/status_badge.dart';
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
        BlocProvider.value(
          value: serviceLocator<MaintenanceDetailBloc>()
            ..add(FetchMaintenanceDetail(id)),
        ),
        BlocProvider.value(value: serviceLocator<MaintenanceActionBloc>()),
      ],
      child: const _DetailView(),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView();

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return BlocListener<MaintenanceActionBloc, MaintenanceActionState>(
      listener: (context, state) {
        if (state is MaintenanceActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: isDark
                        ? AppColorsDark.statusDone
                        : AppColorsLight.statusDone,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              backgroundColor: isDark
                  ? AppColorsDark.statusDoneBg
                  : AppColorsLight.statusDoneBg,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            ),
          );
          final detailBloc = context.read<MaintenanceDetailBloc>();
          final detailState = detailBloc.state;
          if (detailState is MaintenanceDetailLoaded) {
            detailBloc.add(FetchMaintenanceDetail(detailState.request.id));
          }
        } else if (state is MaintenanceActionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.error,
                    color: isDark
                        ? AppColorsDark.statusCancelled
                        : AppColorsLight.statusCancelled,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              backgroundColor: isDark
                  ? AppColorsDark.statusCancelledBg
                  : AppColorsLight.statusCancelledBg,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColorsDark.background : AppColorsLight.background,
        body: Column(
        children: [
          BlocBuilder<MaintenanceDetailBloc, MaintenanceDetailState>(
            builder: (context, state) {
              String title = 'Detail Laporan';
              Widget? action;
              if (state is MaintenanceDetailLoaded) {
                title =
                    'Laporan #${state.request.id.toString().length > 8 ? state.request.id.toString().substring(0, 8).toUpperCase() : state.request.id.toString().toUpperCase()}';
                action = StatusBadge(
                  status: _statusLabel(state.request.status),
                );
              }

              return AppTopBar(
                title: title,
                breadcrumb: 'Operasional / Laporan Kerusakan / Detail',
                action: action,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 20),
                  onPressed: () => context.router.maybePop(),
                  tooltip: 'Kembali',
                ),
              );
            },
          ),
          Expanded(
            child: BlocBuilder<MaintenanceDetailBloc, MaintenanceDetailState>(
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
                          color: isDark
                              ? AppColorsDark.statusCancelled
                              : AppColorsLight.statusCancelled,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Gagal memuat detail',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(state.message, textAlign: TextAlign.center),
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
        ],
      ),
      ),
    );
  }

  String _statusLabel(dynamic status) {
    switch (status.value) {
      case 'pending':
        return 'Menunggu';
      case 'in_progress':
        return 'Dalam Proses';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Semua';
    }
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.request});

  final MaintenanceRequestEntity request;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isAdmin =
        authState.isLoggedIn &&
        (authState.userInfo?.roles.any(
              (r) => r == 'admin' || r == 'super-admin',
            ) ??
            false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xxxl),
                  child: _buildInfoCard(context),
                ),
              ),
              Container(
                width: 1,
                color: AppTheme.isDark(context)
                    ? AppColorsDark.borderLight
                    : AppColorsLight.borderLight,
              ),
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xxxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTimelineCard(context),
                      if (isAdmin) ...[
                        const SizedBox(height: AppSpacing.xxxl),
                        _AdminReplyForm(requestId: request.id.toString()),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(context),
                const SizedBox(height: AppSpacing.xxxl),
                _buildTimelineCard(context),
                if (isAdmin) ...[
                  const SizedBox(height: AppSpacing.xxxl),
                  _AdminReplyForm(requestId: request.id.toString()),
                ],
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final surfaceColor = isDark
        ? AppColorsDark.surface
        : AppColorsLight.surface;
    final borderColor = isDark
        ? AppColorsDark.borderLight
        : AppColorsLight.borderLight;
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColorsDark.primary
                      : AppColorsLight.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Text(
                'Informasi Laporan',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            request.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.xl,
            runSpacing: AppSpacing.md,
            children: [
              _MetaItem(
                icon: Icons.person_outline,
                label: request.residentName,
              ),
              if (request.room != null)
                _MetaItem(
                  icon: Icons.meeting_room_outlined,
                  label: 'Kamar ${request.room!.number}',
                ),
              if (request.location != null && request.location!.isNotEmpty)
                _MetaItem(
                  icon: Icons.location_on_outlined,
                  label: request.location!,
                ),
              _MetaItem(
                icon: Icons.calendar_today_outlined,
                label: dateFormat.format(
                  request.reportedAt ?? request.createdAt,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Divider(color: borderColor),
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'Deskripsi Kerusakan',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            request.description,
            style: TextStyle(
              height: 1.6,
              color: isDark
                  ? AppColorsDark.textSecondary
                  : AppColorsLight.textSecondary,
            ),
          ),
          if (request.images.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxxl),
            const Text(
              'Foto Lampiran',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: request.images
                  .map(
                    (img) => _buildImageThumbnail(
                      context,
                      ApiConfig.getStorageUrl(img),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(BuildContext context, String url) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(AppSpacing.xl),
            child: Stack(
              alignment: Alignment.center,
              children: [
                InteractiveViewer(
                  child: Image.network(url, fit: BoxFit.contain),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Image.network(
          url,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 120,
            height: 120,
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final surfaceColor = isDark
        ? AppColorsDark.surface
        : AppColorsLight.surface;
    final borderColor = isDark
        ? AppColorsDark.borderLight
        : AppColorsLight.borderLight;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColorsDark.primary
                      : AppColorsLight.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Text(
                'Riwayat Penanganan',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxxl),
          if (request.timeline.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.pending_actions_outlined,
                    size: 48,
                    color: isDark
                        ? AppColorsDark.textSecondary
                        : AppColorsLight.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Belum ada update progres',
                    style: TextStyle(
                      color: isDark
                          ? AppColorsDark.textSecondary
                          : AppColorsLight.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            _MaintenanceTimeline(items: request.timeline),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final color = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MaintenanceTimeline extends StatelessWidget {
  const _MaintenanceTimeline({required this.items});
  final List<MaintenanceTimelineEntity> items;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        final isLast = index == items.length - 1;
        final dotColor = _statusColor(item.status, isDark);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
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
                        color: isDark
                            ? AppColorsDark.borderLight
                            : AppColorsLight.borderLight,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: isLast ? 0 : AppSpacing.xxxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                item.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              if (item.status != null) ...[
                                const SizedBox(width: AppSpacing.md),
                                StatusBadge(status: _statusLabel(item.status!)),
                              ],
                            ],
                          ),
                          Text(
                            dateFormat.format(item.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColorsDark.textSecondary
                                  : AppColorsLight.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColorsDark.surfaceVariant
                              : AppColorsLight.surfaceVariant,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                        ),
                        child: Text(
                          item.description,
                          style: TextStyle(
                            height: 1.5,
                            color: isDark
                                ? AppColorsDark.textPrimary
                                : AppColorsLight.textPrimary,
                          ),
                        ),
                      ),
                      if (item.images.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: item.images
                              .map(
                                (img) => ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusSm,
                                  ),
                                  child: Image.network(
                                    ApiConfig.getStorageUrl(img),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                              .toList(),
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

  Color _statusColor(MaintenanceStatus? status, bool isDark) {
    if (status == null)
      return isDark ? AppColorsDark.primary : AppColorsLight.primary;
    switch (status) {
      case MaintenanceStatus.pending:
        return isDark
            ? AppColorsDark.statusWaiting
            : AppColorsLight.statusWaiting;
      case MaintenanceStatus.inProgress:
        return isDark
            ? AppColorsDark.statusProcess
            : AppColorsLight.statusProcess;
      case MaintenanceStatus.completed:
        return isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone;
      case MaintenanceStatus.cancelled:
        return isDark
            ? AppColorsDark.statusCancelled
            : AppColorsLight.statusCancelled;
    }
  }

  String _statusLabel(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.pending:
        return 'Menunggu';
      case MaintenanceStatus.inProgress:
        return 'Dalam Proses';
      case MaintenanceStatus.completed:
        return 'Selesai';
      case MaintenanceStatus.cancelled:
        return 'Dibatalkan';
    }
  }
}

class _AdminReplyForm extends StatefulWidget {
  const _AdminReplyForm({required this.requestId});
  final String requestId;

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

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result != null) {
      setState(() {
        for (var file in result.files) {
          if (!_selectedImages.any((f) => f.name == file.name)) {
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
        requestId: int.parse(widget.requestId),
        description: _descriptionController.text.trim(),
        status: _selectedStatus,
        images: _selectedImages.isEmpty ? null : _selectedImages,
      ),
    );

    _descriptionController.clear();
    setState(() {
      _selectedStatus = null;
      _selectedImages = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final surfaceColor = isDark
        ? AppColorsDark.surface
        : AppColorsLight.surface;
    final borderColor = isDark
        ? AppColorsDark.borderLight
        : AppColorsLight.borderLight;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: borderColor),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColorsDark.primary
                        : AppColorsLight.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Text(
                  'Tambah Update Progres',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            const Text(
              'Perbarui Status (opsional)',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: _statusOptions.map((s) {
                final isSelected = _selectedStatus == s;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedStatus = isSelected ? null : s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                                ? AppColorsDark.primary
                                : AppColorsLight.primary)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : borderColor,
                      ),
                    ),
                    child: Text(
                      _statusLabels[s]!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                  ? AppColorsDark.textPrimary
                                  : AppColorsLight.textPrimary),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),

            CustomTextForm(
              title: 'Catatan Update',
              hintText: 'Masukkan progres terbaru...',
              isRequired: true,
              controller: _descriptionController,
              maxLines: 4,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: AppSpacing.xl),

            if (_selectedImages.isNotEmpty) ...[
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: List.generate(_selectedImages.length, (i) {
                  final file = _selectedImages[i];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
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
                                child: const Icon(Icons.image),
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
                            decoration: const BoxDecoration(
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
              const SizedBox(height: AppSpacing.md),
            ],

            if (_selectedImages.length < 4)
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.attach_file, size: 16),
                label: const Text('Lampirkan Foto'),
              ),

            const SizedBox(height: AppSpacing.xxxl),

            BlocBuilder<MaintenanceActionBloc, MaintenanceActionState>(
              builder: (context, state) {
                final isLoading = state is MaintenanceActionSubmitting;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => _handleSubmit(context),
                      icon: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send, size: 16),
                      label: Text(isLoading ? 'Mengirim...' : 'Kirim Update'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
