import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/domain/entity/schedule_entity.dart';
import 'package:frontend/domain/entity/schedule_update_entity.dart';
import 'package:frontend/presentation/bloc/schedule/schedule_action_bloc.dart';
import 'package:frontend/presentation/bloc/schedule/schedule_action_event.dart';
import 'package:frontend/presentation/bloc/schedule/schedule_action_state.dart';
import 'package:frontend/presentation/bloc/schedule_detail/schedule_detail_bloc.dart';
import 'package:frontend/presentation/bloc/schedule_detail/schedule_detail_event.dart';
import 'package:frontend/presentation/bloc/schedule_detail/schedule_detail_state.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';
import 'package:frontend/presentation/widget/core/textform/textform.dart';
import 'package:intl/intl.dart';

@RoutePage()
class MaintananceDetailPage extends StatelessWidget {
  const MaintananceDetailPage({super.key, required this.schedule});

  final ScheduleEntity schedule;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => serviceLocator<ScheduleDetailBloc>()
            ..add(FetchScheduleDetail(schedule.id!)),
        ),
        BlocProvider(
          create: (context) => serviceLocator<ScheduleActionBloc>(),
        ),
      ],
      child: const _MaintananceDetailView(),
    );
  }
}

class _MaintananceDetailView extends StatelessWidget {
  const _MaintananceDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScheduleActionBloc, ScheduleActionState>(
      listener: (context, state) {
        if (state is ScheduleActionSuccess) {
          AppSnackbar.showSuccess(state.message);
          final bloc = context.read<ScheduleDetailBloc>();
          if (bloc.state is ScheduleDetailLoaded) {
            final scheduleId = (bloc.state as ScheduleDetailLoaded).schedule.id;
            bloc.add(FetchScheduleDetail(scheduleId!));
          }
        } else if (state is ScheduleActionFailure) {
          AppSnackbar.showError(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          title: const Text(
            'Detail Pemeliharaan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: BlocBuilder<ScheduleDetailBloc, ScheduleDetailState>(
          builder: (context, state) {
            if (state is ScheduleDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ScheduleDetailLoaded) {
              return _ScrollableDetailContent(schedule: state.schedule);
            } else if (state is ScheduleDetailError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _ScrollableDetailContent extends StatelessWidget {
  const _ScrollableDetailContent({required this.schedule});
  final ScheduleEntity schedule;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderCard(schedule: schedule),
          const SizedBox(height: 24),
          _DetailsGrid(schedule: schedule),
          if (schedule.notes != null && schedule.notes!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _NotesCard(notes: schedule.notes!),
          ],
          const SizedBox(height: 32),
          _TimelineHeader(scheduleId: schedule.id!),
          const SizedBox(height: 16),
          _ModernTimeline(updates: schedule.updates),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.schedule});
  final ScheduleEntity schedule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              schedule.type == 'pembersihan'
                  ? Icons.clean_hands_rounded
                  : Icons.build_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.technicianName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  schedule.location,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          _StatusBadge(status: schedule.status, isDark: true),
        ],
      ),
    );
  }
}

class _DetailsGrid extends StatelessWidget {
  const _DetailsGrid({required this.schedule});
  final ScheduleEntity schedule;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEEE, dd MMM yyyy', 'id_ID');
    final tf = DateFormat('HH:mm');

    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.2,
      children: [
        _InfoItem(
          icon: Icons.category_rounded,
          label: 'Misi',
          value: schedule.type == 'pembersihan' ? 'Pembersihan' : 'Perawatan',
        ),
        _InfoItem(
          icon: Icons.settings_suggest_rounded,
          label: 'Kategori',
          value: schedule.subtype.toUpperCase(),
        ),
        _InfoItem(
          icon: Icons.event_rounded,
          label: 'Tanggal',
          value: df.format(schedule.startTime),
        ),
        _InfoItem(
          icon: Icons.schedule_rounded,
          label: 'Waktu',
          value:
              '${tf.format(schedule.startTime)} - ${schedule.endTime != null ? tf.format(schedule.endTime!) : "Selesai"}',
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes});
  final String notes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primaryContainer,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes_rounded,
                  size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Catatan Penugasan',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            notes,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _TimelineHeader extends StatelessWidget {
  const _TimelineHeader({required this.scheduleId});
  final int scheduleId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Rekam Jejak Progres',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: () => _showUpdateDialog(context),
          icon: const Icon(Icons.add_task_rounded, size: 18),
          label: const Text('Input Progress'),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ScheduleActionBloc>(),
        child: _UpdateFormDialog(scheduleId: scheduleId),
      ),
    );
  }
}

