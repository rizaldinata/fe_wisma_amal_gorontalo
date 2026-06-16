import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/domain/entity/maintenance_request_entity.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/maintenance_list/maintenance_list_bloc.dart';
import 'package:frontend/presentation/bloc/maintenance_list/maintenance_list_event.dart';
import 'package:frontend/presentation/bloc/maintenance_list/maintenance_list_state.dart';
import 'package:frontend/presentation/pages/maintenance_report/widgets/maintenance_request_card.dart';
import 'package:frontend/presentation/widget/core/appbar/app_topbar.dart';
import 'package:frontend/presentation/widget/core/appbar/search_and_filter_bar.dart';
import 'package:frontend/presentation/widget/core/card/summary_stat_card.dart';
import 'package:frontend/presentation/widget/core/chip/status_badge.dart';
import 'package:frontend/presentation/widget/core/table/app_data_table.dart';
import 'package:frontend/presentation/widget/core/wrapper/empty_state_widget.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';

@RoutePage()
class MaintenanceReportListPage extends StatelessWidget {
  const MaintenanceReportListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: serviceLocator<MaintenanceListBloc>(),
      child: const _MaintenanceReportListView(),
    );
  }
}

class _MaintenanceReportListView extends StatefulWidget {
  const _MaintenanceReportListView();

  @override
  State<_MaintenanceReportListView> createState() =>
      _MaintenanceReportListViewState();
}

