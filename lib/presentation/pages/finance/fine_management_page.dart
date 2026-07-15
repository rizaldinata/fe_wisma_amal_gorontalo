import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entity/finance/fine_eligible_user_entity.dart';
import '../../../domain/entity/finance/fine_entity.dart';
import '../../../domain/usecase/finance/get_fine_eligible_users_usecase.dart';
import '../../bloc/fine/fine_cubit.dart';
import '../../bloc/fine/fine_state.dart';
import '../../widget/core/appbar/app_topbar.dart';
import '../../widget/core/appbar/search_and_filter_bar.dart';
import '../../widget/core/card/summary_stat_card.dart';
import '../../widget/core/table/app_data_table.dart';
import '../../widget/core/wrapper/empty_state_widget.dart';

@RoutePage()
class FineManagementPage extends StatefulWidget {
  const FineManagementPage({super.key});

  @override
  State<FineManagementPage> createState() => _FineManagementPageState();
}

class _FineManagementPageState extends State<FineManagementPage> {
  String _formatCurrency(double v) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(v);

  String _formatDate(DateTime dt) =>
      DateFormat('d MMM yyyy', 'id_ID').format(dt);

  String? _filterStatus;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  int _currentPage = 1;
  static const int _perPage = 10;

  late FineCubit _cubit;
  late GetFineEligibleUsersUseCase _getEligibleUsers;

