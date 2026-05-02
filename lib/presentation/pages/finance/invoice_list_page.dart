import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../domain/entity/finance/invoice_entity.dart';
import '../../bloc/invoice/invoice_bloc.dart';
import '../../bloc/invoice/invoice_event.dart';
import '../../bloc/invoice/invoice_state.dart';
import '../../widget/core/card/basic_card.dart';

@RoutePage()
class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({super.key});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  late InvoiceBloc _bloc;

  String _searchQuery = '';
  String _statusFilter = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  // Pagination
  int _currentPage = 1;
  static const int _perPage = 10;

  static const _statusOptions = ['Semua', 'Belum Bayar', 'Lunas', 'Dibatalkan'];

  @override
  void initState() {
    super.initState();
    _bloc = serviceLocator.get<InvoiceBloc>();
    _bloc.add(FetchInvoices());
  }

  @override
  void dispose() {
    _bloc.close();
    _searchController.dispose();
    super.dispose();
  }

  String formatRupiah(double amount) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);

  String formatDate(DateTime d) =>
      DateFormat('dd MMM yyyy', 'id_ID').format(d);

  // Mapping status API → label ramah admin
  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'paid':      return 'Lunas';
      case 'unpaid':    return 'Belum Bayar';
      case 'cancelled': return 'Dibatalkan';
      default:          return status.toUpperCase();
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':      return Colors.green.shade600;
      case 'unpaid':    return Colors.orange.shade700;
      case 'cancelled': return Colors.grey.shade500;
      default:          return Colors.blue.shade600;
    }
  }

  Color _statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'paid':      return Colors.green.shade50;
      case 'unpaid':    return Colors.orange.shade50;
      case 'cancelled': return Colors.grey.shade100;
      default:          return Colors.blue.shade50;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':      return Icons.check_circle_outline;
      case 'unpaid':    return Icons.schedule;
      case 'cancelled': return Icons.cancel_outlined;
      default:          return Icons.info_outline;
    }
  }

  bool _isOverdue(InvoiceEntity inv) =>
      inv.status.toLowerCase() == 'unpaid' && inv.dueDate.isBefore(DateTime.now());

  List<InvoiceEntity> _filtered(List<InvoiceEntity> all) {
    return all.where((inv) {
      // Filter status
      if (_statusFilter != 'Semua') {
        final label = _statusLabel(inv.status);
        if (label != _statusFilter) return false;
      }
      // Filter search
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!inv.invoiceNumber.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList();
  }

  List<InvoiceEntity> _paged(List<InvoiceEntity> filtered) {
    final start = (_currentPage - 1) * _perPage;
    if (start >= filtered.length) return [];
    return filtered.sublist(start, (start + _perPage).clamp(0, filtered.length));
  }

  int _totalPages(int count) => (count / _perPage).ceil().clamp(1, 9999);

  Future<void> _printPdf(int invoiceId) async {
    final url = Uri.parse('http://127.0.0.1:8000/api/v1/finance/invoices/$invoiceId/print');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuka URL pencetakan.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Header ────────────────────────────────────────────────
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Daftar Tagihan', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('Rekap seluruh tagihan sewa penghuni wisma.', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ]),
              OutlinedButton.icon(
                onPressed: () { _bloc.add(FetchInvoices()); },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ]),
            const SizedBox(height: 28),

            BlocBuilder<InvoiceBloc, InvoiceState>(
              builder: (context, state) {
                if (state is InvoiceLoading) {
                  return const Center(child: Padding(padding: EdgeInsets.all(60), child: CircularProgressIndicator()));
                }
                if (state is InvoiceError) {
                  return Center(child: Text('Gagal memuat: ${state.message}', style: const TextStyle(color: Colors.red)));
                }
                if (state is! InvoiceLoaded) return const SizedBox.shrink();

                final all = state.invoices;
                final paidCount    = all.where((i) => i.status.toLowerCase() == 'paid').length;
                final unpaidCount  = all.where((i) => i.status.toLowerCase() == 'unpaid').length;
                final overdueCount = all.where(_isOverdue).length;
                final totalRevenue = all.where((i) => i.status.toLowerCase() == 'paid').fold(0.0, (s, i) => s + i.amount);

                final filtered  = _filtered(all);
                final totalPages = _totalPages(filtered.length);
                final page      = _currentPage.clamp(1, totalPages);
                final paged     = _paged(filtered);

                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // ── Summary cards ──────────────────────────────────
                  Row(children: [
                    Expanded(child: _summaryCard('Total Tagihan', '${all.length} Tagihan', 'Semua periode', Icons.receipt_long, Colors.blue.shade700, Colors.blue.shade50)),
                    const SizedBox(width: 16),
                    Expanded(child: _summaryCard('Sudah Lunas', '$paidCount Tagihan', formatRupiah(totalRevenue), Icons.check_circle_outline, Colors.green.shade700, Colors.green.shade50)),
                    const SizedBox(width: 16),
                    Expanded(child: _summaryCard('Belum Dibayar', '$unpaidCount Tagihan', 'Termasuk jatuh tempo', Icons.schedule, Colors.orange.shade700, Colors.orange.shade50)),
                    const SizedBox(width: 16),
                    Expanded(child: _summaryCard('Sudah Jatuh Tempo', '$overdueCount Tagihan', 'Perlu tindak lanjut', Icons.warning_amber_rounded, Colors.red.shade700, Colors.red.shade50)),
                  ]),
                  const SizedBox(height: 24),

                  // ── Filter bar ────────────────────────────────────
                  BasicCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(children: [
                        // Search
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() { _searchQuery = v; _currentPage = 1; }),
                            decoration: InputDecoration(
                              hintText: 'Cari nomor tagihan...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchController.clear(); setState(() { _searchQuery = ''; _currentPage = 1; }); })
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Status filter chips
                        ..._statusOptions.map((opt) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: GestureDetector(
                            onTap: () => setState(() { _statusFilter = opt; _currentPage = 1; }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: _statusFilter == opt ? Theme.of(context).primaryColor : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _statusFilter == opt ? Theme.of(context).primaryColor : Colors.grey.shade300),
                              ),
                              child: Text(opt, style: TextStyle(fontSize: 13, fontWeight: _statusFilter == opt ? FontWeight.w600 : FontWeight.normal, color: _statusFilter == opt ? Colors.white : Colors.grey.shade700)),
                            ),
                          ),
                        )),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Table ─────────────────────────────────────────
                  BasicCard(
                    child: Column(children: [
                      // Header row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        child: Row(children: [
                          Expanded(flex: 3, child: _th('Nomor Tagihan')),
                          Expanded(flex: 2, child: _th('Nominal')),
                          Expanded(flex: 2, child: _th('Jatuh Tempo')),
                          Expanded(flex: 2, child: _th('Status')),
                          const SizedBox(width: 100),
                        ]),
                      ),
                      const Divider(height: 1),

                      // Data rows
                      if (paged.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(child: Column(children: [
                            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text('Tidak ada tagihan ditemukan.', style: TextStyle(color: Colors.grey.shade500)),
                          ])),
                        )
                      else
                        ...paged.asMap().entries.map((entry) {
                          final i = entry.key;
                          final inv = entry.value;
                          final isLast = i == paged.length - 1;
                          final overdue = _isOverdue(inv);

                          return Column(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                // Nomor tagihan
                                Expanded(flex: 3, child: Row(children: [
                                  Container(
                                    width: 38, height: 38,
                                    decoration: BoxDecoration(
                                      color: _statusBg(inv.status),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(_statusIcon(inv.status), color: _statusColor(inv.status), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                    if (overdue)
                                      Text('Sudah Jatuh Tempo', style: TextStyle(fontSize: 11, color: Colors.red.shade600, fontWeight: FontWeight.w600)),
                                  ]),
                                ])),

                                // Nominal
                                Expanded(flex: 2, child: Text(formatRupiah(inv.amount), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),

                                // Jatuh tempo
                                Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(formatDate(inv.dueDate), style: TextStyle(fontSize: 13, color: overdue ? Colors.red.shade700 : Colors.grey.shade700, fontWeight: overdue ? FontWeight.w600 : FontWeight.normal)),
                                  if (overdue)
                                    Text('${DateTime.now().difference(inv.dueDate).inDays} hari lalu', style: TextStyle(fontSize: 11, color: Colors.red.shade400)),
                                ])),

                                // Status badge
                                Expanded(flex: 2, child: _StatusBadge(label: _statusLabel(inv.status), color: _statusColor(inv.status), bg: _statusBg(inv.status))),

                                // Aksi
                                SizedBox(
                                  width: 100,
                                  child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                    Tooltip(
                                      message: 'Cetak Nota PDF',
                                      child: IconButton(
                                        icon: Icon(Icons.print_outlined, size: 18, color: Colors.blue.shade600),
                                        splashRadius: 20,
                                        onPressed: () => _printPdf(inv.id),
                                      ),
                                    ),
                                  ]),
                                ),
                              ]),
                            ),
                            if (!isLast) const Divider(height: 1, indent: 70),
                          ]);
                        }),

                      const Divider(height: 1),

                      // ── Footer: info + pagination ──────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        child: Row(children: [
                          Text('Menampilkan ${paged.length} dari ${filtered.length} tagihan', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                          const Spacer(),
                          _PaginationBar(currentPage: page, totalPages: totalPages, onPageChanged: (p) => setState(() => _currentPage = p)),
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
    );
  }

  Widget _th(String label) => Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade600, letterSpacing: 0.5));

  Widget _summaryCard(String title, String value, String sub, IconData icon, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: textColor.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: textColor, size: 20), const SizedBox(width: 8), Expanded(child: Text(title, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)))]),
        const SizedBox(height: 10),
        Text(value, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(sub, style: TextStyle(color: textColor.withOpacity(0.65), fontSize: 11)),
      ]),
    );
  }
}

