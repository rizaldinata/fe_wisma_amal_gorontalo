import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../domain/entity/finance/expense_entity.dart';
import '../../bloc/expense/expense_bloc.dart';
import '../../bloc/expense/expense_event.dart';
import '../../bloc/expense/expense_state.dart';
import '../../widget/core/card/basic_card.dart';

@RoutePage()
class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({Key? key}) : super(key: key);

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  late ExpenseBloc _expenseBloc;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Pagination
  int _currentPage = 1;
  static const int _perPage = 10;

  @override
  void initState() {
    super.initState();
    _expenseBloc = serviceLocator.get<ExpenseBloc>();
    _expenseBloc.add(FetchExpenses());
  }

  @override
  void dispose() {
    _expenseBloc.close();
    _searchController.dispose();
    super.dispose();
  }

  String formatRupiah(double amount) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);

  List<ExpenseEntity> _filtered(List<ExpenseEntity> all) {
    if (_searchQuery.isEmpty) return all;
    final q = _searchQuery.toLowerCase();
    return all.where((e) =>
        e.title.toLowerCase().contains(q) ||
        (e.notes?.toLowerCase().contains(q) ?? false)).toList();
  }

  List<ExpenseEntity> _paged(List<ExpenseEntity> filtered) {
    final start = (_currentPage - 1) * _perPage;
    if (start >= filtered.length) return [];
    final end = (start + _perPage).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  int _totalPages(int count) => (count / _perPage).ceil().clamp(1, 9999);

  void _goToPage(int page, int totalPages) {
    if (page < 1 || page > totalPages) return;
    setState(() => _currentPage = page);
  }

  IconData _icon(String title) {
    final t = title.toLowerCase();
    if (t.contains('listrik') || t.contains('pln')) return Icons.bolt;
    if (t.contains('air') || t.contains('pdam')) return Icons.water_drop;
    if (t.contains('internet') || t.contains('wifi')) return Icons.wifi;
    if (t.contains('ac') || t.contains('servis')) return Icons.ac_unit;
    if (t.contains('kebersihan') || t.contains('cuci') || t.contains('sapu')) return Icons.cleaning_services;
    if (t.contains('petugas') || t.contains('upah')) return Icons.person;
    if (t.contains('cat') || t.contains('perbaikan') || t.contains('renovasi')) return Icons.build;
    if (t.contains('keamanan')) return Icons.security;
    if (t.contains('atk') || t.contains('administrasi')) return Icons.description;
    if (t.contains('snack') || t.contains('konsumsi')) return Icons.restaurant;
    if (t.contains('transportasi') || t.contains('parkir')) return Icons.directions_car;
    return Icons.receipt_long;
  }

  Color _color(String title) {
    final t = title.toLowerCase();
    if (t.contains('listrik') || t.contains('pln')) return Colors.amber.shade700;
    if (t.contains('air') || t.contains('pdam')) return Colors.blue.shade600;
    if (t.contains('internet') || t.contains('wifi')) return Colors.indigo.shade500;
    if (t.contains('ac') || t.contains('servis')) return Colors.cyan.shade600;
    if (t.contains('kebersihan') || t.contains('cuci')) return Colors.green.shade600;
    if (t.contains('petugas') || t.contains('upah')) return Colors.purple.shade500;
    if (t.contains('keamanan')) return Colors.deepOrange.shade600;
    return Colors.red.shade600;
  }

  void _showDialog([ExpenseEntity? expense]) {
    final titleCtrl = TextEditingController(text: expense?.title ?? '');
    final amountCtrl = TextEditingController(
        text: expense != null ? expense.amount.toStringAsFixed(0) : '');
    final notesCtrl = TextEditingController(text: expense?.notes ?? '');
    DateTime pickedDate = expense != null
        ? (DateTime.tryParse(expense.date) ?? DateTime.now())
        : DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.trending_down, color: Colors.red.shade700, size: 20),
            ),
            const SizedBox(width: 12),
            Text(expense == null ? 'Tambah Pengeluaran' : 'Ubah Pengeluaran',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                _field(titleCtrl, 'Nama / Judul Pengeluaran', 'Contoh: Tagihan Listrik PLN', Icons.label_outline),
                const SizedBox(height: 12),
                _field(amountCtrl, 'Nominal (Rp)', 'Contoh: 850000', Icons.payments_outlined, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                const Text('Tanggal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
                const SizedBox(height: 6),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    final p = await showDatePicker(context: ctx, initialDate: pickedDate, firstDate: DateTime(2023), lastDate: DateTime.now());
                    if (p != null) setS(() => pickedDate = p);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [
                      Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 10),
                      Text(DateFormat('dd MMMM yyyy', 'id_ID').format(pickedDate), style: const TextStyle(fontSize: 14)),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                _field(notesCtrl, 'Keterangan (opsional)', 'Deskripsi singkat...', Icons.notes_outlined, maxLines: 3),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              onPressed: () {
                final e = ExpenseEntity(
                  id: expense?.id ?? 0,
                  title: titleCtrl.text.trim(),
                  amount: double.tryParse(amountCtrl.text) ?? 0,
                  date: pickedDate.toIso8601String(),
                  notes: notesCtrl.text.trim(),
                );
                _expenseBloc.add(expense == null ? CreateExpense(e) : UpdateExpense(e));
                Navigator.pop(ctx);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      }),
    );
  }

  Widget _field(TextEditingController c, String label, String hint, IconData icon,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
      const SizedBox(height: 6),
      TextField(
        controller: c, keyboardType: keyboardType, maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint, prefixIcon: Icon(icon, size: 18),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        ),
      ),
    ]);
  }

  void _confirmDelete(ExpenseEntity e) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.red.shade600), const SizedBox(width: 8), const Text('Hapus Pengeluaran?')]),
        content: Text('Data "${e.title}" akan dihapus secara permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            onPressed: () { _expenseBloc.add(DeleteExpense(e.id)); Navigator.pop(ctx); },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _expenseBloc,
      child: BlocListener<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
            _expenseBloc.add(FetchExpenses());
          } else if (state is ExpenseError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── Header ──────────────────────────────────────────────
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Manajemen Pengeluaran', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('Kelola dan pantau seluruh pengeluaran operasional wisma.', style: TextStyle(fontSize: 14, color: Colors.grey)),
                ]),
                FilledButton.icon(
                  onPressed: () => _showDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Pengeluaran'),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ]),
              const SizedBox(height: 28),

              BlocBuilder<ExpenseBloc, ExpenseState>(
                buildWhen: (p, c) => c is ExpenseLoading || c is ExpenseLoaded || c is ExpenseInitial,
                builder: (context, state) {
                  if (state is ExpenseLoading) {
                    return const Center(child: Padding(padding: EdgeInsets.all(60), child: CircularProgressIndicator()));
                  }
                  if (state is! ExpenseLoaded) return const SizedBox.shrink();

                  final all = state.expenses;
                  final filtered = _filtered(all);
                  final totalPages = _totalPages(filtered.length);
                  final page = _currentPage.clamp(1, totalPages);
                  final paged = _paged(filtered);

                  final totalAll = all.fold(0.0, (s, e) => s + e.amount);
                  final totalThisMonth = all.where((e) {
                    final d = DateTime.tryParse(e.date);
                    if (d == null) return false;
                    final now = DateTime.now();
                    return d.month == now.month && d.year == now.year;
                  }).fold(0.0, (s, e) => s + e.amount);

                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // ── Summary cards ────────────────────────────────
                    Row(children: [
                      Expanded(child: _summaryCard('Total Pengeluaran', formatRupiah(totalAll), '${all.length} transaksi', Icons.account_balance_wallet_outlined, Colors.red.shade700, Colors.red.shade50)),
                      const SizedBox(width: 16),
                      Expanded(child: _summaryCard('Bulan Ini', formatRupiah(totalThisMonth), DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now()), Icons.calendar_month_outlined, Colors.orange.shade700, Colors.orange.shade50)),
                      const SizedBox(width: 16),
                      Expanded(child: _summaryCard('Entri Manual', '${all.where((e) => !e.isIntegrated).length} Transaksi', 'Dicatat oleh admin', Icons.edit_note, Colors.blue.shade700, Colors.blue.shade50)),
                      const SizedBox(width: 16),
                      Expanded(child: _summaryCard('Dari Sistem', '${all.where((e) => e.isIntegrated).length} Transaksi', 'Otomatis (inventaris)', Icons.auto_awesome, Colors.purple.shade700, Colors.purple.shade50)),
                    ]),
                    const SizedBox(height: 24),

                    // ── Search bar ───────────────────────────────────
                    BasicCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() { _searchQuery = v; _currentPage = 1; }),
                          decoration: InputDecoration(
                            hintText: 'Cari berdasarkan nama atau keterangan...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchController.clear(); setState(() { _searchQuery = ''; _currentPage = 1; }); })
                                : null,
                            border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Table ────────────────────────────────────────
                    BasicCard(
                      child: Column(children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          child: Row(children: [
                            Expanded(flex: 4, child: Text('Nama Pengeluaran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade600, letterSpacing: 0.5))),
                            Expanded(flex: 2, child: Text('Tanggal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade600, letterSpacing: 0.5))),
                            Expanded(flex: 2, child: Text('Nominal', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade600, letterSpacing: 0.5))),
                            const SizedBox(width: 88),
                          ]),
                        ),
                        const Divider(height: 1),

                        // Rows
                        if (paged.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(child: Column(children: [
                              Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(_searchQuery.isEmpty ? 'Belum ada data pengeluaran.' : 'Tidak ada hasil untuk "$_searchQuery".', style: TextStyle(color: Colors.grey.shade500)),
                            ])),
                          )
                        else
                          ...paged.asMap().entries.map((entry) {
                            final i = entry.key;
                            final e = entry.value;
                            final date = DateTime.tryParse(e.date);
                            final isLast = i == paged.length - 1;
                            return Column(children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                  // Nama
                                  Expanded(flex: 4, child: Row(children: [
                                    Container(
                                      width: 38, height: 38,
                                      decoration: BoxDecoration(color: _color(e.title).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                      child: Icon(_icon(e.title), color: _color(e.title), size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                      if (e.notes != null && e.notes!.isNotEmpty)
                                        Text(e.notes!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                    ])),
                                    if (e.isIntegrated)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue.shade200)),
                                        child: Text('Sistem', style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
                                      ),
                                  ])),

                                  // Tanggal
                                  Expanded(flex: 2, child: Text(date != null ? DateFormat('dd MMM yyyy', 'id_ID').format(date) : '-', style: TextStyle(fontSize: 13, color: Colors.grey.shade700))),

                                  // Nominal
                                  Expanded(flex: 2, child: Text(formatRupiah(e.amount), textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red.shade700))),

                                  // Aksi
                                  SizedBox(
                                    width: 88,
                                    child: Row(mainAxisAlignment: MainAxisAlignment.end, children: e.isIntegrated
                                      ? [Tooltip(message: 'Dikelola otomatis oleh sistem', child: Icon(Icons.lock_outline, size: 16, color: Colors.grey.shade400))]
                                      : [
                                          IconButton(icon: Icon(Icons.edit_outlined, size: 18, color: Colors.blue.shade600), tooltip: 'Ubah', splashRadius: 20, onPressed: () => _showDialog(e)),
                                          IconButton(icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade600), tooltip: 'Hapus', splashRadius: 20, onPressed: () => _confirmDelete(e)),
                                        ]),
                                  ),
                                ]),
                              ),
                              if (!isLast) const Divider(height: 1, indent: 70),
                            ]);
                          }),

                        const Divider(height: 1),

                        // ── Footer: total + pagination ───────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          child: Row(children: [
                            Text(
                              'Menampilkan ${paged.length} dari ${filtered.length} data',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                            ),
                            const Spacer(),
                            // Pagination controls
                            _PaginationBar(
                              currentPage: page,
                              totalPages: totalPages,
                              onPageChanged: (p) => setState(() => _currentPage = p),
                            ),
                          ]),
                        ),
                      ]),
                    ),
                  ]);
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, String sub, IconData icon, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: textColor.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 10),
        Text(value, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(sub, style: TextStyle(color: textColor.withOpacity(0.65), fontSize: 11)),
      ]),
    );
  }
}

