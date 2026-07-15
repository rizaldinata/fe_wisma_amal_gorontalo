import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/domain/entity/resident/resident_entity.dart';
import 'package:frontend/presentation/bloc/resident/resident_bloc.dart';
import 'package:frontend/presentation/widget/core/appbar/app_topbar.dart';
import 'package:frontend/presentation/widget/core/appbar/search_and_filter_bar.dart';
import 'package:frontend/presentation/widget/core/card/summary_stat_card.dart';
import 'package:frontend/presentation/widget/core/chip/status_badge.dart';
import 'package:frontend/presentation/widget/core/table/app_data_table.dart';
import 'package:frontend/presentation/widget/core/wrapper/empty_state_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart'; // Catatan: Sepertinya ada typo 'botton', sesuaikan dengan path asli Anda jika error
import 'form/resident_detail_form.dart';

@RoutePage()
class ResidentPage extends StatelessWidget {
  const ResidentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<ResidentBloc>(),
      child: const _ResidentView(),
    );
  }
}

class _ResidentView extends StatefulWidget {
  const _ResidentView();

  @override
  State<_ResidentView> createState() => _ResidentViewState();
}

class _ResidentViewState extends State<_ResidentView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _tableScrollController = ScrollController();
  Timer? _debounce;

  String _selectedStatus = 'Semua';
  String _selectedPayment = 'Semua';
  int _currentPage = 1;
  int _perPage = 10;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<ResidentItem> _residentCache = <ResidentItem>[];

  @override
  void initState() {
    super.initState();
    _tableScrollController.addListener(_onTableScroll);
    _fetchResidents();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _tableScrollController.dispose();
    super.dispose();
  }

  void _fetchResidents({bool isRefresh = false}) {
    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _residentCache.clear();
        _hasMore = true;
      });
    }

    final query = _searchController.text.trim();

    context.read<ResidentBloc>().add(
      FetchResidents(
        page: _currentPage,
        perPage: _perPage,
        search: query.isEmpty ? null : query,
        status: _selectedStatus == 'Semua' ? null : _selectedStatus,
        payment: _selectedPayment == 'Semua' ? null : _selectedPayment,
      ),
    );
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchResidents(isRefresh: true);
    });
  }

  void _onTableScroll() {
    if (!_hasMore || _isLoadingMore) return;
    final position = _tableScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 120) {
      setState(() {
        _isLoadingMore = true;
        _currentPage += 1;
      });
      _fetchResidents();
    }
  }

  void _showResidentDetail(BuildContext context, ResidentItem resident) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ResidentDetailForm(residentId: resident.id),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: isDark
          ? AppColorsDark.background
          : AppColorsLight.background,
      body: Column(
        children: [
          AppTopBar(
            title: 'Daftar Penghuni',
            breadcrumb: 'Manajemen / Daftar Penghuni',
          ),
          Expanded(
            child: BlocConsumer<ResidentBloc, ResidentState>(
              listener: (context, state) {
                if (state is ResidentLoaded) {
                  setState(() {
                    if (_currentPage == 1) {
                      _residentCache = List<ResidentItem>.from(
                        state.data.residents,
                      );
                    } else {
                      _residentCache.addAll(state.data.residents);
                    }
                    _hasMore =
                        state.data.pagination.currentPage <
                        state.data.pagination.lastPage;
                    _isLoadingMore = false;
                  });
                }

                if (state is ResidentError) {
                  setState(() {
                    _isLoadingMore = false;
                  });
                }
              },
              builder: (context, state) {
                if (state is ResidentLoading && _residentCache.isEmpty) {
                  return _buildSkeleton(isDark);
                }

                if (state is ResidentError && _residentCache.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'Gagal Memuat Data',
                    subtitle: state.message,
                    action: BasicButton(
                      onPressed: () => _fetchResidents(isRefresh: true),
                      label: 'Coba Lagi',
                    ),
                  );
                }

                if (state is ResidentLoaded || _residentCache.isNotEmpty) {
                  final data = state is ResidentLoaded ? state.data : null;
                  final stats = data?.stats;

                  final activeCount = stats?.penghuniAktif ?? 0;
                  final pendingCount = stats?.kontrakPending ?? 0;
                  final availableRooms = stats?.kamarTersedia ?? 0;

                  final query = _searchController.text.trim().toLowerCase();

                  final residentRows = _residentCache.where((row) {
                    final matchesSearch =
                        query.isEmpty ||
                        row.nama.toLowerCase().contains(query) ||
                        row.kamar.toLowerCase().contains(query) ||
                        row.kontak.toLowerCase().contains(query);

                    final matchesStatus =
                        _selectedStatus == 'Semua' ||
                        row.status == _selectedStatus;
                    final matchesPayment =
                        _selectedPayment == 'Semua' ||
                        row.detailBayar == _selectedPayment;

                    return matchesSearch && matchesStatus && matchesPayment;
                  }).toList();

                  return SingleChildScrollView(
                    controller: _tableScrollController,
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Cards
                        Row(
                              children: [
                                Expanded(
                                  child: SummaryStatCard(
                                    label: 'Penghuni Aktif',
                                    value: activeCount.toString(),
                                    icon: Icons.person_outline,
                                    iconColor: isDark
                                        ? AppColorsDark.statusDone
                                        : AppColorsLight.statusDone,
                                    iconBg: isDark
                                        ? AppColorsDark.statusDoneBg
                                        : AppColorsLight.statusDoneBg,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: SummaryStatCard(
                                    label: 'Kontrak Pending',
                                    value: pendingCount.toString(),
                                    icon: Icons.note_add_outlined,
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
                                    label: 'Kamar Tersedia',
                                    value: availableRooms.toString(),
                                    icon: Icons.bedroom_parent_outlined,
                                    iconColor: isDark
                                        ? AppColorsDark.primary
                                        : AppColorsLight.primary,
                                    iconBg: isDark
                                        ? AppColorsDark.primaryLight
                                        : AppColorsLight.primaryLight,
                                  ),
                                ),
                              ],
                            )
                            .animate()
                            .fadeIn(duration: 300.ms)
                            .slideY(begin: 0.1, end: 0, duration: 300.ms),

                        const SizedBox(height: AppSpacing.xxxl),

                        // Search & Filter
                        SearchAndFilterBar(
                          searchController: _searchController,
                          searchHint: 'Cari nama, kamar, kontak...',
                          onSearchChanged: _onSearchChanged,
                          dropdownFilter: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildDropdownFilter(
                                isDark: isDark,
                                value: _selectedStatus,
                                items: const ['Semua', 'Aktif', 'Pending'],
                                icon: Icons.filter_list,
                                label: 'Status',
                                onChanged: (value) {
                                  setState(() => _selectedStatus = value);
                                  _fetchResidents(isRefresh: true);
                                },
                              ),
                              const SizedBox(width: AppSpacing.md),
                              _buildDropdownFilter(
                                isDark: isDark,
                                value: _selectedPayment,
                                items: const ['Semua', 'Lunas', 'Belum Lunas'],
                                icon: Icons.receipt_long_outlined,
                                label: 'Detil Bayar',
                                onChanged: (value) {
                                  setState(() => _selectedPayment = value);
                                  _fetchResidents(isRefresh: true);
                                },
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

                        const SizedBox(height: AppSpacing.lg),

                        // Table or Empty State
                        if (_residentCache.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: AppSpacing.xxxl),
                            child: EmptyStateWidget(
                              icon: Icons.group_off_outlined,
                              title: 'Tidak Ada Penghuni',
                              subtitle:
                                  'Belum ada data penghuni yang terdaftar atau sesuai filter saat ini.',
                            ),
                          )
                        else
                          AppDataTable(
                            columns: const [
                              DataColumn(label: Text('NO')),
                              DataColumn(label: Text('NAMA')),
                              DataColumn(label: Text('KAMAR')),
                              DataColumn(label: Text('KONTAK')),
                              DataColumn(label: Text('DETIL BAYAR')),
                              DataColumn(label: Text('STATUS')),
                              DataColumn(label: Text('KONTRAK')),
                            ],
                            rows: _residentCache.asMap().entries.map((entry) {
                              final index = entry.key + 1;
                              final row = entry.value;
                              return DataRow(
                                cells: [
                                  DataCell(Text('$index')),
                                  DataCell(
                                    Text(
                                      row.nama,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(row.kamar)),
                                  DataCell(Text(row.kontak)),
                                  DataCell(
                                    StatusBadge(status: row.detailBayar),
                                  ),
                                  DataCell(StatusBadge(status: row.status)),
                                  DataCell(
                                    TextButton(
                                      onPressed: () =>
                                          _showResidentDetail(context, row),
                                      child: const Text('Detail'),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

                        // Loading more indicator
                        if (_isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required bool isDark,
    required String value,
    required List<String> items,
    required IconData icon,
    required String label,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark
              ? AppColorsDark.borderLight
              : AppColorsLight.borderLight,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          icon: const Icon(Icons.arrow_drop_down, size: 18),
        ),
      ),
    );
  }

  Widget _buildSkeleton(bool isDark) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        children: [
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < 2 ? AppSpacing.lg : 0,
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
