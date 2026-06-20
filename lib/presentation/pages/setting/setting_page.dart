import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entity/setting/bank_account_entity.dart';
import '../../../domain/entity/setting/midtrans_fee_config_entity.dart';
import '../../../domain/entity/setting/midtrans_method_entity.dart';
import '../../bloc/bank_account/bank_account_cubit.dart';
import '../../bloc/midtrans_fee/midtrans_fee_cubit.dart';
import '../../bloc/payment_method_setting/payment_method_setting_cubit.dart';
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
  late PaymentMethodSettingCubit _paymentCubit;
  late BankAccountCubit _bankAccountCubit;
  late MidtransFeeCubit _midtransFeeCubit;

  final _wismaNameController = TextEditingController();
  bool _featureDailyRental = false;
  bool _featureWhatsappReceipt = false;
  bool _featureWhatsappPdfLink = false;
  bool _featurePaymentMidtrans = true;
  bool _featurePengeluaranTetap = false;
  final Set<String> _jenisAktif = {};
  bool _hasChanges = false;

  static const _allJenis = {'listrik', 'air', 'wifi'};
  static const _jenisLabel = {'listrik': 'Listrik', 'air': 'Air', 'wifi': 'WiFi'};

  @override
  void initState() {
    super.initState();
    _bloc = serviceLocator.get<SettingBloc>();
    _bloc.add(FetchSettingsEvent());
    _paymentCubit = serviceLocator.get<PaymentMethodSettingCubit>();
    _paymentCubit.load();
    _bankAccountCubit = serviceLocator.get<BankAccountCubit>();
    _bankAccountCubit.load();
    _midtransFeeCubit = serviceLocator.get<MidtransFeeCubit>();
    _midtransFeeCubit.load();
  }

  @override
  void dispose() {
    _wismaNameController.dispose();
    _paymentCubit.close();
    _bankAccountCubit.close();
    _midtransFeeCubit.close();
    super.dispose();
  }

  void _populateData(Map<String, dynamic> settings) {
    _wismaNameController.text = settings['wisma_name']?.toString() ?? 'Wisma Amal Gorontalo';
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

  List<MidtransMethodEntity> _currentPaymentMethods() {
    final s = _paymentCubit.state;
    if (s is PaymentMethodSettingLoaded) return s.methods;
    if (s is PaymentMethodSettingSaving) return s.methods;
    if (s is PaymentMethodSettingSaved) return s.methods;
    return [];
  }

  void _saveSettings() {
    if (_featurePaymentMidtrans) {
      final methods = _currentPaymentMethods();
      if (methods.isNotEmpty && !methods.any((m) => m.enabled)) {
        _showWarningSnackBar('Aktifkan minimal satu metode pembayaran Midtrans terlebih dahulu.');
        return;
      }
    }
    if (_featurePengeluaranTetap && _jenisAktif.isEmpty) {
      _showWarningSnackBar('Pilih minimal satu jenis utilitas untuk fitur Pengeluaran Tetap.');
      return;
    }
    final payload = {
      'wisma_name': _wismaNameController.text.trim(),
      'feature_daily_rental': _featureDailyRental,
      'feature_whatsapp_receipt': _featureWhatsappReceipt,
      'feature_whatsapp_pdf_link': _featureWhatsappPdfLink,
      'feature_payment_midtrans': _featurePaymentMidtrans,
      'feature_pengeluaran_tetap': _featurePengeluaranTetap,
      'pengeluaran_tetap_jenis_aktif': _jenisAktif.toList(),
    };
    _bloc.add(UpdateSettingsEvent(payload));
  }

  void _showWarningSnackBar(String message) {
    final isDark = AppTheme.isDark(context);
    final warningColor = isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(Icons.warning_amber_rounded, color: warningColor, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: TextStyle(color: warningColor))),
      ]),
      backgroundColor: isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
      margin: const EdgeInsets.all(AppSpacing.lg),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final bgColor = isDark ? AppColorsDark.background : AppColorsLight.background;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _bloc),
        BlocProvider.value(value: _paymentCubit),
        BlocProvider.value(value: _bankAccountCubit),
        BlocProvider.value(value: _midtransFeeCubit),
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
                          child: _buildWismaNameField(isDark),
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

                        if (_featurePengeluaranTetap) ...[
                          const SizedBox(height: AppSpacing.xl),
                          _SectionCard(
                            isDark: isDark,
                            icon: Icons.bolt_outlined,
                            accentColor: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting,
                            title: 'Jenis Utilitas Pengeluaran Tetap',
                            subtitle: 'Pilih jenis utilitas yang akan dipantau setiap bulan (minimal satu).',
                            child: _buildJenisUtilitas(isDark),
                          ),
                        ],

                        if (_featurePaymentMidtrans) ...[
                          const SizedBox(height: AppSpacing.xl),
                          _SectionCard(
                            isDark: isDark,
                            icon: Icons.payment_rounded,
                            accentColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
                            title: 'Metode Pembayaran Midtrans',
                            subtitle: 'Pilih metode yang tersedia untuk penghuni. Toggle tersimpan otomatis.',
                            child: _buildPaymentMethods(isDark),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _SectionCard(
                            isDark: isDark,
                            icon: Icons.percent_rounded,
                            accentColor: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting,
                            title: 'Biaya Transaksi Midtrans',
                            subtitle: 'Atur siapa yang menanggung biaya transaksi dan besaran tarifnya.',
                            child: _buildMidtransFeeSetting(isDark),
                          ),
                        ],

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

  Widget _buildWismaNameField(bool isDark) {
    final borderColor = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final borderMedColor = isDark ? AppColorsDark.borderMedium : AppColorsLight.borderMedium;
    final textSecColor = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nama Wisma / Kos',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecColor),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _wismaNameController,
          onChanged: (_) => _markChanged(),
          decoration: InputDecoration(
            hintText: 'Contoh: Wisma Amal Gorontalo',
            prefixIcon: const Icon(Icons.apartment_outlined, size: 20),
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

  Widget _buildFiturSistem(bool isDark) {
    final warningColor = isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FeatureToggle(
          isDark: isDark,
          icon: Icons.today_outlined,
          accentColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
          title: 'Sewa Harian',
          description: 'Izinkan penghuni menyewa kamar per hari (mode hotel/kos harian). Jika dinonaktifkan, hanya sewa bulanan yang tersedia.',
          value: _featureDailyRental,
          onChanged: (val) { setState(() => _featureDailyRental = val); _markChanged(); },
        ),
        const SizedBox(height: AppSpacing.md),
        _FeatureToggle(
          isDark: isDark,
          icon: Icons.chat_outlined,
          accentColor: isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess,
          title: 'Notifikasi WhatsApp Struk Pembayaran',
          description: 'Kirim pesan WhatsApp otomatis ke penghuni setiap kali pembayaran berhasil diverifikasi oleh admin.',
          value: _featureWhatsappReceipt,
          onChanged: (val) { setState(() => _featureWhatsappReceipt = val); _markChanged(); },
        ),
        const SizedBox(height: AppSpacing.md),
        _FeatureToggle(
          isDark: isDark,
          icon: Icons.picture_as_pdf_outlined,
          accentColor: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
          title: 'Sertakan Link PDF Invoice di WA',
          description: 'Tambahkan link unduh invoice PDF ke dalam pesan WhatsApp struk. Membutuhkan fitur notifikasi WA aktif.',
          value: _featureWhatsappPdfLink,
          onChanged: _featureWhatsappReceipt
              ? (val) { setState(() => _featureWhatsappPdfLink = val); _markChanged(); }
              : null,
        ),
        if (!_featureWhatsappReceipt) ...[
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Text(
              'Aktifkan "Notifikasi WhatsApp Struk" terlebih dahulu untuk menggunakan fitur ini.',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColorsDark.textHint : AppColorsLight.textHint,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        _FeatureToggle(
          isDark: isDark,
          icon: Icons.account_balance_wallet_outlined,
          accentColor: isDark ? AppColorsDark.primaryDark : AppColorsLight.primary,
          title: 'Pembayaran Midtrans (Online)',
          description: 'Aktifkan integrasi Midtrans untuk pembayaran melalui Virtual Account, QRIS, dan metode online lainnya.',
          value: _featurePaymentMidtrans,
          onChanged: (val) { setState(() => _featurePaymentMidtrans = val); _markChanged(); },
        ),
        const SizedBox(height: AppSpacing.md),
        _FeatureToggle(
          isDark: isDark,
          icon: Icons.bolt_outlined,
          accentColor: warningColor,
          title: 'Pengeluaran Tetap (Listrik, Air, WiFi)',
          description: 'Aktifkan untuk mendapat pengingat mengisi nominal biaya utilitas setiap bulan. Dashboard akan menampilkan indikator "Belum Diisi" jika belum dicatat.',
          value: _featurePengeluaranTetap,
          onChanged: (val) {
            setState(() {
              _featurePengeluaranTetap = val;
              if (!val) _jenisAktif.clear();
            });
            _markChanged();
          },
        ),
      ],
    );
  }

  Widget _buildJenisUtilitas(bool isDark) {
    final warningColor = isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;
    final warningBg = isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg;
    final warningBorder = isDark ? AppColorsDark.statusWaitingBorder : AppColorsLight.statusWaitingBorder;
    final borderColor = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final primaryColor = isDark ? AppColorsDark.primary : AppColorsLight.primary;
    final primaryBg = isDark ? AppColorsDark.primaryLight : AppColorsLight.primaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_jenisAktif.isEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
            decoration: BoxDecoration(
              color: warningBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: warningBorder),
            ),
            child: Row(children: [
              Icon(Icons.warning_amber_rounded, color: warningColor, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(
                'Pilih minimal satu jenis utilitas sebelum menyimpan.',
                style: TextStyle(fontSize: 12, color: warningColor),
              )),
            ]),
          ),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _allJenis.map((jenis) {
            final isSelected = _jenisAktif.contains(jenis);
            return FilterChip(
              label: Text(_jenisLabel[jenis] ?? jenis),
              selected: isSelected,
              selectedColor: primaryBg,
              checkmarkColor: primaryColor,
              side: BorderSide(color: isSelected ? primaryColor : borderColor),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _jenisAktif.add(jenis);
                  } else {
                    _jenisAktif.remove(jenis);
                  }
                });
                _markChanged();
              },
            );
          }).toList(),
        ),
      ],
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

  Widget _buildMidtransFeeSetting(bool isDark) {
    final cancelColor = isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled;
    final doneColor   = isDark ? AppColorsDark.statusDone      : AppColorsLight.statusDone;
    final doneBg      = isDark ? AppColorsDark.statusDoneBg    : AppColorsLight.statusDoneBg;

    return BlocConsumer<MidtransFeeCubit, MidtransFeeState>(
      listener: (context, state) {
        if (state is MidtransFeeSaved) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [
              Icon(Icons.check_circle, color: doneColor, size: 18),
              const SizedBox(width: 10),
              Text('Pengaturan biaya Midtrans disimpan', style: TextStyle(color: doneColor)),
            ]),
            backgroundColor: doneBg,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
            margin: const EdgeInsets.all(AppSpacing.lg),
            duration: const Duration(seconds: 2),
          ));
        } else if (state is MidtransFeeError) {
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
        if (state is MidtransFeeInitial || state is MidtransFeeLoading) {
          return const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.lg), child: CircularProgressIndicator()));
        }
        if (state is MidtransFeeError) {
          return Text('Gagal memuat: ${state.message}', style: TextStyle(color: cancelColor));
        }

        final config = state is MidtransFeeLoaded ? state.config
                     : state is MidtransFeeSaving ? state.config
                     : state is MidtransFeeSaved  ? state.config
                     : null;
        if (config == null) return const SizedBox.shrink();

        return _MidtransFeeSettingBody(
          isDark: isDark,
          config: config,
          isSaving: state is MidtransFeeSaving,
          cubit: context.read<MidtransFeeCubit>(),
        );
      },
    );
  }

  Widget _buildPaymentMethods(bool isDark) {
    final warningColor = isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;
    final warningBg = isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg;
    final warningBorder = isDark ? AppColorsDark.statusWaitingBorder : AppColorsLight.statusWaitingBorder;
    final activeColor = isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone;
    final activeBg = isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg;
    final activeBorder = isDark ? AppColorsDark.statusDoneBorder : AppColorsLight.statusDoneBorder;
    final surfaceVariant = isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
    final borderColor = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;

    return BlocConsumer<PaymentMethodSettingCubit, PaymentMethodSettingState>(
      listener: (context, pmState) {
        if (pmState is PaymentMethodSettingSaved) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [
              Icon(Icons.check_circle, color: activeColor, size: 18),
              const SizedBox(width: 10),
              Text('Metode pembayaran diperbarui', style: TextStyle(color: activeColor)),
            ]),
            backgroundColor: activeBg,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
            margin: const EdgeInsets.all(AppSpacing.lg),
            duration: const Duration(seconds: 2),
          ));
        } else if (pmState is PaymentMethodSettingError) {
          final cancelColor = isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [
              Icon(Icons.error_outline, color: cancelColor, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text('Gagal: ${pmState.message}', style: TextStyle(color: cancelColor))),
            ]),
            backgroundColor: isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
            margin: const EdgeInsets.all(AppSpacing.lg),
          ));
        }
      },
      builder: (context, pmState) {
        if (pmState is PaymentMethodSettingInitial || pmState is PaymentMethodSettingLoading) {
          return const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.lg), child: CircularProgressIndicator()));
        }
        if (pmState is PaymentMethodSettingError) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Text(
              'Gagal memuat metode: ${pmState.message}',
              style: TextStyle(color: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled),
            ),
          );
        }

        final List<MidtransMethodEntity> methods;
        if (pmState is PaymentMethodSettingLoaded) {
          methods = pmState.methods;
        } else if (pmState is PaymentMethodSettingSaving) {
          methods = pmState.methods;
        } else if (pmState is PaymentMethodSettingSaved) {
          methods = pmState.methods;
        } else {
          methods = [];
        }

        final isSavingPm = pmState is PaymentMethodSettingSaving;
        final enabledCount = methods.where((m) => m.enabled).length;
        final showWarning = methods.isNotEmpty && enabledCount == 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showWarning)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
                decoration: BoxDecoration(
                  color: warningBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: warningBorder),
                ),
                child: Row(children: [
                  Icon(Icons.warning_amber_rounded, color: warningColor, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(
                    'Tidak ada metode yang aktif. Aktifkan minimal satu metode, atau matikan fitur Midtrans.',
                    style: TextStyle(fontSize: 12, height: 1.4, color: warningColor),
                  )),
                ]),
              ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisExtent: 52,
              ),
              itemCount: methods.length,
              itemBuilder: (context, index) {
                final method = methods[index];
                return Container(
                  decoration: BoxDecoration(
                    color: method.enabled ? activeBg : surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: method.enabled ? activeBorder : borderColor),
                  ),
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    dense: true,
                    title: Text(
                      method.label,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    value: method.enabled,
                    activeColor: activeColor,
                    onChanged: isSavingPm
                        ? null
                        : (val) {
                            if (!val && enabledCount <= 1 && method.enabled) {
                              _showWarningSnackBar('Minimal satu metode harus aktif selama Midtrans dinyalakan.');
                              return;
                            }
                            final enabledCodes = methods
                                .where((m) => m.code == method.code ? val : m.enabled)
                                .map((m) => m.code)
                                .toList();
                            context.read<PaymentMethodSettingCubit>().save(enabledCodes);
                          },
                  ),
                );
              },
            ),
          ],
        );
      },
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

