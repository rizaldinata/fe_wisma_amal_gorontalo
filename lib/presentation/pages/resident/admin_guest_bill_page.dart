import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/domain/entity/guest/guest_bill_entity.dart';
import 'package:frontend/presentation/bloc/guest/guest_bill_bloc.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/dialog/app_dialog.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';
import 'package:intl/intl.dart';

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

  String _formatDateTime(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: const Color(0xFFF3F4F6),
        body: BlocBuilder<GuestBillBloc, GuestBillState>(
          builder: (context, state) {
            if (state is GuestBillLoading && _cache.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFA794F2)),
              );
            }
            if (state is GuestBillError && _cache.isEmpty) {
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
                    'Tagihan Tamu',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(
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
                      padding:
                          const EdgeInsets.fromLTRB(34, 22, 34, 24),
                      child: Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
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
                                  'Tagihan',
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
                                SizedBox(
                                  width: 220,
                                  height: 36,
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: _onSearch,
                                    decoration: InputDecoration(
                                      hintText: 'Cari penghuni, tamu...',
                                      hintStyle: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF9CA3AF)),
                                      prefixIcon: const Icon(Icons.search,
                                          size: 18,
                                          color: Color(0xFF9CA3AF)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 12),
                                      filled: true,
                                      fillColor: const Color(0xFFF3F4F6),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  _HeaderCell(label: 'NO', flex: 1),
                                  _HeaderCell(
                                      label: 'NO TAGIHAN', flex: 3),
                                  _HeaderCell(label: 'PENGHUNI', flex: 3),
                                  _HeaderCell(label: 'NAMA TAMU', flex: 3),
                                  _HeaderCell(label: 'JUMLAH', flex: 2),
                                  _HeaderCell(label: 'METODE', flex: 2),
                                  _HeaderCell(label: 'STATUS', flex: 2),
                                  _HeaderCell(label: 'AKSI', flex: 2),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: _cache.isEmpty &&
                                      state is! GuestBillLoading
                                  ? Center(
                                      child: Text(
                                        'Tidak ada tagihan tamu',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color:
                                                  const Color(0xFF6B7280),
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    )
                                  : Scrollbar(
                                      controller: _scrollController,
                                      thumbVisibility: true,
                                      child: ListView.separated(
                                        controller: _scrollController,
                                        itemCount: _cache.length +
                                            (_isLoadingMore ? 1 : 0),
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 8),
                                        itemBuilder: (context, index) {
                                          if (index >= _cache.length) {
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
                                          final item = _cache[index];
                                          return _BillRow(
                                            no: index + 1,
                                            item: item,
                                            currency: _currency,
                                            onVerify: item.canVerify
                                                ? () =>
                                                    _showVerifyDialog(item)
                                                : null,
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
      ),
    );
  }
}

// ─── Row Tagihan ──────────────────────────────────────────────────────────────

class _BillRow extends StatelessWidget {
  const _BillRow({
    required this.no,
    required this.item,
    required this.currency,
    this.onVerify,
  });

  final int no;
  final AdminGuestBillItem item;
  final NumberFormat currency;
  final VoidCallback? onVerify;

  Color _statusColor(String status) {
    switch (status) {
      case 'unpaid':
        return Colors.grey;
      case 'pending':
        return Colors.orange;
      case 'verified':
      case 'paid':
        return Colors.green;
      case 'rejected':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BodyCell(value: no.toString(), flex: 1),
        _BodyCell(value: item.billNumber, flex: 3),
        _BodyCell(value: item.penghuni, flex: 3),
        _BodyCell(value: item.guestName, flex: 3),
        _BodyCell(value: currency.format(item.amount), flex: 2),
        _BodyCell(value: item.paymentMethod ?? '-', flex: 2),
        Expanded(
          flex: 2,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _statusColor(item.status).withAlpha(30),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.statusLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _statusColor(item.status),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: onVerify != null
              ? TextButton(
                  onPressed: onVerify,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(60, 28),
                  ),
                  child: const Text('Verifikasi',
                      style: TextStyle(fontSize: 12)),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ─── Private Widgets ──────────────────────────────────────────────────────────

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
