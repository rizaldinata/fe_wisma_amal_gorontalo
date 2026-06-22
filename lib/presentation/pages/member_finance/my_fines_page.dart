import 'dart:typed_data';
import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entity/finance/fine_entity.dart';
import '../../../domain/entity/setting/bank_account_entity.dart';
import '../../bloc/member_finance/member_finance_bloc.dart';
import '../../bloc/member_finance/member_finance_event.dart';
import '../../bloc/member_finance/member_finance_state.dart';
import '../../widget/core/appbar/app_topbar.dart';
import '../../widget/core/wrapper/empty_state_widget.dart';

@RoutePage()
class MyFinesPage extends StatefulWidget {
  const MyFinesPage({super.key});

  @override
  State<MyFinesPage> createState() => _MyFinesPageState();
}

class _MyFinesPageState extends State<MyFinesPage> {
  final Set<int> _selectedIds = {};

  String _formatCurrency(double v) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(v);

  String _formatDate(DateTime dt) =>
      DateFormat('d MMM yyyy', 'id_ID').format(dt);

  Future<void> _launchMidtrans(String token) async {
    final url = Uri.parse('https://app.sandbox.midtrans.com/snap/v2/vtweb/$token');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka halaman pembayaran')),
        );
      }
    }
  }

  void _toggle(FineEntity fine) {
    if (!fine.isUnpaid) return;
    setState(() {
      if (_selectedIds.contains(fine.id)) {
        _selectedIds.remove(fine.id);
      } else {
        _selectedIds.add(fine.id);
      }
    });
  }

  double _totalSelected(List<FineEntity> fines) =>
      fines.where((f) => _selectedIds.contains(f.id)).fold(0.0, (s, f) => s + f.amount);

  Future<void> _bayar(BuildContext context, List<BankAccountEntity> bankAccounts, bool isMidtrans) async {
    if (_selectedIds.isEmpty) return;

    final bloc = context.read<MemberFinanceBloc>();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _PayFineDialog(
        bankAccounts: bankAccounts,
        isMidtransEnabled: isMidtrans,
        totalAmount: _totalSelected(bloc.state.myFines),
        formatCurrency: _formatCurrency,
      ),
    );

    if (result == null || !mounted) return;

    bloc.add(PayFinesEvent(
      _selectedIds.toList(),
      result['payment_method'] as String,
      paymentProofBytes: result['payment_proof_bytes'] as Uint8List?,
      paymentProofName: result['payment_proof_name'] as String?,
      preferredPaymentType: result['preferred_payment_type'] as String?,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return BlocProvider(
      create: (_) => serviceLocator.get<MemberFinanceBloc>()..add(FetchMyFines()),
      child: BlocConsumer<MemberFinanceBloc, MemberFinanceState>(
        listener: (context, state) {
          if (state.status == MemberFinanceStatus.finePaymentSuccess) {
            if (state.snapToken != null && state.snapToken!.isNotEmpty) {
              _launchMidtrans(state.snapToken!);
            } else {
              _snack(context, 'Bukti pembayaran berhasil diunggah. Menunggu verifikasi admin.',
                  isDark: isDark);
              setState(() => _selectedIds.clear());
            }
          }
          if (state.status == MemberFinanceStatus.failure) {
            _snackError(context, state.errorMessage ?? 'Terjadi kesalahan', isDark: isDark);
          }
        },
        builder: (context, state) {
          final fines    = state.myFines;
          final isLoading = state.status == MemberFinanceStatus.loading;

          return Scaffold(
            backgroundColor: isDark ? AppColorsDark.background : AppColorsLight.background,
            body: Column(children: [
              AppTopBar(title: 'Denda Saya', breadcrumb: 'Keuangan / Denda Saya'),
              Expanded(child: isLoading
                  ? _buildSkeleton(isDark)
                  : fines.isEmpty
                      ? _buildEmpty()
                      : _buildContent(context, state, fines, isDark)),
            ]),
          );
        },
      ),
    );
  }

  // ── Content utama ─────────────────────────────────────────────────────────────

  Widget _buildContent(
    BuildContext context,
    MemberFinanceState state,
    List<FineEntity> fines,
    bool isDark,
  ) {
    final unpaid    = fines.where((f) => f.isUnpaid).toList();
    final paid      = fines.where((f) => f.isPaid).toList();
    final waived    = fines.where((f) => f.isWaived).toList();
    final cancelled = fines.where((f) => f.isCancelled).toList();

    final totalUnpaid = unpaid.fold(0.0, (s, f) => s + f.amount);
    final totalPaid   = paid.fold(0.0, (s, f) => s + f.amount);

    final isProcessing = state.status == MemberFinanceStatus.loading;

    return Stack(children: [
      SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: _selectedIds.isNotEmpty ? 120 : AppSpacing.lg,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Summary row ──────────────────────────────────────────────────
          Row(children: [
            Expanded(child: _SummaryTile(
              icon: Icons.warning_amber_rounded,
              label: 'Belum Dibayar',
              value: _formatCurrency(totalUnpaid),
              sub: '${unpaid.length} denda',
              color: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting,
              bg:    isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg,
              isDark: isDark,
            )),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _SummaryTile(
              icon: Icons.check_circle_outline_rounded,
              label: 'Sudah Lunas',
              value: _formatCurrency(totalPaid),
              sub: '${paid.length} denda',
              color: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
              bg:    isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg,
              isDark: isDark,
            )),
          ]).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0, duration: 300.ms),

          const SizedBox(height: AppSpacing.xl),

          // ── Instruksi pilih (muncul hanya jika ada yang unpaid) ───────────
          if (unpaid.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: (isDark ? AppColorsDark.primary : AppColorsLight.primary).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (isDark ? AppColorsDark.primary : AppColorsLight.primary).withValues(alpha: 0.25),
                ),
              ),
              child: Row(children: [
                Icon(Icons.info_outline_rounded, size: 16,
                    color: isDark ? AppColorsDark.primary : AppColorsLight.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  'Ketuk kartu denda untuk memilih, lalu bayar sekaligus.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColorsDark.primary : AppColorsLight.primary,
                  ),
                )),
              ]),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: AppSpacing.lg),
          ],

          // ── Daftar denda belum bayar ──────────────────────────────────────
          if (unpaid.isNotEmpty) ...[
            _SectionHeader(label: 'Belum Dibayar', count: unpaid.length, isDark: isDark),
            const SizedBox(height: AppSpacing.sm),
            ...unpaid.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _FineCard(
                fine: e.value,
                isSelected: _selectedIds.contains(e.value.id),
                onTap: () => _toggle(e.value),
                formatCurrency: _formatCurrency,
                formatDate: _formatDate,
                isDark: isDark,
              ).animate().fadeIn(delay: Duration(milliseconds: 80 * e.key), duration: 250.ms)
                .slideY(begin: 0.05, end: 0, duration: 250.ms),
            )),
            const SizedBox(height: AppSpacing.lg),
          ],

          // ── Sudah lunas ───────────────────────────────────────────────────
          if (paid.isNotEmpty) ...[
            _SectionHeader(label: 'Sudah Lunas', count: paid.length, isDark: isDark),
            const SizedBox(height: AppSpacing.sm),
            ...paid.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _FineCard(
                fine: f,
                isSelected: false,
                onTap: null,
                formatCurrency: _formatCurrency,
                formatDate: _formatDate,
                isDark: isDark,
              ),
            )),
            const SizedBox(height: AppSpacing.lg),
          ],

          // ── Dimaafkan ─────────────────────────────────────────────────────
          if (waived.isNotEmpty) ...[
            _SectionHeader(label: 'Dimaafkan', count: waived.length, isDark: isDark),
            const SizedBox(height: AppSpacing.sm),
            ...waived.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _FineCard(
                fine: f,
                isSelected: false,
                onTap: null,
                formatCurrency: _formatCurrency,
                formatDate: _formatDate,
                isDark: isDark,
              ),
            )),
            const SizedBox(height: AppSpacing.lg),
          ],

          // ── Dibatalkan ────────────────────────────────────────────────────
          if (cancelled.isNotEmpty) ...[
            _SectionHeader(label: 'Dibatalkan', count: cancelled.length, isDark: isDark),
            const SizedBox(height: AppSpacing.sm),
            ...cancelled.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _FineCard(
                fine: f,
                isSelected: false,
                onTap: null,
                formatCurrency: _formatCurrency,
                formatDate: _formatDate,
                isDark: isDark,
              ),
            )),
          ],

        ]),
      ),

      // ── Pay bar floating ──────────────────────────────────────────────────
      if (_selectedIds.isNotEmpty)
        Positioned(
          left: 0, right: 0, bottom: 0,
          child: _PayBar(
            count: _selectedIds.length,
            total: _totalSelected(fines),
            isLoading: isProcessing,
            formatCurrency: _formatCurrency,
            onBayar: () => _bayar(context, state.bankAccounts, state.isMidtransEnabled),
            onClear: () => setState(() => _selectedIds.clear()),
          ).animate().slideY(begin: 1, end: 0, duration: 220.ms, curve: Curves.easeOut),
        ),
    ]);
  }

  Widget _buildEmpty() => const Center(
    child: EmptyStateWidget(
      icon: Icons.gavel_rounded,
      title: 'Tidak Ada Denda',
      subtitle: 'Kamu belum memiliki denda. Tetap patuhi peraturan kos!',
    ),
  );

  // ── Skeleton ──────────────────────────────────────────────────────────────────

  Widget _buildSkeleton(bool isDark) {
    final base = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final hi   = isDark ? Colors.grey[700]! : Colors.grey[100]!;
    Widget bone(double h, {double w = double.infinity, double r = 8}) => Shimmer.fromColors(
      baseColor: base, highlightColor: hi,
      child: Container(height: h, width: w,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r))),
    );
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: bone(80, r: AppSpacing.radiusMd)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: bone(80, r: AppSpacing.radiusMd)),
        ]),
        const SizedBox(height: AppSpacing.xl),
        bone(20, w: 120),
        const SizedBox(height: AppSpacing.sm),
        ...List.generate(3, (_) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: bone(100, r: AppSpacing.radiusMd),
        )),
      ]),
    );
  }

  // ── Snack helpers ─────────────────────────────────────────────────────────────

  void _snack(BuildContext ctx, String msg, {required bool isDark}) =>
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(msg)),
        ]),
        backgroundColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ));

  void _snackError(BuildContext ctx, String msg, {required bool isDark}) =>
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(msg)),
        ]),
        backgroundColor: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ));
}

