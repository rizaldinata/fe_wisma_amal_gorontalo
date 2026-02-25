import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:frontend/domain/entity/maintenance_entity.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/textform/textform.dart';

@RoutePage()
class MaintananceFormPage extends StatelessWidget {
  const MaintananceFormPage({super.key, this.maintenanceData});

  /// If not null, the form is in edit mode.
  final MaintenanceEntity? maintenanceData;

  bool get isEditMode => maintenanceData != null;

  @override
  Widget build(BuildContext context) {
    return _MaintananceFormView(
      maintenanceData: maintenanceData,
      isEditMode: isEditMode,
    );
  }
}

class _MaintananceFormView extends StatefulWidget {
  const _MaintananceFormView({
    required this.maintenanceData,
    required this.isEditMode,
  });

  final MaintenanceEntity? maintenanceData;
  final bool isEditMode;

  @override
  State<_MaintananceFormView> createState() => _MaintananceFormViewState();
}

class _MaintananceFormViewState extends State<_MaintananceFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _teknisiController;
  late final TextEditingController _ruanganController;

  String? _selectedTipe;
  String? _selectedSubtipe;
  String? _selectedStatus;
  DateTime? _waktuMulai;
  DateTime? _waktuSelesai;

  @override
  void initState() {
    super.initState();
    final data = widget.maintenanceData;
    _teknisiController = TextEditingController(text: data?.namaTeknisi ?? '');
    _ruanganController = TextEditingController(text: data?.ruangan ?? '');

    _selectedTipe = data?.tipe.displayName;
    _selectedSubtipe = data?.subtipe.displayName;
    _selectedStatus = data?.status.displayName;
    _waktuMulai = data?.waktuMulai;
    _waktuSelesai = data?.waktuSelesai;
  }

  @override
  void dispose() {
    _teknisiController.dispose();
    _ruanganController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final now = DateTime.now();
    final initialDate = isStart
        ? (_waktuMulai ?? now)
        : (_waktuSelesai ?? _waktuMulai ?? now);

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null || !mounted) return;

    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _waktuMulai = picked;
      } else {
        _waktuSelesai = picked;
      }
    });
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_waktuMulai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waktu mulai wajib diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final entity = MaintenanceEntity(
      id: widget.maintenanceData?.id,
      namaTeknisi: _teknisiController.text.trim(),
      ruangan: _ruanganController.text.trim(),
      tipe: MaintenanceType.fromString(_selectedTipe!),
      subtipe: MaintenanceSubtype.fromString(_selectedSubtipe!),
      waktuMulai: _waktuMulai!,
      waktuSelesai: _waktuSelesai,
      status: MaintenanceStatus.fromString(_selectedStatus!),
    );

    // TODO: Dispatch to BLoC for backend integration
    debugPrint('Maintenance form submitted: $entity');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEditMode
              ? 'Jadwal berhasil diperbarui'
              : 'Jadwal berhasil ditambahkan',
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
              // ─── Top bar ───
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
                    widget.isEditMode ? 'Edit Jadwal' : 'Tambah Jadwal',
                    style: theme.textTheme.headlineLarge,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ─── Form card ───
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
                            'Informasi Jadwal',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Row 1: Nama Teknisi & Ruangan
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CustomTextForm(
                              title: 'Nama Teknisi',
                              hintText: 'Masukkan nama teknisi',
                              isRequired: true,
                              controller: _teknisiController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nama teknisi wajib diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: CustomTextForm(
                              title: 'Ruangan',
                              hintText: 'Masukkan nama ruangan',
                              isRequired: true,
                              controller: _ruanganController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Ruangan wajib diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Row 2: Tipe, Subtipe, Status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _DropdownField(
                              title: 'Tipe',
                              isRequired: true,
                              hint: 'Pilih tipe',
                              value: _selectedTipe,
                              items: MaintenanceType.displayNames,
                              onChanged: (v) =>
                                  setState(() => _selectedTipe = v),
                              validator: (v) =>
                                  v == null ? 'Tipe wajib dipilih' : null,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _DropdownField(
                              title: 'Subtipe',
                              isRequired: true,
                              hint: 'Pilih subtipe',
                              value: _selectedSubtipe,
                              items: MaintenanceSubtype.displayNames,
                              onChanged: (v) =>
                                  setState(() => _selectedSubtipe = v),
                              validator: (v) =>
                                  v == null ? 'Subtipe wajib dipilih' : null,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _DropdownField(
                              title: 'Status',
                              isRequired: true,
                              hint: 'Pilih status',
                              value: _selectedStatus,
                              items: MaintenanceStatus.displayNames,
                              onChanged: (v) =>
                                  setState(() => _selectedStatus = v),
                              validator: (v) =>
                                  v == null ? 'Status wajib dipilih' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Row 3: Waktu Mulai & Waktu Selesai
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _DateTimePickerField(
                              title: 'Waktu Mulai',
                              isRequired: true,
                              value: _waktuMulai,
                              onTap: () => _pickDateTime(isStart: true),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _DateTimePickerField(
                              title: 'Waktu Selesai',
                              value: _waktuSelesai,
                              onTap: () => _pickDateTime(isStart: false),
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

// ─── DateTime picker field ───

class _DateTimePickerField extends StatelessWidget {
  const _DateTimePickerField({
    required this.title,
    required this.onTap,
    this.value,
    this.isRequired = false,
  });

  final String title;
  final DateTime? value;
  final bool isRequired;
  final VoidCallback onTap;

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
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null
                        ? MaintenanceEntity.formatDateTime(value)
                        : 'Pilih tanggal & waktu',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: value != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Reusable dropdown field ───

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
