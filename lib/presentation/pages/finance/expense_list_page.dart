import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import 'package:frontend/main.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entity/finance/expense_entity.dart';
import '../../../domain/entity/finance/fixed_expense_entry_entity.dart';
import '../../../domain/entity/finance/fixed_expense_status_entity.dart';
import '../../bloc/expense/expense_bloc.dart';
import '../../bloc/expense/expense_event.dart';
import '../../bloc/expense/expense_state.dart';
import '../../bloc/fixed_expense/fixed_expense_bloc.dart';
import '../../bloc/fixed_expense/fixed_expense_event.dart';
import '../../bloc/fixed_expense/fixed_expense_state.dart';
import '../../widget/core/appbar/app_topbar.dart';
import '../../widget/core/appbar/search_and_filter_bar.dart';
import '../../widget/core/card/summary_stat_card.dart';
import '../../widget/core/table/app_data_table.dart';
import '../../widget/core/textform/textform.dart';
import '../../widget/core/wrapper/empty_state_widget.dart';

// ── Config visual per jenis pengeluaran tetap ─────────────────────────────────
const _kJenisConfig = {
  'listrik': _JenisConfig(
    icon: Icons.bolt_rounded,
    label: 'Listrik',
    color: Color(0xFFD97706),
    colorLight: Color(0xFFFFFBEB),
    gradient: [Color(0xFFD97706), Color(0xFFF59E0B)],
  ),
  'air': _JenisConfig(
    icon: Icons.water_drop_rounded,
    label: 'Air',
    color: Color(0xFF2563EB),
    colorLight: Color(0xFFEFF6FF),
    gradient: [Color(0xFF2563EB), Color(0xFF3B82F6)],
  ),
  'wifi': _JenisConfig(
    icon: Icons.wifi_rounded,
    label: 'WiFi',
    color: Color(0xFF7C3AED),
    colorLight: Color(0xFFF5F3FF),
    gradient: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
  ),
};

class _JenisConfig {
  final IconData icon;
  final String label;
  final Color color;
  final Color colorLight;
  final List<Color> gradient;
  const _JenisConfig({
    required this.icon,
    required this.label,
    required this.color,
    required this.colorLight,
    required this.gradient,
  });
}

// ── Unified table item ────────────────────────────────────────────────────────
class _TableItem {
  final FixedExpenseEntryEntity? fixed;
  final ExpenseEntity? expense;

  const _TableItem.fixed(FixedExpenseEntryEntity e) : fixed = e, expense = null;
  const _TableItem.expense(ExpenseEntity e) : expense = e, fixed = null;

  bool get isFixed => fixed != null;
  bool get isUnfilledFixed => fixed != null && !fixed!.isFilled;

  DateTime get sortDate {
    if (fixed != null) return DateTime(fixed!.tahun, fixed!.bulan);
    return DateTime.tryParse(expense!.date) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
}

// ── Page ──────────────────────────────────────────────────────────────────────
@RoutePage()
class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  late ExpenseBloc _expenseBloc;
  late FixedExpenseBloc _fixedExpenseBloc;

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int? _filterYear;
  int? _filterMonth;

  int _currentPage = 1;
  static const int _perPage = 10;

  @override
  void initState() {
    super.initState();
    _expenseBloc = serviceLocator.get<ExpenseBloc>();
    _fixedExpenseBloc = serviceLocator.get<FixedExpenseBloc>();
    _expenseBloc.add(FetchExpenses());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.isFeatureEnabled('finance_fixed_expense')) {
        _fixedExpenseBloc.add(FetchFixedExpenses());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String formatRupiah(double amount) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);

  String _bulanLabel(int b) => DateFormat('MMMM', 'id_ID').format(DateTime(2000, b));