// ══════════════════════════════════════════════════════════════════════════════
// Summary Tile
// ══════════════════════════════════════════════════════════════════════════════

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color color;
  final Color bg;
  final bool isDark;

  const _SummaryTile({
    required this.icon, required this.label, required this.value,
    required this.sub,  required this.color,  required this.bg,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColorsDark.surface : AppColorsLight.surface;
    final border  = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final textSec = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 11, color: textSec, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(sub, style: TextStyle(fontSize: 11, color: textSec)),
        ])),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Section Header
// ══════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final bool isDark;
  const _SectionHeader({required this.label, required this.count, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textSec = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    return Row(children: [
      Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      const SizedBox(width: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('$count', style: TextStyle(fontSize: 11, color: textSec, fontWeight: FontWeight.w600)),
      ),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Fine Card
// ══════════════════════════════════════════════════════════════════════════════

class _FineCard extends StatelessWidget {
  final FineEntity fine;
  final bool isSelected;
  final VoidCallback? onTap;
  final String Function(double) formatCurrency;
  final String Function(DateTime) formatDate;
  final bool isDark;

  const _FineCard({
    required this.fine,
    required this.isSelected,
    required this.onTap,
    required this.formatCurrency,
    required this.formatDate,
    required this.isDark,
  });

  Color _statusColor(bool isDark) => switch (fine.status) {
    'paid'      => isDark ? AppColorsDark.statusDone      : AppColorsLight.statusDone,
    'waived'    => isDark ? AppColorsDark.statusProcess   : AppColorsLight.statusProcess,
    'cancelled' => isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
    _           => isDark ? AppColorsDark.statusWaiting   : AppColorsLight.statusWaiting,
  };

  Color _statusBg(bool isDark) => switch (fine.status) {
    'paid'      => isDark ? AppColorsDark.statusDoneBg      : AppColorsLight.statusDoneBg,
    'waived'    => isDark ? AppColorsDark.statusProcessBg   : AppColorsLight.statusProcessBg,
    'cancelled' => isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg,
    _           => isDark ? AppColorsDark.statusWaitingBg   : AppColorsLight.statusWaitingBg,
  };

  String get _statusLabel => switch (fine.status) {
    'paid'      => 'Lunas',
    'waived'    => 'Dimaafkan',
    'cancelled' => 'Dibatalkan',
    _           => 'Belum Bayar',
  };

  IconData get _statusIcon => switch (fine.status) {
    'paid'      => Icons.check_circle_rounded,
    'waived'    => Icons.handshake_rounded,
    'cancelled' => Icons.cancel_rounded,
    _           => Icons.schedule_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final canSelect   = fine.isUnpaid && onTap != null;
    final surface     = isDark ? AppColorsDark.surface : AppColorsLight.surface;
    final border      = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final primary     = isDark ? AppColorsDark.primary : AppColorsLight.primary;
    final textSec     = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    final statusColor = _statusColor(isDark);
    final statusBg    = _statusBg(isDark);

    return GestureDetector(
      onTap: canSelect ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? primary : border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Header strip warna sesuai status ──────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMd)),
            ),
            child: Row(children: [
              Icon(_statusIcon, size: 15, color: statusColor),
              const SizedBox(width: 6),
              Text(_statusLabel,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor)),
              const Spacer(),
              if (fine.createdAt != null)
                Text(formatDate(fine.createdAt!),
                    style: TextStyle(fontSize: 11, color: statusColor.withValues(alpha: 0.8))),
            ]),
          ),

          // ── Body ──────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Checkbox (hanya untuk unpaid)
              if (canSelect)
                Padding(
                  padding: const EdgeInsets.only(right: 12, top: 2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? primary : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? primary : border,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                ),

              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Alasan
                Text(fine.reason,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),

                const SizedBox(height: 8),

                // Nominal
                Row(children: [
                  Icon(Icons.monetization_on_outlined, size: 14, color: statusColor),
                  const SizedBox(width: 4),
                  Text(formatCurrency(fine.amount),
                      style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800, color: statusColor)),
                ]),

                // Alasan dimaafkan (jika ada)
                if (fine.waiveReason != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColorsDark.statusProcessBg : AppColorsLight.statusProcessBg),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(children: [
                      Icon(Icons.chat_bubble_outline_rounded, size: 13,
                          color: isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess),
                      const SizedBox(width: 6),
                      Expanded(child: Text(
                        fine.waiveReason!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess,
                        ),
                      )),
                    ]),
                  ),
                ],

                // Tip bayar (hanya untuk unpaid)
                if (fine.isUnpaid) ...[
                  const SizedBox(height: 8),
                  Text('Ketuk untuk pilih denda ini',
                      style: TextStyle(fontSize: 11, color: textSec,
                          fontStyle: FontStyle.italic)),
                ],
              ])),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Pay Bar (floating bottom)
