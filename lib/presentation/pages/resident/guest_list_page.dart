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
                  leadIcon: const Icon(Icons.add, size: 18, color: Colors.white),
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
                        rows: _guestCache.asMap().entries.map((entry) {
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
                                TextButton(
                                  onPressed: () => _confirmCheckout(context, row),
                                  child: const Text('Checkout', style: TextStyle(color: Colors.red)),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
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

class _AdminGuestDialogState extends State<_AdminGuestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roomController = TextEditingController();

  String _relationship = 'friend';
  DateTime? _checkIn;
  DateTime? _checkOut;
  bool _isSubmitting = false;

  List<ResidentItem> _residentOptions = <ResidentItem>[];
  ResidentItem? _selectedResident;
  bool _isLoadingResidents = false;
  String? _residentError;

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
    _nameController.dispose();
    _roomController.dispose();
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

    final leaseId = int.tryParse(_selectedResident!.id);
    if (leaseId == null) {
      AppSnackbar.showError('ID sewa tidak valid.');
      return;
    }

    setState(() => _isSubmitting = true);

    context.read<GuestBloc>().add(CreateAdminGuest(
          leaseId: leaseId,
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
        constraints: const BoxConstraints(maxWidth: 460),
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
              DropdownButtonFormField<ResidentItem>(
                value: _selectedResident,
                decoration: const InputDecoration(
                  labelText: 'Nama Penghuni (aktif)',
                  border: OutlineInputBorder(),
                ),
                items: _residentOptions
                    .map((row) => DropdownMenuItem(
                          value: row,
                          child: Text('${row.nama} - ${row.kamar}'),
                        ))
                    .toList(),
                onChanged: _isLoadingResidents ? null : _setSelectedResident,
                validator: (value) =>
                    value == null ? 'Pilih penghuni aktif' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _roomController,
                enabled: false,
                hintText: 'Nomor Kamar',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                hintText: 'Nama Tamu',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama tamu tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16),
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
                onChanged: (v) => setState(() => _relationship = v ?? 'friend'),
              ),
              const SizedBox(height: 16),
              _DateTimeTile(
                label: 'Tanggal & Jam Masuk',
                value: _checkIn != null ? _formatDateTime(_checkIn!) : null,
                onTap: () => _pickDateTime(isCheckIn: true),
              ),
              const SizedBox(height: 12),
              _DateTimeTile(
                label: 'Tanggal & Jam Keluar',
                value: _checkOut != null ? _formatDateTime(_checkOut!) : null,
                onTap: () => _pickDateTime(isCheckIn: false),
              ),
              const SizedBox(height: 24),
              if (_residentOptions.isEmpty && !_isLoadingResidents)
                Text(
                  'Belum ada penghuni aktif yang bisa dipilih.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: const Color(0xFF6B7280)),
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
                      label: 'Simpan',
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
                  const Icon(Icons.notifications_active,
                      color: Color(0xFFA794F2), size: 22),
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
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$unread baru',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.red,
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
                        child: CircularProgressIndicator(
                          color: Color(0xFFA794F2),
                        ),
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
                              style: const TextStyle(color: Colors.red)),
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
                                  size: 48, color: Color(0xFFE5E7EB)),
                              const SizedBox(height: 12),
                              Text(
                                'Tidak ada log notifikasi',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF6B7280),
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
                                  foregroundColor: const Color(0xFFA794F2),
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
                  color: isRead ? const Color(0xFFF3F4F6) : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.notifications,
                    color: isRead ? const Color(0xFF6B7280) : Colors.red),
              ),
              if (!isRead)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
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
                        color: const Color(0xFFA794F2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.typeLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: const Color(0xFFA794F2),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value ?? label,
                style: TextStyle(
                  color: value != null
                      ? const Color(0xFF111827)
                      : const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}