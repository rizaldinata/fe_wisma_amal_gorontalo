import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/domain/entity/guest/guest_entity.dart';
import 'package:frontend/presentation/bloc/guest/my_guest_bloc.dart';
import 'package:frontend/presentation/widget/core/dialog/app_dialog.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

@RoutePage()
class MyGuestPage extends StatelessWidget {
  const MyGuestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<MyGuestBloc>()..add(FetchMyGuests()),
      child: const _MyGuestView(),
    );
  }
}

class _MyGuestView extends StatelessWidget {
  const _MyGuestView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<MyGuestBloc, MyGuestState>(
      listener: (context, state) {
        if (state is MyGuestActionSuccess) {
          AppSnackbar.showSuccess(state.message);
        } else if (state is MyGuestActionError) {
          AppSnackbar.showError(state.message);
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tamu Saya',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Daftar tamu yang menginap di kamar Anda',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddGuestDialog(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Tambah Tamu'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<MyGuestBloc, MyGuestState>(
                  builder: (context, state) {
                    if (state is MyGuestLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is MyGuestError) {
                      return _ErrorView(
                        message: state.message,
                        onRetry: () =>
                            context.read<MyGuestBloc>().add(FetchMyGuests()),
                      );
                    }
                    if (state is MyGuestLoaded) {
                      if (state.guests.isEmpty) {
                        return _EmptyView(
                          onAdd: () => _showAddGuestDialog(context),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async =>
                            context.read<MyGuestBloc>().add(FetchMyGuests()),
                        child: ListView.separated(
                          itemCount: state.guests.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _GuestCard(
                              item: state.guests[index],
                              onDelete: () => _confirmDelete(
                                  context, state.guests[index]),
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, MyGuestItem item) async {
    final confirmed = await AppDialog.show(
      context,
      title: 'Hapus Tamu',
      message:
          'Apakah Anda yakin ingin menghapus data tamu "${item.name}"? Tindakan ini tidak dapat dibatalkan.',
      confirmLabel: 'Hapus',
      cancelLabel: 'Batal',
      type: AppDialogType.danger,
    );
    if (confirmed == true && context.mounted) {
      context.read<MyGuestBloc>().add(DeleteMyGuest(item.id));
    }
  }

  void _showAddGuestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<MyGuestBloc>(),
        child: const _AddGuestDialog(),
      ),
    );
  }
}

// ─── Add Guest Dialog ─────────────────────────────────────────────────────────

class _AddGuestDialog extends StatefulWidget {
  const _AddGuestDialog();

  @override
  State<_AddGuestDialog> createState() => _AddGuestDialogState();
}

class _AddGuestDialogState extends State<_AddGuestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _relationship = 'friend';
  DateTime? _checkIn;
  DateTime? _checkOut;
  bool _isSubmitting = false;

  static const _relationships = [
    ('parent', 'Orang Tua'),
    ('sibling', 'Saudara'),
    ('friend', 'Teman'),
    ('relative', 'Kerabat'),
    ('colleague', 'Rekan Kerja'),
    ('other', 'Lainnya'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isCheckIn}) async {
    final now = DateTime.now();
    final initial = isCheckIn ? (_checkIn ?? now) : (_checkOut ?? _checkIn ?? now);

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;

    final picked =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() {
      if (isCheckIn) {
        _checkIn = picked;
        if (_checkOut != null && _checkOut!.isBefore(picked)) {
          _checkOut = null;
        }
      } else {
        _checkOut = picked;
      }
    });
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_checkIn == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal & jam masuk terlebih dahulu')),
      );
      return;
    }
    if (_checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal & jam keluar terlebih dahulu')),
      );
      return;
    }
    if (!_checkOut!.isAfter(_checkIn!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal keluar harus setelah tanggal masuk')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    context.read<MyGuestBloc>().add(CreateMyGuest(
          name: _nameController.text.trim(),
          checkInAt: _checkIn!.toIso8601String(),
          checkOutAt: _checkOut!.toIso8601String(),
          relationship: _relationship,
        ));

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah Tamu',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Nama
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Tamu',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              // Hubungan
              DropdownButtonFormField<String>(
                value: _relationship,
                decoration: const InputDecoration(
                  labelText: 'Hubungan',
                  border: OutlineInputBorder(),
                ),
                items: _relationships
                    .map((r) => DropdownMenuItem(
                          value: r.$1,
                          child: Text(r.$2),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _relationship = v!),
              ),
              const SizedBox(height: 16),

              // Tanggal Masuk
              _DateTimeTile(
                label: 'Tanggal & Jam Masuk',
                value: _checkIn != null ? _formatDateTime(_checkIn!) : null,
                onTap: () => _pickDateTime(isCheckIn: true),
              ),
              const SizedBox(height: 12),

              // Tanggal Keluar
              _DateTimeTile(
                label: 'Tanggal & Jam Keluar',
                value: _checkOut != null ? _formatDateTime(_checkOut!) : null,
                onTap: () => _pickDateTime(isCheckIn: false),
              ),
              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateTimeTile extends StatelessWidget {
  const _DateTimeTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value ?? label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: value != null
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Guest Card ───────────────────────────────────────────────────────────────

class _GuestCard extends StatelessWidget {
  const _GuestCard({required this.item, required this.onDelete});

  final MyGuestItem item;
  final VoidCallback onDelete;

  String _formatDateTime(String raw) {
    try {
      final dt = DateTime.parse(raw);
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day/$month/$year $hour:$minute';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.person_outline,
                  color: theme.colorScheme.onPrimaryContainer, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.relationshipLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.login_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        'Masuk: ${_formatDateTime(item.checkInAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.logout_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        'Keluar: ${_formatDateTime(item.checkOutAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline_rounded,
                  color: theme.colorScheme.error),
              tooltip: 'Hapus Tamu',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper Views ─────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.4,
            child: const Icon(Icons.people_alt_outlined, size: 72),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data tamu',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ketuk tombol "Tambah Tamu" untuk mendaftarkan tamu baru',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Tambah Tamu'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 56, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text('Gagal memuat data',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