// ── Pagination Bar Widget ──────────────────────────────────────────────────────
class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const _PaginationBar({required this.currentPage, required this.totalPages, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    // Tentukan halaman yang ditampilkan (maks 5 tombol)
    final pages = <int>[];
    int start = (currentPage - 2).clamp(1, totalPages);
    int end = (start + 4).clamp(1, totalPages);
    start = (end - 4).clamp(1, totalPages);
    for (int i = start; i <= end; i++) pages.add(i);

    return Row(mainAxisSize: MainAxisSize.min, children: [
      // Prev
      _NavBtn(icon: Icons.chevron_left, enabled: currentPage > 1, onTap: () => onPageChanged(currentPage - 1)),
      const SizedBox(width: 4),

      // First page jika perlu
      if (start > 1) ...[
        _PageBtn(page: 1, isActive: false, onTap: () => onPageChanged(1)),
        if (start > 2) Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text('...', style: TextStyle(color: Colors.grey.shade500))),
      ],

      // Halaman tengah
      ...pages.map((p) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: _PageBtn(page: p, isActive: p == currentPage, onTap: () => onPageChanged(p)),
      )),

      // Last page jika perlu
      if (end < totalPages) ...[
        if (end < totalPages - 1) Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text('...', style: TextStyle(color: Colors.grey.shade500))),
        _PageBtn(page: totalPages, isActive: false, onTap: () => onPageChanged(totalPages)),
      ],

      const SizedBox(width: 4),
      // Next
      _NavBtn(icon: Icons.chevron_right, enabled: currentPage < totalPages, onTap: () => onPageChanged(currentPage + 1)),
    ]);
  }
}

class _PageBtn extends StatelessWidget {
  final int page;
  final bool isActive;
  final VoidCallback onTap;
  const _PageBtn({required this.page, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive ? null : Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: Text('$page', style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.white : Colors.grey.shade700, fontSize: 13)),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: enabled ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
    );
  }
}