class _MaintenanceReportListViewState
    extends State<_MaintenanceReportListView> {
  String _filterStatus = 'Semua';
  String _searchQuery = '';

  final List<String> _statusFilters = [
    'Semua',
    'Menunggu',
    'Dalam Proses',
    'Selesai',
    'Dibatalkan',
  ];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    final authState = context.read<AuthBloc>().state;
    final isAdmin =
        authState.isLoggedIn &&
        (authState.userInfo?.roles.any(
              (r) => r == 'admin' || r == 'super-admin',
            ) ??
            false);

    if (isAdmin) {
      context.read<MaintenanceListBloc>().add(FetchAllMaintenanceRequests());
    } else {
      context.read<MaintenanceListBloc>().add(FetchMyMaintenanceRequests());
    }
  }

  String _statusLabel(dynamic status) {
    switch (status.value) {
      case 'pending':
        return 'Menunggu';
      case 'in_progress':
        return 'Dalam Proses';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Semua';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final authState = context.watch<AuthBloc>().state;
    final isAdmin =
        authState.isLoggedIn &&
        (authState.userInfo?.roles.any(
              (r) => r == 'admin' || r == 'super-admin',
            ) ??
            false);

    return Scaffold(
      backgroundColor: isDark ? AppColorsDark.background : AppColorsLight.background,
      body: Column(
        children: [
          AppTopBar(
            title: 'Laporan Kerusakan',
            breadcrumb: 'Operasional / Laporan Kerusakan',
            action: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isAdmin)
                  IconButton(
                    tooltip: 'Muat Ulang',
                    onPressed: _loadReports,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                if (!isAdmin)
                  ElevatedButton.icon(
                    onPressed: () async {
                      await context.router.push(
                        const MaintenanceCreateReportRoute(),
                      );
                      if (mounted) _loadReports();
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Buat Laporan'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<MaintenanceListBloc, MaintenanceListState>(
              builder: (context, state) {
                if (state is MaintenanceListLoading) {
                  return _buildSkeleton(isDark, isAdmin);
                }

                if (state is MaintenanceListError) {
                  return EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'Gagal Memuat Data',
                    subtitle: state.message,
                    action: ElevatedButton(
                      onPressed: _loadReports,
                      child: const Text('Coba Lagi'),
                    ),
                  );
                }

                if (state is MaintenanceListLoaded) {
                  final allItems = state.requests;

                  // Filtering
                  var filteredItems = allItems.where((item) {
                    final matchQuery =
                        item.title.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ||
                        item.residentName.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        );
                    final matchStatus =
                        _filterStatus == 'Semua' ||
                        _statusLabel(item.status) == _filterStatus;
                    return matchQuery && matchStatus;
                  }).toList();

                  if (isAdmin) {
                    return _buildAdminView(filteredItems, allItems, isDark);
                  } else {
                    return _buildResidentView(filteredItems, allItems, isDark);
                  }
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminView(
    List<MaintenanceRequestEntity> filteredItems,
    List<MaintenanceRequestEntity> allItems,
    bool isDark,
  ) {
    final totalLaporan = allItems.length;
    final menunggu = allItems.where((r) => r.status.value == 'pending').length;
    final proses = allItems
        .where((r) => r.status.value == 'in_progress')
        .length;
    final selesai = allItems.where((r) => r.status.value == 'completed').length;

    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
                children: [
                  Expanded(
                    child: SummaryStatCard(
                      label: 'Total Laporan',
                      value: totalLaporan.toString(),
                      icon: Icons.report_problem_outlined,
                      iconColor: isDark
                          ? AppColorsDark.primary
                          : AppColorsLight.primary,
                      iconBg: isDark
                          ? AppColorsDark.primaryLight
                          : AppColorsLight.primaryLight,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: SummaryStatCard(
                      label: 'Menunggu',
                      value: menunggu.toString(),
                      icon: Icons.hourglass_empty_rounded,
                      iconColor: isDark
                          ? AppColorsDark.statusWaiting
                          : AppColorsLight.statusWaiting,
                      iconBg: isDark
                          ? AppColorsDark.statusWaitingBg
                          : AppColorsLight.statusWaitingBg,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: SummaryStatCard(
                      label: 'Dalam Proses',
                      value: proses.toString(),
                      icon: Icons.sync_rounded,
                      iconColor: isDark
                          ? AppColorsDark.statusProcess
                          : AppColorsLight.statusProcess,
                      iconBg: isDark
                          ? AppColorsDark.statusProcessBg
                          : AppColorsLight.statusProcessBg,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: SummaryStatCard(
                      label: 'Selesai',
                      value: selesai.toString(),
                      icon: Icons.check_circle_outline,
                      iconColor: isDark
                          ? AppColorsDark.statusDone
                          : AppColorsLight.statusDone,
                      iconBg: isDark
                          ? AppColorsDark.statusDoneBg
                          : AppColorsLight.statusDoneBg,
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1, end: 0, duration: 300.ms),

          const SizedBox(height: AppSpacing.xxxl),

          // Search & Segmented Filter
          SearchAndFilterBar(
            searchHint: 'Cari judul laporan atau nama...',
            onSearchChanged: (val) => setState(() => _searchQuery = val),
            dropdownFilter: _buildSegmentedFilter(isDark),
            onSortPressed: () {},
            sortLabel: 'Urutkan: Terbaru',
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

          const SizedBox(height: AppSpacing.lg),

          // Table
          if (filteredItems.isEmpty)
            EmptyStateWidget(
              icon: Icons.assignment_outlined,
              title: 'Tidak ada laporan',
              subtitle: 'Coba ubah filter atau kata kunci pencarian Anda.',
            ).animate().fadeIn()
          else
            AppDataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('JUDUL')),
                DataColumn(label: Text('PELAPOR')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('TANGGAL')),
                DataColumn(label: Text('')),
              ],
              rows: filteredItems
                  .map(
                    (item) => DataRow(
                      cells: [
                        DataCell(
                          Text(
                            '#${item.id.toString().length > 8 ? item.id.toString().substring(0, 8).toUpperCase() : item.id.toString().toUpperCase()}',
                            style: TextStyle(
                              color: isDark
                                  ? AppColorsDark.textSecondary
                                  : AppColorsLight.textSecondary,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        DataCell(Text(item.residentName)),
                        DataCell(
                          StatusBadge(status: _statusLabel(item.status)),
                        ),
                        DataCell(
                          Text(
                            dateFormat.format(
                              item.reportedAt ?? item.createdAt,
                            ),
                          ),
                        ),
                        DataCell(
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () async {
                                await context.router.push(
                                  MaintenanceReportDetailRoute(id: item.id),
                                );
                                if (mounted) _loadReports();
                              },
                              child: const Text('Detail'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
        ],
      ),
    );
  }

  Widget _buildResidentView(
    List<MaintenanceRequestEntity> filteredItems,
    List<MaintenanceRequestEntity> allItems,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented Filter
          _buildSegmentedFilter(isDark),
          const SizedBox(height: AppSpacing.xl),

          if (filteredItems.isEmpty)
            Expanded(
              child: EmptyStateWidget(
                icon: Icons.handyman_outlined,
                title: 'Belum ada laporan',
                subtitle:
                    'Anda belum membuat laporan kerusakan dengan status ini.',
                action: ElevatedButton.icon(
                  onPressed: () async {
                    await context.router.push(
                      const MaintenanceCreateReportRoute(),
                    );
                    if (mounted) _loadReports();
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Buat Laporan Baru'),
                ),
              ).animate().fadeIn(),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _loadReports(),
                child: ListView.separated(
                  itemCount: filteredItems.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final request = filteredItems[index];
                    return MaintenanceRequestCard(
                      request: request,
                      onTap: () async {
                        await context.router.push(
                          MaintenanceReportDetailRoute(id: request.id),
                        );
                        if (mounted) _loadReports();
                      },
                    ).animate().fadeIn(
                      delay: Duration(milliseconds: 50 * index),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSegmentedFilter(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColorsDark.surfaceVariant
            : AppColorsLight.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _statusFilters.map((filter) {
          final isSelected = _filterStatus == filter;
          return GestureDetector(
            onTap: () => setState(() => _filterStatus = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColorsDark.surface : AppColorsLight.surface)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? (isDark
                            ? AppColorsDark.textPrimary
                            : AppColorsLight.textPrimary)
                      : (isDark
                            ? AppColorsDark.textSecondary
                            : AppColorsLight.textSecondary),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSkeleton(bool isDark, bool isAdmin) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAdmin) ...[
            Row(
              children: List.generate(
                4,
                (index) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < 3 ? AppSpacing.lg : 0,
                    ),
                    child: Shimmer.fromColors(
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],

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