  @override
  void initState() {
    super.initState();
    _cubit = serviceLocator.get<FineCubit>()..loadFines();
    _getEligibleUsers = serviceLocator.get<GetFineEligibleUsersUseCase>();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Filter & pagination ───────────────────────────────────────────────────────

  List<FineEntity> _applyFilter(List<FineEntity> fines) {
    var list = fines.toList();
    if (_filterStatus != null) list = list.where((f) => f.status == _filterStatus).toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((f) =>
          f.tenantName.toLowerCase().contains(q) ||
          f.reason.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  int _totalPages(int count) => (count / _perPage).ceil().clamp(1, 9999);

  List<FineEntity> _paged(List<FineEntity> list) {
    final start = ((_currentPage - 1) * _perPage).clamp(0, list.length);
    final end   = (_currentPage * _perPage).clamp(0, list.length);
    return list.sublist(start, end);
  }

  // ── Status helpers ────────────────────────────────────────────────────────────

  Color _statusColor(String s, bool d)  => switch (s) {
    'paid'      => d ? AppColorsDark.statusDone      : AppColorsLight.statusDone,
    'waived'    => d ? AppColorsDark.statusProcess   : AppColorsLight.statusProcess,
    'cancelled' => d ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
    _           => d ? AppColorsDark.statusWaiting   : AppColorsLight.statusWaiting,
  };

  Color _statusBg(String s, bool d) => switch (s) {
    'paid'      => d ? AppColorsDark.statusDoneBg      : AppColorsLight.statusDoneBg,
    'waived'    => d ? AppColorsDark.statusProcessBg   : AppColorsLight.statusProcessBg,
    'cancelled' => d ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg,
    _           => d ? AppColorsDark.statusWaitingBg   : AppColorsLight.statusWaitingBg,
  };

  Color _statusBorder(String s, bool d) => switch (s) {
    'paid'      => d ? AppColorsDark.statusDoneBorder      : AppColorsLight.statusDoneBorder,
    'waived'    => d ? AppColorsDark.statusProcessBorder   : AppColorsLight.statusProcessBorder,
    'cancelled' => d ? AppColorsDark.statusCancelledBorder : AppColorsLight.statusCancelledBorder,
    _           => d ? AppColorsDark.statusWaitingBorder   : AppColorsLight.statusWaitingBorder,
  };

  String _statusLabel(String s) => switch (s) {
    'paid'      => 'Lunas',
    'waived'    => 'Dimaafkan',
    'cancelled' => 'Dibatalkan',
    _           => 'Belum Bayar',
  };

  Widget _statusChip(String status, bool isDark) {
    final color  = _statusColor(status, isDark);
    final bg     = _statusBg(status, isDark);
    final border = _statusBorder(status, isDark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(_statusLabel(status),
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────────

  void _showCreateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CreateFineDialog(
        getEligibleUsers: _getEligibleUsers,
        onCreate: ({required int userId, required double amount, required String reason}) {
          _cubit.createFine(tenantUserId: userId, amount: amount, reason: reason);
        },
      ),
    );
  }

  void _showWaiveDialog(FineEntity fine) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Maafkan Denda'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Penghuni: ${fine.tenantName}', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('Nominal: ${_formatCurrency(fine.amount)}', style: const TextStyle(fontSize: 13)),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'Alasan memaafkan *',
              hintText: 'Penghuni sudah meminta maaf...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isEmpty) return;
              _cubit.waiveFine(fine.id, ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Maafkan'),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(FineEntity fine) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Batalkan Denda'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Penghuni: ${fine.tenantName}', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Yakin ingin membatalkan denda sebesar ${_formatCurrency(fine.amount)}?',
              style: const TextStyle(fontSize: 13)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tidak')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () { _cubit.cancelFine(fine.id); Navigator.pop(context); },
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<FineCubit, FineState>(
        listener: (context, state) {
          if (state is FineOperationSuccess) _snackSuccess(context, state.message, isDark);
          if (state is FineError) _snackError(context, state.message, isDark);
        },
        builder: (context, state) {
          final isFirstLoad = state is FineLoading || state is FineInitial;
          final isRefreshing = state is FineRefreshing;
          final allFines = state is FineLoaded
              ? state.fines
              : state is FineOperationSuccess
                  ? state.fines
                  : state is FineRefreshing
                      ? state.currentFines
                      : <FineEntity>[];

          return Scaffold(
            backgroundColor: isDark ? AppColorsDark.background : AppColorsLight.background,
            body: Column(children: [
              AppTopBar(
                title: 'Manajemen Denda',
                breadcrumb: 'Keuangan / Denda',
                action: FilledButton.icon(
                  onPressed: _showCreateDialog,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Buat Denda'),
                ),
              ),
              Expanded(
                child: isFirstLoad
                    ? _buildSkeleton(isDark)
                    : Stack(children: [
                        _buildContent(allFines, isDark),
                        if (isRefreshing) const LinearProgressIndicator(),
                      ]),
              ),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildContent(List<FineEntity> allFines, bool isDark) {
    final filtered   = _applyFilter(allFines);
    final totalPages = _totalPages(filtered.length);
    final page       = _currentPage.clamp(1, totalPages);
    final paged      = _paged(filtered);

    final totalUnpaid   = allFines.where((f) => f.isUnpaid).fold(0.0, (s, f) => s + f.amount);
    final totalPaid     = allFines.where((f) => f.isPaid).fold(0.0, (s, f) => s + f.amount);
    final countWaived   = allFines.where((f) => f.isWaived).length;
    final textSecondary = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Summary cards ─────────────────────────────────────────────────────
        Row(children: [
          Expanded(child: SummaryStatCard(
            label: 'Total Denda',
            value: '${allFines.length} Denda',
            icon: Icons.gavel_rounded,
            iconColor: isDark ? AppColorsDark.primary : AppColorsLight.primary,
            iconBg:    isDark ? AppColorsDark.primaryLight : AppColorsLight.primaryLight,
            trend: 'Semua status',
          )),
          const SizedBox(width: AppSpacing.lg),
          Expanded(child: SummaryStatCard(
            label: 'Belum Dibayar',
            value: _formatCurrency(totalUnpaid),
            icon: Icons.warning_amber_rounded,
            iconColor: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting,
            iconBg:    isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg,
            trend: '${allFines.where((f) => f.isUnpaid).length} denda',
          )),
          const SizedBox(width: AppSpacing.lg),
          Expanded(child: SummaryStatCard(
            label: 'Terkumpul (Lunas)',
            value: _formatCurrency(totalPaid),
            icon: Icons.check_circle_outline_rounded,
            iconColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
            iconBg:    isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg,
            trend: '${allFines.where((f) => f.isPaid).length} denda lunas',
          )),
          const SizedBox(width: AppSpacing.lg),
          Expanded(child: SummaryStatCard(
            label: 'Dimaafkan',
            value: '$countWaived Denda',
            icon: Icons.handshake_outlined,
            iconColor: isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess,
            iconBg:    isDark ? AppColorsDark.statusProcessBg : AppColorsLight.statusProcessBg,
            trend: 'Denda yg dihapuskan',
          )),
        ]).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms),

        const SizedBox(height: AppSpacing.xxxl),

        // ── Search & Filter ───────────────────────────────────────────────────
        SearchAndFilterBar(
          searchController: _searchCtrl,
          searchHint: 'Cari nama penghuni atau alasan denda...',
          onSearchChanged: (val) => setState(() { _searchQuery = val; _currentPage = 1; }),
          dropdownFilter: Row(mainAxisSize: MainAxisSize.min, children: [
            _buildDropdown<String?>(
              value: _filterStatus,
              hint: 'Semua Status',
              isDark: isDark,
              items: const [
                DropdownMenuItem(value: null,        child: Text('Semua Status')),
                DropdownMenuItem(value: 'unpaid',    child: Text('Belum Bayar')),
                DropdownMenuItem(value: 'paid',      child: Text('Lunas')),
                DropdownMenuItem(value: 'waived',    child: Text('Dimaafkan')),
                DropdownMenuItem(value: 'cancelled', child: Text('Dibatalkan')),
              ],
              onChanged: (val) => setState(() { _filterStatus = val; _currentPage = 1; }),
            ),
            if (_filterStatus != null) ...[
              const SizedBox(width: AppSpacing.sm),
              TextButton.icon(
                onPressed: () => setState(() { _filterStatus = null; _currentPage = 1; }),
                icon: const Icon(Icons.close, size: 14),
                label: const Text('Reset', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(foregroundColor: textSecondary),
              ),
            ],
          ]),
        ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

        const SizedBox(height: AppSpacing.lg),

        // ── Table ─────────────────────────────────────────────────────────────
        if (filtered.isEmpty)
          EmptyStateWidget(
            icon: Icons.gavel_rounded,
            title: _searchQuery.isNotEmpty
                ? 'Tidak ada hasil untuk "$_searchQuery"'
                : _filterStatus != null
                    ? 'Tidak ada denda dengan status "${_statusLabel(_filterStatus!)}"'
                    : 'Belum ada data denda',
            subtitle: _searchQuery.isNotEmpty || _filterStatus != null
                ? 'Coba ubah filter atau kata kunci pencarian.'
                : 'Buat denda baru menggunakan tombol di atas.',
          ).animate().fadeIn()
        else ...[
          AppDataTable(
            dataRowMinHeight: 64,
            columns: const [
              DataColumn(label: Text('Penghuni')),
              DataColumn(label: Text('Alasan')),
              DataColumn(label: Text('Nominal'), numeric: true),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Tanggal')),
              DataColumn(label: Text('Aksi')),
            ],
            rows: paged.map((f) => _buildRow(f, isDark)).toList(),
          ).animate().fadeIn(delay: 150.ms, duration: 300.ms),

          const SizedBox(height: AppSpacing.lg),

          Row(children: [
            Text('Menampilkan ${paged.length} dari ${filtered.length} data',
                style: TextStyle(fontSize: 13, color: textSecondary)),
            const Spacer(),
            _PaginationBar(
              currentPage: page,
              totalPages: totalPages,
              onPageChanged: (p) => setState(() => _currentPage = p),
            ),
          ]),
        ],
      ]),
    );
  }

  DataRow _buildRow(FineEntity fine, bool isDark) {
    final textSecondary = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    final primaryColor  = isDark ? AppColorsDark.primary : AppColorsLight.primary;
    final cancelColor   = isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled;

    return DataRow(cells: [
      // Penghuni
      DataCell(Row(children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isDark ? AppColorsDark.primaryLight : AppColorsLight.primaryLight,
          child: Text(
            fine.tenantName.isNotEmpty ? fine.tenantName[0].toUpperCase() : '?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: primaryColor),
          ),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(fine.tenantName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          if (fine.tenantPhone != null)
            Text(fine.tenantPhone!,
                style: TextStyle(fontSize: 11, color: textSecondary)),
        ]),
      ])),

      // Alasan
      DataCell(Tooltip(
        message: fine.reason,
        child: SizedBox(
          width: 220,
          child: Text(fine.reason,
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: textSecondary)),
        ),
      )),

      // Nominal
      DataCell(Text(
        _formatCurrency(fine.amount),
        style: TextStyle(
          fontWeight: FontWeight.w700, fontSize: 13,
          color: fine.isUnpaid
              ? (isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting)
              : null,
        ),
      )),

      // Status
      DataCell(_statusChip(fine.status, isDark)),

      // Tanggal
      DataCell(Text(
        fine.createdAt != null ? _formatDate(fine.createdAt!) : '-',
        style: TextStyle(fontSize: 13, color: textSecondary),
      )),

      // Aksi
      DataCell(fine.isUnpaid
          ? Row(mainAxisSize: MainAxisSize.min, children: [
              TextButton(
                onPressed: () => _showWaiveDialog(fine),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                child: const Text('Maafkan'),
              ),
              TextButton(
                onPressed: () => _confirmCancel(fine),
                style: TextButton.styleFrom(
                  foregroundColor: cancelColor,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                child: const Text('Batalkan'),
              ),
            ])
          : Text('—', style: TextStyle(fontSize: 16,
              color: isDark ? AppColorsDark.textHint : AppColorsLight.textHint))),
    ]);
  }

  // ── Skeleton ──────────────────────────────────────────────────────────────────

  Widget _buildSkeleton(bool isDark) {
    final base = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final hi   = isDark ? Colors.grey[700]! : Colors.grey[100]!;
    Widget bone(double h, {double radius = 8}) => Shimmer.fromColors(
      baseColor: base, highlightColor: hi,
      child: Container(height: h,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius))),
    );
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(children: [
        Row(children: List.generate(4, (i) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 3 ? AppSpacing.lg : 0),
            child: bone(96, radius: AppSpacing.radiusLg),
          ),
        ))),
        const SizedBox(height: AppSpacing.xxxl),
        bone(48),
        const SizedBox(height: AppSpacing.lg),
        Expanded(child: bone(double.infinity, radius: AppSpacing.radiusMd)),
      ]),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  Widget _buildDropdown<T>({
    required T value, required String hint, required bool isDark,
    required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        color: isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: isDark ? AppColorsDark.surface : AppColorsLight.surface,
          hint: Text(hint, style: TextStyle(fontSize: 13,
              color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary)),
          items: items, onChanged: onChanged, isDense: true,
          style: TextStyle(fontSize: 13,
              color: isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary),
          icon: Icon(Icons.keyboard_arrow_down, size: 18,
              color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
        ),
      ),
    );
  }

  void _snackSuccess(BuildContext ctx, String msg, bool isDark) =>
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Row(children: [const Icon(Icons.check_circle, color: Colors.white, size: 18), const SizedBox(width: 8), Text(msg)]),
        backgroundColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16), duration: const Duration(seconds: 3),
      ));

  void _snackError(BuildContext ctx, String msg, bool isDark) =>
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Row(children: [const Icon(Icons.error_outline, color: Colors.white, size: 18), const SizedBox(width: 8), Text(msg)]),
        backgroundColor: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16), duration: const Duration(seconds: 3),
      ));
}

