import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/domain/entity/guest/guest_entity.dart';
import 'package:frontend/domain/entity/resident/resident_entity.dart';
import 'package:frontend/domain/usecase/resident/get_admin_residents_usecase.dart';
import 'package:frontend/presentation/bloc/notification/notification_log_bloc.dart';
import 'package:frontend/domain/entity/notification/notification_log_entity.dart';
import 'package:frontend/presentation/bloc/guest/guest_bloc.dart';
import 'package:frontend/presentation/widget/core/appbar/app_topbar.dart';
import 'package:frontend/presentation/widget/core/appbar/search_and_filter_bar.dart';
import 'package:frontend/presentation/widget/core/table/app_data_table.dart';
import 'package:frontend/presentation/widget/core/wrapper/empty_state_widget.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';
import 'package:frontend/presentation/widget/core/dialog/app_dialog.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/textform/textfield.dart';
import 'package:frontend/presentation/widget/core/textform/date_time_picker_field.dart';
import 'package:frontend/presentation/widget/core/textform/dropdown_field.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

@RoutePage()
class GuestListPage extends StatelessWidget {
  const GuestListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<GuestBloc>()),
        BlocProvider(
            create: (_) => serviceLocator<NotificationLogBloc>()
              ..add(FetchNotificationLogs())),
      ],
      child: const _GuestListView(),
    );
  }
}

class _GuestListView extends StatefulWidget {
  const _GuestListView();

  @override
  State<_GuestListView> createState() => _GuestListViewState();
}