// ══════════════════════════════════════════════════════════════════════════════

class _PayBar extends StatelessWidget {
  final int count;
  final double total;
  final bool isLoading;
  final String Function(double) formatCurrency;
  final VoidCallback onBayar;
  final VoidCallback onClear;

  const _PayBar({
    required this.count,
    required this.total,
    required this.isLoading,
    required this.formatCurrency,
    required this.onBayar,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark  = AppTheme.isDark(context);
    final surface = isDark ? AppColorsDark.surface : AppColorsLight.surface;
    final border  = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final textSec = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(children: [
          // Info pilihan
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, children: [
            Text('$count denda dipilih',
                style: TextStyle(fontSize: 12, color: textSec)),
            Text(formatCurrency(total),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ])),

          // Batal pilih
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Batal pilih',
            style: IconButton.styleFrom(foregroundColor: textSec),
          ),
          const SizedBox(width: 8),

          // Tombol bayar
          FilledButton.icon(
            onPressed: isLoading ? null : onBayar,
            icon: isLoading
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.payment_rounded, size: 18),
            label: const Text('Bayar Sekarang'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Dialog Pembayaran
// ══════════════════════════════════════════════════════════════════════════════

class _PayFineDialog extends StatefulWidget {
  final List<BankAccountEntity> bankAccounts;
  final bool isMidtransEnabled;
  final double totalAmount;
  final String Function(double) formatCurrency;

  const _PayFineDialog({
    required this.bankAccounts,
    required this.isMidtransEnabled,
    required this.totalAmount,
    required this.formatCurrency,
  });

  @override
  State<_PayFineDialog> createState() => _PayFineDialogState();
}

class _PayFineDialogState extends State<_PayFineDialog> {
  String _method = 'manual';
  Uint8List? _proofBytes;
  String? _proofName;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _proofBytes = result.files.single.bytes;
        _proofName  = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark       = AppTheme.isDark(context);
    final surfaceColor = isDark ? AppColorsDark.surface : AppColorsLight.surface;
    final textSec      = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    final primary      = isDark ? AppColorsDark.primary : AppColorsLight.primary;
    final primaryLight = isDark ? AppColorsDark.primaryLight : AppColorsLight.primaryLight;
    final surfaceVar   = isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
    final borderLight  = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final waiting      = isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;
    final waitingBg    = isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg;

    final canPay = _method == 'midtrans' || (_method == 'manual' && _proofBytes != null);

    return Dialog(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [

          // Header
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: primaryLight, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.payment_rounded, color: primary, size: 20),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Bayar Denda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Text('Pilih metode pembayaran', style: TextStyle(fontSize: 12, color: textSec)),
            ]),
          ]),

          const SizedBox(height: AppSpacing.lg),

          // Total
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: waitingBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: waiting.withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              Icon(Icons.monetization_on_outlined, color: waiting, size: 18),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Total Pembayaran', style: TextStyle(fontSize: 11, color: waiting)),
                Text(widget.formatCurrency(widget.totalAmount),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: waiting)),
              ]),
            ]),
          ),

          const SizedBox(height: AppSpacing.lg),
          const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: AppSpacing.sm),

          // Metode: Transfer Manual
          _MethodTile(
            value: 'manual',
            groupValue: _method,
            label: 'Transfer Manual',
            sub: 'Upload bukti transfer ke rekening kos',
            icon: Icons.account_balance_outlined,
            primary: primary,
            primaryLight: primaryLight,
            surfaceVar: surfaceVar,
            borderLight: borderLight,
            textSec: textSec,
            onTap: () => setState(() => _method = 'manual'),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Metode: Midtrans
          if (widget.isMidtransEnabled) ...[
            _MethodTile(
              value: 'midtrans',
              groupValue: _method,
              label: 'Midtrans (Online)',
              sub: 'Transfer bank, QRIS, e-wallet, kartu kredit',
              icon: Icons.credit_card_rounded,
              primary: primary,
              primaryLight: primaryLight,
              surfaceVar: surfaceVar,
              borderLight: borderLight,
              textSec: textSec,
              onTap: () => setState(() => _method = 'midtrans'),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // Rekening tujuan & upload (manual)
          if (_method == 'manual') ...[
            if (widget.bankAccounts.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: surfaceVar,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: borderLight),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.account_balance_outlined, size: 14, color: textSec),
                    const SizedBox(width: 6),
                    Text('Rekening Tujuan',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSec)),
                  ]),
                  const SizedBox(height: 8),
                  ...widget.bankAccounts.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(children: [
                      const SizedBox(width: 20),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(b.bankName,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        Text('${b.accountNumber} · ${b.accountHolder}',
                            style: TextStyle(fontSize: 12, color: textSec)),
                      ])),
                    ]),
                  )),
                ]),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Upload bukti
            GestureDetector(
              onTap: _pickFile,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: _proofBytes != null
                      ? (isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg)
                      : surfaceVar,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: _proofBytes != null
                        ? (isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone).withValues(alpha: 0.5)
                        : borderLight,
                    style: _proofBytes != null ? BorderStyle.solid : BorderStyle.none,
                  ),
                ),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _proofBytes != null
                          ? (isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone).withValues(alpha: 0.15)
                          : primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _proofBytes != null ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                      size: 18,
                      color: _proofBytes != null
                          ? (isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone)
                          : primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      _proofBytes != null ? 'Bukti berhasil dipilih' : 'Upload Bukti Transfer',
                      style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13,
                        color: _proofBytes != null
                            ? (isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone)
                            : null,
                      ),
                    ),
                    if (_proofName != null)
                      Text(_proofName!,
                          style: TextStyle(fontSize: 11, color: textSec),
                          overflow: TextOverflow.ellipsis),
                    if (_proofBytes == null)
                      Text('Foto / screenshot bukti transfer (JPG, PNG)',
                          style: TextStyle(fontSize: 11, color: textSec)),
                  ])),
                  if (_proofBytes != null)
                    GestureDetector(
                      onTap: () => setState(() { _proofBytes = null; _proofName = null; }),
                      child: Icon(Icons.close, size: 16, color: textSec),
                    ),
                ]),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xxxl),

          // Actions
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            const SizedBox(width: AppSpacing.md),
            FilledButton.icon(
              icon: const Icon(Icons.payment_rounded, size: 16),
              label: const Text('Bayar'),
              onPressed: canPay
                  ? () => Navigator.pop(context, {
                      'payment_method': _method,
                      'payment_proof_bytes': _proofBytes,
                      'payment_proof_name': _proofName,
                    })
                  : null,
            ),
          ]),
        ]),
      ),
    );
  }
}

