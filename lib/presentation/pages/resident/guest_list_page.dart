import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/domain/entity/guest/guest_entity.dart';
import 'package:frontend/presentation/bloc/guest/guest_bloc.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';

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
        },
        builder: (context, state) {
          if (state is GuestLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFA794F2)),
            );
          }

          if (state is GuestError) {
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