// ══════════════════════════════════════════════════════════════════════════════
// Dialog Buat Denda — fetch eligible users (member+resident) dari API
// ══════════════════════════════════════════════════════════════════════════════

class _CreateFineDialog extends StatefulWidget {
  final GetFineEligibleUsersUseCase getEligibleUsers;
  final void Function({required int userId, required double amount, required String reason}) onCreate;

  const _CreateFineDialog({
    required this.getEligibleUsers,
    required this.onCreate,
  });

  @override
  State<_CreateFineDialog> createState() => _CreateFineDialogState();
}

class _CreateFineDialogState extends State<_CreateFineDialog> {
  FineEligibleUserEntity? _selectedUser;
  final _amountCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  late Future<List<FineEligibleUserEntity>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = widget.getEligibleUsers.execute();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final surfaceColor     = isDark ? AppColorsDark.surface : AppColorsLight.surface;
    final textSecondary    = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    final primaryColor     = isDark ? AppColorsDark.primary : AppColorsLight.primary;
    final primaryLightColor = isDark ? AppColorsDark.primaryLight : AppColorsLight.primaryLight;
    final borderLight      = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final surfaceVariant   = isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      backgroundColor: surfaceColor,
      child: Container(
        width: 560,
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: primaryLightColor, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.gavel_rounded, color: primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Buat Denda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Text('Pilih penghuni dan isi detail denda',
                  style: TextStyle(fontSize: 12, color: textSecondary)),
            ]),
          ]),

          const Divider(height: 28),

          // ── Pilih pengguna ────────────────────────────────────────────────
          const Text('Pengguna', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),

          FutureBuilder<List<FineEligibleUserEntity>>(
            future: _usersFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 80,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                );
              }
              if (snap.hasError) {
                return Text('Gagal memuat daftar pengguna: ${snap.error}',
                    style: const TextStyle(color: Colors.red, fontSize: 12));
              }

              final allUsers = snap.data ?? [];
              final q = _searchCtrl.text.toLowerCase();
              final filtered = q.isEmpty
                  ? allUsers
                  : allUsers.where((u) =>
                      u.name.toLowerCase().contains(q) ||
                      u.email.toLowerCase().contains(q)).toList();

              if (_selectedUser != null) {
                return _buildSelectedUser(_selectedUser!, primaryColor, primaryLightColor, textSecondary, isDark, surfaceVariant, borderLight);
              }

              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau email...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    border: const OutlineInputBorder(),
                    isDense: true,
                    filled: true,
                    fillColor: surfaceVariant,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderLight),
                    borderRadius: BorderRadius.circular(8),
                    color: surfaceColor,
                  ),
                  child: filtered.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: Text('Tidak ada pengguna ditemukan',
                              style: TextStyle(color: Colors.grey))),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: borderLight),
                          itemBuilder: (_, i) => _UserListTile(
                            user: filtered[i],
                            primaryColor: primaryColor,
                            primaryLightColor: primaryLightColor,
                            textSecondary: textSecondary,
                            onTap: () => setState(() => _selectedUser = filtered[i]),
                          ),
                        ),
                ),
              ]);
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Nominal ───────────────────────────────────────────────────────
          TextField(
            controller: _amountCtrl,
            decoration: InputDecoration(
              labelText: 'Nominal Denda (Rp)',
              prefixIcon: const Icon(Icons.monetization_on_outlined, size: 18),
              border: const OutlineInputBorder(),
              isDense: true,
              filled: true,
              fillColor: surfaceVariant,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Alasan ────────────────────────────────────────────────────────
          TextField(
            controller: _reasonCtrl,
            decoration: InputDecoration(
              labelText: 'Alasan Denda',
              hintText: 'Melanggar peraturan kos...',
              border: const OutlineInputBorder(),
              isDense: true,
              filled: true,
              fillColor: surfaceVariant,
            ),
            maxLines: 3,
          ),

          const SizedBox(height: AppSpacing.xxxl),

          // ── Actions ───────────────────────────────────────────────────────
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            const SizedBox(width: AppSpacing.md),
            FilledButton.icon(
              icon: const Icon(Icons.gavel_rounded, size: 16),
              label: const Text('Buat Denda'),
              onPressed: () {
                final userId = _selectedUser?.id;
                final amount = double.tryParse(_amountCtrl.text);
                final reason = _reasonCtrl.text.trim();
                if (userId == null || amount == null || amount < 1000 || reason.isEmpty) return;
                widget.onCreate(userId: userId, amount: amount, reason: reason);
                Navigator.pop(context);
              },
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildSelectedUser(
    FineEligibleUserEntity user,
    Color primary, Color primaryLight, Color textSecondary,
    bool isDark, Color surfaceVariant, Color borderLight,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primary.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: primaryLight,
          child: Text(user.name[0].toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.w700, color: primary)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(user.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(width: 8),
            _RoleChip(role: user.role),
          ]),
          Text(user.email, style: TextStyle(fontSize: 12, color: textSecondary)),
          if (user.hasActiveRoom) ...[
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.meeting_room_outlined, size: 13, color: primary),
              const SizedBox(width: 4),
              Text(user.roomLabel,
                  style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w600)),
            ]),
          ],
        ])),
        GestureDetector(
          onTap: () => setState(() { _selectedUser = null; _searchCtrl.clear(); }),
          child: Icon(Icons.close, size: 18, color: textSecondary),
        ),
      ]),
    );
  }
}

