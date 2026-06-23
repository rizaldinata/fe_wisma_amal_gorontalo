import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/auto_route.gr.dart';
import '../../../domain/entity/finance/invoice_entity.dart';
import '../../../domain/entity/finance/payment_entity.dart';
import '../../../domain/entity/setting/bank_account_entity.dart';
import '../../bloc/member_finance/member_finance_bloc.dart';
import '../../bloc/member_finance/member_finance_event.dart';
import '../../bloc/member_finance/member_finance_state.dart';
import '../../widget/core/appbar/app_topbar.dart';
import '../../widget/core/card/summary_stat_card.dart';
import '../../widget/core/table/app_data_table.dart';
import '../../widget/core/wrapper/empty_state_widget.dart';

@RoutePage()
class MemberFinancePage extends StatefulWidget {
  const MemberFinancePage({super.key});

  @override
  State<MemberFinancePage> createState() => _MemberFinancePageState();
}

class _MemberFinancePageState extends State<MemberFinancePage> {
  late final MemberFinanceBloc _bloc;

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _bloc = serviceLocator.get<MemberFinanceBloc>()
      ..add(FetchMemberFinanceSummary())
      ..add(FetchMemberInvoices())
      ..add(FetchMemberPayments());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final doneColor = isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone;
    final cancelColor = isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled;

    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<MemberFinanceBloc, MemberFinanceState>(
        listener: (context, state) {
          if (state.status == MemberFinanceStatus.paymentSuccess) {
            if (state.snapToken != null) {
              _launchMidtrans(state.snapToken!);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(children: [
                    Icon(Icons.check_circle_outline, color: doneColor, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(child: Text('Bukti pembayaran berhasil diunggah. Menunggu verifikasi admin.')),
                  ]),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                  margin: const EdgeInsets.all(AppSpacing.lg),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          } else if (state.status == MemberFinanceStatus.extensionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(children: [
                  Icon(Icons.check_circle_outline, color: doneColor, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  const Text('Permintaan perpanjangan sewa berhasil dikirim'),
                ]),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                margin: const EdgeInsets.all(AppSpacing.lg),
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state.status == MemberFinanceStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(children: [
                  Icon(Icons.error_outline, color: cancelColor, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(state.errorMessage ?? 'Terjadi kesalahan')),
                ]),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                margin: const EdgeInsets.all(AppSpacing.lg),
              ),
            );
          }
        },
        child: Scaffold(
          body: Column(
            children: [
              AppTopBar(
                title: 'Keuangan Saya',
                breadcrumb: 'Keuangan / Ringkasan',
                action: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BlocBuilder<MemberFinanceBloc, MemberFinanceState>(
                      builder: (ctx, state) {
                        final leases = state.summary?.activeLeases ?? [];
                        if (leases.length != 1) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: ElevatedButton.icon(
                            onPressed: () => ctx.router.push(ExtendLeaseRoute(
                              leaseId: leases.first.id,
                              roomNumber: leases.first.roomNumber,
                              currentEndDate: leases.first.endDate,
                              isMidtransEnabled: state.isMidtransEnabled,
                            )),
                            icon: const Icon(Icons.add_circle_outline, size: 18),
                            label: const Text('Perpanjang Sewa'),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      onPressed: () {
                        _bloc.add(FetchMemberFinanceSummary());
                        _bloc.add(FetchMemberInvoices());
                        _bloc.add(FetchMemberPayments());
                      },
                      icon: const Icon(Icons.refresh_outlined),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<MemberFinanceBloc, MemberFinanceState>(
                  builder: (context, state) {
                    final isInitialLoading = state.status == MemberFinanceStatus.initial ||
                        (state.status == MemberFinanceStatus.loading && state.summary == null);

                    if (isInitialLoading) return _buildSkeleton(isDark);

                    if (state.status == MemberFinanceStatus.failure && state.summary == null) {
                      return EmptyStateWidget(
                        icon: Icons.error_outline,
                        title: 'Gagal Memuat Data',
                        subtitle: state.errorMessage ?? 'Terjadi kesalahan',
                        action: ElevatedButton(
                          onPressed: () {
                            _bloc.add(FetchMemberFinanceSummary());
                            _bloc.add(FetchMemberInvoices());
                            _bloc.add(FetchMemberPayments());
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      );
                    }

                    final now = DateTime.now();
                    final overdueInvoices = state.invoices
                        .where((i) => i.status.toLowerCase() == 'unpaid' && i.dueDate.isBefore(now))
                        .toList();
                    final overdueTotal = overdueInvoices.fold(0.0, (s, i) => s + i.amount);
                    final textSecondary = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

                    final isRefreshing = state.status == MemberFinanceStatus.loading && state.summary != null;
                    return Stack(children: [
                      SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state.summary?.residentName != null) ...[
                            Text(
                              'Halo, ${state.summary!.residentName}',
                              style: TextStyle(fontSize: 14, color: textSecondary),
                            ).animate().fadeIn(duration: 300.ms),
                            const SizedBox(height: AppSpacing.xxl),
                          ],

                          _buildSummaryCards(context, state, isDark)
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .slideY(begin: 0.1, end: 0, duration: 300.ms),

                          if (overdueInvoices.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.lg),
                            _buildOverdueAlert(overdueInvoices.length, overdueTotal, isDark)
                                .animate()
                                .fadeIn(delay: 80.ms, duration: 300.ms),
                          ],
                          const SizedBox(height: AppSpacing.xxxl),

                          _buildInvoiceList(context, state, isDark)
                              .animate()
                              .fadeIn(delay: 100.ms, duration: 300.ms),
                          const SizedBox(height: AppSpacing.xxl),

                          _buildPaymentHistory(context, state, isDark)
                              .animate()
                              .fadeIn(delay: 150.ms, duration: 300.ms),
                        ],
                      ),
                      ),
                      if (isRefreshing) const LinearProgressIndicator(),
                    ]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(bool isDark) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    shimmer(double height, {double? width, double radius = 8}) => Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          shimmer(16, width: 160),
          const SizedBox(height: AppSpacing.xxl),
          Row(children: List.generate(3, (i) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < 2 ? AppSpacing.lg : 0),
              child: shimmer(100, radius: AppSpacing.radiusLg),
            ),
          ))),
          const SizedBox(height: AppSpacing.xxxl),
          shimmer(220, radius: AppSpacing.radiusMd),
          const SizedBox(height: AppSpacing.xxl),
          shimmer(180, radius: AppSpacing.radiusMd),
        ],
      ),
    );
  }

  // ── Table with inline empty state ─────────────────────────────────────────

  Widget _buildTableWithEmptyState({
    required bool isEmpty,
    required List<DataColumn> columns,
    required List<DataRow> rows,
    required bool isDark,
    required IconData emptyIcon,
    required String emptyTitle,
    String emptySubtitle = '',
    double minRowHeight = 56,
  }) {
    if (!isEmpty) {
      return AppDataTable(columns: columns, rows: rows, dataRowMinHeight: minRowHeight);
    }

    final borderColor = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final surfaceColor = isDark ? AppColorsDark.surface : AppColorsLight.surface;
    final surfaceVariantColor = isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
    final textSecondaryColor = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    final textHintColor = isDark ? AppColorsDark.textHint : AppColorsLight.textHint;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 48,
            color: surfaceVariantColor,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: columns.map((col) {
                final label = col.label is Text
                    ? ((col.label as Text).data ?? '').toUpperCase()
                    : '';
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(label, style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textSecondaryColor,
                      letterSpacing: 0.5,
                    )),
                  ),
                );
              }).toList(),
            ),
          ),
          Divider(height: 1, thickness: 1, color: borderColor),
          Container(
            color: surfaceColor,
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(emptyIcon, size: 36, color: textHintColor),
                const SizedBox(height: 8),
                Text(emptyTitle, style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textSecondaryColor,
                )),
                if (emptySubtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(emptySubtitle, style: TextStyle(fontSize: 12, color: textHintColor)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary section ───────────────────────────────────────────────────────

  Widget _buildSummaryCards(BuildContext context, MemberFinanceState state, bool isDark) {
    final leases = state.summary?.activeLeases ?? [];
    final unpaid = state.summary?.totalUnpaid ?? 0.0;
    final unpaidCount = state.summary?.unpaidCount ?? 0;

    final billIconColor = unpaid > 0
        ? (isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting)
        : (isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone);
    final billIconBg = unpaid > 0
        ? (isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg)
        : (isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg);
    final billTrend = unpaidCount > 0
        ? '$unpaidCount tagihan belum dibayar'
        : 'Semua tagihan lunas';
    final billTrendColor = unpaid > 0
        ? (isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting)
        : (isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leases.isEmpty) ...[
          Expanded(
            child: SummaryStatCard(
              label: 'KAMAR AKTIF',
              value: '—',
              icon: Icons.home_outlined,
              iconColor: isDark ? AppColorsDark.textHint : AppColorsLight.textHint,
              iconBg: isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant,
              trend: 'Belum ada sewa berjalan',
              trendColor: isDark ? AppColorsDark.textHint : AppColorsLight.textHint,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
        ] else
          ...leases.expand(
            (lease) => [
              Expanded(child: _buildLeaseCard(context, lease, state)),
              const SizedBox(width: AppSpacing.lg),
            ],
          ),
        Expanded(
          child: SummaryStatCard(
            label: 'Tagihan Belum Dibayar',
            value: unpaid > 0 ? currencyFormat.format(unpaid) : 'Lunas',
            icon: Icons.account_balance_wallet_outlined,
            iconColor: billIconColor,
            iconBg: billIconBg,
            trend: billTrend,
            trendColor: billTrendColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaseCard(BuildContext context, dynamic lease, MemberFinanceState state) {
    final isDark = AppTheme.isDark(context);
    final now = DateTime.now();
    final endDate = lease.endDate as DateTime;
    final daysLeft = endDate.difference(now).inDays;
    final endDateStr = DateFormat('dd MMM yyyy').format(endDate);

    final Color iconColor;
    final Color iconBg;
    final Color trendColor;

    if (daysLeft < 0) {
      iconColor = isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled;
      iconBg = isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg;
      trendColor = iconColor;
    } else if (daysLeft <= 7) {
      iconColor = isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled;
      iconBg = isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg;
      trendColor = iconColor;
    } else if (daysLeft <= 30) {
      iconColor = isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;
      iconBg = isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg;
      trendColor = iconColor;
    } else {
      iconColor = isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone;
      iconBg = isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg;
      trendColor = iconColor;
    }

    final surfaceColor = isDark ? AppColorsDark.surface : AppColorsLight.surface;
    final borderColor = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final textPrimaryColor = isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
    final textSecondaryColor = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: borderColor),
        boxShadow: const [AppShadows.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: icon + kamar + perpanjang
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                  child: Icon(Icons.meeting_room_outlined, color: iconColor, size: 18),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Kamar ${lease.roomNumber}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimaryColor),
                ),
              ]),
              Row(mainAxisSize: MainAxisSize.min, children: [
                // Rental type badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: iconColor.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    _rentalTypeLabel(lease.rentalType as String),
                    style: TextStyle(fontSize: 10, color: iconColor, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Tooltip(
                  message: 'Perpanjang Sewa',
                  child: GestureDetector(
                    onTap: () => context.router.push(ExtendLeaseRoute(
                      leaseId: lease.id as int,
                      roomNumber: lease.roomNumber as String,
                      currentEndDate: lease.endDate as DateTime,
                      isMidtransEnabled: state.isMidtransEnabled,
                    )),
                    child: Icon(Icons.add_circle_outline, color: textSecondaryColor, size: 18),
                  ),
                ),
              ]),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Days remaining — ditampilkan besar
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                daysLeft < 0 ? '${-daysLeft}' : '$daysLeft',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: trendColor, height: 1),
              ),
              const SizedBox(width: 5),
              Text(
                daysLeft < 0 ? 'hari terlambat' : 'hari tersisa',
                style: TextStyle(fontSize: 13, color: trendColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Berakhir: $endDateStr',
            style: TextStyle(fontSize: 12, color: textSecondaryColor),
          ),
        ],
      ),
    );
  }

  String _rentalTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'monthly':  return 'Bulanan';
      case 'semester': return 'Per Semester';
      case 'annual':   return 'Tahunan';
      default:         return type;
    }
  }

  // ── Overdue alert ─────────────────────────────────────────────────────────

  Widget _buildOverdueAlert(int count, double total, bool isDark) {
    final color = isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled;
    final bg = isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg;
    final border = isDark ? AppColorsDark.statusCancelledBorder : AppColorsLight.statusCancelledBorder;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.warning_amber_rounded, color: color, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            '$count Tagihan Telah Jatuh Tempo',
            style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 14),
          ),
          Text(
            'Total: ${currencyFormat.format(total)} — Harap segera lakukan pembayaran',
            style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.85)),
          ),
        ])),
      ]),
    );
  }

  // ── Invoice & Payment tables ──────────────────────────────────────────────

  Widget _buildInvoiceList(BuildContext context, MemberFinanceState state, bool isDark) {
    final overdueColor = isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled;
    final waitingColor = isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;
    final payBtnColor = isDark ? AppColorsDark.primary : AppColorsLight.primary;
    final primaryColor = isDark ? AppColorsDark.primary : AppColorsLight.primary;
    final textPrimary = isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
    final textHint = isDark ? AppColorsDark.textHint : AppColorsLight.textHint;
    final now = DateTime.now();

    final failedPaymentInvoiceIds = state.payments
        .where((p) => p.status.toLowerCase() == 'failed')
        .map((p) => p.invoiceId)
        .toSet();

    final unpaidInvoices = state.invoices
        .where((i) =>
            i.status.toLowerCase() == 'unpaid' &&
            !failedPaymentInvoiceIds.contains(i.id))
        .toList();

    final pendingMidtransMap = Map.fromEntries(
      state.payments
          .where((p) {
            if (p.status.toLowerCase() != 'pending') return false;
            if (p.paymentMethod.toLowerCase() != 'midtrans') return false;
            final rawExpiry = p.paymentData?['expiry_time'] as String?;
            final expiryDt = rawExpiry != null ? DateTime.tryParse(rawExpiry) : null;
            return expiryDt == null || expiryDt.isAfter(now);
          })
          .map((p) => MapEntry(p.invoiceId, p)),
    );

    final pendingManualIds = state.payments
        .where((p) =>
            p.status.toLowerCase() == 'pending' &&
            p.paymentMethod.toLowerCase() == 'manual')
        .map((p) => p.invoiceId)
        .toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading
        Row(children: [
          Container(
            width: 3, height: 18,
            decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Text(
            unpaidInvoices.isEmpty
                ? 'Tagihan Belum Dibayar'
                : 'Tagihan Belum Dibayar (${unpaidInvoices.length})',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary),
          ),
        ]),
        const SizedBox(height: AppSpacing.md),

        _buildTableWithEmptyState(
          isEmpty: unpaidInvoices.isEmpty,
          isDark: isDark,
          emptyIcon: Icons.check_circle_outline,
          emptyTitle: 'Semua Tagihan Lunas',
          emptySubtitle: 'Tidak ada tagihan yang perlu dibayar saat ini.',
          minRowHeight: 64,
          columns: const [
            DataColumn(label: Text('No. Invoice / Kamar')),
            DataColumn(label: Text('Jenis')),
            DataColumn(label: Text('Jatuh Tempo')),
            DataColumn(label: Text('Jumlah')),
            DataColumn(label: Text('Aksi')),
          ],
          rows: unpaidInvoices.map((invoice) {
              final pendingMidtrans = pendingMidtransMap[invoice.id];
              final hasPendingManual = pendingManualIds.contains(invoice.id);
              final hasPendingPayment = pendingMidtrans != null || hasPendingManual;
              final isOverdue = invoice.dueDate.isBefore(now);
              final daysOverdue = now.difference(invoice.dueDate).inDays;
              final rawExpiry = pendingMidtrans?.paymentData?['expiry_time'] as String?;
              final expiryDt = rawExpiry != null ? DateTime.tryParse(rawExpiry) : null;

              return DataRow(cells: [
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(invoice.invoiceNumber, style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
                    Text(
                      invoice.roomNumber != null ? 'Kamar ${invoice.roomNumber}' : '—',
                      style: TextStyle(fontSize: 11, color: textHint),
                    ),
                  ],
                )),
                DataCell(_buildInvoiceTypeBadge(context, invoice.invoiceNumber, invoiceType: invoice.type)),
                DataCell(
                  pendingMidtrans != null && expiryDt != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.timer_outlined, size: 11, color: waitingColor),
                              const SizedBox(width: 3),
                              Text('Batas bayar', style: TextStyle(fontSize: 11, color: waitingColor)),
                            ]),
                            Text(
                              DateFormat('dd MMM yyyy, HH:mm').format(expiryDt),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: waitingColor),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('dd MMM yyyy').format(invoice.dueDate),
                              style: TextStyle(
                                color: isOverdue && !hasPendingPayment ? overdueColor : null,
                                fontWeight: isOverdue && !hasPendingPayment ? FontWeight.w600 : null,
                              ),
                            ),
                            Text(
                              DateFormat('HH:mm').format(invoice.dueDate),
                              style: TextStyle(
                                fontSize: 11,
                                color: isOverdue && !hasPendingPayment ? overdueColor : textHint,
                              ),
                            ),
                            if (isOverdue && !hasPendingPayment)
                              Text('Terlambat $daysOverdue hari', style: TextStyle(fontSize: 11, color: overdueColor)),
                          ],
                        ),
                ),
                DataCell(Text(currencyFormat.format(invoice.amount), style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(
                  pendingMidtrans != null
                      ? _buildResumeMidtransButton(context, invoice, pendingMidtrans)
                      : hasPendingManual
                          ? _buildPaymentStatusBadge(context, 'pending')
                          : ElevatedButton(
                              onPressed: () => context.router.push(InvoicePaymentRoute(
                                invoiceId: invoice.id,
                                invoiceNumber: invoice.invoiceNumber,
                                amount: invoice.amount,
                                roomNumber: invoice.roomNumber,
                                invoiceType: invoice.type,
                                dueDate: invoice.dueDate,
                              )),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: payBtnColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                                minimumSize: const Size(0, 36),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              child: const Text('Bayar'),
                            ),
                ),
              ]);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildPaymentHistory(BuildContext context, MemberFinanceState state, bool isDark) {
    final borderColor = isDark ? AppColorsDark.borderMedium : AppColorsLight.borderMedium;
    final textSecondary = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    final textPrimary = isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
    final textHint = isDark ? AppColorsDark.textHint : AppColorsLight.textHint;
    final primaryColor = isDark ? AppColorsDark.primary : AppColorsLight.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading
        Row(children: [
          Container(
            width: 3, height: 18,
            decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Text(
            state.payments.isEmpty
                ? 'Riwayat Pembayaran'
                : 'Riwayat Pembayaran (${state.payments.length})',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary),
          ),
        ]),
        const SizedBox(height: AppSpacing.md),

        _buildTableWithEmptyState(
          isEmpty: state.payments.isEmpty,
          isDark: isDark,
          emptyIcon: Icons.history_outlined,
          emptyTitle: 'Belum Ada Riwayat',
          emptySubtitle: 'Riwayat pembayaran Anda akan muncul di sini.',
          minRowHeight: 60,
          columns: const [
            DataColumn(label: Text('No. Invoice')),
            DataColumn(label: Text('Kamar')),
            DataColumn(label: Text('Jumlah')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Aksi')),
          ],
          rows: state.payments.map((payment) {
              final dateStr = DateFormat('dd MMM yyyy').format(DateTime.parse(payment.paymentDate));
              final methodLabel = payment.paymentMethod == 'midtrans' ? 'Midtrans' : 'Transfer Manual';

              return DataRow(cells: [
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(payment.invoiceNumber ?? '—', style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
                    Text('$dateStr · $methodLabel', style: TextStyle(fontSize: 11, color: textHint)),
                  ],
                )),
                DataCell(Text(payment.roomNumber ?? '—')),
                DataCell(Text(currencyFormat.format(payment.amount), style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(_buildPaymentStatusBadge(context, payment.status)),
                DataCell(OutlinedButton(
                  onPressed: () => _showPaymentDetailDialog(context, payment),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                    side: BorderSide(color: borderColor),
                    minimumSize: const Size(0, 36),
                    foregroundColor: textSecondary,
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                  child: const Text('Detail'),
                )),
              ]);
            }).toList(),
          ),
      ],
    );
  }

  // ── Badges & action buttons ───────────────────────────────────────────────

  Widget _buildResumeMidtransButton(
    BuildContext context,
    InvoiceEntity invoice,
    PaymentEntity pendingMidtrans,
  ) {
    final isDark = AppTheme.isDark(context);
    final bg = isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess;

    return ElevatedButton.icon(
      onPressed: () => context.router.push(ExtendLeasePaymentRoute(
        invoiceId: invoice.id,
        roomNumber: invoice.roomNumber ?? '—',
        amount: invoice.amount,
        snapToken: pendingMidtrans.snapToken,
        paymentData: pendingMidtrans.paymentData,
      )),
      icon: const Icon(Icons.arrow_forward_rounded, size: 14),
      label: const Text('Lanjutkan'),
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        minimumSize: const Size(0, 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildInvoiceTypeBadge(BuildContext context, String invoiceNumber, {String? invoiceType}) {
    final isDark = AppTheme.isDark(context);
    final bool isExtension = invoiceNumber.startsWith('EXT') || invoiceType == 'extension';
    final bool isDp = invoiceType == 'dp' || invoiceNumber.startsWith('DP-');
    final bool isPelunasan = invoiceType == 'pelunasan' || invoiceNumber.startsWith('PLN-');

    final Color color, bg, border;
    final String label;
    final IconData icon;

    if (isDp) {
      color = Colors.orange.shade700;
      bg = Colors.orange.shade50;
      border = Colors.orange.shade200;
      label = 'Uang Muka (DP)';
      icon = Icons.payments_outlined;
    } else if (isPelunasan) {
      color = Colors.teal.shade700;
      bg = Colors.teal.shade50;
      border = Colors.teal.shade200;
      label = 'Pelunasan';
      icon = Icons.task_alt_outlined;
    } else if (isExtension) {
      color = isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess;
      bg = isDark ? AppColorsDark.statusProcessBg : AppColorsLight.statusProcessBg;
      border = isDark ? AppColorsDark.statusProcessBorder : AppColorsLight.statusProcessBorder;
      label = 'Perpanjang';
      icon = Icons.update_rounded;
    } else {
      color = isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone;
      bg = isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg;
      border = isDark ? AppColorsDark.statusDoneBorder : AppColorsLight.statusDoneBorder;
      label = 'Sewa Bulanan';
      icon = Icons.home_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  static String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'verified':   return 'BERHASIL';
      case 'pending':    return 'MENUNGGU';
      case 'rejected':   return 'DITOLAK';
      case 'failed':     return 'GAGAL';
      case 'refunded':   return 'DIKEMBALIKAN';
      default:           return status.toUpperCase();
    }
  }

  Widget _buildPaymentStatusBadge(BuildContext context, String status) {
    final isDark = AppTheme.isDark(context);
    final Color color;
    final Color bg;
    final Color border;

    switch (status.toLowerCase()) {
      case 'verified':
      case 'paid':
        color = isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone;
        bg = isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg;
        border = isDark ? AppColorsDark.statusDoneBorder : AppColorsLight.statusDoneBorder;
        break;
      case 'pending':
        color = isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;
        bg = isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg;
        border = isDark ? AppColorsDark.statusWaitingBorder : AppColorsLight.statusWaitingBorder;
        break;
      case 'rejected':
      case 'failed':
        color = isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled;
        bg = isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg;
        border = isDark ? AppColorsDark.statusCancelledBorder : AppColorsLight.statusCancelledBorder;
        break;
      case 'refunded':
        color = isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess;
        bg = isDark ? AppColorsDark.statusProcessBg : AppColorsLight.statusProcessBg;
        border = isDark ? AppColorsDark.statusProcessBorder : AppColorsLight.statusProcessBorder;
        break;
      default:
        color = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
        bg = isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
        border = isDark ? AppColorsDark.borderMedium : AppColorsLight.borderMedium;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(_statusLabel(status), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showPaymentDetailDialog(BuildContext context, dynamic payment) {
    final isDark = AppTheme.isDark(context);
    final status = (payment.status as String).toLowerCase();

    Color resolveColor(String s) {
      switch (s) {
        case 'verified':
        case 'paid':
          return isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone;
        case 'pending':
          return isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;
        case 'rejected':
        case 'failed':
          return isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled;
        case 'refunded':
          return isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess;
        default:
          return isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
      }
    }

    Color resolveBg(String s) {
      switch (s) {
        case 'verified':
        case 'paid':
          return isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg;
        case 'pending':
          return isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg;
        case 'rejected':
        case 'failed':
          return isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg;
        case 'refunded':
          return isDark ? AppColorsDark.statusProcessBg : AppColorsLight.statusProcessBg;
        default:
          return isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
      }
    }

    IconData resolveIcon(String s) {
      switch (s) {
        case 'verified':
        case 'paid':
          return Icons.check_circle_outline;
        case 'pending':
          return Icons.hourglass_top;
        case 'rejected':
        case 'failed':
          return Icons.cancel_outlined;
        case 'refunded':
          return Icons.replay;
        default:
          return Icons.info_outline;
      }
    }

    final surfaceVariant = isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
    final borderColor = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final cancelBorderColor = isDark ? AppColorsDark.statusCancelledBorder : AppColorsLight.statusCancelledBorder;
    final cancelBgColor = isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg;
    final textHint = isDark ? AppColorsDark.textHint : AppColorsLight.textHint;
    final textSecondary = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    final textPrimary = isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
    final processColor = isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess;
    final doneColor = isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone;

    String formatDateTime(String d) {
      final dt = DateTime.tryParse(d);
      return dt != null ? DateFormat('dd MMM yyyy, HH:mm').format(dt) : '-';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: resolveBg(status),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(resolveIcon(status), color: resolveColor(status), size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Pembayaran',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
                  ),
                  Text(
                    _statusLabel(payment.status as String),
                    style: TextStyle(fontSize: 12, color: resolveColor(status), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('No. Invoice', style: TextStyle(fontSize: 11, color: textHint)),
                                Text(
                                  payment.invoiceNumber ?? '-',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
                                ),
                                if (payment.roomNumber != null) ...[
                                  const SizedBox(height: 2),
                                  Text('Kamar ${payment.roomNumber}', style: TextStyle(fontSize: 12, color: textSecondary)),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Nominal', style: TextStyle(fontSize: 11, color: textHint)),
                              Text(
                                currencyFormat.format(payment.amount),
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
                              ),
                              Text(
                                payment.paymentMethod == 'midtrans' ? 'Midtrans / QRIS' : 'Transfer Manual',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: payment.paymentMethod == 'midtrans' ? processColor : doneColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Divider(height: 20, color: borderColor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tanggal Pembayaran', style: TextStyle(fontSize: 11, color: textHint)),
                              Text(formatDateTime(payment.paymentDate), style: TextStyle(fontSize: 12, color: textPrimary)),
                            ],
                          ),
                          if (payment.updatedAt != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Tanggal Diproses', style: TextStyle(fontSize: 11, color: textHint)),
                                Text(formatDateTime(payment.updatedAt!), style: TextStyle(fontSize: 12, color: textPrimary)),
                              ],
                            ),
                        ],
                      ),
                      if (payment.transactionId != null) ...[
                        Divider(height: 16, color: borderColor),
                        Row(
                          children: [
                            Icon(Icons.tag, size: 13, color: textHint),
                            const SizedBox(width: 4),
                            Text(
                              'ID Transaksi: ${payment.transactionId}',
                              style: TextStyle(fontSize: 12, color: textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                if (payment.adminNotes != null && (payment.adminNotes as String).isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text('Catatan Admin', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary)),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: status == 'rejected' ? cancelBgColor : surfaceVariant,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: status == 'rejected' ? cancelBorderColor : borderColor),
                    ),
                    child: Text(payment.adminNotes as String, style: TextStyle(fontSize: 13, color: textPrimary)),
                  ),
                ],

                const SizedBox(height: AppSpacing.md),
                Text('Bukti Transfer:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary)),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: borderColor),
                  ),
                  child: (payment.paymentProofUrl != null && (payment.paymentProofUrl as String).isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          child: Image.network(
                            payment.paymentProofUrl as String,
                            fit: BoxFit.contain,
                            loadingBuilder: (_, child, progress) =>
                                progress == null ? child : const Center(child: CircularProgressIndicator()),
                            errorBuilder: (_, __, ___) => Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.broken_image_outlined, size: 40, color: textHint),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text('Gambar tidak dapat dimuat', style: TextStyle(color: textSecondary)),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image_not_supported_outlined, size: 40, color: textHint),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                payment.paymentMethod == 'midtrans'
                                    ? 'Pembayaran dilakukan via Midtrans'
                                    : 'Tidak ada bukti transfer',
                                style: TextStyle(color: textSecondary),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

// ── Manual Payment Dialog dengan countdown timer ──────────────────────────────

class _ManualPaymentDialog extends StatefulWidget {
  const _ManualPaymentDialog({
    required this.invoiceId,
    required this.bankAccounts,
    required this.isDark,
    required this.bloc,
  });

  final int invoiceId;
  final List<BankAccountEntity> bankAccounts;
  final bool isDark;
  final MemberFinanceBloc bloc;

  @override
  State<_ManualPaymentDialog> createState() => _ManualPaymentDialogState();
}

class _ManualPaymentDialogState extends State<_ManualPaymentDialog> {
  PlatformFile? _selectedFile;
  Timer? _timer;
  int _remainingSeconds = 900;
  bool _timerExpired = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timerExpired = true;
          t.cancel();
        }
      });
      if (_timerExpired) Navigator.of(context).pop();
    });
  }

  String get _timerLabel {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color get _timerColor {
    if (_remainingSeconds <= 60) return Colors.red;
    if (_remainingSeconds <= 120) return Colors.orange;
    return widget.isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final surfaceVariant = isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
    final borderColor    = isDark ? AppColorsDark.borderLight    : AppColorsLight.borderLight;
    final doneColor      = isDark ? AppColorsDark.statusDone     : AppColorsLight.statusDone;
    final textPrimary    = isDark ? AppColorsDark.textPrimary    : AppColorsLight.textPrimary;
    final textSecondary  = isDark ? AppColorsDark.textSecondary  : AppColorsLight.textSecondary;
    final textHint       = isDark ? AppColorsDark.textHint       : AppColorsLight.textHint;

    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      title: Row(
        children: [
          Expanded(child: const Text('Upload Bukti Transfer')),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _timerColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _timerColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, size: 14, color: _timerColor),
                const SizedBox(width: 4),
                Text(
                  _timerLabel,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _timerColor),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.bankAccounts.isEmpty)
              Text(
                'Hubungi pengelola wisma untuk informasi rekening transfer.',
                style: TextStyle(fontSize: 13, color: textSecondary),
              )
            else ...[
              Text(
                'Silakan transfer ke salah satu rekening berikut:',
                style: TextStyle(fontSize: 13, color: textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              ...widget.bankAccounts.map((account) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: surfaceVariant,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(account.bankName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textPrimary)),
                      const SizedBox(height: 4),
                      Text(account.accountNumber,
                          style: TextStyle(
                              fontSize: 18,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                              color: textPrimary)),
                      Text('a.n. ${account.accountHolder}',
                          style:
                              TextStyle(fontSize: 12, color: textHint)),
                      if (account.paymentInstructions != null &&
                          account.paymentInstructions!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(account.paymentInstructions!,
                            style: TextStyle(
                                fontSize: 12, color: textSecondary)),
                      ],
                    ],
                  ),
                ),
              )),
            ],
            const SizedBox(height: AppSpacing.sm),
            if (_selectedFile != null) ...[
              Text(
                'File terpilih: ${_selectedFile!.name}',
                style: TextStyle(fontSize: 12, color: doneColor),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            ElevatedButton.icon(
              onPressed: _timerExpired
                  ? null
                  : () async {
                      final result = await FilePicker.platform.pickFiles(
                          type: FileType.image, withData: true);
                      if (result != null) {
                        setState(() => _selectedFile = result.files.first);
                      }
                    },
              icon: const Icon(Icons.image),
              label: Text(_selectedFile == null
                  ? 'Pilih Gambar Bukti'
                  : 'Ganti Gambar'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: (_selectedFile == null || _timerExpired)
              ? null
              : () {
                  widget.bloc.add(PayInvoiceEvent(
                    widget.invoiceId,
                    'manual',
                    paymentProofBytes: _selectedFile!.bytes,
                    paymentProofName: _selectedFile!.name,
                  ));
                  Navigator.pop(context);
                },
          child: const Text('Kirim Bukti'),
        ),
      ],
    );
  }
}
