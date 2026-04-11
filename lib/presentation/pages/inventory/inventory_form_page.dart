import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/domain/entity/inventory_entity.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/textform/textform.dart';
import 'package:frontend/presentation/bloc/inventory/inventory_action_bloc.dart';

@RoutePage()
class InventoryFormPage extends StatelessWidget {
  const InventoryFormPage({super.key, this.inventoryData});

  /// If not null, the form is in edit mode.
  final InventoryEntity? inventoryData;

  bool get isEditMode => inventoryData != null;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<InventoryActionBloc>(),
      child: _InventoryFormView(
        inventoryData: inventoryData,
        isEditMode: isEditMode,
      ),
    );
  }
}

class _InventoryFormView extends StatefulWidget {
  const _InventoryFormView({
    required this.inventoryData,
    required this.isEditMode,
  });

  final InventoryEntity? inventoryData;
  final bool isEditMode;

  @override
  State<_InventoryFormView> createState() => _InventoryFormViewState();
}

class _InventoryFormViewState extends State<_InventoryFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _namaController;
  late final TextEditingController _keteranganController;
  late final TextEditingController _jumlahController;
  late final TextEditingController _hargaBeliController;

  String? _selectedKondisi;

  @override
  void initState() {
    super.initState();
    final data = widget.inventoryData;
    _namaController = TextEditingController(text: data?.nama ?? '');
    _keteranganController = TextEditingController(text: data?.keterangan ?? '');
    _jumlahController = TextEditingController(
      text: data != null ? data.jumlah.toString() : '',
    );
    _hargaBeliController = TextEditingController(
      text: data?.purchasePrice != null ? data!.purchasePrice!.toInt().toString() : '',
    );

    _selectedKondisi = data?.kondisi.displayName;
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

    if (widget.isEditMode) {
      context.read<InventoryActionBloc>().add(UpdateInventoryEvent(entity.id!, entity));
    } else {
      context.read<InventoryActionBloc>().add(CreateInventoryEvent(entity));
    }
  }

  void _handleDelete() {
    if (widget.inventoryData?.id == null) return;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Inventaris'),
        content: const Text('Apakah Anda yakin ingin menghapus barang ini? Data yang terhapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<InventoryActionBloc>().add(DeleteInventoryEvent(widget.inventoryData!.id!));
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<InventoryActionBloc, InventoryActionState>(
      listener: (context, state) {
        if (state is InventoryActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
          // Return true to indicate a refresh is needed in the list
          context.router.maybePop(true);
        } else if (state is InventoryActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar with back button and title
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.router.maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.isEditMode ? 'Edit Inventaris' : 'Tambah Inventaris',
                      style: theme.textTheme.headlineLarge,
                    ),
                    const Spacer(),
                    if (widget.isEditMode)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          elevation: 0,
                        ),
                        onPressed: _handleDelete,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Hapus'),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Form card
                BasicCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section title
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Informasi Inventaris',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Row 1: Nama & Jumlah
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: CustomTextForm(
                                title: 'Nama Barang',
                                hintText: 'Masukkan nama barang',
                                isRequired: true,
                                controller: _namaController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Nama barang wajib diisi';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 1,
                              child: CustomTextForm(
                                title: 'Jumlah',
                                hintText: '0',
                                isRequired: true,
                                keyboardType: TextInputType.number,
                                controller: _jumlahController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Wajib diisi';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Angka tidak valid';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Row 2: Keterangan
                        CustomTextForm(
                          title: 'Keterangan',
                          hintText: 'Masukkan keterangan barang (opsional)',
                          controller: _keteranganController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),

                        // Row 3: Kondisi & Harga Beli
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _DropdownField(
                                title: 'Kondisi',
                                isRequired: true,
                                hint: 'Pilih kondisi',
                                value: _selectedKondisi,
                                items: InventoryCondition.displayNames,
                                onChanged: (v) =>
                                    setState(() => _selectedKondisi = v),
                                validator: (v) =>
                                    v == null ? 'Kondisi wajib dipilih' : null,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: CustomTextForm(
                                title: 'Harga Beli (Rp)',
                                hintText: 'Opsional',
                                keyboardType: TextInputType.number,
                                controller: _hargaBeliController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Action buttons
                        BlocBuilder<InventoryActionBloc, InventoryActionState>(
                          builder: (context, state) {
                            final isLoading = state is InventoryActionLoading;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 140,
                                  height: 44,
                                  child: BasicButton(
                                    type: ButtonType.secondary,
                                    label: 'Batal',
                                    onPressed: isLoading ? null : () => context.router.maybePop(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 140,
                                  height: 44,
                                  child: BasicButton(
                                    label: widget.isEditMode ? 'Simpan' : 'Tambah',
                                    onPressed: isLoading ? null : _handleSubmit,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable dropdown field with the same visual style as [CustomTextForm].
class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.title,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.value,
    this.isRequired = false,
    this.validator,
  });

  final String title;
  final String hint;
  final List<String> items;
  final String? value;
  final bool isRequired;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: title,
            style: theme.textTheme.titleMedium,
            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Colors.red.shade300,
                        fontSize: 12,
                      ),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(
            hint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