// ── Feature Toggle Row ────────────────────────────────────────────────────────
class _FeatureToggle extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color accentColor;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _FeatureToggle({
    required this.isDark,
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onChanged == null;
    final effectiveColor = isDisabled
        ? (isDark ? AppColorsDark.textHint : AppColorsLight.textHint)
        : accentColor;
    final inactiveBg = isDark ? AppColorsDark.surface : AppColorsLight.surface;
    final inactiveBorder = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final textSecColor = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

    return AnimatedOpacity(
      opacity: isDisabled ? 0.55 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: (!isDisabled && value) ? accentColor.withOpacity(0.06) : inactiveBg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: (!isDisabled && value) ? accentColor.withOpacity(0.3) : inactiveBorder,
          ),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: effectiveColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, color: effectiveColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(description, style: TextStyle(fontSize: 12, color: textSecColor, height: 1.4)),
          ])),
          const SizedBox(width: AppSpacing.md),
          Switch(value: value, onChanged: onChanged, activeColor: accentColor),
        ]),
      ),
    );
  }
}

class _MidtransFeeSettingBody extends StatefulWidget {
  final bool isDark;
  final MidtransFeeConfigEntity config;
  final bool isSaving;
  final MidtransFeeCubit cubit;

  const _MidtransFeeSettingBody({
    required this.isDark,
    required this.config,
    required this.isSaving,
    required this.cubit,
  });

