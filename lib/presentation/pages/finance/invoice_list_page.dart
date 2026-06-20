import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../data/datasource/finance_datasource.dart';
import '../../../domain/entity/finance/invoice_entity.dart';
import '../../bloc/invoice/invoice_bloc.dart';
import '../../bloc/invoice/invoice_event.dart';
import '../../bloc/invoice/invoice_state.dart';
import '../../widget/core/card/basic_card.dart';
import '../../widget/core/table/table.dart';
import '../../../domain/entity/table/tabel_colum.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../widget/core/appbar/app_topbar.dart';
import '../../widget/core/card/summary_stat_card.dart';

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
  int? _filterYear;
  int? _filterMonth;

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

  Color _statusColor(String status, bool isDark) {
    switch (status.toLowerCase()) {
      case 'paid':      return isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone;
      case 'unpaid':    return isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;
      case 'cancelled': return isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
      default:          return isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess;
    }
  }

  Color _statusBg(String status, bool isDark) {
    switch (status.toLowerCase()) {
      case 'paid':      return isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg;
      case 'unpaid':    return isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg;
      case 'cancelled': return isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
      default:          return isDark ? AppColorsDark.statusProcessBg : AppColorsLight.statusProcessBg;
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

  List<int> _availableYears(List<InvoiceEntity> all) {
    final years = all
        .map((inv) => inv.createdAt?.year)
        .whereType<int>()
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    return years;
  }

  List<InvoiceEntity> _filtered(List<InvoiceEntity> all) {
    return all.where((inv) {
      if (_filterYear != null && inv.createdAt?.year != _filterYear) return false;
      if (_filterMonth != null && inv.createdAt?.month != _filterMonth) return false;
      if (_statusFilter != 'Semua') {
        if (_statusLabel(inv.status) != _statusFilter) return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchInvoice = inv.invoiceNumber.toLowerCase().contains(q);
        final matchName    = inv.residentName?.toLowerCase().contains(q) ?? false;
        final matchRoom    = inv.roomNumber?.toLowerCase().contains(q) ?? false;
        if (!matchInvoice && !matchName && !matchRoom) return false;
      }
      return true;
    }).toList();
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
    if (_statusFilter != 'Semua') parts.add(_statusFilter);
    return parts.isEmpty ? 'Data Tagihan' : 'Tagihan — ${parts.join(' · ')}';
  }

  List<InvoiceEntity> _paged(List<InvoiceEntity> filtered) {
    final start = (_currentPage - 1) * _perPage;
    if (start >= filtered.length) return [];
    return filtered.sublist(start, (start + _perPage).clamp(0, filtered.length));
  }

  int _totalPages(int count) => (count / _perPage).ceil().clamp(1, 9999);

  Future<void> _printPdf(int invoiceId) async {
    try {
      final datasource = serviceLocator<FinanceRemoteDatasource>();
      final signedUrl = await datasource.getInvoicePrintLink(invoiceId);
      if (signedUrl.isEmpty) throw Exception('URL kosong');
      final uri = Uri.parse(signedUrl);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Tidak dapat membuka browser');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka cetak: $e'), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final bgColor = isDark ? AppColorsDark.background : AppColorsLight.background;

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Column(
          children: [
            AppTopBar(
              title: 'Daftar Tagihan',
              breadcrumb: 'Keuangan / Tagihan',
              action: ElevatedButton.icon(
                onPressed: () => _bloc.add(FetchInvoices()),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                      final years = _availableYears(all);
                      final paidList    = all.where((i) => i.status.toLowerCase() == 'paid').toList();
                      final unpaidList  = all.where((i) => i.status.toLowerCase() == 'unpaid').toList();
                      final overdueList = all.where(_isOverdue).toList();
                      final totalRevenue   = paidList.fold(0.0, (s, i) => s + i.amount);
                      final totalPiutang   = unpaidList.fold(0.0, (s, i) => s + i.amount);

                      final filtered  = _filtered(all);
                      final totalPages = _totalPages(filtered.length);
                      final page      = _currentPage.clamp(1, totalPages);
                      final paged     = _paged(filtered);

                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // ── Summary cards ──────────────────────────────────
                        Row(children: [
                          Expanded(child: SummaryStatCard(
                            label: 'Total Tagihan',
                            value: '${all.length} Tagihan',
                            icon: Icons.receipt_long,
                            iconColor: isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess,
                            iconBg: isDark ? AppColorsDark.statusProcessBg : AppColorsLight.statusProcessBg,
                            trend: 'Semua periode',
                          )),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(child: SummaryStatCard(
                            label: 'Sudah Lunas',
                            value: '${paidList.length} Tagihan',
                            icon: Icons.check_circle_outline,
                            iconColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
                            iconBg: isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg,
                            trend: formatRupiah(totalRevenue),
                            trendColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
                          )),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(child: SummaryStatCard(
                            label: 'Belum Dibayar',
                            value: '${unpaidList.length} Tagihan',
                            icon: Icons.schedule,
                            iconColor: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting,
                            iconBg: isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg,
                            trend: formatRupiah(totalPiutang),
                            trendColor: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting,
                          )),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(child: SummaryStatCard(
                            label: 'Sudah Jatuh Tempo',
                            value: '${overdueList.length} Tagihan',
                            icon: Icons.warning_amber_rounded,
                            iconColor: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
                            iconBg: isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg,
                            trend: 'Perlu tindak lanjut',
                            trendColor: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
                          )),
                        ]),
                        const SizedBox(height: AppSpacing.xxxl),

                        // ── Filter bar ────────────────────────────────────
                        BasicCard(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              // Row 1: search + tahun + bulan
                              Row(children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (v) => setState(() { _searchQuery = v; _currentPage = 1; }),
                                    decoration: InputDecoration(
                                      hintText: 'Cari nomor tagihan, nama penghuni, atau kamar...',
                                      prefixIcon: const Icon(Icons.search, size: 20),
                                      suffixIcon: _searchQuery.isNotEmpty
                                          ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchController.clear(); setState(() { _searchQuery = ''; _currentPage = 1; }); })
                                          : null,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight)),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _YearDropdown(
                                  value: _filterYear,
                                  years: years,
                                  isDark: isDark,
                                  onChanged: (v) => setState(() { _filterYear = v; _filterMonth = null; _currentPage = 1; }),
                                ),
                                const SizedBox(width: 8),
                                _MonthDropdown(
                                  value: _filterMonth,
                                  isDark: isDark,
                                  onChanged: (v) => setState(() { _filterMonth = v; _currentPage = 1; }),
                                ),
                                if (_filterYear != null || _filterMonth != null) ...[
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () => setState(() { _filterYear = null; _filterMonth = null; _currentPage = 1; }),
                                    icon: const Icon(Icons.close, size: 14),
                                    label: const Text('Reset', style: TextStyle(fontSize: 12)),
                                    style: TextButton.styleFrom(foregroundColor: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
                                  ),
                                ],
                              ]),
                              const SizedBox(height: 10),
                              // Row 2: status chips
                              Row(children: [
                                Text('Status:', style: TextStyle(fontSize: 12, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary, fontWeight: FontWeight.w500)),
                                const SizedBox(width: 8),
                                ..._statusOptions.map((opt) => Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: GestureDetector(
                                    onTap: () => setState(() { _statusFilter = opt; _currentPage = 1; }),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _statusFilter == opt ? Theme.of(context).primaryColor : (isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: _statusFilter == opt ? Theme.of(context).primaryColor : (isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight)),
                                      ),
                                      child: Text(opt, style: TextStyle(fontSize: 12, fontWeight: _statusFilter == opt ? FontWeight.w600 : FontWeight.normal, color: _statusFilter == opt ? Colors.white : (isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary))),
                                    ),
                                  ),
                                )),
                              ]),
                            ]),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),

                        // ── Table ─────────────────────────────────────────
                        TableCard(
                          title: _tableTitle(),
                          emptyMessage: 'Tidak ada tagihan ditemukan.',
                          columns: const [
                            TableColumn(label: 'Penghuni & Tagihan', flex: 4),
                            TableColumn(label: 'Periode', flex: 2),
                            TableColumn(label: 'Nominal', flex: 2),
                            TableColumn(label: 'Jatuh Tempo', flex: 2),
                            TableColumn(label: 'Status', flex: 2),
                            TableColumn(label: 'Aksi', flex: 1, align: TextAlign.right),
                          ],
                          rows: paged.map((inv) {
                            final overdue = _isOverdue(inv);
                            final periode = inv.createdAt != null
                                ? DateFormat('MMMM yyyy', 'id_ID').format(inv.createdAt!)
                                : '-';
                            return [
                              // Kolom 1: info penghuni + nomor invoice
                              Row(children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: _statusBg(inv.status, isDark),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(_statusIcon(inv.status), color: _statusColor(inv.status, isDark), size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(
                                    inv.residentName ?? 'Penghuni tidak diketahui',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(children: [
                                    if (inv.roomNumber != null) ...[
                                      Icon(Icons.meeting_room_outlined, size: 12, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
                                      const SizedBox(width: 3),
                                      Text('Kamar ${inv.roomNumber}', style: TextStyle(fontSize: 12, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary)),
                                      const SizedBox(width: 8),
                                    ],
                                    Icon(Icons.receipt_outlined, size: 12, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
                                    const SizedBox(width: 3),
                                    Text(inv.invoiceNumber, style: TextStyle(fontSize: 12, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary)),
                                  ]),
                                  if (overdue)
                                    Text('Sudah Jatuh Tempo', style: TextStyle(fontSize: 11, color: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled, fontWeight: FontWeight.w600)),
                                ])),
                              ]),
                              // Kolom 2: periode bulan tagihan
                              Text(periode, style: TextStyle(fontSize: 13, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary)),
                              // Kolom 3: nominal
                              Text(formatRupiah(inv.amount), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              // Kolom 4: jatuh tempo
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(
                                  formatDate(inv.dueDate),
                                  style: TextStyle(fontSize: 13, color: overdue ? (isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled) : (isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary), fontWeight: overdue ? FontWeight.w600 : FontWeight.normal),
                                ),
                                if (overdue)
                                  Text('${DateTime.now().difference(inv.dueDate).inDays} hari lalu', style: TextStyle(fontSize: 11, color: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled)),
                              ]),
                              // Kolom 5: status badge
                              _StatusBadge(label: _statusLabel(inv.status), color: _statusColor(inv.status, isDark), bg: _statusBg(inv.status, isDark)),
                              // Kolom 6: aksi
                              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                Tooltip(
                                  message: 'Cetak Nota PDF',
                                  child: IconButton(
                                    icon: Icon(Icons.print_outlined, size: 18, color: isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess),
                                    splashRadius: 20,
                                    onPressed: () => _printPdf(inv.id),
                                  ),
                                ),
                              ]),
                            ];
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),

                        // Footer: info + pagination
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          child: Row(children: [
                            Text('Menampilkan ${paged.length} dari ${filtered.length} tagihan', style: TextStyle(fontSize: 13, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary)),
                            const Spacer(),
                            _PaginationBar(currentPage: page, totalPages: totalPages, onPageChanged: (p) => setState(() => _currentPage = p)),
                          ]),
                        ),
                      ]);
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Year / Month Dropdowns ─────────────────────────────────────────────────────
class _YearDropdown extends StatelessWidget {
  final int? value;
  final List<int> years;
  final bool isDark;
  final ValueChanged<int?> onChanged;
  const _YearDropdown({required this.value, required this.years, required this.isDark, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight), borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: value,
          hint: Text('Tahun', style: TextStyle(fontSize: 13, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary)),
          items: [
            const DropdownMenuItem<int?>(value: null, child: Text('Semua Tahun', style: TextStyle(fontSize: 13))),
            ...years.map((y) => DropdownMenuItem<int?>(value: y, child: Text('$y', style: const TextStyle(fontSize: 13)))),
          ],
          onChanged: onChanged,
          icon: Icon(Icons.keyboard_arrow_down, size: 18, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
        ),
      ),
    );
  }
}

class _MonthDropdown extends StatelessWidget {
  final int? value;
  final bool isDark;
  final ValueChanged<int?> onChanged;
  const _MonthDropdown({required this.value, required this.isDark, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight), borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: value,
          hint: Text('Bulan', style: TextStyle(fontSize: 13, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary)),
          items: [
            const DropdownMenuItem<int?>(value: null, child: Text('Semua Bulan', style: TextStyle(fontSize: 13))),
            ...List.generate(12, (i) => i + 1).map((m) => DropdownMenuItem<int?>(
              value: m,
              child: Text(DateFormat('MMMM', 'id_ID').format(DateTime(0, m)), style: const TextStyle(fontSize: 13)),
            )),
          ],
          onChanged: onChanged,
          icon: Icon(Icons.keyboard_arrow_down, size: 18, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
        ),
      ),
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
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: color)),
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