  // Kembalikan _JenisConfig jika title cocok dengan jenis tetap (listrik/air/wifi)
  _JenisConfig? _cfgFromTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('listrik') || t.contains('pln')) return _kJenisConfig['listrik'];
    if (t.contains('air') || t.contains('pdam')) return _kJenisConfig['air'];
    if (t.contains('internet') || t.contains('wifi')) return _kJenisConfig['wifi'];
    return null;
  }

  IconData _icon(String title) {
    final cfg = _cfgFromTitle(title);
    if (cfg != null) return cfg.icon;
    final t = title.toLowerCase();
    if (t.contains('ac') || t.contains('servis')) return Icons.ac_unit;
    if (t.contains('kebersihan') || t.contains('cuci') || t.contains('sapu')) return Icons.cleaning_services_rounded;
    if (t.contains('petugas') || t.contains('upah')) return Icons.person_rounded;
    if (t.contains('cat') || t.contains('perbaikan') || t.contains('renovasi')) return Icons.build_rounded;
    if (t.contains('keamanan')) return Icons.security_rounded;
    if (t.contains('atk') || t.contains('administrasi')) return Icons.description_rounded;
    if (t.contains('snack') || t.contains('konsumsi')) return Icons.restaurant_rounded;
    if (t.contains('transportasi') || t.contains('parkir')) return Icons.directions_car_rounded;
    return Icons.receipt_long_rounded;
  }

  Color _color(String title) {
    final cfg = _cfgFromTitle(title);
    if (cfg != null) return cfg.color;
    final t = title.toLowerCase();
    if (t.contains('ac') || t.contains('servis')) return Colors.cyan.shade600;
    if (t.contains('kebersihan') || t.contains('cuci')) return Colors.green.shade600;
    if (t.contains('petugas') || t.contains('upah')) return Colors.purple.shade500;
    if (t.contains('keamanan')) return Colors.deepOrange.shade600;
    return Colors.red.shade600;
  }

  Color _colorLight(String title) {
    final cfg = _cfgFromTitle(title);
    if (cfg != null) return cfg.colorLight;
    final t = title.toLowerCase();
    if (t.contains('ac') || t.contains('servis')) return const Color(0xFFECFEFF);
    if (t.contains('kebersihan') || t.contains('cuci')) return const Color(0xFFF0FDF4);
    if (t.contains('petugas') || t.contains('upah')) return const Color(0xFFFAF5FF);
    if (t.contains('keamanan')) return const Color(0xFFFFF7ED);
    if (t.contains('atk') || t.contains('administrasi')) return const Color(0xFFF0F9FF);
    if (t.contains('snack') || t.contains('konsumsi')) return const Color(0xFFFEF3C7);
    if (t.contains('transportasi') || t.contains('parkir')) return const Color(0xFFEFF6FF);
    return const Color(0xFFFEF2F2);
  }

  Widget _jenisChip(String label, Color textColor, Color bgColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── List builders ───────────────────────────────────────────────────────────

  List<FixedExpenseEntryEntity> _buildUnfilledFixed(List<FixedExpenseEntryEntity> allFixed) {
    var list = allFixed.where((e) => !e.isFilled).toList();
    if (_filterYear != null) {
      list = list.where((e) => e.tahun == _filterYear).toList();
    }
    if (_filterMonth != null) {
      list = list.where((e) => e.bulan == _filterMonth).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((e) {
        final cfg = _kJenisConfig[e.jenis];
        return (cfg?.label ?? e.jenisLabel).toLowerCase().contains(q) || e.jenis.contains(q);
      }).toList();
    }
    list.sort((a, b) => DateTime(b.tahun, b.bulan).compareTo(DateTime(a.tahun, a.bulan)));
    return list;
  }

  List<_TableItem> _buildMainList(
    List<FixedExpenseEntryEntity> allFixed,
    List<ExpenseEntity> allExpenses,
  ) {
    var fixed = allFixed.where((e) => e.isFilled).toList();
    var expenses = allExpenses.toList();

    if (_filterYear != null) {
      fixed = fixed.where((e) => e.tahun == _filterYear).toList();
      expenses = expenses.where((e) {
        final d = DateTime.tryParse(e.date);
        return d != null && d.year == _filterYear;
      }).toList();
    }
    if (_filterMonth != null) {
      fixed = fixed.where((e) => e.bulan == _filterMonth).toList();
      expenses = expenses.where((e) {
        final d = DateTime.tryParse(e.date);
        return d != null && d.month == _filterMonth;
      }).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      fixed = fixed.where((e) {
        final cfg = _kJenisConfig[e.jenis];
        return (cfg?.label ?? e.jenisLabel).toLowerCase().contains(q) || e.jenis.contains(q);
      }).toList();
      expenses = expenses.where((e) =>
          e.title.toLowerCase().contains(q) ||
          (e.notes?.toLowerCase().contains(q) ?? false)).toList();
    }

    return <_TableItem>[
      ...fixed.map((e) => _TableItem.fixed(e)),
      ...expenses.map((e) => _TableItem.expense(e)),
    ]..sort((a, b) => b.sortDate.compareTo(a.sortDate));
  }

  int _totalPages(int count) => (count / _perPage).ceil().clamp(1, 9999);

  List<_TableItem> _paged(List<_TableItem> list) {
    final start = ((_currentPage - 1) * _perPage).clamp(0, list.length);
    final end = (_currentPage * _perPage).clamp(0, list.length);
    return list.sublist(start, end);
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _showDialog([ExpenseEntity? expense]) {
    final isDark = AppTheme.isDark(context);
    final isEdit = expense != null;
    final surfaceColor = isDark ? AppColorsDark.surface : AppColorsLight.surface;
    final textPrimaryColor = isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
    final primaryColor = isDark ? AppColorsDark.primary : AppColorsLight.primary;

    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController(text: expense?.title ?? '');
    final amountCtrl = TextEditingController(
        text: expense != null ? expense.amount.toStringAsFixed(0) : '');
    final notesCtrl = TextEditingController(text: expense?.notes ?? '');
    DateTime pickedDate = expense != null
        ? (DateTime.tryParse(expense.date) ?? DateTime.now())
        : DateTime.now();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
          backgroundColor: surfaceColor,
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'Ubah Pengeluaran' : 'Tambah Pengeluaran',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Nama / Judul
                  CustomTextForm(
                    title: 'Nama / Judul Pengeluaran',
                    hintText: 'Contoh: Tagihan Listrik PLN',
                    isRequired: true,
                    controller: titleCtrl,
                    validator: (val) => (val == null || val.trim().isEmpty)
                        ? 'Nama pengeluaran wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Nominal + Tanggal (berdampingan)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomTextForm(
                          title: 'Nominal (Rp)',
                          hintText: '0',
                          isRequired: true,
                          controller: amountCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (val) =>
                              (val == null || val.trim().isEmpty)
                                  ? 'Nominal wajib diisi'
                                  : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(TextSpan(
                              text: 'Tanggal',
                              style: Theme.of(ctx).textTheme.titleMedium,
                              children: const [
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                              ],
                            )),
                            const SizedBox(height: 8),
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () async {
                                final p = await showDatePicker(
                                  context: ctx,
                                  initialDate: pickedDate,
                                  firstDate: DateTime(2023),
                                  lastDate: DateTime.now(),
                                  builder: (context, child) => Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: Theme.of(context)
                                          .colorScheme
                                          .copyWith(
                                            primary: primaryColor,
                                            onPrimary: Colors.white,
                                            surface: surfaceColor,
                                            onSurface: textPrimaryColor,
                                          ),
                                    ),
                                    child: child!,
                                  ),
                                );
                                if (p != null) setS(() => pickedDate = p);
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Theme.of(ctx)
                                      .colorScheme
                                      .surfaceContainerLow,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                  suffixIcon: const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 18),
                                ),
                                child: Text(
                                  DateFormat('dd MMM yyyy', 'id_ID')
                                      .format(pickedDate),
                                  style: TextStyle(
                                      fontSize: 14, color: textPrimaryColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Keterangan
                  CustomTextForm(
                    title: 'Keterangan',
                    hintText: 'Deskripsi singkat (opsional)',
                    controller: notesCtrl,
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Batal'),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;
                          final e = ExpenseEntity(
                            id: expense?.id ?? 0,
                            title: titleCtrl.text.trim(),
                            amount:
                                double.tryParse(amountCtrl.text) ?? 0,
                            date: pickedDate.toIso8601String(),
                            notes: notesCtrl.text.trim().isEmpty
                                ? null
                                : notesCtrl.text.trim(),
                          );
                          _expenseBloc.add(isEdit
                              ? UpdateExpense(e)
                              : CreateExpense(e));
                          Navigator.pop(ctx);
                        },
                        child: const Text('Simpan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void _showFillDialog(FixedExpenseEntryEntity entry) {
    final isDark = AppTheme.isDark(context);
    final cfg = _kJenisConfig[entry.jenis];
    final surfaceColor = isDark ? AppColorsDark.surface : AppColorsLight.surface;
    final textSecondaryColor = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

    final formKey = GlobalKey<FormState>();
    final amountCtrl = TextEditingController(
        text: entry.isFilled ? entry.amount.toStringAsFixed(0) : '');
    final notesCtrl = TextEditingController(text: entry.notes ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
        backgroundColor: surfaceColor,
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.isFilled ? 'Ubah Pengeluaran Tetap' : 'Isi Nominal',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${cfg?.label ?? entry.jenisLabel} — ${_bulanLabel(entry.bulan)} ${entry.tahun}',
                  style: TextStyle(fontSize: 14, color: textSecondaryColor),
                ),
                const SizedBox(height: AppSpacing.xxxl),

                CustomTextForm(
                  title: 'Nominal (Rp)',
                  hintText: '0',
                  isRequired: true,
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nominal wajib diisi';
                    }
                    if ((int.tryParse(val) ?? 0) <= 0) {
                      return 'Nominal harus lebih dari 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                CustomTextForm(
                  title: 'Catatan',
                  hintText: 'Misal: Tagihan PLN bulan Juni... (opsional)',
                  controller: notesCtrl,
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.xxxl),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        final amount =
                            double.tryParse(amountCtrl.text) ?? 0;
                        _fixedExpenseBloc.add(UpdateFixedExpense(
                          id: entry.id,
                          amount: amount,
                          notes: notesCtrl.text.trim().isEmpty
                              ? null
                              : notesCtrl.text.trim(),
                        ));
                        Navigator.pop(ctx);
                      },
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(ExpenseEntity e) {
    final isDark = AppTheme.isDark(context);
    final cancelledColor = isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengeluaran?'),
        content: Text(
          'Anda yakin ingin menghapus "${e.title}"? Aksi ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cancelledColor,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _expenseBloc.add(DeleteExpense(e.id));
            },
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _expenseBloc),
        BlocProvider.value(value: _fixedExpenseBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ExpenseBloc, ExpenseState>(
            listener: (context, state) {
              if (state is ExpenseOperationSuccess) {
                _snackSuccess(context, state.message, isDark);
                _expenseBloc.add(FetchExpenses());
              } else if (state is ExpenseError) {
                _snackError(context, state.message, isDark);
              }
            },
          ),
          BlocListener<FixedExpenseBloc, FixedExpenseState>(
            listener: (context, state) {
              if (state is FixedExpenseOperationSuccess) {
                _snackSuccess(context, state.message, isDark);
                _fixedExpenseBloc.add(FetchFixedExpenses());
              } else if (state is FixedExpenseError) {
                _snackError(context, state.message, isDark);
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: isDark ? AppColorsDark.background : AppColorsLight.background,
          body: Column(
            children: [
              AppTopBar(
                title: 'Pengeluaran',
                breadcrumb: 'Keuangan / Pengeluaran',
                action: ElevatedButton.icon(
                  onPressed: () => _showDialog(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah Pengeluaran'),
                ),
              ),
              Expanded(
                child: BlocBuilder<FixedExpenseBloc, FixedExpenseState>(
                  builder: (context, fixedState) {
                    final isFixedEnabled = context.isFeatureEnabled('finance_fixed_expense');
                    return BlocBuilder<ExpenseBloc, ExpenseState>(
                      builder: (context, expenseState) {
                        final isFirstLoad =
                            (isFixedEnabled && (fixedState is FixedExpenseLoading ||
                            fixedState is FixedExpenseInitial)) ||
                            expenseState is ExpenseLoading ||
                            expenseState is ExpenseInitial;
                        final isRefreshing = expenseState is ExpenseRefreshing;

                        if (isFirstLoad) return _buildSkeleton(isDark);

                        if (expenseState is ExpenseError) {
                          return EmptyStateWidget(
                            icon: Icons.error_outline,
                            title: 'Gagal Memuat Data',
                            subtitle: expenseState.message,
                            action: ElevatedButton(
                              onPressed: () {
                                _expenseBloc.add(FetchExpenses());
                                if (isFixedEnabled) _fixedExpenseBloc.add(FetchFixedExpenses());
                              },
                              child: const Text('Coba Lagi'),
                            ),
                          );
                        }

                        final fixedEntries = (isFixedEnabled && fixedState is FixedExpenseLoaded)
                            ? fixedState.entries
                            : <FixedExpenseEntryEntity>[];
                        final fixedStatus = (isFixedEnabled && fixedState is FixedExpenseLoaded)
                            ? fixedState.status
                            : null;
                        final expenses = expenseState is ExpenseLoaded
                            ? expenseState.expenses
                            : expenseState is ExpenseRefreshing
                                ? expenseState.currentExpenses
                                : <ExpenseEntity>[];

                        return Stack(children: [
                          _buildContent(fixedEntries, fixedStatus, expenses, isDark),
                          if (isRefreshing) const LinearProgressIndicator(),
                        ]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    List<FixedExpenseEntryEntity> allFixed,
    FixedExpenseStatusEntity? fixedStatus,
    List<ExpenseEntity> allExpenses,
    bool isDark,
  ) {
    final textSecondaryColor = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    final textPrimaryColor = isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;

    // Summary stats untuk general expense (sesuai filter)
    final now = DateTime.now();
    final yearFiltered = _filterYear == null
        ? allExpenses
        : allExpenses.where((e) {
            final d = DateTime.tryParse(e.date);
            return d != null && d.year == _filterYear;
          }).toList();
    final periodExpenses = (_filterYear != null && _filterMonth != null)
        ? yearFiltered.where((e) {
            final d = DateTime.tryParse(e.date);
            return d != null && d.month == _filterMonth;
          }).toList()
        : yearFiltered;

    final totalAll = periodExpenses.fold(0.0, (s, e) => s + e.amount);
    final int refYear = _filterYear ?? now.year;
    final totalThisMonth = yearFiltered.where((e) {
      final d = DateTime.tryParse(e.date);
      return d != null && d.month == now.month && d.year == refYear;
    }).fold(0.0, (s, e) => s + e.amount);
    final String card1Title = _filterYear != null && _filterMonth != null
        ? 'Total ${DateFormat('MMM yyyy', 'id_ID').format(DateTime(_filterYear!, _filterMonth!))}'
        : _filterYear != null
            ? 'Total Tahun $_filterYear'
            : 'Total Pengeluaran';
    final String card2Sub =
        '${DateFormat('MMMM', 'id_ID').format(DateTime(refYear, now.month))} $refYear';

    // Split list: unfilled fixed (section atas) vs main table (filled + general)
    final unfilledFixed = _buildUnfilledFixed(allFixed);
    final mainList = _buildMainList(allFixed, allExpenses);
    final hasAny = unfilledFixed.isNotEmpty || mainList.isNotEmpty;
    final totalPages = _totalPages(mainList.length);
    final page = _currentPage.clamp(1, totalPages);
    final paged = _paged(mainList);

    // Years available dari kedua sumber
    final years = <int>{
      ...allExpenses.map((e) => DateTime.tryParse(e.date)?.year).whereType<int>(),
      ...allFixed.map((e) => e.tahun),
    }.toList()..sort((a, b) => b.compareTo(a));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Summary cards (general expense stats) ─────────────────────────
          Row(
            children: [
              Expanded(
                child: SummaryStatCard(
                  label: card1Title,
                  value: formatRupiah(totalAll),
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: isDark ? AppColorsDark.primary : AppColorsLight.primary,
                  iconBg: isDark ? AppColorsDark.primaryLight : AppColorsLight.primaryLight,
                  trend: '${periodExpenses.length} transaksi',
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: SummaryStatCard(
                  label: _filterYear != null ? 'Bulan Ini ($_filterYear)' : 'Bulan Ini',
                  value: formatRupiah(totalThisMonth),
                  icon: Icons.calendar_month_outlined,
                  iconColor: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting,
                  iconBg: isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg,
                  trend: card2Sub,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: SummaryStatCard(
                  label: 'Entri Manual',
                  value: '${allExpenses.where((e) => !e.isIntegrated).length} Transaksi',
                  icon: Icons.edit_note_outlined,
                  iconColor: isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess,
                  iconBg: isDark ? AppColorsDark.statusProcessBg : AppColorsLight.statusProcessBg,
                  trend: 'Dicatat oleh admin',
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: SummaryStatCard(
                  label: 'Dari Sistem',
                  value: '${allExpenses.where((e) => e.isIntegrated).length} Transaksi',
                  icon: Icons.auto_awesome_outlined,
                  iconColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
                  iconBg: isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg,
                  trend: 'Otomatis (inventaris)',
                ),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms),

          // ── Summary cards (fixed expense status bulan ini) ─────────────────
          if (fixedStatus != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildFixedStatusCards(allFixed, fixedStatus, isDark),
          ],

          const SizedBox(height: AppSpacing.xxxl),

          // ── Search & Filter ─────────────────────────────────────────────────
          SearchAndFilterBar(
            searchController: _searchController,
            searchHint: 'Cari pengeluaran...',
            onSearchChanged: (val) => setState(() {
              _searchQuery = val;
              _currentPage = 1;
            }),
            dropdownFilter: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDropdown<int?>(
                  value: _filterYear,
                  hint: 'Semua Tahun',
                  isDark: isDark,
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('Semua Tahun')),
                    ...years.map((y) => DropdownMenuItem<int?>(value: y, child: Text('$y'))),
                  ],
                  onChanged: (val) => setState(() {
                    _filterYear = val;
                    _filterMonth = null;
                    _currentPage = 1;
                  }),
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildDropdown<int?>(
                  value: _filterMonth,
                  hint: 'Semua Bulan',
                  isDark: isDark,
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('Semua Bulan')),
                    ...List.generate(12, (i) => DropdownMenuItem<int?>(
                      value: i + 1,
                      child: Text(DateFormat('MMMM', 'id_ID').format(DateTime(2000, i + 1))),
                    )),
                  ],
                  onChanged: (val) => setState(() {
                    _filterMonth = val;
                    _currentPage = 1;
                  }),
                ),
                if (_filterYear != null || _filterMonth != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  TextButton.icon(
                    onPressed: () => setState(() {
                      _filterYear = null;
                      _filterMonth = null;
                      _currentPage = 1;
                    }),
                    icon: const Icon(Icons.close, size: 14),
                    label: const Text('Reset', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(foregroundColor: textSecondaryColor),
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

          const SizedBox(height: AppSpacing.lg),

          // ── Table sections ──────────────────────────────────────────────────
          if (!hasAny)
            EmptyStateWidget(
              icon: Icons.receipt_long,
              title: _searchQuery.isNotEmpty
                  ? 'Tidak ada hasil untuk "$_searchQuery"'
                  : _filterYear != null
                      ? 'Tidak ada pengeluaran pada periode yang dipilih'
                      : 'Belum ada data pengeluaran',
              subtitle: _searchQuery.isNotEmpty || _filterYear != null
                  ? 'Coba ubah filter atau kata kunci pencarian Anda.'
                  : 'Tambah pengeluaran baru menggunakan tombol di atas.',
            ).animate().fadeIn()
          else ...[
            // Section: pengeluaran tetap belum diisi
            if (unfilledFixed.isNotEmpty) ...[
              _buildUnfilledSection(unfilledFixed, isDark),
              const SizedBox(height: AppSpacing.xxxl),
            ],

            // Section: semua yang sudah diisi / umum
            if (mainList.isNotEmpty) ...[
              if (unfilledFixed.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(children: [
                    Container(
                      width: 3, height: 18,
                      decoration: BoxDecoration(
                        color: isDark ? AppColorsDark.primary : AppColorsLight.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Sudah Diisi & Umum',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textPrimaryColor)),
                  ]),
                ),
              AppDataTable(
                columns: const [
                  DataColumn(label: Text('PENGELUARAN')),
                  DataColumn(label: Text('JENIS')),
                  DataColumn(label: Text('TANGGAL / PERIODE')),
                  DataColumn(label: Text('NOMINAL')),
                  DataColumn(label: Text('AKSI')),
                ],
                rows: paged
                    .map((item) => item.isFixed
                        ? _buildFixedRow(item.fixed!, isDark)
                        : _buildExpenseRow(item.expense!, isDark))
                    .toList(),
                dataRowMinHeight: 60,
              ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

              const SizedBox(height: AppSpacing.lg),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Menampilkan ${paged.length} dari ${mainList.length} data',
                      style: TextStyle(fontSize: 13, color: textSecondaryColor),
                    ),
                    const Spacer(),
                    _PaginationBar(
                      currentPage: page,
                      totalPages: totalPages,
                      onPageChanged: (p) => setState(() => _currentPage = p),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ── Fixed expense status cards (bulan ini) ─────────────────────────────────
  Widget _buildFixedStatusCards(
    List<FixedExpenseEntryEntity> entries,
    FixedExpenseStatusEntity status,
    bool isDark,
  ) {
    final detailEntries = status.detail.entries.toList();
    if (detailEntries.isEmpty) return const SizedBox.shrink();

    return Row(
      children: List.generate(detailEntries.length, (i) {
        final kv = detailEntries[i];
        final jenis = kv.key;
        final s = kv.value;
        final cfg = _kJenisConfig[jenis];
        if (cfg == null) return const Expanded(child: SizedBox.shrink());

        final entry = s.entryId != null
            ? entries.where((e) => e.id == s.entryId).firstOrNull
            : null;
        final isFilled = s.filled;
        final iconColor = isFilled
            ? (isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone)
            : cfg.color;
        final iconBg = isFilled
            ? (isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg)
            : cfg.colorLight;
        final trendColor = isFilled
            ? (isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone)
            : (isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting);

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < detailEntries.length - 1 ? AppSpacing.lg : 0),
            child: GestureDetector(
              onTap: entry != null ? () => _showFillDialog(entry) : null,
              child: SummaryStatCard(
                label: cfg.label,
                value: isFilled ? formatRupiah(s.amount ?? 0) : 'Belum Diisi',
                icon: cfg.icon,
                iconColor: iconColor,
                iconBg: iconBg,
                trend: isFilled ? '✓ Sudah diisi' : 'Tap untuk isi nominal',
                trendColor: trendColor,
              ),
            ),
          ),
        );
      }),
    ).animate().fadeIn(delay: 150.ms, duration: 300.ms);
  }

  // ── Unfilled fixed section ─────────────────────────────────────────────────

  Widget _buildUnfilledSection(List<FixedExpenseEntryEntity> unfilled, bool isDark) {
    final warningColor = isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;
    final warningBg = isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg;
    final warningBorder = isDark ? AppColorsDark.statusWaitingBorder : AppColorsLight.statusWaitingBorder;
    final textPrimaryColor = isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 3, height: 18,
            decoration: BoxDecoration(
              color: warningColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text('Belum Diisi',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: textPrimaryColor)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: warningBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: warningBorder),
            ),
            child: Text('${unfilled.length}',
                style: TextStyle(
                    fontSize: 12, color: warningColor, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: AppSpacing.md),
        AppDataTable(
          columns: const [
            DataColumn(label: Text('PENGELUARAN')),
            DataColumn(label: Text('PERIODE')),
            DataColumn(label: Text('AKSI')),
          ],
          rows: unfilled.map((e) => _buildUnfilledRow(e, isDark)).toList(),
          dataRowMinHeight: 58,
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 300.ms);
  }

  DataRow _buildUnfilledRow(FixedExpenseEntryEntity entry, bool isDark) {
    final cfg = _kJenisConfig[entry.jenis];
    final textSecondaryColor = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    final surfaceVariantColor = isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
    final primaryColor = isDark ? AppColorsDark.primary : AppColorsLight.primary;

    return DataRow(cells: [
      DataCell(Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cfg?.colorLight ?? surfaceVariantColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(cfg?.icon ?? Icons.receipt_long_rounded,
              size: 20, color: cfg?.color ?? textSecondaryColor),
        ),
        const SizedBox(width: 12),
        Text(cfg?.label ?? entry.jenisLabel,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ])),
      DataCell(Text('${_bulanLabel(entry.bulan)} ${entry.tahun}',
          style: TextStyle(fontSize: 13, color: textSecondaryColor))),
      DataCell(TextButton(
        onPressed: () => _showFillDialog(entry),
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        child: const Text('Isi Nominal'),
      )),
    ]);
  }

  // ── Table row builders ─────────────────────────────────────────────────────

  DataRow _buildFixedRow(FixedExpenseEntryEntity entry, bool isDark) {
    final cfg = _kJenisConfig[entry.jenis];
    final textSecondaryColor = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    final surfaceVariantColor = isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
    final warningColor = isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;
    final warningBg = isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg;
    final warningBorder = isDark ? AppColorsDark.statusWaitingBorder : AppColorsLight.statusWaitingBorder;

    return DataRow(cells: [
      // Pengeluaran
      DataCell(Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cfg?.colorLight ?? surfaceVariantColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(cfg?.icon ?? Icons.receipt_long_rounded,
              size: 20, color: cfg?.color ?? textSecondaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(cfg?.label ?? entry.jenisLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              if (entry.notes != null && entry.notes!.isNotEmpty)
                Text(entry.notes!, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: textSecondaryColor)),
            ],
          ),
        ),
      ])),
      // Jenis chip
      DataCell(_jenisChip('Tetap', warningColor, warningBg, warningBorder)),
      // Tanggal / Periode
      DataCell(Text('${_bulanLabel(entry.bulan)} ${entry.tahun}',
          style: TextStyle(fontSize: 13, color: textSecondaryColor))),
      // Nominal
      DataCell(Text(
        formatRupiah(entry.amount),
        style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 14,
          color: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
        ),
      )),
      // Aksi
      DataCell(TextButton(
        onPressed: () => _showFillDialog(entry),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        child: const Text('Ubah'),
      )),
    ]);
  }

  DataRow _buildExpenseRow(ExpenseEntity e, bool isDark) {
    final date = DateTime.tryParse(e.date);
    final textSecondaryColor = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    final textHintColor = isDark ? AppColorsDark.textHint : AppColorsLight.textHint;
    final processColor = isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess;
    final processBg = isDark ? AppColorsDark.statusProcessBg : AppColorsLight.statusProcessBg;
    final processBorder = isDark ? AppColorsDark.statusProcessBorder : AppColorsLight.statusProcessBorder;
    final borderLight = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final surfaceVariant = isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
    final cancelledColor = isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled;
    final primaryColor = isDark ? AppColorsDark.primary : AppColorsLight.primary;

    return DataRow(cells: [
      // Pengeluaran
      DataCell(Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _colorLight(e.title),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_icon(e.title), color: _color(e.title), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              if (e.notes != null && e.notes!.isNotEmpty)
                Text(e.notes!, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: textSecondaryColor)),
            ],
          ),
        ),
      ])),
      // Jenis chip
      DataCell(e.isIntegrated
          ? _jenisChip('Sistem', processColor, processBg, processBorder)
          : _jenisChip('Manual', textSecondaryColor, surfaceVariant, borderLight)),
      // Tanggal
      DataCell(Text(
        date != null ? DateFormat('dd MMM yyyy', 'id_ID').format(date) : '-',
        style: TextStyle(fontSize: 13, color: textSecondaryColor),
      )),
      // Nominal
      DataCell(Text(
        formatRupiah(e.amount),
        style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 14,
          color: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
        ),
      )),
      // Aksi
      DataCell(e.isIntegrated
          ? Tooltip(
              message: 'Dikelola otomatis oleh sistem',
              child: Text('—', style: TextStyle(color: textHintColor, fontSize: 16)),
            )
          : Row(mainAxisSize: MainAxisSize.min, children: [
              TextButton(
                onPressed: () => _showDialog(e),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                child: const Text('Ubah'),
              ),
              TextButton(
                onPressed: () => _confirmDelete(e),
                style: TextButton.styleFrom(
                  foregroundColor: cancelledColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                child: const Text('Hapus'),
              ),
            ])),
    ]);
  }

  // ── Skeleton loading ───────────────────────────────────────────────────────
  Widget _buildSkeleton(bool isDark) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        children: [
          Row(
            children: List.generate(4, (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 3 ? AppSpacing.lg : 0),
                child: Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                  ),
                ),
              ),
            )),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: List.generate(3, (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 2 ? AppSpacing.lg : 0),
                child: Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                  ),
                ),
              ),
            )),
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

  // ── Dropdown helper ────────────────────────────────────────────────────────
  Widget _buildDropdown<T>({
    required T value,
    required String hint,
    required bool isDark,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        color: isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: isDark ? AppColorsDark.surface : AppColorsLight.surface,
          hint: Text(hint,
              style: TextStyle(fontSize: 13,
                  color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary)),
          items: items,
          onChanged: onChanged,
          isDense: true,
          style: TextStyle(fontSize: 13,
              color: isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary),
          icon: Icon(Icons.keyboard_arrow_down, size: 18,
              color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
        ),
      ),
    );
  }

  // ── Snackbar helpers ───────────────────────────────────────────────────────
  void _snackSuccess(BuildContext ctx, String message, bool isDark) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(message),
      ]),
      backgroundColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }

  void _snackError(BuildContext ctx, String message, bool isDark) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(message),
      ]),
      backgroundColor: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }
}

