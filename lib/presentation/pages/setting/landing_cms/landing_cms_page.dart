import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';

import 'package:frontend/core/theme/app_shadows.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/presentation/bloc/setting/setting_bloc.dart';
import 'package:frontend/presentation/bloc/setting/setting_event.dart';
import 'package:frontend/presentation/bloc/setting/setting_state.dart';
import 'package:frontend/presentation/bloc/room_list/room_bloc.dart';
import 'package:frontend/presentation/bloc/room_list/room_event.dart';
import 'package:frontend/presentation/bloc/room_list/room_state.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';

import 'widgets/fasilitas_chip_input.dart';

@RoutePage()
class LandingCmsPage extends StatefulWidget {
  const LandingCmsPage({super.key});

  @override
  State<LandingCmsPage> createState() => _LandingCmsPageState();
}

class _LandingCmsPageState extends State<LandingCmsPage> {
  final _formKey = GlobalKey<FormState>();

  final _headerTitleController = TextEditingController();
  final _headerSubtitleController = TextEditingController();

  List<String> _fasilitas = [];
  List<int> _selectedRoomIds = [];

  bool _isInit = false;
  bool _hasUnsavedChanges = false;
  String _kamarSearch = '';

  late String _initialHeaderTitle;
  late String _initialHeaderSubtitle;
  late List<String> _initialFasilitas;
  late List<int> _initialSelectedRoomIds;

  @override
  void initState() {
    super.initState();
    _headerTitleController.addListener(_checkChanges);
    _headerSubtitleController.addListener(_checkChanges);
  }

  @override
  void dispose() {
    _headerTitleController.removeListener(_checkChanges);
    _headerSubtitleController.removeListener(_checkChanges);
    _headerTitleController.dispose();
    _headerSubtitleController.dispose();
    super.dispose();
  }

  void _checkChanges() {
    if (!_isInit) return;

    bool changed =
        _headerTitleController.text != _initialHeaderTitle ||
        _headerSubtitleController.text != _initialHeaderSubtitle ||
        _fasilitas.join(',') != _initialFasilitas.join(',') ||
        _selectedRoomIds.join(',') != _initialSelectedRoomIds.join(',');

    if (_hasUnsavedChanges != changed) {
      setState(() => _hasUnsavedChanges = changed);
    }
  }

