import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entity/setting/bank_account_entity.dart';
import '../../bloc/bank_account/bank_account_cubit.dart';
import '../../bloc/setting/setting_bloc.dart';
import '../../bloc/setting/setting_event.dart';
import '../../bloc/setting/setting_state.dart';
import '../../widget/core/appbar/app_topbar.dart';
import '../../widget/core/card/basic_card.dart';

@RoutePage()
class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late SettingBloc _bloc;
  late BankAccountCubit _bankAccountCubit;

  final _wismaNameController = TextEditingController();
  final _wismaAddressController = TextEditingController();
  final _wismaPhoneController = TextEditingController();
  final _wismaEmailController = TextEditingController();
  final _wismaMapsLinkController = TextEditingController();
  final _wismaOperationalHoursController = TextEditingController();
  bool _featureDailyRental = false;
  bool _featureWhatsappReceipt = false;
  bool _featureWhatsappPdfLink = false;
  bool _featurePaymentMidtrans = true;
  bool _featurePengeluaranTetap = false;
  final Set<String> _jenisAktif = {};
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _bloc = serviceLocator.get<SettingBloc>();
    _bloc.add(FetchSettingsEvent());
    _bankAccountCubit = serviceLocator.get<BankAccountCubit>();
    _bankAccountCubit.load();
  }

  @override
  void dispose() {
    _wismaNameController.dispose();
    _wismaAddressController.dispose();
    _wismaPhoneController.dispose();
    _wismaEmailController.dispose();
    _wismaMapsLinkController.dispose();
    _wismaOperationalHoursController.dispose();
    _bankAccountCubit.close();
    super.dispose();
  }

  void _populateData(Map<String, dynamic> settings) {
    _wismaNameController.text = settings['wisma_name']?.toString() ?? 'Wisma Amal Gorontalo';
    _wismaAddressController.text = settings['wisma_address']?.toString() ?? 'Jl. Wisma Amal No. 1, Gorontalo';
    _wismaPhoneController.text = settings['wisma_phone']?.toString() ?? '0811-4300-XXX';
    _wismaEmailController.text = settings['wisma_email']?.toString() ?? 'wismaamal@email.com';
    _wismaMapsLinkController.text = settings['wisma_maps_link']?.toString() ?? 'https://maps.google.com';
    _wismaOperationalHoursController.text = settings['wisma_operational_hours']?.toString() ?? 'Senin - Sabtu, 08.00 - 17.00 WITA';
    _featureDailyRental         = settings['feature_daily_rental'] == true || settings['feature_daily_rental']?.toString() == 'true';
    _featureWhatsappReceipt   = settings['feature_whatsapp_receipt'] == true || settings['feature_whatsapp_receipt']?.toString() == 'true';
    _featureWhatsappPdfLink   = settings['feature_whatsapp_pdf_link'] == true || settings['feature_whatsapp_pdf_link']?.toString() == 'true';
    _featurePaymentMidtrans   = settings['feature_payment_midtrans'] == true || settings['feature_payment_midtrans']?.toString() == 'true';
    _featurePengeluaranTetap  = settings['feature_pengeluaran_tetap'] == true || settings['feature_pengeluaran_tetap']?.toString() == 'true';
    _jenisAktif.clear();
    final rawJenis = settings['pengeluaran_tetap_jenis_aktif'];
    if (rawJenis is List) {
      _jenisAktif.addAll(rawJenis.map((e) => e.toString()));
    }
    _hasChanges = false;
  }

  void _markChanged() => setState(() => _hasChanges = true);

  void _saveSettings() {
    final payload = {
      'wisma_name': _wismaNameController.text.trim(),
      'wisma_address': _wismaAddressController.text.trim(),
      'wisma_phone': _wismaPhoneController.text.trim(),
      'wisma_email': _wismaEmailController.text.trim(),
      'wisma_maps_link': _wismaMapsLinkController.text.trim(),
      'wisma_operational_hours': _wismaOperationalHoursController.text.trim(),
      'feature_daily_rental': _featureDailyRental,
      'feature_whatsapp_receipt': _featureWhatsappReceipt,
      'feature_whatsapp_pdf_link': _featureWhatsappPdfLink,
      'feature_payment_midtrans': _featurePaymentMidtrans,
      'feature_pengeluaran_tetap': _featurePengeluaranTetap,
      'pengeluaran_tetap_jenis_aktif': _jenisAktif.toList(),
    };
    _bloc.add(UpdateSettingsEvent(payload));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final bgColor = isDark ? AppColorsDark.background : AppColorsLight.background;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _bloc),
        BlocProvider.value(value: _bankAccountCubit),
      ],
      child: BlocConsumer<SettingBloc, SettingState>(
        listener: (context, state) {
          if (state is SettingLoaded) {
            setState(() => _populateData(state.entity.settings));
          } else if (state is SettingUpdateSuccess) {
            setState(() => _populateData(state.entity.settings));
            final doneColor = isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(children: [
                Icon(Icons.check_circle, color: doneColor, size: 18),
                const SizedBox(width: 10),
                Text('Pengaturan berhasil disimpan', style: TextStyle(color: doneColor)),
              ]),
              backgroundColor: isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
              margin: const EdgeInsets.all(AppSpacing.lg),
            ));
          } else if (state is SettingError) {
            final cancelColor = isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(children: [
                Icon(Icons.error_outline, color: cancelColor, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text('Gagal: ${state.message}', style: TextStyle(color: cancelColor))),
              ]),
              backgroundColor: isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
              margin: const EdgeInsets.all(AppSpacing.lg),
            ));
          }
        },
        builder: (context, state) {
          if (state is SettingInitial || (state is SettingLoading && _wismaNameController.text.isEmpty)) {
            return Scaffold(
              backgroundColor: bgColor,
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          final isSaving = state is SettingLoading;

          return Scaffold(
            backgroundColor: bgColor,
            body: Column(
              children: [
                AppTopBar(
                  title: 'Pengaturan Aplikasi',
                  breadcrumb: 'Pengaturan / Umum',
                  action: isSaving
                      ? const SizedBox(
                          width: 140,
                          height: 36,
                          child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5))),
                        )
                      : ElevatedButton.icon(
                          onPressed: _hasChanges ? _saveSettings : null,
                          icon: const Icon(Icons.save_outlined, size: 18),
                          label: const Text('Simpan Perubahan'),
                        ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionCard(
                          isDark: isDark,
                          icon: Icons.apartment_outlined,
                          accentColor: isDark ? AppColorsDark.primary : AppColorsLight.primary,
                          title: 'Informasi Wisma',
                          subtitle: 'Data identitas wisma yang ditampilkan pada invoice dan notifikasi.',
                          child: _buildWismaInfoFields(isDark),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        _SectionCard(
                          isDark: isDark,
                          icon: Icons.account_balance_outlined,
                          accentColor: isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess,
                          title: 'Rekening Bank Pemilik',
                          subtitle: 'Daftar rekening transfer manual yang ditampilkan kepada penghuni saat pembayaran.',
                          child: _buildRekeningBankCrud(isDark),
                        ),
                        const SizedBox(height: AppSpacing.xl),


                        _SectionCard(
                          isDark: isDark,
                          icon: Icons.tune_outlined,
                          accentColor: isDark ? AppColorsDark.primaryDark : AppColorsLight.primaryDark,
                          title: 'Fitur Sistem',
                          subtitle: 'Aktifkan atau nonaktifkan fitur tertentu sesuai kebutuhan operasional.',
                          child: _buildFiturSistem(isDark),
                        ),

                        const SizedBox(height: AppSpacing.xxxl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWismaInfoFields(bool isDark) {
    final borderColor = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final borderMedColor = isDark ? AppColorsDark.borderMedium : AppColorsLight.borderMedium;
    final textSecColor = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

    Widget _buildField(String label, String hint, IconData icon, TextEditingController controller) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecColor),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            onChanged: (_) => _markChanged(),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                borderSide: BorderSide(color: borderMedColor),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField('Nama Wisma / Kos', 'Contoh: Wisma Amal Gorontalo', Icons.apartment_outlined, _wismaNameController),
        const SizedBox(height: AppSpacing.md),
        _buildField('Alamat Wisma', 'Contoh: Jl. Wisma Amal No. 1, Gorontalo', Icons.location_on_outlined, _wismaAddressController),
        const SizedBox(height: AppSpacing.md),
        _buildField('Kontak / No. Telepon', 'Contoh: 0811-4300-XXX', Icons.phone_outlined, _wismaPhoneController),
        const SizedBox(height: AppSpacing.md),
        _buildField('Alamat Email', 'Contoh: wismaamal@email.com', Icons.email_outlined, _wismaEmailController),
        const SizedBox(height: AppSpacing.md),
        _buildField('Link Google Maps', 'Contoh: https://maps.google.com/...', Icons.map_outlined, _wismaMapsLinkController),
        const SizedBox(height: AppSpacing.md),
        _buildField('Jam Operasional', 'Contoh: Senin - Sabtu, 08.00 - 17.00 WITA', Icons.access_time_outlined, _wismaOperationalHoursController),
      ],
    );
  }

  Widget _buildFiturSistem(bool isDark) {
    final surfaceVariant = isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
    final borderColor = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final primaryColor = isDark ? AppColorsDark.primary : AppColorsLight.primary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          onTap: () {
            context.router.push(const FeatureToggleRoute());
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.settings_suggest_outlined, color: primaryColor, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kelola Fitur & Modul',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Mengaktifkan atau menonaktifkan modul dan fitur secara granular di seluruh sistem.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRekeningBankCrud(bool isDark) {
    final surfaceVariant = isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
    final borderColor    = isDark ? AppColorsDark.borderLight    : AppColorsLight.borderLight;
    final textPrimary    = isDark ? AppColorsDark.textPrimary    : AppColorsLight.textPrimary;
    final textSecondary  = isDark ? AppColorsDark.textSecondary  : AppColorsLight.textSecondary;
    final textHint       = isDark ? AppColorsDark.textHint       : AppColorsLight.textHint;
    final cancelColor    = isDark ? AppColorsDark.statusCancelled: AppColorsLight.statusCancelled;
    final cancelBg       = isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg;
    final processColor   = isDark ? AppColorsDark.statusProcess  : AppColorsLight.statusProcess;
    final doneColor      = isDark ? AppColorsDark.statusDone     : AppColorsLight.statusDone;
    final doneBg         = isDark ? AppColorsDark.statusDoneBg   : AppColorsLight.statusDoneBg;
    final infoColor      = textSecondary;
    final infoBg         = surfaceVariant;
    final infoBorder     = borderColor;

    return BlocBuilder<BankAccountCubit, BankAccountState>(
      builder: (context, state) {
        final accounts = state is BankAccountLoaded ? state.accounts : <BankAccountEntity>[];
        final isLoading = state is BankAccountLoading;
        final actionError = state is BankAccountLoaded ? state.actionError : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (actionError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(color: cancelBg, borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                  child: Text(actionError, style: TextStyle(color: cancelColor, fontSize: 12)),
                ),
              ),

            if (isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.lg), child: CircularProgressIndicator()))
            else if (accounts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  'Belum ada rekening bank. Tambahkan untuk ditampilkan ke penghuni.',
                  style: TextStyle(fontSize: 13, color: textHint),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...accounts.map((account) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(account.bankName,
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                                      const SizedBox(width: AppSpacing.sm),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: account.isActive ? doneBg : cancelBg,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          account.isActive ? 'Aktif' : 'Nonaktif',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: account.isActive ? doneColor : cancelColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(account.accountNumber,
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: 1)),
                                  Text('a.n. ${account.accountHolder}',
                                      style: TextStyle(fontSize: 12, color: textHint)),
                                  if (account.paymentInstructions != null && account.paymentInstructions!.isNotEmpty) ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(account.paymentInstructions!,
                                        style: TextStyle(fontSize: 12, color: textSecondary)),
                                  ],
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit_outlined, size: 18, color: processColor),
                                  tooltip: 'Edit',
                                  onPressed: () => _showBankAccountDialog(context, isDark, existing: account),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, size: 18, color: cancelColor),
                                  tooltip: 'Hapus',
                                  onPressed: () => _confirmDeleteBankAccount(context, isDark, account),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),

            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showBankAccountDialog(context, isDark),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah Rekening Bank'),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
              decoration: BoxDecoration(
                color: infoBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: infoBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: infoColor),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Rekening ini hanya ditampilkan sebagai referensi transfer manual untuk penghuni. '
                      'Untuk mengubah rekening pencairan dana Midtrans, login ke dashboard Midtrans secara langsung.',
                      style: TextStyle(fontSize: 12, color: infoColor, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBankAccountDialog(BuildContext context, bool isDark, {BankAccountEntity? existing}) {
    final bankNameCtrl    = TextEditingController(text: existing?.bankName ?? '');
    final accountNumCtrl  = TextEditingController(text: existing?.accountNumber ?? '');
    final holderCtrl      = TextEditingController(text: existing?.accountHolder ?? '');
    final instrCtrl       = TextEditingController(text: existing?.paymentInstructions ?? '');
    bool isActive         = existing?.isActive ?? true;
    final cubit           = context.read<BankAccountCubit>();

    final borderColor    = isDark ? AppColorsDark.borderLight  : AppColorsLight.borderLight;
    final borderMedColor = isDark ? AppColorsDark.borderMedium : AppColorsLight.borderMedium;
    final textSecColor   = isDark ? AppColorsDark.textSecondary: AppColorsLight.textSecondary;

    Widget field(String label, String hint, IconData icon, TextEditingController ctrl, {int maxLines = 1}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecColor)),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: maxLines == 1 ? Icon(icon, size: 18) : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: borderMedColor),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
            ),
          ),
        ],
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
          title: Text(existing == null ? 'Tambah Rekening Bank' : 'Edit Rekening Bank'),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  field('Nama Bank', 'Contoh: BSI / BCA / BRI', Icons.account_balance_outlined, bankNameCtrl),
                  const SizedBox(height: AppSpacing.md),
                  field('Nomor Rekening', 'Contoh: 7000001234', Icons.credit_card_outlined, accountNumCtrl),
                  const SizedBox(height: AppSpacing.md),
                  field('Atas Nama', 'Contoh: Pemilik Wisma', Icons.person_outline, holderCtrl),
                  const SizedBox(height: AppSpacing.md),
                  field('Cara Pembayaran (Opsional)', 'Contoh: Transfer sesuai nominal tagihan dan kirim bukti.',
                      Icons.info_outline, instrCtrl, maxLines: 3),
                  const SizedBox(height: AppSpacing.md),
                  SwitchListTile(
                    value: isActive,
                    onChanged: (val) => setLocalState(() => isActive = val),
                    title: Text('Rekening Aktif', style: TextStyle(fontSize: 13, color: textSecColor)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final name   = bankNameCtrl.text.trim();
                final number = accountNumCtrl.text.trim();
                final holder = holderCtrl.text.trim();
                if (name.isEmpty || number.isEmpty || holder.isEmpty) return;

                final data = {
                  'bank_name':            name,
                  'account_number':       number,
                  'account_holder':       holder,
                  'payment_instructions': instrCtrl.text.trim().isEmpty ? null : instrCtrl.text.trim(),
                  'is_active':            isActive,
                };

                if (existing == null) {
                  cubit.create(data);
                } else {
                  cubit.update(existing.id, data);
                }
                Navigator.pop(ctx);
              },
              child: Text(existing == null ? 'Tambah' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteBankAccount(BuildContext context, bool isDark, BankAccountEntity account) {
    final cancelColor = isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled;
    final cubit = context.read<BankAccountCubit>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
        title: const Text('Hapus Rekening Bank?'),
        content: Text(
          'Rekening "${account.bankName} - ${account.accountNumber}" akan dihapus dan tidak lagi ditampilkan ke penghuni.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: cancelColor, foregroundColor: Colors.white),
            onPressed: () {
              cubit.delete(account.id);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }


}

// ── Section Card ──────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.isDark,
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final textSecColor = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

    return BasicCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 12, color: textSecColor)),
            ])),
          ]),
          const Divider(height: AppSpacing.xxxl - 4),
          child,
        ]),
      ),
    );
  }
}