// ── Tile pengguna dalam list ───────────────────────────────────────────────────

class _UserListTile extends StatelessWidget {
  final FineEligibleUserEntity user;
  final Color primaryColor;
  final Color primaryLightColor;
  final Color textSecondary;
  final VoidCallback onTap;

  const _UserListTile({
    required this.user,
    required this.primaryColor,
    required this.primaryLightColor,
    required this.textSecondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: primaryLightColor,
            child: Text(user.name[0].toUpperCase(),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primaryColor)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(user.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 6),
              _RoleChip(role: user.role),
            ]),
            Text(user.email,
                style: TextStyle(fontSize: 11, color: textSecondary),
                overflow: TextOverflow.ellipsis),
            // Info kamar untuk resident
            if (user.isResident && user.hasActiveRoom) ...[
              const SizedBox(height: 3),
              Row(children: [
                Icon(Icons.meeting_room_outlined, size: 12, color: primaryColor),
                const SizedBox(width: 4),
                Flexible(child: Text(user.roomLabel,
                    style: TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.w600))),
                if (user.scheduleEndDate != null) ...[
                  Text('  ·  s/d ', style: TextStyle(fontSize: 11, color: textSecondary)),
                  Text(
                    DateFormat('d MMM yyyy', 'id_ID').format(DateTime.parse(user.scheduleEndDate!)),
                    style: TextStyle(fontSize: 11, color: textSecondary),
                  ),
                ],
              ]),
            ],
          ])),
        ]),
      ),
    );
  }
}