  void _handleSave(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final updatedSettings = {
        'landing_header_title': _headerTitleController.text,
        'landing_header_subtitle': _headerSubtitleController.text,
        'landing_facilities': _fasilitas.join(', '),
        'landing_highlighted_rooms': _selectedRoomIds,
      };

      context.read<SettingBloc>().add(UpdateSettingsEvent(updatedSettings));
    }
  }

  Widget _buildLabeledField({
    required String label,
    bool isRequired = false,
    required TextEditingController controller,
    int maxLines = 1,
    int? maxLength,
    String? hintText,
    String? helperText,
  }) {
    final c = AppTheme.colors(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: c.textPrimary,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 3),
              Text(
                '*',
                style: TextStyle(color: c.statusCancelled, fontSize: 13),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          style: TextStyle(fontSize: 14, color: c.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: c.textHint, fontSize: 14),
            helperText: helperText,
            helperStyle: TextStyle(color: c.textHint, fontSize: 11),
            counterStyle: TextStyle(color: c.textHint, fontSize: 11),
            filled: true,
            fillColor: c.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: c.borderLight),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: c.borderLight),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: c.primary, width: 1.5),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          validator: isRequired
              ? (v) => (v == null || v.trim().isEmpty)
                    ? 'Field ini wajib diisi'
                    : null
              : null,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required Widget child,
    bool expandChild = false,
  }) {
    final c = AppTheme.colors(context);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: c.borderLight),
        boxShadow: const [AppShadows.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: c.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: c.borderLight, height: 1),
          expandChild
              ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: child,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: child,
                ),
        ],
      ),
    );
  }

  Widget _buildKamarCard(
    RoomEntity kamar,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final c = AppTheme.colors(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? c.primary : c.borderLight,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: c.primary.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : const [AppShadows.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusMd - 1),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: kamar.imageUrl.isNotEmpty
                        ? Image.network(
                            kamar.imageUrl.first.fullImageUrl,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: c.surfaceVariant,
                            child: Center(
                              child: Icon(
                                Icons.bed_outlined,
                                size: 32,
                                color: c.textHint,
                              ),
                            ),
                          ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: c.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kamar.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? c.primary : c.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    kamar.priceFormatted,
                    style: TextStyle(fontSize: 12, color: c.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.colors(context);

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Perubahan belum disimpan'),
            content: const Text(
              'Anda memiliki perubahan yang belum disimpan. '
              'Yakin ingin meninggalkan halaman ini?',
            ),
            actions: [
              TextButton(
                child: const Text('Tetap di sini'),
                onPressed: () => Navigator.pop(context, false),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.statusCancelled,
                ),
                child: const Text(
                  'Tinggalkan',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        );
        if (shouldLeave == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                serviceLocator<SettingBloc>()..add(FetchSettingsEvent()),
          ),
          BlocProvider(
            create: (_) =>
                serviceLocator<RoomBloc>()..add(const GetRoomsEvent()),
          ),
        ],
        child: Scaffold(
          backgroundColor: c.background,
          appBar: AppBar(
            backgroundColor: c.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            toolbarHeight: 0, // We use custom header instead
          ),
          body: BlocConsumer<SettingBloc, SettingState>(
            listener: (context, state) {
              if (state is SettingUpdateSuccess) {
                _initialHeaderTitle = _headerTitleController.text;
                _initialHeaderSubtitle = _headerSubtitleController.text;
                _initialFasilitas = List.from(_fasilitas);
                _initialSelectedRoomIds = List.from(_selectedRoomIds);
                setState(() => _hasUnsavedChanges = false);
                AppSnackbar.showSuccess(
                  'Pengaturan landing page berhasil disimpan.',
                );
              } else if (state is SettingError) {
                AppSnackbar.showError('Gagal menyimpan. Coba lagi.');
              } else if (state is SettingLoaded && !_isInit) {
                _headerTitleController.text =
                    state.entity.getString('landing_header_title') ?? '';
                _headerSubtitleController.text =
                    state.entity.getString('landing_header_subtitle') ?? '';
                final facilitiesStr =
                    state.entity.getString('landing_facilities') ?? '';
                _fasilitas = facilitiesStr.isEmpty
                    ? []
                    : facilitiesStr
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                final idsStringList = state.entity.getList(
                  'landing_highlighted_rooms',
                );
                _selectedRoomIds = idsStringList
                    .map((e) => int.tryParse(e) ?? 0)
                    .where((id) => id > 0)
                    .toList();

                _initialHeaderTitle = _headerTitleController.text;
                _initialHeaderSubtitle = _headerSubtitleController.text;
                _initialFasilitas = List.from(_fasilitas);
                _initialSelectedRoomIds = List.from(_selectedRoomIds);

                _isInit = true;
              }
            },
            builder: (context, state) {
              if (state is SettingLoading && state is! SettingLoaded) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  // Custom Header / TopBar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: c.surface,
                      border: Border(bottom: BorderSide(color: c.borderLight)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Pengaturan Landing Page',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: c.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 24,
                                        ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  if (_hasUnsavedChanges)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: c.statusWaitingBg,
                                        border: Border.all(
                                          color: c.statusWaitingBorder,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: c.statusWaiting,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            'Belum Disimpan',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: c.statusWaiting,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Kelola konten yang ditampilkan pada halaman publik kost Anda.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: c.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              context.router.navigate(LandingRoute()),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.public, size: 16),
                          label: const Text(
                            'Lihat Landing Page',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        ElevatedButton.icon(
                          onPressed:
                              (_hasUnsavedChanges && state is! SettingLoading)
                              ? () => _handleSave(context)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: c.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: c.borderLight,
                            disabledForegroundColor: c.textHint,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                            ),
                          ),
                          icon: state is SettingLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined, size: 16),
                          label: Text(
                            state is SettingLoading
                                ? 'Menyimpan...'
                                : 'Simpan Perubahan',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Content
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 1024;

                          Widget heroSection = _buildSectionCard(
                            icon: Icons.text_fields_rounded,
                            iconColor: c.primary,
                            iconBg: c.primaryLight,
                            title: 'Hero Section',
                            subtitle:
                                'Teks utama yang pertama dilihat pengunjung.',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabeledField(
                                  label: 'Judul Utama',
                                  isRequired: true,
                                  controller: _headerTitleController,
                                  hintText:
                                      'Misal: Kos Nyaman & Aman di Gorontalo',
                                  maxLength: 80,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                _buildLabeledField(
                                  label: 'Sub-judul',
                                  controller: _headerSubtitleController,
                                  hintText:
                                      'Nikmati fasilitas lengkap dengan harga terjangkau...',
                                  maxLength: 160,
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          );

                          Widget fasilitasSection = _buildSectionCard(
                            icon: Icons.star_outline_rounded,
                            iconColor: const Color(0xFF7C3AED),
                            iconBg: const Color(0xFFF5F3FF),
                            title: 'Fasilitas Utama',
                            subtitle: 'Nilai jual utama kost Anda.',
                            child: FasilitasChipInput(
                              initialValues: _fasilitas,
                              onChanged: (updated) {
                                setState(() {
                                  _fasilitas = updated;
                                  _checkChanges();
                                });
                              },
                            ),
                          );

                          Widget kamarSection = _buildSectionCard(
                            icon: Icons.hotel_outlined,
                            iconColor: const Color(0xFF0891B2),
                            iconBg: const Color(0xFFECFEFF),
                            title: 'Kamar Unggulan',
                            subtitle:
                                'Pilih kamar yang ditampilkan di halaman depan.',
                            expandChild: isWide,
                            child: BlocBuilder<RoomBloc, RoomState>(
                              builder: (context, roomState) {
                                if (roomState.status ==
                                        FormzSubmissionStatus.initial ||
                                    roomState.status ==
                                        FormzSubmissionStatus.inProgress) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (roomState.status ==
                                    FormzSubmissionStatus.failure) {
                                  return Text(
                                    'Gagal memuat kamar: ${roomState.errorMessage}',
                                  );
                                }

                                final rooms = roomState.rooms;
                                final filteredKamar = rooms
                                    .where(
                                      (r) => r.title.toLowerCase().contains(
                                        _kamarSearch.toLowerCase(),
                                      ),
                                    )
                                    .toList();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextField(
                                      onChanged: (v) =>
                                          setState(() => _kamarSearch = v),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: c.textPrimary,
                                      ),
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.search,
                                          size: 18,
                                          color: c.textHint,
                                        ),
                                        hintText: 'Cari nama kamar...',
                                        hintStyle: TextStyle(
                                          color: c.textHint,
                                          fontSize: 13,
                                        ),
                                        filled: true,
                                        fillColor: c.surfaceVariant,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.md,
                                              vertical: AppSpacing.sm,
                                            ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: c.borderLight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusMd,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: c.borderLight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusMd,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: c.primary,
                                            width: 1.5,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusMd,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    if (filteredKamar.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.all(
                                          AppSpacing.lg,
                                        ),
                                        child: Center(
                                          child: Text(
                                            _kamarSearch.isEmpty
                                                ? 'Belum ada data kamar'
                                                : 'Tidak ada kamar yang cocok',
                                            style: TextStyle(
                                              color: c.textSecondary,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      isWide
                                          ? Expanded(
                                              child: GridView.builder(
                                                shrinkWrap: false,
                                                physics:
                                                    const AlwaysScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              childAspectRatio: 0.85,
                                              crossAxisSpacing: AppSpacing.sm,
                                              mainAxisSpacing: AppSpacing.sm,
                                            ),
                                        itemCount: filteredKamar.length,
                                        itemBuilder: (ctx, i) =>
                                            _buildKamarCard(
                                              filteredKamar[i],
                                              _selectedRoomIds.contains(
                                                filteredKamar[i].id,
                                              ),
                                              () {
                                                setState(() {
                                                  if (_selectedRoomIds.contains(
                                                    filteredKamar[i].id,
                                                  )) {
                                                    _selectedRoomIds.remove(
                                                      filteredKamar[i].id,
                                                    );
                                                  } else {
                                                    _selectedRoomIds.add(
                                                      filteredKamar[i].id,
                                                    );
                                                  }
                                                  _checkChanges();
                                                });
                                              },
                                            ),
                                              ),
                                            )
                                          : GridView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 3,
                                                    childAspectRatio: 0.85,
                                                    crossAxisSpacing: AppSpacing.sm,
                                                    mainAxisSpacing: AppSpacing.sm,
                                                  ),
                                              itemCount: filteredKamar.length,
                                              itemBuilder: (ctx, i) =>
                                                  _buildKamarCard(
                                                    filteredKamar[i],
                                                    _selectedRoomIds.contains(
                                                      filteredKamar[i].id,
                                                    ),
                                                    () {
                                                      setState(() {
                                                        if (_selectedRoomIds.contains(
                                                          filteredKamar[i].id,
                                                        )) {
                                                          _selectedRoomIds.remove(
                                                            filteredKamar[i].id,
                                                          );
                                                        } else {
                                                          _selectedRoomIds.add(
                                                            filteredKamar[i].id,
                                                          );
                                                        }
                                                        _checkChanges();
                                                      });
                                                    },
                                                  ),
                                            ),
                                    const SizedBox(height: AppSpacing.md),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: AppSpacing.sm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _selectedRoomIds.isEmpty
                                            ? c.surfaceVariant
                                            : c.primaryLight,
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusSm,
                                        ),
                                        border: Border.all(
                                          color: _selectedRoomIds.isEmpty
                                              ? c.borderLight
                                              : c.primary.withValues(
                                                  alpha: 0.3,
                                                ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _selectedRoomIds.isEmpty
                                                ? Icons.info_outline
                                                : Icons.check_circle_outline,
                                            size: 16,
                                            color: _selectedRoomIds.isEmpty
                                                ? c.textHint
                                                : c.primary,
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Text(
                                            _selectedRoomIds.isEmpty
                                                ? 'Belum ada kamar dipilih'
                                                : '${_selectedRoomIds.length} kamar dipilih untuk ditampilkan',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: _selectedRoomIds.isEmpty
                                                  ? c.textHint
                                                  : c.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          );

                          if (isWide) {
                            return Padding(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 55,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          heroSection,
                                          const SizedBox(height: AppSpacing.lg),
                                          fasilitasSection,
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.lg),
                                  Expanded(
                                    flex: 45,
                                    child: kamarSection,
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return SingleChildScrollView(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Column(
                                children: [
                                  heroSection,
                                  const SizedBox(height: AppSpacing.lg),
                                  fasilitasSection,
                                  const SizedBox(height: AppSpacing.lg),
                                  kamarSection,
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
