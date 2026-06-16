import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/domain/entity/guest/guest_entity.dart';
import 'package:frontend/domain/usecase/finance/get_member_finance_summary_usecase.dart';
import 'package:frontend/presentation/bloc/guest/my_guest_bloc.dart';
import 'package:frontend/presentation/widget/core/appbar/app_topbar.dart';
import 'package:frontend/presentation/widget/core/wrapper/empty_state_widget.dart';
import 'package:frontend/presentation/widget/core/dialog/app_dialog.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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

  static final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return BlocListener<MyGuestBloc, MyGuestState>(
      listener: (context, state) {
        if (state is MyGuestActionSuccess) {
          AppSnackbar.showSuccess(state.message);
        } else if (state is MyGuestActionError) {
          AppSnackbar.showError(state.message);
        } else if (state is MyGuestMidtransInitiated) {
          AppSnackbar.showSuccess(state.message);
          final url = Uri.parse(
              'https://app.sandbox.midtrans.com/snap/v2/vtweb/${state.snapToken}');
          launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColorsDark.background : AppColorsLight.background,
        body: Column(
          children: [
            AppTopBar(
              title: 'Tamu Saya',
              breadcrumb: 'Penghuni / Tamu Saya',
              action: ElevatedButton.icon(
                onPressed: () => _showAddGuestDialog(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Tambah Tamu'),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
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
                        return EmptyStateWidget(
                          icon: Icons.people_outline,
                          title: 'Belum ada tamu',
                          subtitle: 'Tambahkan tamu pertama Anda dengan menekan tombol di atas.',
                          action: ElevatedButton.icon(
                            onPressed: () => _showAddGuestDialog(context),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Tambah Tamu'),
                          ),
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
                              currency: _currency,
                              onDelete: () => _confirmDelete(
                                  context, state.guests[index]),
                              onPay: () => _showPaymentDialog(
                                  context, state.guests[index]),
                              onCheckout: () => _confirmCheckout(
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
            ),
          ],
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

  void _confirmCheckout(BuildContext context, MyGuestItem item) async {
    final confirmed = await AppDialog.show(
      context,
      title: 'Checkout Tamu',
      message: 'Apakah tamu "${item.name}" telah selesai menginap dan keluar dari area Wisma?',
      confirmLabel: 'Ya, Selesai',
      cancelLabel: 'Batal',
      type: AppDialogType.warning,
    );
    if (confirmed == true && context.mounted) {
      context.read<MyGuestBloc>().add(CheckoutMyGuest(item.id));
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

  Future<void> _showPaymentDialog(BuildContext context, MyGuestItem item) async {
    final method = await showDialog<String>(
      context: context,
      builder: (ctx) => _PaymentMethodDialog(item: item),
    );
    if (method == null || !context.mounted) return;

    if (method == 'midtrans') {
      context.read<MyGuestBloc>().add(PayGuestBillMidtrans(item.id));
    } else {
      final amount = item.bill?.amount ?? item.chargeAmount;
      final result = await context.router.push<bool>(
        GuestBillPaymentRoute(
          guestId: item.id,
          guestName: item.name,
          amount: amount,
          billNumber: item.bill?.billNumber,
        ),
      );
      if (result == true && context.mounted) {
        context.read<MyGuestBloc>().add(FetchMyGuests());
      }
    }
  }
}

// ─── Payment Method Dialog ────────────────────────────────────────────────────

class _PaymentMethodDialog extends StatefulWidget {
  const _PaymentMethodDialog({required this.item});
  final MyGuestItem item;

  @override
  State<_PaymentMethodDialog> createState() => _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends State<_PaymentMethodDialog> {
  String _method = 'manual';

  static final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bill = widget.item.bill;
    final amount = bill?.amount ?? widget.item.chargeAmount;

    return Dialog(
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bayar Tagihan Tamu',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Tamu: ${widget.item.name}',
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: 2),
            Text(
              'Jumlah: ${_currency.format(amount)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text('Pilih Metode Pembayaran',
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MethodOption(
                    label: 'Manual',
                    subtitle: 'Upload bukti transfer',
                    icon: Icons.account_balance_outlined,
                    selected: _method == 'manual',
                    onTap: () => setState(() => _method = 'manual'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MethodOption(
                    label: 'Midtrans',
                    subtitle: 'Bayar via gateway',
                    icon: Icons.payment_outlined,
                    selected: _method == 'midtrans',
                    onTap: () => setState(() => _method = 'midtrans'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_method),
                    child: Text(_method == 'midtrans'
                        ? 'Lanjut ke Midtrans'
                        : 'Lanjut ke Pembayaran'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodOption extends StatelessWidget {
  const _MethodOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: selected
              ? theme.colorScheme.primaryContainer.withAlpha(80)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                size: 20,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 4),
            Text(label,
                style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface)),
            Text(subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant, fontSize: 10)),
          ],
        ),
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
  final _residentController = TextEditingController();
  final _roomController = TextEditingController();
  final _nameController = TextEditingController();
  String _relationship = 'friend';
  DateTime? _checkIn;
  DateTime? _checkOut;
  bool _isSubmitting = false;
  bool _isLoadingResident = false;
  String? _residentError;
  bool _hasActiveLease = true;

  static const _relationships = [
    ('parent', 'Orang Tua'),
    ('sibling', 'Saudara'),
    ('friend', 'Teman'),
    ('relative', 'Kerabat'),
    ('colleague', 'Rekan Kerja'),
    ('other', 'Lainnya'),
  ];

  @override
  void initState() {
    super.initState();
    _loadResidentInfo();
  }

  @override
  void dispose() {
    _residentController.dispose();
    _roomController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadResidentInfo() async {
    setState(() {
      _isLoadingResident = true;
      _residentError = null;
    });

    try {
      final summary = await serviceLocator
          .get<GetMemberFinanceSummaryUseCase>()
          .execute();
      _residentController.text =
          summary.residentName.isNotEmpty ? summary.residentName : '-';
      if (summary.activeLeases.isNotEmpty) {
        _roomController.text = summary.activeLeases.first.roomNumber;
        _hasActiveLease = true;
      } else {
        _roomController.text = '-';
        _hasActiveLease = false;
      }
    } catch (e) {
      _residentError = e.toString();
      _residentController.text = '-';
      _roomController.text = '-';
      _hasActiveLease = false;
    } finally {
      if (mounted) {
        setState(() => _isLoadingResident = false);
      }
    }
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
    if (!_hasActiveLease) {
      AppSnackbar.showError('Anda tidak memiliki sewa aktif untuk mendaftarkan tamu.');
      return;
    }
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

              if (_isLoadingResident)
                const LinearProgressIndicator(minHeight: 2),
              if (_residentError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _residentError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      TextButton(
                        onPressed: _loadResidentInfo,
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),

              TextFormField(
                controller: _residentController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Nama Penghuni',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _roomController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Nomor Kamar',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

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
                      onPressed: (_isSubmitting || _isLoadingResident || !_hasActiveLease)
                          ? null
                          : _submit,
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
  const _GuestCard({
    required this.item,
    required this.currency,
    required this.onDelete,
    required this.onPay,
    required this.onCheckout,
  });

  final MyGuestItem item;
  final NumberFormat currency;
  final VoidCallback onDelete;
  final VoidCallback onPay;
  final VoidCallback onCheckout;

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

  Color _billStatusColor(String status) {
    switch (status) {
      case 'unpaid':
        return Colors.grey;
      case 'pending':
        return Colors.orange;
      case 'verified':
      case 'paid':
        return Colors.green;
      case 'rejected':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bill = item.bill;
    final hasBill = bill != null;
    final canPay = hasBill && bill.canPay;

    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withAlpha(40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row atas: avatar + nama + badge hubungan + tombol hapus ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.person_outline,
                      color: theme.colorScheme.onPrimaryContainer, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.relationshipLabel,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline_rounded,
                      color: theme.colorScheme.error, size: 24),
                  tooltip: 'Hapus Tamu',
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // ── Info tanggal & biaya ──
            Row(
              children: [
                Expanded(
                  child: _InfoRow(
                    icon: Icons.login_outlined,
                    label: 'Masuk',
                    value: _formatDateTime(item.checkInAt),
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Expanded(
                  child: _InfoRow(
                    icon: Icons.logout_outlined,
                    label: 'Keluar',
                    value: _formatDateTime(item.checkOutAt),
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (item.totalDays > 0) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.nights_stay_outlined,
                label: 'Durasi',
                value: '${item.totalDays} hari'
                    '${item.billableDays > 0 ? ' (${item.billableDays} hari dikenakan biaya)' : ''}',
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
            if (item.chargeAmount > 0) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.receipt_outlined,
                label: 'Biaya Tamu',
                value: currency.format(item.chargeAmount),
                color: theme.colorScheme.error,
                bold: true,
              ),
            ],

            // ── Status tagihan + tombol bayar ──
            if (hasBill) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _billStatusColor(bill.status).withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      bill.statusLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _billStatusColor(bill.status),
                      ),
                    ),
                  ),
                  if (canPay) ...[
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: onPay,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        textStyle: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      icon: const Icon(Icons.payment_outlined, size: 18),
                      label: const Text('Bayar'),
                    ),
                  ],
                ],
              ),
            ],

            // ── Tombol / status checkout ──
            const SizedBox(height: 12),
            if (item.stayCompletedNotifiedAt == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onCheckout,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text('Tamu Telah Keluar'),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.withAlpha(60)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle,
                        size: 20, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Tamu Telah Keluar',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Helper row widget untuk menampilkan info dengan icon
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontFamily: DefaultTextStyle.of(context).style.fontFamily),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontWeight:
                        bold ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
