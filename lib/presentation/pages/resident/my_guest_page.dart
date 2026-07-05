import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
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
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/textform/textfield.dart';
import 'package:frontend/presentation/widget/core/textform/date_time_picker_field.dart';
import 'package:frontend/presentation/widget/core/textform/dropdown_field.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
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

class _MyGuestView extends StatefulWidget {
  const _MyGuestView();

  @override
  State<_MyGuestView> createState() => _MyGuestViewState();
}

class _MyGuestViewState extends State<_MyGuestView> {
  static final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _selectedStatus = 'Semua';

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
              action: BasicButton(
                onPressed: () => _showAddGuestDialog(context),
                leadIcon: Icon(Icons.add_rounded, size: 18, color: Theme.of(context).colorScheme.onPrimary),
                label: 'Tambah Tamu',
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
                          action: BasicButton(
                            onPressed: () => _showAddGuestDialog(context),
                            leadIcon: Icon(Icons.add_rounded, size: 18, color: Theme.of(context).colorScheme.onPrimary),
                            label: 'Tambah Tamu',
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async =>
                            context.read<MyGuestBloc>().add(FetchMyGuests()),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: ['Semua', 'Aktif', 'Keluar'].map((status) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ChoiceChip(
                                      label: Text(status),
                                      selected: _selectedStatus == status,
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() => _selectedStatus = status);
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final filteredGuests = state.guests.where((item) {
                                    if (_selectedStatus == 'Semua') return true;
                                    if (_selectedStatus == 'Aktif') return item.stayCompletedNotifiedAt == null;
                                    if (_selectedStatus == 'Keluar') return item.stayCompletedNotifiedAt != null;
                                    return true;
                                  }).toList();

                                  if (filteredGuests.isEmpty) {
                                    return const Center(child: Text('Tidak ada tamu dengan status tersebut.'));
                                  }

                                  return ListView.separated(
                                    itemCount: filteredGuests.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      return _GuestCard(
                                        item: filteredGuests[index],
                                        currency: _currency,
                                        onDelete: () => _confirmDelete(context, filteredGuests[index]),
                                        onPay: () => _showPaymentDialog(context, filteredGuests[index]),
                                        onCheckout: () => _confirmCheckout(context, filteredGuests[index]),
                                        onExtend: () => _showExtendDialog(context, filteredGuests[index], state.guests),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
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

  // REVISI: Cari tamu terkait (check-in/out yang sama) untuk perpanjangan selektif
  void _showExtendDialog(BuildContext context, MyGuestItem item, List<MyGuestItem> allGuests) {
    // Cari tamu-tamu lain yang memiliki check-in dan check-out yang sama (didaftarkan bersamaan)
    final relatedGuests = allGuests.where((g) =>
      g.checkInAt == item.checkInAt &&
      g.checkOutAt == item.checkOutAt &&
      g.stayCompletedNotifiedAt == null // Hanya yang masih aktif
    ).toList();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<MyGuestBloc>(),
        child: _ExtendGuestDialog(item: item, relatedGuests: relatedGuests),
      ),
    );
  }

  // REVISI: Tambahkan opsi pembayaran cash
  Future<void> _showPaymentDialog(BuildContext context, MyGuestItem item) async {
    final method = await showDialog<String>(
      context: context,
      builder: (ctx) => _PaymentMethodDialog(item: item),
    );
    if (method == null || !context.mounted) return;

    if (method == 'midtrans') {
      context.read<MyGuestBloc>().add(PayGuestBillMidtrans(item.id));
    } else if (method == 'cash') {
      // Pembayaran cash langsung tanpa upload bukti
      context.read<MyGuestBloc>().add(PayGuestBillCash(item.id));
    } else {
      // Manual transfer — navigasi ke halaman upload bukti
      final amount = item.bill != null && (item.bill!.amount < item.chargeAmount)
          ? item.chargeAmount - item.bill!.amount
          : (item.bill?.amount ?? item.chargeAmount);
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

// ─── Extend Guest Dialog (REVISI: Perpanjangan Selektif) ─────────────────────
class _ExtendGuestDialog extends StatefulWidget {
  const _ExtendGuestDialog({required this.item, required this.relatedGuests});
  final MyGuestItem item;
  final List<MyGuestItem> relatedGuests;

  @override
  State<_ExtendGuestDialog> createState() => _ExtendGuestDialogState();
}

class _ExtendGuestDialogState extends State<_ExtendGuestDialog> {
  DateTime? _checkOut;
  bool _isSubmitting = false;
  late Map<int, bool> _selectedGuests;

  @override
  void initState() {
    super.initState();
    // Inisialisasi: centang tamu yang diklik, sisanya tidak dicentang
    _selectedGuests = {};
    for (final g in widget.relatedGuests) {
      _selectedGuests[g.id] = g.id == widget.item.id;
    }
  }

  bool get _hasMultipleGuests => widget.relatedGuests.length > 1;

  List<int> get _selectedIds =>
      _selectedGuests.entries.where((e) => e.value).map((e) => e.key).toList();

  Future<void> _pickDateTime() async {
    final oldCheckOut = DateTime.tryParse(widget.item.checkOutAt) ?? DateTime.now();
    final initial = _checkOut ?? oldCheckOut;
    
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;

    setState(() {
      _checkOut = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _submit() {
    if (_checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal & jam perpanjangan terlebih dahulu')),
      );
      return;
    }

    final oldCheckOut = DateTime.tryParse(widget.item.checkOutAt) ?? DateTime.now();
    if (!_checkOut!.isAfter(oldCheckOut)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal keluar baru harus setelah tanggal keluar sebelumnya')),
      );
      return;
    }

    final selectedIds = _selectedIds;
    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu tamu untuk diperpanjang')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Fire ExtendMyGuest event untuk setiap tamu yang dipilih
    for (final id in selectedIds) {
      context.read<MyGuestBloc>().add(ExtendMyGuest(
            id: id,
            newCheckOutAt: _checkOut!.toIso8601String(),
          ));
    }

    Navigator.of(context).pop();
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Perpanjang Masa Inap',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                _hasMultipleGuests
                    ? 'Pilih tamu yang akan diperpanjang masa inap nya, '
                      'lalu tentukan tanggal keluar baru. '
                      'Biaya sewa tambahan (jika ada) akan dihitung secara otomatis.'
                    : 'Pilih tanggal keluar yang baru untuk tamu ${widget.item.name}. '
                      'Biaya sewa tambahan (jika ada) akan dihitung secara otomatis.',
                style: theme.textTheme.bodyMedium,
              ),

              // REVISI: Tampilkan checkbox jika ada lebih dari 1 tamu terkait
              if (_hasMultipleGuests) ...[
                const SizedBox(height: 16),
                Text(
                  'Pilih Tamu',
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...widget.relatedGuests.map((g) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: _selectedGuests[g.id] == true
                        ? theme.colorScheme.primaryContainer.withAlpha(80)
                        : theme.colorScheme.surfaceContainerHigh.withAlpha(60),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedGuests[g.id] == true
                          ? theme.colorScheme.primary.withAlpha(120)
                          : theme.colorScheme.outlineVariant,
                    ),
                  ),
                  child: CheckboxListTile(
                    title: Text(
                      g.name,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      g.relationshipLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    value: _selectedGuests[g.id] ?? false,
                    onChanged: (val) => setState(() => _selectedGuests[g.id] = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                )),
              ],

              const SizedBox(height: 16),
              CustomDateTimePickerField(
                label: 'Pilih Tanggal Keluar Baru',
                value: _checkOut != null ? _formatDateTime(_checkOut!) : null,
                onTap: _pickDateTime,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: BasicButton(
                      type: ButtonType.secondary,
                      onPressed: () => Navigator.of(context).pop(),
                      label: 'Batal',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BasicButton(
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _submit,
                      label: 'Perpanjang${_hasMultipleGuests ? ' (${_selectedIds.length})' : ''}',
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

// ─── Payment Method Dialog (REVISI: Tambah opsi Cash) ─────────────────────────
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
    final isExtensionBill = bill != null && (bill.amount < widget.item.chargeAmount);
    final amount = isExtensionBill
        ? widget.item.chargeAmount - bill.amount
        : (bill?.amount ?? widget.item.chargeAmount);

    return Dialog(
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 440),
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
            // REVISI: 3 opsi pembayaran — Manual, Midtrans, Cash
            Row(
              children: [
                Expanded(
                  child: _MethodOption(
                    label: 'Transfer',
                    subtitle: 'Upload bukti transfer',
                    icon: Icons.account_balance_outlined,
                    selected: _method == 'manual',
                    onTap: () => setState(() => _method = 'manual'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MethodOption(
                    label: 'Midtrans',
                    subtitle: 'Bayar via gateway',
                    icon: Icons.payment_outlined,
                    selected: _method == 'midtrans',
                    onTap: () => setState(() => _method = 'midtrans'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MethodOption(
                    label: 'Tunai',
                    subtitle: 'Bayar langsung',
                    icon: Icons.money_outlined,
                    selected: _method == 'cash',
                    onTap: () => setState(() => _method = 'cash'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: BasicButton(
                    type: ButtonType.secondary,
                    onPressed: () => Navigator.of(context).pop(null),
                    label: 'Batal',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BasicButton(
                    onPressed: () => Navigator.of(context).pop(_method),
                    label: _method == 'midtrans'
                        ? 'Lanjut ke Midtrans'
                        : _method == 'cash'
                            ? 'Konfirmasi Tunai'
                            : 'Lanjut ke Pembayaran',
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

// ─── Add Guest Dialog (REVISI: Multi-Tamu maks 3) ─────────────────────────────
class _AddGuestDialog extends StatefulWidget {
  const _AddGuestDialog();

  @override
  State<_AddGuestDialog> createState() => _AddGuestDialogState();
}

/// Representasi satu entry tamu dalam form
class _GuestFormEntry {
  final TextEditingController nameController;
  String relationship;
  Uint8List? imageBytes;
  String? imageName;

  _GuestFormEntry({String? name, this.relationship = 'friend'})
      : nameController = TextEditingController(text: name);

  void dispose() => nameController.dispose();
}

class _AddGuestDialogState extends State<_AddGuestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _residentController = TextEditingController();
  final _roomController = TextEditingController();

  // REVISI: List dinamis tamu (maks 3)
  final List<_GuestFormEntry> _guestEntries = [_GuestFormEntry()];

  DateTime? _checkIn;
  DateTime? _checkOut;
  bool _isSubmitting = false;
  bool _isLoadingResident = false;
  String? _residentError;
  bool _hasActiveLease = true;

  static const int _maxGuests = 3;

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
    for (final e in _guestEntries) {
      e.dispose();
    }
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

  void _addGuestEntry() {
    if (_guestEntries.length >= _maxGuests) return;
    setState(() => _guestEntries.add(_GuestFormEntry()));
  }

  void _removeGuestEntry(int index) {
    if (_guestEntries.length <= 1) return;
    setState(() {
      _guestEntries[index].dispose();
      _guestEntries.removeAt(index);
    });
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

    final missingIdentity = _guestEntries.any((e) => e.imageBytes == null);
    if (missingIdentity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap unggah foto identitas untuk setiap tamu')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // REVISI: Kirim array tamu ke BLoC
    final guests = _guestEntries.map((e) => {
      'name': e.nameController.text.trim(),
      'relationship': e.relationship,
    }).toList();

    final identityImages = _guestEntries.map((e) => e.imageBytes ?? Uint8List(0)).toList();
    final identityImageNames = _guestEntries.map((e) => e.imageName ?? '').toList();

    context.read<MyGuestBloc>().add(CreateMyGuest(
          guests: guests,
          identityImages: identityImages,
          identityImageNames: identityImageNames,
          checkInAt: _checkIn!.toIso8601String(),
          checkOutAt: _checkOut!.toIso8601String(),
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
        constraints: const BoxConstraints(maxWidth: 480),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tambah Tamu',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Daftarkan hingga $_maxGuests tamu sekaligus',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
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

                CustomTextField(
                  controller: _residentController,
                  enabled: false,
                  hintText: 'Nama Penghuni',
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _roomController,
                  enabled: false,
                  hintText: 'Nomor Kamar',
                ),
                const SizedBox(height: 20),

                // ─── Daftar Tamu Dinamis ──────────────────────────────
                ..._guestEntries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final guestEntry = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh.withAlpha(60),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${index + 1}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tamu ${index + 1}',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            if (_guestEntries.length > 1)
                              IconButton(
                                onPressed: () => _removeGuestEntry(index),
                                icon: Icon(Icons.close_rounded,
                                    color: theme.colorScheme.error, size: 18),
                                visualDensity: VisualDensity.compact,
                                tooltip: 'Hapus Tamu ${index + 1}',
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: guestEntry.nameController,
                          hintText: 'Nama Tamu',
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Nama tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 12),
                        CustomDropdownField<String>(
                          title: 'Hubungan',
                          hint: 'Pilih hubungan',
                          value: guestEntry.relationship,
                          items: _relationships
                              .map((r) => DropdownMenuItem(
                                    value: r.$1,
                                    child: Text(r.$2),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => guestEntry.relationship = v!),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final result = await FilePicker.platform.pickFiles(type: FileType.image);
                              if (result != null) {
                                setState(() {
                                  guestEntry.imageBytes = result.files.first.bytes;
                                  guestEntry.imageName = result.files.first.name;
                                });
                              }
                            },
                            icon: Icon(guestEntry.imageBytes != null ? Icons.check_circle : Icons.upload_file, size: 18),
                            label: Text(guestEntry.imageBytes != null ? guestEntry.imageName! : 'Upload Foto Identitas'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: BorderSide(
                                color: guestEntry.imageBytes != null ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Tombol tambah tamu
                if (_guestEntries.length < _maxGuests)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _addGuestEntry,
                      icon: const Icon(Icons.person_add_outlined, size: 18),
                      label: Text('Tambah Tamu (${_guestEntries.length}/$_maxGuests)'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(
                          color: theme.colorScheme.primary.withAlpha(120),
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Tanggal Masuk
                CustomDateTimePickerField(
                  label: 'Tanggal & Jam Masuk',
                  value: _checkIn != null ? _formatDateTime(_checkIn!) : null,
                  onTap: () => _pickDateTime(isCheckIn: true),
                ),
                const SizedBox(height: 12),

                // Tanggal Keluar
                CustomDateTimePickerField(
                  label: 'Tanggal & Jam Keluar',
                  value: _checkOut != null ? _formatDateTime(_checkOut!) : null,
                  onTap: () => _pickDateTime(isCheckIn: false),
                ),
                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: BasicButton(
                        type: ButtonType.secondary,
                        onPressed: () => Navigator.of(context).pop(),
                        label: 'Batal',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BasicButton(
                        isLoading: _isSubmitting,
                        onPressed: (_isSubmitting || _isLoadingResident || !_hasActiveLease)
                            ? null
                            : _submit,
                        label: 'Simpan (${_guestEntries.length} tamu)',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
    required this.onExtend, 
  });

  final MyGuestItem item;
  final NumberFormat currency;
  final VoidCallback onDelete;
  final VoidCallback onPay;
  final VoidCallback onCheckout;
  final VoidCallback onExtend; 

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

  Color _billStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'unpaid':
        return theme.colorScheme.outline;
      case 'pending':
        return theme.colorScheme.secondary;
      case 'verified':
      case 'paid':
        return theme.colorScheme.tertiary;
      case 'rejected':
      case 'failed':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bill = item.bill;
    final hasBill = bill != null;

    final isExtensionBill = hasBill && (bill.amount < item.chargeAmount);
    final canPay = (hasBill && bill.canPay) || isExtensionBill;

    return BasicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primaryContainer.withAlpha(150),
                  child: Icon(Icons.person_outline,
                      color: theme.colorScheme.onPrimaryContainer, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.relationshipLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _CompactInfo(label: 'Masuk', value: _formatDateTime(item.checkInAt)),
                          ),
                          Expanded(
                            child: _CompactInfo(label: 'Keluar', value: _formatDateTime(item.checkOutAt)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _CompactInfo(
                              label: 'Durasi', 
                              value: '${item.totalDays} hari${item.billableDays > 0 ? '\n(${item.billableDays} berbayar)' : ''}',
                            ),
                          ),
                          if (item.chargeAmount > 0)
                            Expanded(
                              child: _CompactInfo(
                                label: isExtensionBill ? 'Total Keseluruhan' : 'Total Biaya', 
                                value: currency.format(item.chargeAmount),
                                valueColor: isExtensionBill ? theme.colorScheme.onSurface : theme.colorScheme.error,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline_rounded,
                      color: theme.colorScheme.error.withAlpha(200), size: 20),
                  tooltip: 'Hapus Tamu',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

            if (isExtensionBill) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withAlpha(80),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sisa Tagihan (Extend)', 
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                    Text(currency.format(item.chargeAmount - bill.amount),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],

            if (hasBill) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _billStatusColor(bill.status, theme),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        bill.statusLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: _billStatusColor(bill.status, theme),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (canPay)
                    TextButton.icon(
                      onPressed: onPay,
                      icon: Icon(Icons.payment_outlined, size: 16, color: theme.colorScheme.primary),
                      label: Text('Bayar', style: TextStyle(color: theme.colorScheme.primary)),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                ],
              ),
            ],

            const SizedBox(height: 16),
            if (item.stayCompletedNotifiedAt == null)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onExtend,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      child: Text('Perpanjang', style: TextStyle(color: theme.colorScheme.onSurface)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: onCheckout,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Checkout'),
                    ),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Telah Keluar',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
    );
  }
}

class _CompactInfo extends StatelessWidget {
  const _CompactInfo({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: valueColor ?? theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
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
          BasicButton(
            onPressed: onAdd,
            leadIcon: Icon(Icons.add_rounded, size: 18, color: Theme.of(context).colorScheme.onPrimary),
            label: 'Tambah Tamu',
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
          BasicButton(
            onPressed: onRetry,
            leadIcon: Icon(Icons.refresh_rounded, size: 18, color: Theme.of(context).colorScheme.onPrimary),
            label: 'Coba Lagi',
          ),
        ],
      ),
    );
  }
}