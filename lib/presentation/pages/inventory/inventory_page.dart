import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/domain/entity/inventory_entity.dart';
import 'package:frontend/presentation/bloc/inventory/inventory_list_bloc.dart';
import 'package:frontend/presentation/bloc/inventory/inventory_action_bloc.dart';
import 'package:frontend/presentation/widget/core/appbar/app_topbar.dart';
import 'package:frontend/presentation/widget/core/appbar/search_and_filter_bar.dart';
import 'package:frontend/presentation/widget/core/card/summary_stat_card.dart';
import 'package:frontend/presentation/widget/core/table/app_data_table.dart';
import 'package:frontend/presentation/widget/core/wrapper/empty_state_widget.dart';
import 'package:frontend/presentation/widget/core/textform/textform.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';

@RoutePage()
class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: serviceLocator<InventoryListBloc>()..add(FetchInventories()),
        ),
        BlocProvider.value(
          value: serviceLocator<InventoryActionBloc>(),
        ),
      ],
      child: const InventoryView(),
    );
  }
}

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  String _searchQuery = '';
  String _selectedKondisi = 'Semua Kondisi';

  String _formatCurrency(double? price) {
    if (price == null || price == 0) return '-';
    if (price >= 1000000) {
      final inJuta = price / 1000000;
      return 'Rp ${inJuta.toStringAsFixed(inJuta.truncateToDouble() == inJuta ? 0 : 1)}jt';
    }
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(price);
  }

  Widget _buildConditionDot(InventoryCondition kondisi, bool isDark) {
    Color color;
    switch (kondisi) {
      case InventoryCondition.baik:
        color = isDark ? AppColorsDark.conditionGood : AppColorsLight.conditionGood;
        break;
      case InventoryCondition.cukup:
        color = isDark ? AppColorsDark.conditionFair : AppColorsLight.conditionFair;
        break;
      case InventoryCondition.rusakRingan:
        color = Colors.deepOrange;
        break;
      case InventoryCondition.rusakBerat:
        color = isDark ? AppColorsDark.conditionPoor : AppColorsLight.conditionPoor;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          kondisi.displayName,
          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }

  void _showFormDialog(BuildContext context, {InventoryEntity? item}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<InventoryActionBloc>()),
          BlocProvider.value(value: context.read<InventoryListBloc>()),
        ],
        child: InventoryFormDialog(inventoryData: item),
      ),
    );
  }

  void _confirmDelete(BuildContext context, InventoryEntity item) {
    final isDark = AppTheme.isDark(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Inventaris?'),
        content: Text('Anda yakin ingin menghapus "${item.nama}"? Aksi ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<InventoryActionBloc>().add(DeleteInventoryEvent(item.id!));
            },
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return BlocListener<InventoryActionBloc, InventoryActionState>(
      listener: (context, state) {
        if (state is InventoryActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [
              Icon(Icons.check_circle, color: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone),
              const SizedBox(width: 8),
              Text(state.message, style: const TextStyle(color: Colors.white)),
            ]),
            backgroundColor: isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ));
          context.read<InventoryListBloc>().add(FetchInventories());
        } else if (state is InventoryActionError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [
              Icon(Icons.error, color: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled),
              const SizedBox(width: 8),
              Text(state.message, style: const TextStyle(color: Colors.white)),
            ]),
            backgroundColor: isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ));
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColorsDark.background : AppColorsLight.background,
        body: Column(
          children: [
            AppTopBar(
            title: 'Inventaris',
            breadcrumb: 'Operasional / Inventaris',
            action: ElevatedButton.icon(
              onPressed: () => _showFormDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah Inventaris'),
            ),
          ),
          Expanded(
            child: BlocBuilder<InventoryListBloc, InventoryListState>(
              builder: (context, state) {
                if (state is InventoryListLoading || state is InventoryListInitial) {
                  return _buildSkeleton(isDark);
                } else if (state is InventoryListError) {
                  return EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'Gagal Memuat Data',
                    subtitle: state.message,
                    action: ElevatedButton(
                      onPressed: () => context.read<InventoryListBloc>().add(FetchInventories()),
                      child: const Text('Coba Lagi'),
                    ),
                  );
                } else if (state is InventoryListLoaded) {
                  final allItems = state.inventories;
                  
                  // Stats calc
                  final totalBarang = allItems.length;
                  final totalNilai = allItems.fold<double>(0, (sum, item) => sum + ((item.purchasePrice ?? 0) * item.jumlah));
                  final kondisiBaik = allItems.where((i) => i.kondisi == InventoryCondition.baik).length;
                  final perluPerhatian = allItems.where((i) => i.kondisi != InventoryCondition.baik).length;

                  // Filtering
                  var filteredItems = allItems.where((item) {
                    final matchQuery = item.nama.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                     (item.keterangan.toLowerCase().contains(_searchQuery.toLowerCase()));
                    final matchKondisi = _selectedKondisi == 'Semua Kondisi' || item.kondisi.displayName == _selectedKondisi;
                    return matchQuery && matchKondisi;
                  }).toList();

                  // Sorting (default alphabetical)
                  filteredItems.sort((a, b) => a.nama.compareTo(b.nama));

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Cards
                        Row(
                          children: [
                            Expanded(child: SummaryStatCard(
                              label: 'Total Barang',
                              value: totalBarang.toString(),
                              icon: Icons.inventory_2_outlined,
                              iconColor: isDark ? AppColorsDark.primary : AppColorsLight.primary,
                              iconBg: isDark ? AppColorsDark.primaryLight : AppColorsLight.primaryLight,
                            )),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(child: SummaryStatCard(
                              label: 'Total Nilai',
                              value: _formatCurrency(totalNilai),
                              icon: Icons.account_balance_wallet_outlined,
                              iconColor: isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess,
                              iconBg: isDark ? AppColorsDark.statusProcessBg : AppColorsLight.statusProcessBg,
                            )),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(child: SummaryStatCard(
                              label: 'Kondisi Baik',
                              value: '$kondisiBaik Baik',
                              icon: Icons.check_circle_outline,
                              iconColor: isDark ? AppColorsDark.conditionGood : AppColorsLight.conditionGood,
                              iconBg: isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg,
                            )),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(child: SummaryStatCard(
                              label: 'Perlu Perhatian',
                              value: '$perluPerhatian Cukup/Buruk',
                              icon: Icons.warning_amber_rounded,
                              iconColor: isDark ? AppColorsDark.conditionFair : AppColorsLight.conditionFair,
                              iconBg: isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg,
                            )),
                          ],
                        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms),
                        
                        const SizedBox(height: AppSpacing.xxxl),
                        
                        // Search & Filter
                        SearchAndFilterBar(
                          searchHint: 'Cari nama barang...',
                          onSearchChanged: (val) => setState(() => _searchQuery = val),
                          dropdownFilter: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              border: Border.all(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedKondisi,
                                items: ['Semua Kondisi', ...InventoryCondition.displayNames].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
                                onChanged: (v) => setState(() => _selectedKondisi = v!),
                              ),
                            ),
                          ),
                          onSortPressed: () {},
                          sortLabel: 'Sort: Nama',
                        ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                        
                        const SizedBox(height: AppSpacing.lg),
                        
                        // Table
                        if (filteredItems.isEmpty)
                          EmptyStateWidget(
                            icon: Icons.inventory_2_outlined,
                            title: 'Tidak ada barang ditemukan',
                            subtitle: 'Coba ubah filter atau kata kunci pencarian Anda.',
                          ).animate().fadeIn()
                        else
                          AppDataTable(
                            columns: const [
                              DataColumn(label: Text('NAMA')),
                              DataColumn(label: Text('KETERANGAN')),
                              DataColumn(label: Text('JML')),
                              DataColumn(label: Text('KONDISI')),
                              DataColumn(label: Text('NILAI')),
                              DataColumn(label: Text('')),
                            ],
                            rows: filteredItems.map((item) => DataRow(
                              cells: [
                                DataCell(Text(item.nama, style: const TextStyle(fontWeight: FontWeight.w600))),
                                DataCell(Text(item.keterangan.isEmpty ? '-' : item.keterangan, maxLines: 1, overflow: TextOverflow.ellipsis)),
                                DataCell(Text(item.jumlah.toString())),
                                DataCell(_buildConditionDot(item.kondisi, isDark)),
                                DataCell(Text(_formatCurrency((item.purchasePrice ?? 0) * item.jumlah))),
                                DataCell(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 18),
                                      onPressed: () => _showFormDialog(context, item: item),
                                      tooltip: 'Edit',
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, size: 18, color: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled),
                                      onPressed: () => _confirmDelete(context, item),
                                      tooltip: 'Hapus',
                                    ),
                                  ],
                                )),
                              ],
                            )).toList(),
                          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
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
            children: List.generate(4, (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index < 3 ? AppSpacing.lg : 0),
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
}

