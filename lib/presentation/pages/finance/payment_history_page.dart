import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../domain/entity/finance/payment_entity.dart';
import '../../bloc/payment_verification/payment_verification_bloc.dart';
import '../../bloc/payment_verification/payment_verification_event.dart';
import '../../bloc/payment_verification/payment_verification_state.dart';
import '../../widget/core/card/basic_card.dart';
import '../../widget/core/table/table.dart';
import '../../../domain/entity/table/tabel_colum.dart';

@RoutePage()
class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  late PaymentVerificationBloc _bloc;

  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();
  int _page = 1;

  int? _filterYear;
  int? _filterMonth;
  String _methodFilter = 'Semua';
  String _statusFilter = 'Semua';

  static const int _perPage = 15;
  static const _statusOptions = ['Semua', 'Menunggu', 'Disetujui', 'Ditolak', 'Refund', 'Gagal'];
  static const _methodOptions = ['Semua', 'Manual', 'Midtrans'];

  @override
  void initState() {
    super.initState();
    _bloc = serviceLocator<PaymentVerificationBloc>();
    _bloc.add(FetchAllPayments());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String formatRupiah(double v) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(v);

  String formatDate(String d) {
    final dt = DateTime.tryParse(d);
    return dt != null ? DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt) : '-';
  }

  String _methodLabel(String m) => m == 'midtrans' ? 'Midtrans / QRIS' : 'Transfer Manual';
  IconData _methodIcon(String m) => m == 'midtrans' ? Icons.qr_code : Icons.account_balance;
  Color _methodColor(String m) =>
      m == 'midtrans' ? Colors.indigo.shade600 : Colors.teal.shade600;

  String _statusLabel(String s) {
    switch (s.toLowerCase()) {
      case 'pending':  return 'Menunggu';
      case 'verified': return 'Disetujui';
      case 'paid':     return 'Disetujui';
      case 'rejected': return 'Ditolak';
      case 'refunded': return 'Refund';
      case 'failed':   return 'Gagal';
      default:         return s;
    }
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'pending':             return Colors.orange.shade700;
      case 'verified':
      case 'paid':                return Colors.green.shade700;
      case 'rejected':
      case 'failed':              return Colors.red.shade600;
      case 'refunded':            return Colors.blue.shade600;
      default:                    return Colors.grey.shade600;
    }
  }

  Color _statusBg(String s) {
    switch (s.toLowerCase()) {
      case 'pending':             return Colors.orange.shade50;
      case 'verified':
      case 'paid':                return Colors.green.shade50;
      case 'rejected':
      case 'failed':              return Colors.red.shade50;
      case 'refunded':            return Colors.blue.shade50;
      default:                    return Colors.grey.shade100;
    }
  }

  IconData _statusIcon(String s) {
    switch (s.toLowerCase()) {
      case 'pending':             return Icons.hourglass_top;
      case 'verified':
      case 'paid':                return Icons.check_circle_outline;
      case 'rejected':
      case 'failed':              return Icons.cancel_outlined;
      case 'refunded':            return Icons.replay;
      default:                    return Icons.info_outline;
    }
  }

  List<PaymentEntity> _filtered(List<PaymentEntity> all) {
    return all.where((p) {
      // Year filter (based on payment date)
      if (_filterYear != null) {
        final dt = DateTime.tryParse(p.paymentDate);
        if (dt == null || dt.year != _filterYear) return false;
      }
      // Month filter
      if (_filterMonth != null) {
        final dt = DateTime.tryParse(p.paymentDate);
        if (dt == null || dt.month != _filterMonth) return false;
      }
      // Method filter
      if (_methodFilter != 'Semua') {
        final isManual = p.paymentMethod != 'midtrans';
        if (_methodFilter == 'Manual' && !isManual) return false;
        if (_methodFilter == 'Midtrans' && isManual) return false;
      }
      // Status filter
      if (_statusFilter != 'Semua' && _statusLabel(p.status) != _statusFilter) return false;
      // Search
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        final matches =
            (p.residentName?.toLowerCase().contains(q) ?? false) ||
            (p.roomNumber?.toLowerCase().contains(q) ?? false) ||
            (p.invoiceNumber?.toLowerCase().contains(q) ?? false) ||
            (p.transactionId?.toLowerCase().contains(q) ?? false);
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  List<PaymentEntity> _paged(List<PaymentEntity> list) {
    final start = (_page - 1) * _perPage;
    if (start >= list.length) return [];
    return list.sublist(start, (start + _perPage).clamp(0, list.length));
  }

  int _totalPages(int count) => (count / _perPage).ceil().clamp(1, 9999);

  // ─── Derive available years from data ───────────────────────────────────────
  List<int> _availableYears(List<PaymentEntity> all) {
    final years = all
        .map((p) => DateTime.tryParse(p.paymentDate)?.year)
        .whereType<int>()
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    return years;
  }

  // ─── Detail dialog (read-only) ───────────────────────────────────────────────
  void _showDetailDialog(PaymentEntity payment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _statusBg(payment.status), borderRadius: BorderRadius.circular(8)),
            child: Icon(_statusIcon(payment.status), color: _statusColor(payment.status), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Detail Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(_statusLabel(payment.status),
                style: TextStyle(fontSize: 12, color: _statusColor(payment.status), fontWeight: FontWeight.w600)),
          ])),
        ]),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 460,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                child: Column(children: [
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Penghuni', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      Text(payment.residentName ?? '-', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      if (payment.roomNumber != null)
                        Text('Kamar ${payment.roomNumber}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      if (payment.invoiceNumber != null) ...[
                        const SizedBox(height: 2),
                        Text(payment.invoiceNumber!, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('Nominal', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      Text(formatRupiah(payment.amount), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(_methodLabel(payment.paymentMethod),
                          style: TextStyle(fontSize: 12, color: _methodColor(payment.paymentMethod), fontWeight: FontWeight.w600)),
                    ]),
                  ]),
                  const Divider(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Tanggal Pembayaran', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      Text(formatDate(payment.paymentDate), style: const TextStyle(fontSize: 12)),
                    ]),
                    if (payment.updatedAt != null)
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('Tanggal Diproses', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        Text(formatDate(payment.updatedAt!), style: const TextStyle(fontSize: 12)),
                      ]),
                  ]),
                  if (payment.transactionId != null) ...[
                    const Divider(height: 16),
                    Row(children: [
                      Icon(Icons.tag, size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text('ID Transaksi: ${payment.transactionId}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ]),
                  ],
                ]),
              ),
              if (payment.adminNotes != null && payment.adminNotes!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text('Catatan Admin', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: payment.status.toLowerCase() == 'rejected' ? Colors.red.shade50 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: payment.status.toLowerCase() == 'rejected' ? Colors.red.shade200 : Colors.grey.shade200),
                  ),
                  child: Text(payment.adminNotes!, style: TextStyle(fontSize: 13, color: Colors.grey.shade800)),
                ),
              ],
              const SizedBox(height: 14),
              const Text('Bukti Transfer:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                height: 260,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                child: (payment.paymentProofUrl != null && payment.paymentProofUrl!.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          payment.paymentProofUrl!,
                          fit: BoxFit.contain,
                          loadingBuilder: (_, child, progress) =>
                              progress == null ? child : const Center(child: CircularProgressIndicator()),
                          errorBuilder: (_, __, ___) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text('Gambar tidak dapat dimuat', style: TextStyle(color: Colors.grey.shade500)),
                          ])),
                        ),
                      )
                    : Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text('Tidak ada bukti transfer', style: TextStyle(color: Colors.grey.shade500)),
                      ])),
              ),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        ],
      ),
    );
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
            // ── Header ───────────────────────────────────────────────
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Riwayat Pembayaran', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 6),
                const Text('Seluruh transaksi pembayaran penghuni — manual maupun via Midtrans.',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
              ])),
              OutlinedButton.icon(
                onPressed: () => _bloc.add(FetchAllPayments()),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ]),
            const SizedBox(height: 28),

            BlocBuilder<PaymentVerificationBloc, PaymentVerificationState>(
              buildWhen: (p, c) => c is PaymentVerificationLoading || c is PaymentVerificationLoaded,
              builder: (ctx, state) {
                if (state is PaymentVerificationLoading) {
                  return const Center(child: Padding(padding: EdgeInsets.all(60), child: CircularProgressIndicator()));
                }
                if (state is! PaymentVerificationLoaded) return const SizedBox.shrink();

                final all = state.payments;
                final years = _availableYears(all);

                final filteredList = _filtered(all);
                final totalPagesCount = _totalPages(filteredList.length);
                final currentPage = _page.clamp(1, totalPagesCount);
                final pagedList = _paged(filteredList);

                // Summary stats (based on full unfiltered data)
                final totalAmount   = all.fold(0.0, (s, p) => s + p.amount);
                final verifiedAmount = all.where((p) => ['verified', 'paid'].contains(p.status.toLowerCase())).fold(0.0, (s, p) => s + p.amount);
                final pendingCount  = all.where((p) => p.status.toLowerCase() == 'pending').length;
                final rejectedCount = all.where((p) => ['rejected', 'failed'].contains(p.status.toLowerCase())).length;

                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // ── Summary cards ──────────────────────────────────
                  Row(children: [
                    Expanded(child: _summaryCard('Total Transaksi', '${all.length} Transaksi', formatRupiah(totalAmount), Icons.receipt_long, Colors.blue.shade700, Colors.blue.shade50)),
                    const SizedBox(width: 16),
                    Expanded(child: _summaryCard('Lunas / Disetujui', '${all.where((p) => ['verified', 'paid'].contains(p.status.toLowerCase())).length} Transaksi', formatRupiah(verifiedAmount), Icons.check_circle_outline, Colors.green.shade700, Colors.green.shade50)),
                    const SizedBox(width: 16),
                    Expanded(child: _summaryCard('Menunggu Verifikasi', '$pendingCount Transaksi', 'Perlu tindak lanjut', Icons.hourglass_top, Colors.orange.shade700, Colors.orange.shade50)),
                    const SizedBox(width: 16),
                    Expanded(child: _summaryCard('Ditolak / Gagal', '$rejectedCount Transaksi', 'Perlu perhatian', Icons.cancel_outlined, Colors.red.shade600, Colors.red.shade50)),
                  ]),
                  const SizedBox(height: 24),

                  // ── Filter bar ─────────────────────────────────────
                  BasicCard(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // Row 1: Search + Year + Month
                        Row(children: [
                          Expanded(
                            flex: 4,
                            child: TextField(
                              controller: _searchCtrl,
                              onChanged: (v) => setState(() { _search = v; _page = 1; }),
                              decoration: InputDecoration(
                                hintText: 'Cari nama, kamar, nomor invoice, ID transaksi...',
                                prefixIcon: const Icon(Icons.search, size: 20),
                                suffixIcon: _search.isNotEmpty
                                    ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchCtrl.clear(); setState(() { _search = ''; _page = 1; }); })
                                    : null,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _FilterDropdown<int?>(
                            hint: 'Tahun',
                            value: _filterYear,
                            items: [null, ...years],
                            labelBuilder: (v) => v == null ? 'Semua Tahun' : '$v',
                            onChanged: (v) => setState(() { _filterYear = v; _filterMonth = null; _page = 1; }),
                          ),
                          const SizedBox(width: 8),
                          _FilterDropdown<int?>(
                            hint: 'Bulan',
                            value: _filterMonth,
                            items: [null, ...List.generate(12, (i) => i + 1)],
                            labelBuilder: (v) => v == null ? 'Semua Bulan' : DateFormat('MMMM', 'id_ID').format(DateTime(0, v)),
                            onChanged: (v) => setState(() { _filterMonth = v; _page = 1; }),
                          ),
                          if (_filterYear != null || _filterMonth != null) ...[
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => setState(() { _filterYear = null; _filterMonth = null; _page = 1; }),
                              icon: const Icon(Icons.close, size: 14),
                              label: const Text('Reset', style: TextStyle(fontSize: 12)),
                              style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
                            ),
                          ],
                        ]),
                        const SizedBox(height: 12),
                        // Row 2: Method chips + Status chips
                        Row(children: [
                          Text('Metode:', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                          const SizedBox(width: 8),
                          ..._methodOptions.map((opt) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _FilterChip(
                              label: opt,
                              selected: _methodFilter == opt,
                              onTap: () => setState(() { _methodFilter = opt; _page = 1; }),
                            ),
                          )),
                          const SizedBox(width: 16),
                          Text('Status:', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                          const SizedBox(width: 8),
                          ..._statusOptions.map((opt) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _FilterChip(
                              label: opt,
                              selected: _statusFilter == opt,
                              onTap: () => setState(() { _statusFilter = opt; _page = 1; }),
                            ),
                          )),
                        ]),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Table ──────────────────────────────────────────
                  TableCard(
                    title: _tableTitle(),
                    emptyMessage: _search.isEmpty && _filterYear == null && _filterMonth == null && _methodFilter == 'Semua' && _statusFilter == 'Semua'
                        ? 'Belum ada data pembayaran.'
                        : 'Tidak ada hasil yang cocok dengan filter yang dipilih.',
                    columns: const [
                      TableColumn(label: 'Penghuni & Tagihan', flex: 4),
                      TableColumn(label: 'Metode', flex: 2),
                      TableColumn(label: 'Nominal', flex: 2),
                      TableColumn(label: 'Tanggal', flex: 2),
                      TableColumn(label: 'Status', flex: 2),
                      TableColumn(label: 'Aksi', flex: 1, align: TextAlign.right),
                    ],
                    rows: pagedList.map((p) => [
                      _colPenghuni(p),
                      _colMetode(p),
                      Text(formatRupiah(p.amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(formatDate(p.paymentDate), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: _statusBg(p.status), borderRadius: BorderRadius.circular(20), border: Border.all(color: _statusColor(p.status).withOpacity(0.3))),
                        child: Text(_statusLabel(p.status), style: TextStyle(color: _statusColor(p.status), fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      OutlinedButton(
                        onPressed: () => _showDetailDialog(p),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), side: BorderSide(color: Colors.grey.shade300), minimumSize: const Size(70, 34)),
                        child: const Text('Detail', style: TextStyle(fontSize: 12)),
                      ),
                    ]).toList(),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(children: [
                      Text('Menampilkan ${pagedList.length} dari ${filteredList.length} transaksi',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                      const Spacer(),
                      _PaginationBar(currentPage: currentPage, totalPages: totalPagesCount, onPageChanged: (p) => setState(() => _page = p)),
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

  String _tableTitle() {
    final parts = <String>[];
    if (_filterMonth != null && _filterYear != null) {
      parts.add(DateFormat('MMMM yyyy', 'id_ID').format(DateTime(_filterYear!, _filterMonth!)));
    } else if (_filterYear != null) {
      parts.add('Tahun $_filterYear');
    } else if (_filterMonth != null) {
      parts.add(DateFormat('MMMM', 'id_ID').format(DateTime(0, _filterMonth!)));
    }
    if (_methodFilter != 'Semua') parts.add(_methodFilter);
    if (_statusFilter != 'Semua') parts.add(_statusFilter);
    return parts.isEmpty ? 'Semua Pembayaran' : 'Pembayaran — ${parts.join(' · ')}';
  }

  Widget _colPenghuni(PaymentEntity p) => Row(children: [
    Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: _statusBg(p.status), borderRadius: BorderRadius.circular(10)),
      child: Icon(_statusIcon(p.status), color: _statusColor(p.status), size: 20),
    ),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(p.residentName ?? '-', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
      Row(children: [
        if (p.roomNumber != null) ...[
          Icon(Icons.meeting_room_outlined, size: 12, color: Colors.grey.shade500),
          const SizedBox(width: 3),
          Text('Kamar ${p.roomNumber}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(width: 8),
        ],
        if (p.invoiceNumber != null) ...[
          Icon(Icons.receipt_outlined, size: 12, color: Colors.grey.shade400),
          const SizedBox(width: 3),
          Text(p.invoiceNumber!, style: TextStyle(fontSize: 12, color: Colors.grey.shade500), overflow: TextOverflow.ellipsis),
        ],
      ]),
    ])),
  ]);

  Widget _colMetode(PaymentEntity p) => Row(children: [
    Icon(_methodIcon(p.paymentMethod), size: 15, color: _methodColor(p.paymentMethod)),
    const SizedBox(width: 6),
    Flexible(child: Text(_methodLabel(p.paymentMethod),
        style: TextStyle(fontSize: 12, color: _methodColor(p.paymentMethod), fontWeight: FontWeight.w600))),
  ]);

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

// ── Filter Dropdown ─────────────────────────────────────────────────────────
class _FilterDropdown<T> extends StatelessWidget {
  final String hint;
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;

  const _FilterDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          items: items
              .map((item) => DropdownMenuItem<T>(value: item, child: Text(labelBuilder(item), style: const TextStyle(fontSize: 13))))
              .toList(),
          onChanged: (v) { if (v != null || null is T) onChanged(v as T); },
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          icon: Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey.shade500),
        ),
      ),
    );
  }
}

// ── Filter Chip ─────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Theme.of(context).primaryColor : Colors.grey.shade300),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w600 : FontWeight.normal, color: selected ? Colors.white : Colors.grey.shade700)),
      ),
    );
  }
}