// ── Status Badge ───────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _StatusBadge({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Pagination Bar ─────────────────────────────────────────────────────────────
class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  const _PaginationBar({required this.currentPage, required this.totalPages, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    int start = (currentPage - 2).clamp(1, totalPages);
    int end   = (start + 4).clamp(1, totalPages);
    start = (end - 4).clamp(1, totalPages);
    final pages = List.generate(end - start + 1, (i) => start + i);

    return Row(mainAxisSize: MainAxisSize.min, children: [
      _NavBtn(icon: Icons.chevron_left, enabled: currentPage > 1, onTap: () => onPageChanged(currentPage - 1)),
      const SizedBox(width: 4),
      if (start > 1) ...[
        _PageBtn(page: 1, isActive: false, onTap: () => onPageChanged(1), ctx: context),
        if (start > 2) Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text('...', style: TextStyle(color: Colors.grey.shade500))),
      ],
      ...pages.map((p) => Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: _PageBtn(page: p, isActive: p == currentPage, onTap: () => onPageChanged(p), ctx: context))),
      if (end < totalPages) ...[
        if (end < totalPages - 1) Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text('...', style: TextStyle(color: Colors.grey.shade500))),
        _PageBtn(page: totalPages, isActive: false, onTap: () => onPageChanged(totalPages), ctx: context),
      ],
      const SizedBox(width: 4),
      _NavBtn(icon: Icons.chevron_right, enabled: currentPage < totalPages, onTap: () => onPageChanged(currentPage + 1)),
    ]);
  }
}

class _PageBtn extends StatelessWidget {
  final int page;
  final bool isActive;
  final VoidCallback onTap;
  final BuildContext ctx;
  const _PageBtn({required this.page, required this.isActive, required this.onTap, required this.ctx});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: isActive ? Theme.of(ctx).primaryColor : Colors.transparent,
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
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: enabled ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
    );
  }
}