  @override
  State<_MidtransFeeSettingBody> createState() => _MidtransFeeSettingBodyState();
}

class _MidtransFeeSettingBodyState extends State<_MidtransFeeSettingBody> {
  late Map<String, TextEditingController> _controllers;
  final TextEditingController _simulationCtrl = TextEditingController(text: '100000');

  @override
  void initState() {
    super.initState();
    _controllers = _buildControllers(widget.config);
    _simulationCtrl.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(_MidtransFeeSettingBody old) {
    super.didUpdateWidget(old);
    // Update controller values when config changes (e.g. after save), but only
    // if the fee list changed (different keys or a new bearer-change reload).
    final oldKeys = old.config.fees.map((f) => f.key).join(',');
    final newKeys = widget.config.fees.map((f) => f.key).join(',');
    if (oldKeys != newKeys) {
      _disposeControllers();
      _controllers = _buildControllers(widget.config);
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    _simulationCtrl.dispose();
    super.dispose();
  }

  Map<String, TextEditingController> _buildControllers(MidtransFeeConfigEntity config) =>
      {
        for (final fee in config.fees)
          fee.key: TextEditingController(
            text: fee.type == 'flat'
                ? (fee.amount?.toStringAsFixed(0) ?? '0')
                : (fee.rate?.toString() ?? '0'),
          ),
      };

  void _disposeControllers() {
    for (final ctrl in _controllers.values) {
      ctrl.dispose();
    }
  }

  MidtransFeeConfigEntity _buildUpdatedConfig(String bearer) {
    final newFees = widget.config.fees.map((fee) {
      final raw = double.tryParse(_controllers[fee.key]?.text ?? '') ?? 0;
      return MidtransFeeItemEntity(
        key: fee.key, label: fee.label, type: fee.type,
        amount: fee.type == 'flat' ? raw : null,
        rate:   fee.type == 'percent' ? raw : null,
      );
    }).toList();
    return MidtransFeeConfigEntity(bearer: bearer, fees: newFees);
  }

  @override
  Widget build(BuildContext context) {
    final isDark        = widget.isDark;
    final config        = widget.config;
    final isSaving      = widget.isSaving;
    final cubit         = widget.cubit;

    final surfaceVariant = isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
    final borderColor    = isDark ? AppColorsDark.borderLight    : AppColorsLight.borderLight;
    final textPrimary    = isDark ? AppColorsDark.textPrimary    : AppColorsLight.textPrimary;
    final textSecondary  = isDark ? AppColorsDark.textSecondary  : AppColorsLight.textSecondary;
    final textHint       = isDark ? AppColorsDark.textHint       : AppColorsLight.textHint;
    final primaryColor   = isDark ? AppColorsDark.primary        : AppColorsLight.primary;
    final warningColor   = isDark ? AppColorsDark.statusWaiting  : AppColorsLight.statusWaiting;
    final warningBg      = isDark ? AppColorsDark.statusWaitingBg: AppColorsLight.statusWaitingBg;

    final isCustomer = config.isCustomerBearer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Pilihan bearer ─────────────────────────────────────────────
        Text('Biaya ditanggung oleh',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        Row(children: [
          _BearerOption(
            isDark: isDark,
            label: 'Wisma (Merchant)',
            description: 'Biaya dipotong dari penerimaan wisma. Penghuni bayar sesuai tagihan.',
            icon: Icons.store_outlined,
            selected: !isCustomer,
            accentColor: primaryColor,
            onTap: isSaving ? null : () => cubit.save(_buildUpdatedConfig('merchant')),
          ),
          const SizedBox(width: AppSpacing.md),
          _BearerOption(
            isDark: isDark,
            label: 'Penghuni',
            description: 'Biaya ditambahkan ke tagihan penghuni saat checkout.',
            icon: Icons.person_outline,
            selected: isCustomer,
            accentColor: warningColor,
            onTap: isSaving ? null : () => cubit.save(_buildUpdatedConfig('customer')),
          ),
        ]),

        if (isCustomer) ...[
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
            decoration: BoxDecoration(
              color: warningBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: warningColor.withOpacity(0.4)),
            ),
            child: Row(children: [
              Icon(Icons.info_outline, size: 16, color: warningColor),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(
                'Biaya akan ditambahkan ke tagihan penghuni saat memilih metode pembayaran online.',
                style: TextStyle(fontSize: 12, color: warningColor, height: 1.4),
              )),
            ]),
          ),
        ],

        // ── Tabel tarif ────────────────────────────────────────────────
        const SizedBox(height: AppSpacing.xl),
        Row(children: [
          Expanded(
            child: Text('Tarif Biaya per Metode',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary)),
          ),
        ]),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
          decoration: BoxDecoration(
            color: isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: (isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.verified_outlined, size: 15,
                  color: isDark ? AppColorsDark.primary : AppColorsLight.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                        fontSize: 11,
                        color: textSecondary,
                        height: 1.45),
                    children: [
                      const TextSpan(
                          text: 'Tarif di bawah sesuai ketentuan resmi Midtrans. '),
                      TextSpan(
                          text: 'Jangan ubah kecuali ada pembaruan tarif dari Midtrans.',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: config.fees.asMap().entries.map((entry) {
              final index  = entry.key;
              final fee    = entry.value;
              final ctrl   = _controllers[fee.key]!;
              final isLast = index == config.fees.length - 1;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fee.label,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
                            Text(fee.type == 'flat' ? 'Flat per transaksi' : 'Persentase dari nominal',
                                style: TextStyle(fontSize: 11, color: textHint)),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: ctrl,
                          enabled: !isSaving,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                            suffixText: fee.type == 'flat' ? 'Rp' : '%',
                            suffixStyle: TextStyle(fontSize: 12, color: textHint),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                              borderSide: BorderSide(color: borderColor),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  if (!isLast) Divider(height: 1, color: borderColor),
                ],
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isSaving ? null : () => cubit.save(_buildUpdatedConfig(config.bearer)),
            icon: isSaving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_outlined, size: 18),
            label: Text(isSaving ? 'Menyimpan...' : 'Simpan Tarif'),
          ),
        ),

        // ── Simulasi biaya ─────────────────────────────────────────────
        const SizedBox(height: AppSpacing.xl),
        Divider(color: borderColor),
        const SizedBox(height: AppSpacing.lg),
        Row(children: [
          Icon(Icons.calculate_outlined, size: 16, color: textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Text('Simulasi Biaya',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary)),
        ]),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Masukkan nominal untuk melihat perkiraan biaya yang ditanggung dan uang yang diterima.',
          style: TextStyle(fontSize: 11, color: textHint, height: 1.4),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _simulationCtrl,
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
          decoration: InputDecoration(
            labelText: 'Nominal Pembayaran',
            prefixText: 'Rp ',
            prefixStyle: TextStyle(fontSize: 14, color: textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(color: borderColor),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildSimulationTable(config, isCustomer, textPrimary, textSecondary, textHint, borderColor, surfaceVariant, primaryColor, warningColor, isDark),
      ],
    );
  }

