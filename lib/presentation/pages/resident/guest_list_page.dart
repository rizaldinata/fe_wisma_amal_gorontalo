import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/domain/entity/guest/guest_entity.dart';
import 'package:frontend/domain/entity/resident/resident_entity.dart';
import 'package:frontend/domain/usecase/resident/get_admin_residents_usecase.dart';
import 'package:frontend/presentation/bloc/notification/notification_log_bloc.dart';
import 'package:frontend/presentation/bloc/guest/guest_bloc.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

@RoutePage()
class GuestListPage extends StatelessWidget {
  const GuestListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<GuestBloc>(),
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
    await showDialog<void>(
      context: context,
      builder: (ctx) => BlocProvider(
        create: (_) => serviceLocator<NotificationLogBloc>()
          ..add(FetchNotificationLogs()),
        child: const _NotificationLogDialog(),
      ),
    );
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
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: BlocConsumer<GuestBloc, GuestState>(
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
          if (state is GuestLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFA794F2)),
            );
          }

          if (state is GuestError && _guestCache.isEmpty) {
            return Center(
              child: Text(state.message,
                  style: const TextStyle(color: Colors.red)),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daftar Tamu',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        height: 1,
                        color: const Color(0xFF121212),
                      ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: BasicCard(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    padding: const EdgeInsets.fromLTRB(34, 22, 34, 24),
                    child: Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header card
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 14,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFA794F2),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                'Tamu',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontSize: 33,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF141414),
                                    ),
                              ),
                              const Spacer(),
                              OutlinedButton.icon(
                                onPressed: _showNotificationLog,
                                icon: const Icon(Icons.notifications_none,
                                    size: 18, color: Color(0xFF111827)),
                                label: const Text('Log Notifikasi'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF111827),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  side: const BorderSide(
                                      color: Color(0xFFE5E7EB)),
                                  textStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: _showAddGuestDialog,
                                icon: const Icon(Icons.add,
                                    size: 18, color: Colors.white),
                                label: const Text('Tambah'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFA794F2),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  textStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Search field
                              SizedBox(
                                width: 220,
                                height: 36,
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: _onSearch,
                                  decoration: InputDecoration(
                                    hintText: 'Cari tamu, penghuni, kamar...',
                                    hintStyle: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF9CA3AF)),
                                    prefixIcon: const Icon(Icons.search,
                                        size: 18, color: Color(0xFF9CA3AF)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 12),
                                    filled: true,
                                    fillColor: const Color(0xFFF3F4F6),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Header tabel
                          Container(
                            height: 34,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                _HeaderCell(label: 'NO', flex: 1),
                                _HeaderCell(label: 'NAMA PENGHUNI', flex: 3),
                                _HeaderCell(label: 'KAMAR', flex: 2),
                                _HeaderCell(label: 'NAMA TAMU', flex: 3),
                                _HeaderCell(label: 'HUBUNGAN', flex: 2),
                                _HeaderCell(label: 'MASUK', flex: 3),
                                _HeaderCell(label: 'KELUAR', flex: 3),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Isi tabel
                          Expanded(
                            child: _guestCache.isEmpty && state is! GuestLoading
                                ? Center(
                                    child: Text(
                                      'Tidak ada data tamu',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: const Color(0xFF6B7280),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  )
                                : Scrollbar(
                                    controller: _scrollController,
                                    thumbVisibility: true,
                                    child: ListView.separated(
                                      controller: _scrollController,
                                      itemCount: _guestCache.length +
                                          (_isLoadingMore ? 1 : 0),
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 8),
                                      itemBuilder: (context, index) {
                                        if (index >= _guestCache.length) {
                                          return const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12),
                                            child: Center(
                                              child: SizedBox(
                                                height: 22,
                                                width: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2),
                                              ),
                                            ),
                                          );
                                        }
                                        final row = _guestCache[index];
                                        return _GuestRow(
                                          no: index + 1,
                                          item: row,
                                        );
                                      },
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GuestRow extends StatelessWidget {
  const _GuestRow({required this.no, required this.item});

  final int no;
  final GuestItem item;

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
    return Row(
      children: [
        _BodyCell(value: no.toString(), flex: 1),
        _BodyCell(value: item.penghuni, flex: 3),
        _BodyCell(value: item.kamar, flex: 2),
        _BodyCell(value: item.name, flex: 3),
        _BodyCell(value: item.relationshipLabel, flex: 2),
        _BodyCell(value: _formatDateTime(item.checkInAt), flex: 3),
        _BodyCell(value: _formatDateTime(item.checkOutAt), flex: 3),
      ],
    );
  }
}

// ─── Private Widgets ───────────────────────────────────────────────────────

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label, required this.flex});

  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell({required this.value, required this.flex});

  final String value;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF111827),
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

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
              TextFormField(
                controller: _roomController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Nomor Kamar',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Tamu',
                  border: OutlineInputBorder(),
                ),
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

class _NotificationLogDialog extends StatefulWidget {
  const _NotificationLogDialog();

  @override
  State<_NotificationLogDialog> createState() => _NotificationLogDialogState();
}

class _NotificationLogDialogState extends State<_NotificationLogDialog> {
  final ScrollController _scrollController = ScrollController();

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Log Notifikasi',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
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
                        OutlinedButton.icon(
                          onPressed: () => context
                              .read<NotificationLogBloc>()
                              .add(FetchNotificationLogs()),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Muat Ulang'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is NotificationLogLoaded) {
                  final logs = state.data.logs;
                  if (logs.isEmpty) {
                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text('Tidak ada log notifikasi'),
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
                            message: item.message,
                            createdAt: _formatDateTime(item.createdAt),
                            status: item.status,
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
        ),
      ),
    );
  }
}

class _NotificationLogTile extends StatelessWidget {
  const _NotificationLogTile({
    required this.message,
    required this.createdAt,
    required this.status,
  });

  final String message;
  final String createdAt;
  final String status;

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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications, color: Color(0xFF6B7280)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
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
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
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