// ── Role chip kecil ────────────────────────────────────────────────────────────

class _RoleChip extends StatelessWidget {
  final String role;
  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    final isResident = role == 'resident';
    final color = isResident ? Colors.indigo : Colors.teal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        isResident ? 'Penghuni' : 'Member',
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Pagination
// ══════════════════════════════════════════════════════════════════════════════

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  const _PaginationBar({required this.currentPage, required this.totalPages, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final textHint = isDark ? AppColorsDark.textHint : AppColorsLight.textHint;
    final pages = <int>[];
    int start = (currentPage - 2).clamp(1, totalPages);
    int end   = (start + 4).clamp(1, totalPages);
    start = (end - 4).clamp(1, totalPages);
    for (int i = start; i <= end; i++) { pages.add(i); }

    return Row(mainAxisSize: MainAxisSize.min, children: [
      _NavBtn(icon: Icons.chevron_left, enabled: currentPage > 1,
          onTap: () => onPageChanged(currentPage - 1)),
      const SizedBox(width: 4),
      if (start > 1) ...[
        _PageBtn(page: 1, isActive: false, onTap: () => onPageChanged(1)),
        if (start > 2)
          Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('...', style: TextStyle(color: textHint))),
      ],
      ...pages.map((p) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: _PageBtn(page: p, isActive: p == currentPage, onTap: () => onPageChanged(p)),
      )),
      if (end < totalPages) ...[
        if (end < totalPages - 1)
          Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('...', style: TextStyle(color: textHint))),
        _PageBtn(page: totalPages, isActive: false, onTap: () => onPageChanged(totalPages)),
      ],
      const SizedBox(width: 4),
      _NavBtn(icon: Icons.chevron_right, enabled: currentPage < totalPages,
          onTap: () => onPageChanged(currentPage + 1)),
    ]);
  }
}

class _PageBtn extends StatelessWidget {
  final int page; final bool isActive; final VoidCallback onTap;
  const _PageBtn({required this.page, required this.isActive, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final primary = isDark ? AppColorsDark.primary : AppColorsLight.primary;
    final border  = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final text    = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: isActive ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive ? null : Border.all(color: border),
        ),
        alignment: Alignment.center,
        child: Text('$page', style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? Colors.white : text, fontSize: 13)),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon; final bool enabled; final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.enabled, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final border = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final active = isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
    final hint   = isDark ? AppColorsDark.textHint : AppColorsLight.textHint;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: border)),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: enabled ? active : hint),
      ),
    );
  }
}
