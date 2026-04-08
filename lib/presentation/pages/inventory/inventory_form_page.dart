import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/domain/entity/inventory_entity.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/textform/textform.dart';

@RoutePage()
class InventoryFormPage extends StatelessWidget {
  const InventoryFormPage({super.key, this.inventoryData});

  /// If not null, the form is in edit mode.
  final InventoryEntity? inventoryData;

  bool get isEditMode => inventoryData != null;

  @override
  Widget build(BuildContext context) {
    return _InventoryFormView(
      inventoryData: inventoryData,
      isEditMode: isEditMode,
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

  String? _selectedKondisi;
  String? _selectedJenis;
  String? _selectedKategori;

  @override
  void initState() {
    super.initState();
    final data = widget.inventoryData;
    _namaController = TextEditingController(text: data?.nama ?? '');
    _keteranganController = TextEditingController(text: data?.keterangan ?? '');
    _jumlahController = TextEditingController(
      text: data != null ? data.jumlah.toString() : '',
    );

    _selectedKondisi = data?.kondisi.displayName;
    _selectedJenis = data?.jenis.displayName;
    _selectedKategori = data?.kategori.displayName;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _keteranganController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final entity = InventoryEntity(
      id: widget.inventoryData?.id,
      nama: _namaController.text.trim(),
      keterangan: _keteranganController.text.trim(),
      jumlah: int.tryParse(_jumlahController.text) ?? 0,
      kondisi: InventoryCondition.fromString(_selectedKondisi!),
      jenis: InventoryType.fromString(_selectedJenis!),
      kategori: InventoryCategory.fromString(_selectedKategori!),
    );

    // TODO: Dispatch to BLoC for backend integration
    debugPrint('Form submitted: $entity');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEditMode
              ? 'Inventaris berhasil diperbarui'
              : 'Inventaris berhasil ditambahkan',
        ),
        backgroundColor: Colors.green,
      ),
    );

    context.router.maybePop(entity);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
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
                        hintText: 'Masukkan keterangan barang',
                        controller: _keteranganController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),

                      // Row 3: Kondisi, Jenis, Kategori (dropdowns)
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
                            child: _DropdownField(
                              title: 'Jenis',
                              isRequired: true,
                              hint: 'Pilih jenis',
                              value: _selectedJenis,
                              items: InventoryType.displayNames,
                              onChanged: (v) =>
                                  setState(() => _selectedJenis = v),
                              validator: (v) =>
                                  v == null ? 'Jenis wajib dipilih' : null,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _DropdownField(
                              title: 'Kategori',
                              isRequired: true,
                              hint: 'Pilih kategori',
                              value: _selectedKategori,
                              items: InventoryCategory.displayNames,
                              onChanged: (v) =>
                                  setState(() => _selectedKategori = v),
                              validator: (v) =>
                                  v == null ? 'Kategori wajib dipilih' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 44,
                            child: BasicButton(
                              type: ButtonType.secondary,
                              label: 'Batal',
                              onPressed: () => context.router.maybePop(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 140,
                            height: 44,
                            child: BasicButton(
                              label: widget.isEditMode ? 'Simpan' : 'Tambah',
                              onPressed: _handleSubmit,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
