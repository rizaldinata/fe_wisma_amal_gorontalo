import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/maintenance_list/maintenance_list_bloc.dart';
import 'package:frontend/presentation/bloc/maintenance_list/maintenance_list_event.dart';
import 'package:frontend/presentation/bloc/maintenance_list/maintenance_list_state.dart';
import 'package:frontend/presentation/pages/maintenance_report/widgets/maintenance_request_card.dart';

@RoutePage()
class MaintenanceReportListPage extends StatelessWidget {
  const MaintenanceReportListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<MaintenanceListBloc>(),
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
    final isAdmin = authState.isLoggedIn &&
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final isAdmin = authState.isLoggedIn &&
        (authState.userInfo?.roles.any(
              (r) => r == 'admin' || r == 'super-admin',
            ) ??
            false);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Laporan Kerusakan',
                        style: theme.textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAdmin
                            ? 'Semua laporan kerusakan dari penghuni'
                            : 'Laporan kerusakan yang Anda buat',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isAdmin)
                  ElevatedButton.icon(
                    onPressed: () async {
                      await context.router.push(
                        const MaintenanceCreateReportRoute(),
                      );
                      // Reload on return
                      if (mounted) _loadReports();
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Buat Laporan'),
                  ),
                if (isAdmin)
                  IconButton(
                    tooltip: 'Muat Ulang',
                    onPressed: _loadReports,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Status Filter Chips ──
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _statusFilters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _statusFilters[index];
                  final isSelected = _filterStatus == filter;
                  return FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => _filterStatus = filter),
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // ── Content ──
            Expanded(
              child: BlocBuilder<MaintenanceListBloc, MaintenanceListState>(
                builder: (context, state) {
                  if (state is MaintenanceListLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is MaintenanceListError) {
                    return _ErrorView(
                      message: state.message,
                      onRetry: _loadReports,
                    );
                  }

                  if (state is MaintenanceListLoaded) {
                    var items = state.requests;

                    // Apply filter
                    if (_filterStatus != 'Semua') {
                      items = items.where((r) {
                        return _statusLabel(r.status) == _filterStatus;
                      }).toList();
                    }

                    if (items.isEmpty) {
                      return _EmptyView(
                        isAdmin: isAdmin,
                        hasFilter: _filterStatus != 'Semua',
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async => _loadReports(),
                      child: ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final request = items[index];
                          return MaintenanceRequestCard(
                            request: request,
                            onTap: () async {
                              await context.router.push(
                                MaintenanceReportDetailRoute(id: request.id),
                              );
                              if (mounted) _loadReports();
                            },
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
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
          Icon(
            Icons.error_outline_rounded,
            size: 56,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat data',
            style: Theme.of(context).textTheme.titleMedium,
          ),
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

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.isAdmin, required this.hasFilter});
  final bool isAdmin;
  final bool hasFilter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.4,
            child: Icon(
              hasFilter
                  ? Icons.filter_list_off_rounded
                  : Icons.handyman_outlined,
              size: 72,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilter
                ? 'Tidak ada laporan untuk filter ini'
                : isAdmin
                    ? 'Belum ada laporan kerusakan'
                    : 'Anda belum membuat laporan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (!hasFilter && !isAdmin) ...[
            const SizedBox(height: 8),
            Text(
              'Ketuk tombol "Buat Laporan" untuk melaporkan kerusakan',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