  Widget _buildSimulationTable(
    MidtransFeeConfigEntity config,
    bool isCustomer,
    Color textPrimary,
    Color textSecondary,
    Color textHint,
    Color borderColor,
    Color surfaceVariant,
    Color primaryColor,
    Color warningColor,
    bool isDark,
  ) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final nominal = double.tryParse(_simulationCtrl.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;

    if (nominal <= 0) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text('Masukkan nominal di atas untuk melihat simulasi.',
              style: TextStyle(fontSize: 12, color: textHint)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: (isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight).withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMd)),
            ),
            child: Row(children: [
              Expanded(flex: 3, child: Text('Metode',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textSecondary))),
              Expanded(flex: 3, child: Text('Biaya',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textSecondary))),
              Expanded(flex: 4, child: Text('Dibayar Penghuni',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                      color: isCustomer ? warningColor : textSecondary))),
              Expanded(flex: 4, child: Text('Diterima Wisma',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                      color: primaryColor))),
            ]),
          ),
          ...config.fees.asMap().entries.map((entry) {
            final index  = entry.key;
            final fee    = entry.value;
            final isLast = index == config.fees.length - 1;

            final rawVal  = double.tryParse(_controllers[fee.key]?.text ?? '') ?? 0;
            final feeAmt  = fee.type == 'flat' ? rawVal : (nominal * rawVal / 100).roundToDouble();
            final customerPays  = isCustomer ? nominal + feeAmt : nominal;
            final adminReceives = isCustomer ? nominal           : nominal - feeAmt;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
                  child: Row(children: [
                    Expanded(flex: 3, child: Text(fee.label,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textPrimary))),
                    Expanded(flex: 3, child: Text(fmt.format(feeAmt),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: textHint))),
                    Expanded(flex: 4, child: Text(fmt.format(customerPays),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isCustomer ? warningColor : textPrimary))),
                    Expanded(flex: 4, child: Text(fmt.format(adminReceives),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: primaryColor))),
                  ]),
                ),
                if (!isLast) Divider(height: 1, color: borderColor),
              ],
            );
          }),
          // Footer note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: (isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight).withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppSpacing.radiusMd)),
            ),
            child: Row(children: [
              Icon(Icons.info_outline, size: 12, color: textHint),
              const SizedBox(width: 4),
              Expanded(child: Text(
                isCustomer
                    ? 'Bearer: Penghuni — biaya ditambahkan ke tagihan. Wisma menerima penuh ${fmt.format(nominal)}.'
                    : 'Bearer: Wisma — penghuni bayar ${fmt.format(nominal)}, selisih biaya ditanggung wisma.',
                style: TextStyle(fontSize: 10, color: textHint, height: 1.3),
              )),
            ]),
          ),
        ],
      ),
    );
  }
}

class _BearerOption extends StatelessWidget {
  final bool isDark;
  final String label;
  final String description;
  final IconData icon;
  final bool selected;
  final Color accentColor;
  final VoidCallback? onTap;

  const _BearerOption({
    required this.isDark,
    required this.label,
    required this.description,
    required this.icon,
    required this.selected,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceVariant = isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
    final borderColor    = isDark ? AppColorsDark.borderLight    : AppColorsLight.borderLight;
    final textPrimary    = isDark ? AppColorsDark.textPrimary    : AppColorsLight.textPrimary;
    final textSecondary  = isDark ? AppColorsDark.textSecondary  : AppColorsLight.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? accentColor.withOpacity(0.08) : surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: selected ? accentColor.withOpacity(0.5) : borderColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, size: 16, color: selected ? accentColor : textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected ? accentColor : textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle, size: 14, color: accentColor),
              ]),
              const SizedBox(height: 4),
              Text(description,
                style: TextStyle(fontSize: 10, color: textSecondary, height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
