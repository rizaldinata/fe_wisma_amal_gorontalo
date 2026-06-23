import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entity/notification/notification_log_entity.dart';
import '../../bloc/notification/notification_monitoring_cubit.dart';
import '../../widget/core/appbar/app_topbar.dart';
import '../../widget/core/appbar/search_and_filter_bar.dart';
import '../../widget/core/card/summary_stat_card.dart';
import '../../widget/core/table/app_data_table.dart';
import '../../widget/core/wrapper/empty_state_widget.dart';

@RoutePage()
class NotificationMonitoringPage extends StatefulWidget {
  const NotificationMonitoringPage({super.key});

  @override
  State<NotificationMonitoringPage> createState() => _NotificationMonitoringPageState();
}

class _NotificationMonitoringPageState extends State<NotificationMonitoringPage> {
  late NotificationMonitoringCubit _cubit;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = serviceLocator.get<NotificationMonitoringCubit>()..load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(dt);
    } catch (_) {
      return raw;
    }
  }

  Color _statusColor(String s, bool d) => switch (s.toLowerCase()) {
    'terkirim' || 'sent'   => d ? AppColorsDark.statusDone       : AppColorsLight.statusDone,
    'gagal'    || 'failed' => d ? AppColorsDark.statusCancelled  : AppColorsLight.statusCancelled,
    _                      => d ? AppColorsDark.statusWaiting    : AppColorsLight.statusWaiting,
  };

  Color _statusBg(String s, bool d) => switch (s.toLowerCase()) {
    'terkirim' || 'sent'   => d ? AppColorsDark.statusDoneBg        : AppColorsLight.statusDoneBg,
    'gagal'    || 'failed' => d ? AppColorsDark.statusCancelledBg   : AppColorsLight.statusCancelledBg,
    _                      => d ? AppColorsDark.statusWaitingBg     : AppColorsLight.statusWaitingBg,
  };

  Color _statusBorder(String s, bool d) => switch (s.toLowerCase()) {
    'terkirim' || 'sent'   => d ? AppColorsDark.statusDoneBorder       : AppColorsLight.statusDoneBorder,
    'gagal'    || 'failed' => d ? AppColorsDark.statusCancelledBorder  : AppColorsLight.statusCancelledBorder,
    _                      => d ? AppColorsDark.statusWaitingBorder    : AppColorsLight.statusWaitingBorder,
  };

  void _showSendDialog(bool isDark) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SendNotificationDialog(isDark: isDark, cubit: _cubit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<NotificationMonitoringCubit, NotificationMonitoringState>(
        listener: (context, state) {
          if (state.successMessage != null) _snack(context, state.successMessage!, isError: false, isDark: isDark);
          if (state.errorMessage != null)   _snack(context, state.errorMessage!,   isError: true,  isDark: isDark);
        },
        builder: (context, state) {
          final isLoading = state.status == NotificationMonitoringStatus.loading;
          return Scaffold(
            backgroundColor: isDark ? AppColorsDark.background : AppColorsLight.background,
            body: Column(children: [
              AppTopBar(
                title: 'Monitoring Notifikasi',
                breadcrumb: 'Notifikasi / WhatsApp',
                action: FilledButton.icon(
                  onPressed: () => _showSendDialog(isDark),
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Kirim Notifikasi'),
                ),
              ),
              Expanded(
                child: isLoading && state.logs.isEmpty
                    ? _buildSkeleton(isDark)
                    : Stack(children: [
                        _buildContent(state, isDark),
                        if (isLoading) const LinearProgressIndicator(),
                      ]),
              ),
            ]),
          );
        },
      ),
    );
  }

  // ─── Content ──────────────────────────────────────────────────────────────

  Widget _buildContent(NotificationMonitoringState state, bool isDark) {
    final primary      = isDark ? AppColorsDark.primary      : AppColorsLight.primary;
    final primaryLight = isDark ? AppColorsDark.primaryLight : AppColorsLight.primaryLight;
    final borderLight  = isDark ? AppColorsDark.borderLight  : AppColorsLight.borderLight;
    final textSec      = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    final textHint     = isDark ? AppColorsDark.textHint     : AppColorsLight.textHint;
    final hasFilter    = state.statusFilter != null || state.typeFilter != null || state.searchQuery.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Summary cards ───────────────────────────────────────────────────
        if (state.summary != null)
          Row(children: [
            Expanded(child: SummaryStatCard(
              label: 'Total Notifikasi',
              value: '${state.summary!.total}',
              icon: Icons.notifications_outlined,
              iconColor: primary,
              iconBg: primaryLight,
              trend: 'Semua waktu',
            )),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: SummaryStatCard(
              label: 'Terkirim',
              value: '${state.summary!.sent}',
              icon: Icons.check_circle_outline_rounded,
              iconColor: isDark ? AppColorsDark.statusDone   : AppColorsLight.statusDone,
              iconBg:    isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg,
              trend: 'Berhasil dikirim',
            )),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: SummaryStatCard(
              label: 'Gagal',
              value: '${state.summary!.failed}',
              icon: Icons.error_outline_rounded,
              iconColor: isDark ? AppColorsDark.statusCancelled   : AppColorsLight.statusCancelled,
              iconBg:    isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg,
              trend: 'Perlu dikirim ulang',
            )),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: SummaryStatCard(
              label: 'Hari Ini',
              value: '${state.summary!.today}',
              icon: Icons.today_rounded,
              iconColor: isDark ? AppColorsDark.statusProcess   : AppColorsLight.statusProcess,
              iconBg:    isDark ? AppColorsDark.statusProcessBg : AppColorsLight.statusProcessBg,
              trend: 'Notifikasi hari ini',
            )),
          ]).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms),

        const SizedBox(height: AppSpacing.xxxl),

        // ── Search & Filter ─────────────────────────────────────────────────
        SearchAndFilterBar(
          searchController: _searchCtrl,
          searchHint: 'Cari nomor telepon...',
          onSearchChanged: (val) => _cubit.applyFilter(searchQuery: val),
          dropdownFilter: Row(children: [
            _AppDropdown<String?>(
              value: state.statusFilter,
              isDark: isDark,
              hint: 'Semua Status',
              items: const [
                DropdownMenuItem(value: null,      child: Text('Semua Status')),
                DropdownMenuItem(value: 'sent',    child: Text('Terkirim')),
                DropdownMenuItem(value: 'failed',  child: Text('Gagal')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
              ],
              onChanged: (val) => _cubit.applyFilter(statusFilter: val, clearStatus: val == null),
            ),
            const SizedBox(width: AppSpacing.md),
            _AppDropdown<String?>(
              value: state.typeFilter,
              isDark: isDark,
              hint: 'Semua Tipe',
              items: const [
                DropdownMenuItem(value: null,                    child: Text('Semua Tipe')),
                DropdownMenuItem(value: 'payment_receipt',       child: Text('Kwitansi Bayar')),
                DropdownMenuItem(value: 'manual_broadcast',      child: Text('Broadcast')),
                DropdownMenuItem(value: 'pembayaran_diterima',   child: Text('Pembayaran Diterima')),
                DropdownMenuItem(value: 'pembayaran_dibatalkan', child: Text('Pembayaran Batal')),
                DropdownMenuItem(value: 'jadwal_dibuat',         child: Text('Jadwal Dibuat')),
                DropdownMenuItem(value: 'jadwal_sewa_aktif',     child: Text('Sewa Aktif')),
                DropdownMenuItem(value: 'jadwal_sewa_selesai',   child: Text('Sewa Selesai')),
                DropdownMenuItem(value: 'jadwal_batal',          child: Text('Jadwal Batal')),
                DropdownMenuItem(value: 'laporan_kerusakan',     child: Text('Kerusakan')),
              ],
              onChanged: (val) => _cubit.applyFilter(typeFilter: val, clearType: val == null),
            ),
            if (hasFilter) ...[
              const SizedBox(width: AppSpacing.sm),
              TextButton.icon(
                onPressed: () {
                  _searchCtrl.clear();
                  _cubit.applyFilter(clearStatus: true, clearType: true, searchQuery: '');
                },
                icon: const Icon(Icons.close, size: 14),
                label: const Text('Reset', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(foregroundColor: textSec),
              ),
            ],
          ]),
        ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

        const SizedBox(height: AppSpacing.lg),

        // ── Table ───────────────────────────────────────────────────────────
        if (state.logs.isEmpty)
          EmptyStateWidget(
            icon: Icons.notifications_off_outlined,
            title: hasFilter ? 'Tidak ada hasil untuk filter ini' : 'Belum ada log notifikasi',
            subtitle: hasFilter
                ? 'Coba ubah filter atau kata kunci pencarian.'
                : 'Notifikasi WhatsApp yang dikirim akan muncul di sini.',
          ).animate().fadeIn()
        else
          AppDataTable(
            dataRowMinHeight: 56,
            dataRowMaxHeight: double.infinity,
            columns: const [
              DataColumn(label: Text('Tipe')),
              DataColumn(label: Text('No. Telepon')),
              DataColumn(label: Text('Pesan')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Waktu')),
              DataColumn(label: Text('')),
            ],
            rows: state.logs.map((log) {
              final isFailed = log.status.toLowerCase() == 'gagal' || log.status.toLowerCase() == 'failed';
              final statusC  = _statusColor(log.status, isDark);
              final statusB  = _statusBg(log.status, isDark);
              final statusBd = _statusBorder(log.status, isDark);
              final isResending = state.resendingIds.contains(log.id);

              return DataRow(cells: [
                // Tipe
                DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_typeIcon(log.channel), size: 16,
                      color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
                  const SizedBox(width: 8),
                  Text(log.typeLabel, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ])),

                // No. Telepon
                DataCell(Text(
                  log.recipient ?? '-',
                  style: TextStyle(fontSize: 13,
                      color: isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary),
                )),

                // Pesan (preview)
                DataCell(ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text(
                    log.message.length > 80 ? '${log.message.substring(0, 80)}…' : log.message,
                    style: TextStyle(fontSize: 12,
                        color: isDark ? AppColorsDark.textHint : AppColorsLight.textHint),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),

                // Status + error reason
                DataCell(Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusB,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusBd),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 5, height: 5,
                            decoration: BoxDecoration(color: statusC, shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        Text(log.status,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusC)),
                      ]),
                    ),
                    if (isFailed && log.errorResponse != null) ...[
                      const SizedBox(height: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 180),
                        child: Text(
                          log.errorResponse!,
                          style: TextStyle(fontSize: 10, color: statusC, height: 1.3),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                )),

                // Waktu
                DataCell(Text(
                  _formatDate(log.createdAt),
                  style: TextStyle(fontSize: 12,
                      color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
                )),

                // Aksi
                DataCell(
                  isFailed
                      ? (isResending
                          ? SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: statusC),
                            )
                          : OutlinedButton.icon(
                              onPressed: () => _cubit.resend(log.id),
                              icon: Icon(Icons.refresh_rounded, size: 13, color: statusC),
                              label: Text('Kirim Ulang',
                                  style: TextStyle(fontSize: 11, color: statusC, fontWeight: FontWeight.w600)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                side: BorderSide(color: statusC.withValues(alpha: 0.5)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                            ))
                      : const SizedBox.shrink(),
                ),
              ]);
            }).toList(),
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

        const SizedBox(height: AppSpacing.xl),

        // ── Pagination ──────────────────────────────────────────────────────
        if (state.pagination != null && state.logs.isNotEmpty)
          Row(children: [
            Text(
              'Halaman ${state.currentPage} dari ${state.pagination!.lastPage} • ${state.pagination!.total} entri',
              style: TextStyle(fontSize: 13,
                  color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
            ),
            const Spacer(),
            _PaginationBar(
              currentPage: state.currentPage,
              totalPages: state.pagination!.lastPage,
              onPrev: state.currentPage > 1 ? () => _cubit.prevPage() : null,
              onNext: state.currentPage < state.pagination!.lastPage ? () => _cubit.nextPage() : null,
              isDark: isDark,
              borderLight: borderLight,
              textHint: textHint,
            ),
          ]),
      ]),
    );
  }

  // ── Skeleton ───────────────────────────────────────────────────────────────

  Widget _buildSkeleton(bool isDark) {
    final base = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final hi   = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    Widget bone(double h, {double radius = 8, double? w}) => Shimmer.fromColors(
      baseColor: base, highlightColor: hi,
      child: Container(
        height: h, width: w,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius)),
      ),
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
        Shimmer.fromColors(
          baseColor: base, highlightColor: hi,
          child: Container(
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Snackbar ───────────────────────────────────────────────────────────────

  void _snack(BuildContext ctx, String msg, {required bool isError, required bool isDark}) {
    final bg = isError
        ? (isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled)
        : (isDark ? AppColorsDark.statusDone      : AppColorsLight.statusDone);
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }

  IconData _typeIcon(String? type) => switch (type) {
    'payment_receipt'       => Icons.receipt_long_rounded,
    'payment_reminder'      => Icons.payment_rounded,
    'manual_broadcast'      => Icons.campaign_rounded,
    'system_alert'          => Icons.warning_amber_rounded,
    'pembayaran_diterima'   => Icons.check_circle_outline_rounded,
    'pembayaran_dibatalkan' => Icons.cancel_outlined,
    'jadwal_dibuat'         => Icons.event_rounded,
    'jadwal_sewa_aktif'     => Icons.home_rounded,
    'jadwal_sewa_selesai'   => Icons.home_work_outlined,
    'jadwal_batal'          => Icons.event_busy_rounded,
    'laporan_kerusakan'     => Icons.build_outlined,
    _                       => Icons.notifications_outlined,
  };
}

// ══════════════════════════════════════════════════════════════════════════════
// Send Notification Dialog
// ══════════════════════════════════════════════════════════════════════════════

class _SendNotificationDialog extends StatefulWidget {
  final bool isDark;
  final NotificationMonitoringCubit cubit;

  const _SendNotificationDialog({required this.isDark, required this.cubit});

  @override
  State<_SendNotificationDialog> createState() => _SendNotificationDialogState();
}

class _SendNotificationDialogState extends State<_SendNotificationDialog> {
  bool _useUser = true;
  NotificationRecipientEntity? _selectedUser;
  final _phoneCtrl   = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _searchCtrl  = TextEditingController();
  late Future<List<NotificationRecipientEntity>> _recipientsFuture;

  @override
  void initState() {
    super.initState();
    _recipientsFuture = widget.cubit.loadRecipients();
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final message = _messageCtrl.text.trim();
    if (message.isEmpty) return;
    if (_useUser) {
      if (_selectedUser == null) return;
      widget.cubit.sendCustom(userId: _selectedUser!.id, message: message);
    } else {
      final phone = _phoneCtrl.text.trim();
      if (phone.isEmpty) return;
      widget.cubit.sendCustom(targetPhone: phone, message: message);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark        = widget.isDark;
    final surface       = isDark ? AppColorsDark.surface        : AppColorsLight.surface;
    final textPrimary   = isDark ? AppColorsDark.textPrimary    : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColorsDark.textSecondary  : AppColorsLight.textSecondary;
    final textHint      = isDark ? AppColorsDark.textHint       : AppColorsLight.textHint;
    final primary       = isDark ? AppColorsDark.primary        : AppColorsLight.primary;
    final primaryLight  = isDark ? AppColorsDark.primaryLight   : AppColorsLight.primaryLight;
    final borderLight   = isDark ? AppColorsDark.borderLight    : AppColorsLight.borderLight;
    final surfaceVar    = isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      backgroundColor: surface,
      child: Container(
        width: 560,
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Header
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: primaryLight, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.send_rounded, color: primary, size: 22),
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Kirim Notifikasi WhatsApp',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: textPrimary)),
              Text('Kirim pesan langsung ke pengguna terdaftar',
                  style: TextStyle(fontSize: 12, color: textSecondary)),
            ]),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.close, size: 20, color: textSecondary),
            ),
          ]),

          const SizedBox(height: AppSpacing.xl),

          // Tab toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: surfaceVar,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: borderLight),
            ),
            child: Row(children: [
              Expanded(child: _TabOption(
                label: 'Pilih Pengguna',
                icon: Icons.person_search_outlined,
                isActive: _useUser,
                isDark: isDark,
                onTap: () => setState(() { _useUser = true; _selectedUser = null; }),
              )),
              const SizedBox(width: 4),
              Expanded(child: _TabOption(
                label: 'Nomor Manual',
                icon: Icons.dialpad_outlined,
                isActive: !_useUser,
                isDark: isDark,
                onTap: () => setState(() { _useUser = false; }),
              )),
            ]),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Input penerima
          if (_useUser) ...[
            Text('Penerima', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
            const SizedBox(height: 8),
            FutureBuilder<List<NotificationRecipientEntity>>(
              future: _recipientsFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 56, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
                }
                if (snap.hasError) {
                  return Text('Gagal memuat penerima.', style: TextStyle(color: Colors.red.shade400, fontSize: 12));
                }

                final all = snap.data ?? [];

                if (_selectedUser != null) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: primary.withValues(alpha: 0.25)),
                    ),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: primaryLight,
                        child: Text(
                          _selectedUser!.name.isNotEmpty ? _selectedUser!.name[0].toUpperCase() : '?',
                          style: TextStyle(fontWeight: FontWeight.w700, color: primary, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_selectedUser!.name,
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textPrimary)),
                        if (_selectedUser!.phone != null)
                          Text(_selectedUser!.phone!, style: TextStyle(fontSize: 12, color: textSecondary)),
                      ])),
                      GestureDetector(
                        onTap: () => setState(() { _selectedUser = null; _searchCtrl.clear(); }),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: surfaceVar, borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: borderLight),
                          ),
                          child: Icon(Icons.close, size: 14, color: textSecondary),
                        ),
                      ),
                    ]),
                  );
                }

                final q = _searchCtrl.text.toLowerCase();
                final filtered = q.isEmpty
                    ? all
                    : all.where((u) => u.name.toLowerCase().contains(q) || (u.phone ?? '').contains(q)).toList();

                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _searchCtrl,
                      style: TextStyle(fontSize: 13, color: textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Cari nama atau nomor...',
                        hintStyle: TextStyle(fontSize: 13, color: textHint),
                        prefixIcon: Icon(Icons.search, size: 16, color: textSecondary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: borderLight),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        isDense: true,
                        filled: true,
                        fillColor: surfaceVar,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 180),
                    decoration: BoxDecoration(
                      border: Border.all(color: borderLight),
                      borderRadius: BorderRadius.circular(8),
                      color: surface,
                    ),
                    child: filtered.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: Text('Tidak ada penerima ditemukan',
                                  style: TextStyle(fontSize: 13, color: textHint)),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => Divider(height: 1, color: borderLight),
                            itemBuilder: (_, i) => InkWell(
                              onTap: () => setState(() => _selectedUser = filtered[i]),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Row(children: [
                                  CircleAvatar(
                                    radius: 15,
                                    backgroundColor: primaryLight,
                                    child: Text(
                                      filtered[i].name.isNotEmpty ? filtered[i].name[0].toUpperCase() : '?',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: primary),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(filtered[i].name,
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
                                    if (filtered[i].phone != null)
                                      Text(filtered[i].phone!,
                                          style: TextStyle(fontSize: 11, color: textSecondary)),
                                  ])),
                                  Icon(Icons.chevron_right, size: 16, color: textHint),
                                ]),
                              ),
                            ),
                          ),
                  ),
                ]);
              },
            ),
          ] else ...[
            Text('Nomor Telepon', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneCtrl,
              style: TextStyle(fontSize: 13, color: textPrimary),
              decoration: InputDecoration(
                hintText: '08xxxxxxxxxx',
                hintStyle: TextStyle(fontSize: 13, color: textHint),
                prefixIcon: Icon(Icons.phone_outlined, size: 16, color: textSecondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: borderLight),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                isDense: true,
                filled: true,
                fillColor: surfaceVar,
                helperText: 'Format: 08xxx atau 628xxx',
                helperStyle: TextStyle(fontSize: 11, color: textHint),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // Pesan
          Text('Pesan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
          const SizedBox(height: 8),
          StatefulBuilder(builder: (_, setInner) {
            final charCount = _messageCtrl.text.length;
            return Stack(children: [
              TextField(
                controller: _messageCtrl,
                style: TextStyle(fontSize: 13, color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'Tulis pesan WhatsApp...',
                  hintStyle: TextStyle(fontSize: 13, color: textHint),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderLight),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
                  isDense: true,
                  filled: true,
                  fillColor: surfaceVar,
                ),
                maxLines: 5,
                maxLength: 1000,
                buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                onChanged: (_) => setInner(() {}),
              ),
              Positioned(
                bottom: 8, right: 12,
                child: Text(
                  '$charCount/1000',
                  style: TextStyle(fontSize: 10, color: charCount > 900 ? Colors.orange : textHint),
                ),
              ),
            ]);
          }),

          const SizedBox(height: AppSpacing.xl),

          // Tombol aksi
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              child: const Text('Batal'),
            ),
            const SizedBox(width: AppSpacing.md),
            BlocBuilder<NotificationMonitoringCubit, NotificationMonitoringState>(
              bloc: widget.cubit,
              builder: (context, state) => FilledButton.icon(
                icon: state.isSending
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded, size: 16),
                label: Text(state.isSending ? 'Mengirim...' : 'Kirim Sekarang'),
                onPressed: state.isSending ? null : _submit,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ── Tab Option ────────────────────────────────────────────────────────────────

class _TabOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _TabOption({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary  = isDark ? AppColorsDark.primary       : AppColorsLight.primary;
    final surface  = isDark ? AppColorsDark.surface       : AppColorsLight.surface;
    final textSec  = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? (isDark ? surface : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 1))]
              : null,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 15, color: isActive ? primary : textSec),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? primary : textSec,
              )),
        ]),
      ),
    );
  }
}