// ── Pagination Bar ──────────────────────────────────────────────────────────
class _PaginationBar extends StatelessWidget {
  final int currentPage, totalPages;
  final ValueChanged<int> onPageChanged;
  const _PaginationBar({required this.currentPage, required this.totalPages, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    int start = (currentPage - 2).clamp(1, totalPages);
    int end   = (start + 4).clamp(1, totalPages);
    start = (end - 4).clamp(1, totalPages);
    final pages = List.generate(end - start + 1, (i) => start + i);

    return Row(mainAxisSize: MainAxisSize.min, children: [
      _nav(context, Icons.chevron_left, currentPage > 1, () => onPageChanged(currentPage - 1)),
      const SizedBox(width: 4),
      if (start > 1) ...[
        _btn(context, 1, false),
        if (start > 2) Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text('...', style: TextStyle(color: Colors.grey.shade500))),
      ],
      ...pages.map((p) => Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: _btn(context, p, p == currentPage))),
      if (end < totalPages) ...[
        if (end < totalPages - 1) Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text('...', style: TextStyle(color: Colors.grey.shade500))),
        _btn(context, totalPages, false),
      ],
      const SizedBox(width: 4),
      _nav(context, Icons.chevron_right, currentPage < totalPages, () => onPageChanged(currentPage + 1)),
    ]);
  }

  Widget _btn(BuildContext ctx, int page, bool active) {
    return GestureDetector(
      onTap: () => onPageChanged(page),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: active ? Theme.of(ctx).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: active ? null : Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: Text('$page', style: TextStyle(fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? Colors.white : Colors.grey.shade700, fontSize: 13)),
      ),
    );
  }

  Widget _nav(BuildContext ctx, IconData icon, bool enabled, VoidCallback onTap) {
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