class InventoryFormDialog extends StatefulWidget {
  final InventoryEntity? inventoryData;
  const InventoryFormDialog({super.key, this.inventoryData});

  @override
  State<InventoryFormDialog> createState() => _InventoryFormDialogState();
}

class _InventoryFormDialogState extends State<InventoryFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _namaController;
  late final TextEditingController _keteranganController;
  late final TextEditingController _jumlahController;
  late final TextEditingController _hargaBeliController;

  String? _selectedKondisi;
  double _totalHarga = 0;

  @override
  void initState() {
    super.initState();
    final data = widget.inventoryData;
    _namaController = TextEditingController(text: data?.nama ?? '');
    _keteranganController = TextEditingController(text: data?.keterangan ?? '');
    _jumlahController = TextEditingController(text: data != null ? data.jumlah.toString() : '');
    _hargaBeliController = TextEditingController(text: data?.purchasePrice != null ? data!.purchasePrice!.toInt().toString() : '');
    _selectedKondisi = data?.kondisi.displayName ?? InventoryCondition.baik.displayName;

    _jumlahController.addListener(_calcTotal);
    _hargaBeliController.addListener(_calcTotal);
    _calcTotal();
  }

  void _calcTotal() {
    final qty = int.tryParse(_jumlahController.text) ?? 0;
    final price = double.tryParse(_hargaBeliController.text) ?? 0;
    setState(() {
      _totalHarga = qty * price;
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _keteranganController.dispose();
    _jumlahController.dispose();
    _hargaBeliController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final entity = InventoryEntity(
      id: widget.inventoryData?.id,
      nama: _namaController.text.trim(),
      keterangan: _keteranganController.text.trim(),
      jumlah: int.tryParse(_jumlahController.text) ?? 0,
      kondisi: _selectedKondisi != null 
          ? InventoryCondition.fromString(_selectedKondisi!)
          : InventoryCondition.baik,
      purchasePrice: double.tryParse(_hargaBeliController.text.trim()),
    );

    if (widget.inventoryData != null) {
      context.read<InventoryActionBloc>().add(UpdateInventoryEvent(entity.id!, entity));
    } else {
      context.read<InventoryActionBloc>().add(CreateInventoryEvent(entity));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final surfaceColor = isDark ? AppColorsDark.surface : AppColorsLight.surface;
    final isEditMode = widget.inventoryData != null;

    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      backgroundColor: surfaceColor,
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditMode ? 'Edit Inventaris' : 'Tambah Inventaris',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextForm(
                      title: 'Nama Barang',
                      hintText: 'Masukkan nama',
                      isRequired: true,
                      controller: _namaController,
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    flex: 1,
                    child: CustomTextForm(
                      title: 'Jumlah',
                      hintText: '0',
                      isRequired: true,
                      controller: _jumlahController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Wajib diisi' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              CustomTextForm(
                title: 'Keterangan',
                hintText: 'Masukkan keterangan (opsional)',
                controller: _keteranganController,
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kondisi *', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedKondisi,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: InventoryCondition.displayNames.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
                          onChanged: (v) => setState(() => _selectedKondisi = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: CustomTextForm(
                      title: 'Harga Satuan (Rp)',
                      hintText: '0',
                      controller: _hargaBeliController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Harga Estimasi', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text(
                      formatCurrency.format(_totalHarga),
                      style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? AppColorsDark.primary : AppColorsLight.primary, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    child: const Text('Simpan'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