// ── Method tile ───────────────────────────────────────────────────────────────

class _MethodTile extends StatelessWidget {
  final String value;
  final String groupValue;
  final String label;
  final String sub;
  final IconData icon;
  final Color primary;
  final Color primaryLight;
  final Color surfaceVar;
  final Color borderLight;
  final Color textSec;
  final VoidCallback onTap;

  const _MethodTile({
    required this.value, required this.groupValue,
    required this.label, required this.sub, required this.icon,
    required this.primary, required this.primaryLight,
    required this.surfaceVar, required this.borderLight, required this.textSec,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = value == groupValue;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? primary.withValues(alpha: 0.06) : surfaceVar,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isActive ? primary.withValues(alpha: 0.4) : borderLight,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? primary.withValues(alpha: 0.12) : primaryLight.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: isActive ? primary : textSec),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 13,
              color: isActive ? primary : null,
            )),
            Text(sub, style: TextStyle(fontSize: 11, color: textSec)),
          ])),
          // Custom radio indicator (menghindari Radio.groupValue/onChanged yg deprecated di 3.32+)
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isActive ? primary : borderLight, width: 2),
              color: isActive ? primary : Colors.transparent,
            ),
            child: isActive
                ? Center(child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ))
                : null,
          ),
        ]),
      ),
    );
  }
}