// ── Pagination Bar ─────────────────────────────────────────────────────────────
class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final textHintColor = isDark ? AppColorsDark.textHint : AppColorsLight.textHint;

    final pages = <int>[];
    int start = (currentPage - 2).clamp(1, totalPages);
    int end = (start + 4).clamp(1, totalPages);
    start = (end - 4).clamp(1, totalPages);
    for (int i = start; i <= end; i++) { pages.add(i); }

    return Row(mainAxisSize: MainAxisSize.min, children: [
      _NavBtn(icon: Icons.chevron_left, enabled: currentPage > 1,
          onTap: () => onPageChanged(currentPage - 1)),
      const SizedBox(width: 4),
      if (start > 1) ...[
        _PageBtn(page: 1, isActive: false, onTap: () => onPageChanged(1)),
        if (start > 2)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text('...', style: TextStyle(color: textHintColor)),
          ),
      ],
      ...pages.map((p) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: _PageBtn(page: p, isActive: p == currentPage, onTap: () => onPageChanged(p)),
      )),
      if (end < totalPages) ...[
        if (end < totalPages - 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text('...', style: TextStyle(color: textHintColor)),
          ),
        _PageBtn(page: totalPages, isActive: false, onTap: () => onPageChanged(totalPages)),
      ],
      const SizedBox(width: 4),
      _NavBtn(icon: Icons.chevron_right, enabled: currentPage < totalPages,
          onTap: () => onPageChanged(currentPage + 1)),
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
    final isDark = AppTheme.isDark(context);
    final primaryColor = isDark ? AppColorsDark.primary : AppColorsLight.primary;
    final borderLightColor = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final textSecondaryColor = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive ? null : Border.all(color: borderLightColor),
        ),
        alignment: Alignment.center,
        child: Text('$page',
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.white : textSecondaryColor,
              fontSize: 13,
            )),
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
    final isDark = AppTheme.isDark(context);
    final borderLightColor = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final textPrimaryColor = isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
    final textHintColor = isDark ? AppColorsDark.textHint : AppColorsLight.textHint;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderLightColor),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: enabled ? textPrimaryColor : textHintColor),
      ),
    );
  }
}