// ── Pagination Bar ────────────────────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final bool isDark;
  final Color borderLight;
  final Color textHint;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPrev,
    required this.onNext,
    required this.isDark,
    required this.borderLight,
    required this.textHint,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      _NavBtn(icon: Icons.chevron_left,  enabled: onPrev != null, onTap: onPrev ?? () {}, borderLight: borderLight, isDark: isDark),
      const SizedBox(width: 8),
      Text('$currentPage / $totalPages', style: TextStyle(fontSize: 13, color: textHint)),
      const SizedBox(width: 8),
      _NavBtn(icon: Icons.chevron_right, enabled: onNext != null, onTap: onNext ?? () {}, borderLight: borderLight, isDark: isDark),
    ]);
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final Color borderLight;
  final bool isDark;

  const _NavBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.borderLight,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final active = isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
    final hint   = isDark ? AppColorsDark.textHint    : AppColorsLight.textHint;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderLight),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: enabled ? active : hint),
      ),
    );
  }
}

// ── App Dropdown (lokal, mengikuti gaya inventory) ────────────────────────────

class _AppDropdown<T> extends StatelessWidget {
  final T value;
  final bool isDark;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _AppDropdown({
    required this.value,
    required this.isDark,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final borderLight   = isDark ? AppColorsDark.borderLight   : AppColorsLight.borderLight;
    final textSecondary = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    final textPrimary   = isDark ? AppColorsDark.textPrimary   : AppColorsLight.textPrimary;
    final surface       = isDark ? AppColorsDark.surface       : AppColorsLight.surface;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: borderLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: surface,
          hint: Text(hint, style: TextStyle(fontSize: 14, color: textSecondary)),
          items: items,
          onChanged: onChanged,
          isDense: true,
          style: TextStyle(fontSize: 14, color: textPrimary),
          icon: Icon(Icons.keyboard_arrow_down, size: 18, color: textSecondary),
        ),
      ),
    );
  }
}