class _ModernTimeline extends StatelessWidget {
  const _ModernTimeline({required this.updates});
  final List<ScheduleUpdateEntity> updates;

  @override
  Widget build(BuildContext context) {
    if (updates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.history_rounded, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              const Text('Belum ada histori progres.'),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: updates.length,
      itemBuilder: (context, index) {
        return _ModernTimelineItem(
          update: updates[index],
          isFirst: index == 0,
          isLast: index == updates.length - 1,
        );
      },
    );
  }
}

class _ModernTimelineItem extends StatelessWidget {
  const _ModernTimelineItem({
    required this.update,
    required this.isFirst,
    required this.isLast,
  });
  final ScheduleUpdateEntity update;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isFirst
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 4,
                    ),
                    boxShadow: [
                      if (isFirst)
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                    ],
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
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        update.userName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (update.status != null)
                        _StatusBadge(status: update.status!, isSmall: true),
                      const Spacer(),
                      Text(
                        df.format(update.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.only(
                        topRight: const Radius.circular(16),
                        bottomLeft: const Radius.circular(16),
                        bottomRight: const Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      update.notes,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    this.isDark = false,
    this.isSmall = false,
  });
  final String status;
  final bool isDark;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'done':
        color = Colors.green;
        label = 'SELESAI';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'BATAL';
        break;
      default:
        color = Colors.orange;
        label = 'PROSES';
    }

    if (isDark) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white30),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 2 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: isSmall ? 10 : 12,
        ),
      ),
    );
  }
}

class _UpdateFormDialog extends StatefulWidget {
  const _UpdateFormDialog({required this.scheduleId});
  final int scheduleId;

  @override
  State<_UpdateFormDialog> createState() => _UpdateFormDialogState();
}

class _UpdateFormDialogState extends State<_UpdateFormDialog> {
  final _notesController = TextEditingController();
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Update Progres Kerja'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextForm(
              title: 'Laporan Progres',
              hintText: 'Apa yang sudah dikerjakan?',
              controller: _notesController,
              maxLines: 4,
              isRequired: true,
            ),
            const SizedBox(height: 24),
            Text(
              'Perbarui Status (Jika ada)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedStatus,
                  hint: const Text('Pilih status baru'),
                  items: const [
                    DropdownMenuItem(
                      value: 'in_progress',
                      child: Text('Masih Proses'),
                    ),
                    DropdownMenuItem(value: 'done', child: Text('Sudah Selesai')),
                    DropdownMenuItem(
                      value: 'cancelled',
                      child: Text('Dibatalkan'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedStatus = v),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
        BlocConsumer<ScheduleActionBloc, ScheduleActionState>(
          listener: (context, state) {
            if (state is ScheduleActionSuccess) {
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            final isLoading = state is ScheduleActionSubmitting;
            return FilledButton(
              onPressed: isLoading ? null : _submit,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Simpan Update'),
            );
          },
        ),
      ],
    );
  }

  void _submit() {
    if (_notesController.text.trim().isEmpty) {
      AppSnackbar.showError('Laporan wajib diisi');
      return;
    }

    context.read<ScheduleActionBloc>().add(SubmitScheduleUpdate(
          scheduleId: widget.scheduleId,
          notes: _notesController.text.trim(),
          status: _selectedStatus,
        ));
  }
}
