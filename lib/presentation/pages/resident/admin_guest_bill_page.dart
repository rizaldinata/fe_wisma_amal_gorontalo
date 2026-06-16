import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/domain/entity/guest/guest_bill_entity.dart';
import 'package:frontend/presentation/bloc/guest/guest_bill_bloc.dart';
import 'package:frontend/presentation/widget/core/appbar/app_topbar.dart';
import 'package:frontend/presentation/widget/core/appbar/search_and_filter_bar.dart';
import 'package:frontend/presentation/widget/core/chip/status_badge.dart';
import 'package:frontend/presentation/widget/core/table/app_data_table.dart';
import 'package:frontend/presentation/widget/core/wrapper/empty_state_widget.dart';
import 'package:frontend/presentation/widget/core/dialog/app_dialog.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

@RoutePage()
class AdminGuestBillPage extends StatelessWidget {
  const AdminGuestBillPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<GuestBillBloc>(),
      child: const _AdminGuestBillView(),
    );
  }
}

class _AdminGuestBillView extends StatefulWidget {
  const _AdminGuestBillView();

  @override
  State<_AdminGuestBillView> createState() => _AdminGuestBillViewState();
}

class _AdminGuestBillViewState extends State<_AdminGuestBillView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 1;
  static const int _perPage = 10;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<AdminGuestBillItem> _cache = [];
  Timer? _debounce;

  final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

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
    context.read<GuestBillBloc>().add(FetchAdminGuestBills(
          page: _currentPage,
          perPage: _perPage,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
        ));
  }

  void _onSearch(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _currentPage = 1;
        _cache = [];
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

  void _reload() {
    setState(() {
      _currentPage = 1;
      _cache = [];
      _hasMore = true;
    });
    _fetch();
  }

  Future<void> _showVerifyDialog(AdminGuestBillItem item) async {
    final notesController = TextEditingController();
    bool? isApproved;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Verifikasi Pembayaran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tagihan: ${item.billNumber}'),
              Text('Penghuni: ${item.penghuni}'),
              Text('Tamu: ${item.guestName}'),
              Text('Jumlah: ${_currency.format(item.amount)}'),
              const SizedBox(height: 16),
              if (item.paymentProofUrl != null)
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Lihat Bukti Bayar'),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Catatan Admin (opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setDialogState(() => isApproved = false);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text('Tolak',
                          style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setDialogState(() => isApproved = true);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Terima'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (isApproved != null && mounted) {
      context.read<GuestBillBloc>().add(VerifyAdminGuestBill(
            billId: item.id,
            isApproved: isApproved!,
            adminNotes:
                notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return BlocListener<GuestBillBloc, GuestBillState>(
      listener: (context, state) {
        if (state is GuestBillLoaded) {
          setState(() {
            if (_currentPage == 1) {
              _cache = List.from(state.data.bills);
            } else {
              _cache.addAll(state.data.bills);
            }
            _hasMore = state.data.pagination.currentPage <
                state.data.pagination.lastPage;
            _isLoadingMore = false;
          });
        }
        if (state is GuestBillError) {
          setState(() => _isLoadingMore = false);
        }
        if (state is GuestBillVerifySuccess) {
          AppSnackbar.showSuccess(state.message);
          _reload();
        }
        if (state is GuestBillVerifyError) {
          AppSnackbar.showError(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColorsDark.background : AppColorsLight.background,
        body: Column(
          children: [
            AppTopBar(
              title: 'Tagihan Tamu',
              breadcrumb: 'Manajemen / Tagihan Tamu',
            ),
            Expanded(
              child: BlocBuilder<GuestBillBloc, GuestBillState>(
                builder: (context, state) {
                  if (state is GuestBillLoading && _cache.isEmpty) {
                    return _buildSkeleton(isDark);
                  }
                  if (state is GuestBillError && _cache.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.error_outline,
                      title: 'Gagal Memuat Data',
                      subtitle: state.message,
                      action: ElevatedButton(
                        onPressed: _reload,
                        child: const Text('Coba Lagi'),
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
                          searchHint: 'Cari penghuni, tamu...',
                          onSearchChanged: _onSearch,
                        ).animate().fadeIn(duration: 300.ms),

                        const SizedBox(height: AppSpacing.lg),

                        // Table
                        AppDataTable(
                          columns: const [
                            DataColumn(label: Text('NO')),
                            DataColumn(label: Text('NO TAGIHAN')),
                            DataColumn(label: Text('PENGHUNI')),
                            DataColumn(label: Text('NAMA TAMU')),
                            DataColumn(label: Text('JUMLAH')),
                            DataColumn(label: Text('METODE')),
                            DataColumn(label: Text('STATUS')),
                            DataColumn(label: Text('AKSI')),
                          ],
                          rows: [
                            DataRow(
                              cells: [
                                const DataCell(Text('1')),
                                const DataCell(Text('INV-20231012-01')),
                                const DataCell(Text('Ahmad', style: TextStyle(fontWeight: FontWeight.w600))),
                                const DataCell(Text('Rina')),
                                const DataCell(Text('Rp 150.000', style: TextStyle(fontWeight: FontWeight.w600))),
                                const DataCell(Text('Transfer Bank')),
                                const DataCell(StatusBadge(status: 'Lunas')),
                                DataCell(
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text('Detail', style: TextStyle(fontSize: 12)),
                                  ),
                                ),
                              ],
                            ),
                            DataRow(
                              cells: [
                                const DataCell(Text('2')),
                                const DataCell(Text('INV-20231013-02')),
                                const DataCell(Text('Budi', style: TextStyle(fontWeight: FontWeight.w600))),
                                const DataCell(Text('Siti')),
                                const DataCell(Text('Rp 200.000', style: TextStyle(fontWeight: FontWeight.w600))),
                                const DataCell(Text('-')),
                                const DataCell(StatusBadge(status: 'Belum Lunas')),
                                DataCell(
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text('Detail', style: TextStyle(fontSize: 12)),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