class _GuestListViewState extends State<_GuestListView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 1;
  static const int _perPage = 10;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<GuestItem> _guestCache = <GuestItem>[];
  Timer? _debounce;
  String _selectedStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _fetch() {
    context.read<GuestBloc>().add(FetchAdminGuests(
          page: _currentPage,
          perPage: _perPage,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
        ));
  }

  void _reload() {
    setState(() {
      _currentPage = 1;
      _guestCache = <GuestItem>[];
      _hasMore = true;
      _isLoadingMore = false;
    });
    _fetch();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _currentPage = 1;
        _guestCache = <GuestItem>[];
        _hasMore = true;
      });
      _fetch();
    });
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 120) {
      setState(() {
        _isLoadingMore = true;
        _currentPage += 1;
      });
      _fetch();
    }
  }

  Future<void> _showNotificationLog() async {
    final bloc = context.read<NotificationLogBloc>();
    bloc.add(FetchNotificationLogs()); // Refresh on open
    await showDialog<void>(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: const _NotificationLogDialog(),
      ),
    );
    bloc.add(FetchNotificationLogs()); // Refresh after close to update indicator
  }

  Future<void> _showAddGuestDialog() async {
    final guestBloc = context.read<GuestBloc>();
    await showDialog<void>(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: guestBloc,
        child: const _AdminGuestDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: isDark ? AppColorsDark.background : AppColorsLight.background,
      body: Column(
        children: [
          AppTopBar(
            title: 'Daftar Tamu',
            breadcrumb: 'Manajemen / Daftar Tamu',
            action: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BlocBuilder<NotificationLogBloc, NotificationLogState>(
                  builder: (context, notifState) {
                    bool hasUnread = false;
                    if (notifState is NotificationLogLoaded) {
                      hasUnread = notifState.data.unreadCount > 0;
                    }
                    return Stack(
                      children: [
                        BasicButton(
                          type: ButtonType.secondary,
                          onPressed: _showNotificationLog,
                          leadIcon: const Icon(Icons.notifications_none, size: 18),
                          label: 'Log Notifikasi',
                        ),
                        if (hasUnread)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                BasicButton(
                  onPressed: _showAddGuestDialog,
                  leadIcon: Icon(Icons.add, size: 18, color: Theme.of(context).colorScheme.onPrimary),
                  label: 'Tambah Tamu',
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<GuestBloc, GuestState>(
              listener: (context, state) {
                if (state is GuestLoaded) {
                  setState(() {
                    if (_currentPage == 1) {
                      _guestCache = List<GuestItem>.from(state.data.guests);
                    } else {
                      _guestCache.addAll(state.data.guests);
                    }
                    _hasMore = state.data.pagination.currentPage <
                        state.data.pagination.lastPage;
                    _isLoadingMore = false;
                  });
                }
                if (state is GuestError) {
                  setState(() => _isLoadingMore = false);
                }
                if (state is GuestActionSuccess) {
                  AppSnackbar.showSuccess(state.message);
                  _reload();
                }
                if (state is GuestActionError) {
                  AppSnackbar.showError(state.message);
                }
              },
              builder: (context, state) {
                if (state is GuestLoading && _guestCache.isEmpty) {
                  return _buildSkeleton(isDark);
                }

                if (state is GuestError && _guestCache.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'Gagal Memuat Data',
                    subtitle: state.message,
                    action: BasicButton(
                      onPressed: _reload,
                      label: 'Coba Lagi',
                    ),
                  );
                }

                return SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.xxxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      SearchAndFilterBar(
                        searchController: _searchController,
                        searchHint: 'Cari tamu, penghuni, kamar...',
                        onSearchChanged: _onSearch,
                        dropdownFilter: DropdownButton<String>(
                          value: _selectedStatus,
                          items: ['Semua', 'Aktif', 'Keluar']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                _selectedStatus = v;
                              });
                            }
                          },
                          underline: const SizedBox(),
                          focusColor: Colors.transparent,
                        ),
                      ).animate().fadeIn(duration: 300.ms),

                      const SizedBox(height: AppSpacing.lg),

                      // Table
                      AppDataTable(
                        columns: const [
                          DataColumn(label: Text('NO')),
                          DataColumn(label: Text('NAMA PENGHUNI')),
                          DataColumn(label: Text('KAMAR')),
                          DataColumn(label: Text('NAMA TAMU')),
                          DataColumn(label: Text('HUBUNGAN')),
                          DataColumn(label: Text('MASUK')),
                          DataColumn(label: Text('KELUAR')),
                          DataColumn(label: Text('AKSI')),
                        ],
                        rows: (() {
                          final filteredCache = _guestCache.where((item) {
                            if (_selectedStatus == 'Semua') return true;
                            if (_selectedStatus == 'Aktif') return item.stayCompletedNotifiedAt == null;
                            if (_selectedStatus == 'Keluar') return item.stayCompletedNotifiedAt != null;
                            return true;
                          }).toList();
                          return filteredCache.asMap().entries.map((entry) {
                            final index = entry.key + 1;
                            final row = entry.value;
                          return DataRow(
                            cells: [
                              DataCell(Text('$index')),
                              DataCell(Text(row.penghuni, style: const TextStyle(fontWeight: FontWeight.w600))),
                              DataCell(Text(row.kamar)),
                              DataCell(Text(row.name)),
                              DataCell(Text(row.relationshipLabel)),
                              DataCell(Text(_formatDateTime(row.checkInAt))),
                              DataCell(Text(_formatDateTime(row.checkOutAt))),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => _showGuestDetail(context, row),
                                      icon: Icon(Icons.visibility_outlined, color: Theme.of(context).colorScheme.primary),
                                      tooltip: 'Detail Tamu',
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    if (row.stayCompletedNotifiedAt == null) ...[
                                      const SizedBox(width: 4),
                                      IconButton(
                                        onPressed: () => _confirmCheckout(context, row),
                                        icon: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.error),
                                        tooltip: 'Checkout Tamu',
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      })(),
                    ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

                      // Loading more indicator
                      if (_isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

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

  void _showGuestDetail(BuildContext context, GuestItem item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Detail Tamu', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('Nama Tamu: ${item.name}'),
              const SizedBox(height: 4),
              Text('Penghuni: ${item.penghuni}'),
              const SizedBox(height: 4),
              Text('Kamar: ${item.kamar}'),
              const SizedBox(height: 4),
              Text('Hubungan: ${item.relationshipLabel}'),
              const SizedBox(height: 4),
              Text('Check In: ${_formatDateTime(item.checkInAt)}'),
              const SizedBox(height: 4),
              Text('Check Out: ${_formatDateTime(item.checkOutAt)}'),
              const SizedBox(height: 4),
              Text('Status: ${item.stayCompletedNotifiedAt == null ? 'Aktif' : 'Telah Keluar'}'),
              const SizedBox(height: 16),
              if (item.identityImageUrl != null && item.identityImageUrl!.isNotEmpty) ...[
                Text('Foto Identitas:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.identityImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmCheckout(BuildContext context, GuestItem item) async {
    final confirmed = await AppDialog.show(
      context,
      title: 'Checkout Tamu',
      message: 'Tandai tamu "${item.name}" dari penghuni "${item.penghuni}" sebagai telah keluar?',
      confirmLabel: 'Ya, Checkout',
      cancelLabel: 'Batal',
      type: AppDialogType.warning,
    );
    if (confirmed == true && context.mounted) {
      context.read<GuestBloc>().add(CheckoutAdminGuest(item.id));
    }
  }

  Widget _buildSkeleton(bool isDark) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              height: 40,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// _GuestRow, _HeaderCell, _BodyCell removed — replaced by AppDataTable in main view

class _AdminGuestDialog extends StatefulWidget {
  const _AdminGuestDialog();

  @override
  State<_AdminGuestDialog> createState() => _AdminGuestDialogState();
}

/// Representasi satu entry tamu dalam form admin
class _AdminGuestFormEntry {
  final TextEditingController nameController;
  String relationship;

  _AdminGuestFormEntry({String? name, this.relationship = 'friend'})
      : nameController = TextEditingController(text: name);

  void dispose() => nameController.dispose();
}

class _AdminGuestDialogState extends State<_AdminGuestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _roomController = TextEditingController();

  // REVISI: List dinamis tamu (maks 3)
  final List<_AdminGuestFormEntry> _guestEntries = [_AdminGuestFormEntry()];

  DateTime? _checkIn;
  DateTime? _checkOut;
  bool _isSubmitting = false;

  List<ResidentItem> _residentOptions = <ResidentItem>[];
  ResidentItem? _selectedResident;
  bool _isLoadingResidents = false;
  String? _residentError;

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
    _loadResidents();
  }

  @override
  void dispose() {
    _roomController.dispose();
    for (final e in _guestEntries) {
      e.dispose();
    }
    super.dispose();
  }

  Future<void> _loadResidents() async {
    setState(() {
      _isLoadingResidents = true;
      _residentError = null;
    });

    try {
      final response = await serviceLocator<GetAdminResidentsUseCase>()(
        page: 1,
        perPage: 200,
      );
      final activeResidents = response.residents
          .where((row) => row.status.toLowerCase() == 'active')
          .toList();

      setState(() {
        _residentOptions = activeResidents;
        if (_residentOptions.isNotEmpty && _selectedResident == null) {
          _setSelectedResident(_residentOptions.first);
        }
      });
    } catch (e) {
      setState(() => _residentError = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoadingResidents = false);
      }
    }
  }

  void _setSelectedResident(ResidentItem? item) {
    setState(() {
      _selectedResident = item;
      _roomController.text = item?.kamar ?? '-';
    });
  }

  void _addGuestEntry() {
    if (_guestEntries.length >= _maxGuests) return;
    setState(() => _guestEntries.add(_AdminGuestFormEntry()));
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
    if (_selectedResident == null) {
      AppSnackbar.showError('Pilih penghuni terlebih dahulu.');
      return;
    }
    if (_checkIn == null) {
      AppSnackbar.showError('Pilih tanggal & jam masuk terlebih dahulu.');
      return;
    }
    if (_checkOut == null) {
      AppSnackbar.showError('Pilih tanggal & jam keluar terlebih dahulu.');
      return;
    }
    if (!_checkOut!.isAfter(_checkIn!)) {
      AppSnackbar.showError('Tanggal keluar harus setelah tanggal masuk.');
      return;
    }

    final scheduleId = int.tryParse(_selectedResident!.id);
    if (scheduleId == null) {
      AppSnackbar.showError('ID jadwal tidak valid.');
      return;
    }

    setState(() => _isSubmitting = true);

    // REVISI: Kirim array tamu ke BLoC
    final guests = _guestEntries.map((e) => {
      'name': e.nameController.text.trim(),
      'relationship': e.relationship,
    }).toList();

    context.read<GuestBloc>().add(CreateAdminGuest(
          scheduleId: scheduleId,
          guests: guests,
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
        constraints: const BoxConstraints(maxWidth: 500),
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
                if (_isLoadingResidents)
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
                          onPressed: _loadResidents,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                CustomDropdownField<ResidentItem>(
                  title: 'Nama Penghuni (aktif)',
                  hint: 'Pilih penghuni aktif',
                  value: _selectedResident,
                  items: _residentOptions
                      .map((row) => DropdownMenuItem(
                            value: row,
                            child: Text('${row.nama} - ${row.kamar}'),
                          ))
                      .toList(),
                  onChanged: _isLoadingResidents ? (_) {} : (v) => _setSelectedResident(v),
                  validator: (value) =>
                      value == null ? 'Pilih penghuni aktif' : null,
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
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Nama tamu tidak boleh kosong'
                              : null,
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
                              setState(() => guestEntry.relationship = v ?? 'friend'),
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

                CustomDateTimePickerField(
                  label: 'Tanggal & Jam Masuk',
                  value: _checkIn != null ? _formatDateTime(_checkIn!) : null,
                  onTap: () => _pickDateTime(isCheckIn: true),
                ),
                const SizedBox(height: 12),
                CustomDateTimePickerField(
                  label: 'Tanggal & Jam Keluar',
                  value: _checkOut != null ? _formatDateTime(_checkOut!) : null,
                  onTap: () => _pickDateTime(isCheckIn: false),
                ),
                const SizedBox(height: 24),
                if (_residentOptions.isEmpty && !_isLoadingResidents)
                  Text(
                    'Belum ada penghuni aktif yang bisa dipilih.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                const SizedBox(height: 12),
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

class _NotificationLogDialog extends StatefulWidget {
  const _NotificationLogDialog();

  @override
  State<_NotificationLogDialog> createState() => _NotificationLogDialogState();
}

class _NotificationLogDialogState extends State<_NotificationLogDialog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Tandai semua notifikasi sebagai sudah dibaca saat dialog dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NotificationLogBloc>().add(MarkAllNotificationLogsRead());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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

    return Dialog(
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.notifications_active,
                      color: theme.colorScheme.primary, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Log Notifikasi',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  BlocBuilder<NotificationLogBloc, NotificationLogState>(
                    builder: (context, state) {
                      if (state is NotificationLogLoaded) {
                        final total = state.data.pagination.total;
                        final unread = state.data.unreadCount;
                        if (total > 0) {
                          return Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFA794F2)
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$total notifikasi',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFFA794F2),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (unread > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$unread baru',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              BlocBuilder<NotificationLogBloc, NotificationLogState>(
                builder: (context, state) {
                  if (state is NotificationLogLoading) {
                    return const SizedBox(
                      height: 240,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (state is NotificationLogError) {
                    return SizedBox(
                      height: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.message,
                              style: TextStyle(color: theme.colorScheme.error)),
                          const SizedBox(height: 12),
                          BasicButton(
                            type: ButtonType.secondary,
                            onPressed: () => context
                                .read<NotificationLogBloc>()
                                .add(FetchNotificationLogs()),
                            leadIcon: const Icon(Icons.refresh, size: 18),
                            label: 'Muat Ulang',
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is NotificationLogLoaded) {
                    final logs = state.data.logs;
                    if (logs.isEmpty) {
                      return SizedBox(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.notifications_off,
                                  size: 48, color: Colors.grey),
                              const SizedBox(height: 12),
                              Text(
                                'Tidak ada log notifikasi',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: () => context
                                    .read<NotificationLogBloc>()
                                    .add(FetchNotificationLogs()),
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Muat Ulang'),
                                style: TextButton.styleFrom(
                                  foregroundColor: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 360,
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        child: ListView.separated(
                          controller: _scrollController,
                          itemCount: logs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = logs[index];
                            return _NotificationLogTile(
                              item: item,
                              message: item.message,
                              createdAt: _formatDateTime(item.createdAt),
                              status: item.status,
                              isRead: item.isRead,
                            );
                          },
                        ),
                      ),
                    );
                  }

                  return const SizedBox(
                    height: 200,
                    child: Center(child: Text('Memuat log...')),
                  );
                },
              ),
            ],
            // Perbaikan: Kurung tutup ini sebelumnya hilang
          ),
        ),
      ),
    );
  }
}

class _NotificationLogTile extends StatelessWidget {
  const _NotificationLogTile({
    required this.item,
    required this.message,
    required this.createdAt,
    required this.status,
    required this.isRead,
  });

  final NotificationLogItem item;
  final String message;
  final String createdAt;
  final String status;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLabel = status.trim();
    final hasStatus = statusLabel.isNotEmpty && statusLabel != '-';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isRead ? theme.colorScheme.surfaceContainerHigh : theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.notifications,
                    color: isRead ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.error),
              ),
              if (!isRead)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
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
                        message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.typeLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule,
                        size: 14, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 6),
                    Text(
                      createdAt,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    if (hasStatus) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: status.toLowerCase().contains('gagal')
                              ? Colors.red.withOpacity(0.1)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: status.toLowerCase().contains('gagal')
                                ? Colors.red
                                : const Color(0xFF6B7280),
                            fontWeight: status.toLowerCase().contains('gagal')
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (status.toLowerCase().contains('gagal'))
            IconButton(
              onPressed: () {
                AppSnackbar.showInfo('Fungsi kirim ulang tersedia di menu utama.');
              },
              icon: const Icon(Icons.refresh, size: 20, color: Colors.red),
              tooltip: 'Kirim Ulang',
            ),
        ],
      ),
    );
  }
}
