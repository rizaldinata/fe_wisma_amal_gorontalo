import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../domain/entity/setting/midtrans_method_entity.dart';
import '../../bloc/payment_method_setting/payment_method_setting_cubit.dart';
import '../../bloc/setting/setting_bloc.dart';
import '../../bloc/setting/setting_event.dart';
import '../../bloc/setting/setting_state.dart';
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

  final _wismaNameController = TextEditingController();
  bool _featureDailyRental = false;
  bool _featureWhatsappReceipt = false;
  bool _featureWhatsappPdfLink = false;
  bool _featurePaymentMidtrans = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _bloc = serviceLocator.get<SettingBloc>();
    _bloc.add(FetchSettingsEvent());
    _paymentCubit = serviceLocator.get<PaymentMethodSettingCubit>();
    _paymentCubit.load();
  }

  @override
  void dispose() {
    _wismaNameController.dispose();
    _paymentCubit.close();
    super.dispose();
  }

  void _populateData(Map<String, dynamic> settings) {
    _wismaNameController.text = settings['wisma_name']?.toString() ?? 'Wisma Amal Gorontalo';
    _featureDailyRental      = settings['feature_daily_rental'] == true || settings['feature_daily_rental']?.toString() == 'true';
    _featureWhatsappReceipt  = settings['feature_whatsapp_receipt'] == true || settings['feature_whatsapp_receipt']?.toString() == 'true';
    _featureWhatsappPdfLink  = settings['feature_whatsapp_pdf_link'] == true || settings['feature_whatsapp_pdf_link']?.toString() == 'true';
    _featurePaymentMidtrans  = settings['feature_payment_midtrans'] == true || settings['feature_payment_midtrans']?.toString() == 'true';
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Expanded(child: Text('Aktifkan minimal satu metode pembayaran Midtrans terlebih dahulu.')),
          ]),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        return;
      }
    }
    final payload = {
      'wisma_name': _wismaNameController.text.trim(),
      'feature_daily_rental': _featureDailyRental,
      'feature_whatsapp_receipt': _featureWhatsappReceipt,
      'feature_whatsapp_pdf_link': _featureWhatsappPdfLink,
      'feature_payment_midtrans': _featurePaymentMidtrans,
    };
    _bloc.add(UpdateSettingsEvent(payload));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _bloc),
        BlocProvider.value(value: _paymentCubit),
      ],
      child: BlocConsumer<SettingBloc, SettingState>(
        listener: (context, state) {
          if (state is SettingLoaded) {
            setState(() => _populateData(state.entity.settings));
          } else if (state is SettingUpdateSuccess) {
            setState(() => _populateData(state.entity.settings));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                  SizedBox(width: 10),
                  Text('Pengaturan berhasil disimpan'),
                ]),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          } else if (state is SettingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal: ${state.message}'),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingInitial || (state is SettingLoading && _wismaNameController.text.isEmpty)) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          final isSaving = state is SettingLoading;

          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // ── Header ────────────────────────────────────────────
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
                  const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Pengaturan Aplikasi', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text('Kelola konfigurasi umum dan fitur sistem wisma.', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ]),
                  // Tombol simpan
                  isSaving
                      ? const SizedBox(
                          width: 140,
                          height: 44,
                          child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))),
                        )
                      : FilledButton.icon(
                          onPressed: _hasChanges ? _saveSettings : null,
                          icon: const Icon(Icons.save_outlined, size: 18),
                          label: const Text('Simpan Perubahan'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                ]),
                const SizedBox(height: 32),

                // ── Informasi Wisma ────────────────────────────────────
                _SectionCard(
                  icon: Icons.apartment_outlined,
                  color: Colors.blue.shade600,
                  title: 'Informasi Wisma',
                  subtitle: 'Data identitas wisma yang ditampilkan pada invoice dan notifikasi.',
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Nama Wisma / Kos', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _wismaNameController,
                      onChanged: (_) => _markChanged(),
                      decoration: InputDecoration(
                        hintText: 'Contoh: Wisma Amal Gorontalo',
                        prefixIcon: const Icon(Icons.apartment_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 20),

                // ── Fitur Sistem ───────────────────────────────────────
                _SectionCard(
                  icon: Icons.tune_outlined,
                  color: Colors.purple.shade600,
                  title: 'Fitur Sistem',
                  subtitle: 'Aktifkan atau nonaktifkan fitur tertentu sesuai kebutuhan operasional.',
                  child: Column(children: [
                    _FeatureToggle(
                      icon: Icons.today_outlined,
                      iconColor: Colors.teal.shade600,
                      title: 'Sewa Harian',
                      description: 'Izinkan penghuni menyewa kamar per hari (mode hotel/kos harian). Jika dinonaktifkan, hanya sewa bulanan yang tersedia.',
                      value: _featureDailyRental,
                      onChanged: (val) { setState(() => _featureDailyRental = val); _markChanged(); },
                    ),
                    const SizedBox(height: 12),
                    _FeatureToggle(
                      icon: Icons.chat_outlined,
                      iconColor: Colors.green.shade600,
                      title: 'Notifikasi WhatsApp Struk Pembayaran',
                      description: 'Kirim pesan WhatsApp otomatis ke penghuni setiap kali pembayaran berhasil diverifikasi oleh admin.',
                      value: _featureWhatsappReceipt,
                      onChanged: (val) { setState(() => _featureWhatsappReceipt = val); _markChanged(); },
                    ),
                    const SizedBox(height: 12),
                    _FeatureToggle(
                      icon: Icons.picture_as_pdf_outlined,
                      iconColor: Colors.deepOrange.shade600,
                      title: 'Sertakan Link PDF Invoice di WA',
                      description: 'Tambahkan link unduh invoice PDF ke dalam pesan WhatsApp struk. Membutuhkan fitur notifikasi WA aktif.',
                      value: _featureWhatsappPdfLink,
                      onChanged: _featureWhatsappReceipt
                          ? (val) { setState(() => _featureWhatsappPdfLink = val); _markChanged(); }
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _FeatureToggle(
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: Colors.indigo.shade600,
                      title: 'Pembayaran Midtrans (Online)',
                      description: 'Aktifkan integrasi Midtrans untuk pembayaran melalui Virtual Account, QRIS, dan metode online lainnya.',
                      value: _featurePaymentMidtrans,
                      onChanged: (val) {
                        setState(() => _featurePaymentMidtrans = val);
                        _markChanged();
                      },
                    ),
                    if (!_featureWhatsappReceipt) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 52),
                        child: Text(
                          'Aktifkan "Notifikasi WhatsApp Struk" terlebih dahulu untuk menggunakan fitur ini.',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ]),
                ),
                if (_featurePaymentMidtrans) ...[
                const SizedBox(height: 20),

                // ── Metode Pembayaran Midtrans ─────────────────────────
                _SectionCard(
                  icon: Icons.payment_rounded,
                  color: Colors.teal.shade600,
                  title: 'Metode Pembayaran Midtrans',
                  subtitle: 'Pilih metode yang tersedia untuk penghuni. Toggle tersimpan otomatis.',
                  child: BlocConsumer<PaymentMethodSettingCubit, PaymentMethodSettingState>(
                    listener: (context, pmState) {
                      if (pmState is PaymentMethodSettingSaved) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Row(children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 18),
                            SizedBox(width: 10),
                            Text('Metode pembayaran diperbarui'),
                          ]),
                          backgroundColor: Colors.teal.shade600,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          duration: const Duration(seconds: 2),
                        ));
                      } else if (pmState is PaymentMethodSettingError) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Gagal: ${pmState.message}'),
                          backgroundColor: Colors.red.shade600,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ));
                      }
                    },
                    builder: (context, pmState) {
                      if (pmState is PaymentMethodSettingInitial || pmState is PaymentMethodSettingLoading) {
                        return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                      }
                      if (pmState is PaymentMethodSettingError) {
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text('Gagal memuat metode: ${pmState.message}', style: TextStyle(color: Colors.red.shade600)),
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

                      final isSaving = pmState is PaymentMethodSettingSaving;
                      final enabledCount = methods.where((m) => m.enabled).length;
                      final showWarning = methods.isNotEmpty && enabledCount == 0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showWarning)
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.orange.shade300),
                              ),
                              child: Row(children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 18),
                                const SizedBox(width: 10),
                                const Expanded(child: Text(
                                  'Tidak ada metode yang aktif. Aktifkan minimal satu metode, atau matikan fitur Midtrans.',
                                  style: TextStyle(fontSize: 12, height: 1.4),
                                )),
                              ]),
                            ),
                          GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          mainAxisExtent: 52,
                        ),
                        itemCount: methods.length,
                        itemBuilder: (context, index) {
                          final method = methods[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: method.enabled ? Colors.teal.shade50 : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: method.enabled ? Colors.teal.shade200 : Colors.grey.shade200,
                              ),
                            ),
                            child: SwitchListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              dense: true,
                              title: Text(
                                method.label,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              value: method.enabled,
                              activeColor: Colors.teal.shade600,
                              onChanged: isSaving
                                  ? null
                                  : (val) {
                                      if (!val && enabledCount <= 1 && method.enabled) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: const Row(children: [
                                            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                                            SizedBox(width: 10),
                                            Expanded(child: Text('Minimal satu metode harus aktif selama Midtrans dinyalakan.')),
                                          ]),
                                          backgroundColor: Colors.orange.shade700,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ));
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
                  ),
                ),
                ], // end if (_featurePaymentMidtrans)

                // Indikator perubahan belum disimpan
                if (_hasChanges) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(children: [
                      Icon(Icons.edit_note, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 10),
                      Text('Ada perubahan yang belum disimpan.', style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      TextButton(onPressed: () => _bloc.add(FetchSettingsEvent()), child: const Text('Reset')),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _saveSettings,
                        style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: const Text('Simpan Sekarang'),
                      ),
                    ]),
                  ),
                ],
                const SizedBox(height: 32),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({required this.icon, required this.color, required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return BasicCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Section header
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ])),
          ]),
          const Divider(height: 28),
          child,
        ]),
      ),
    );
  }
}

// ── Feature Toggle Row ────────────────────────────────────────────────────────
class _FeatureToggle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool>? onChanged; // nullable = disabled

  const _FeatureToggle({required this.icon, required this.iconColor, required this.title, required this.description, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDisabled = onChanged == null;
    final effectiveColor = isDisabled ? Colors.grey.shade400 : iconColor;

    return AnimatedOpacity(
      opacity: isDisabled ? 0.55 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (!isDisabled && value) ? iconColor.withOpacity(0.05) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: (!isDisabled && value) ? iconColor.withOpacity(0.3) : Colors.grey.shade200),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: effectiveColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: effectiveColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, height: 1.4)),
          ])),
          const SizedBox(width: 12),
          Switch(value: value, onChanged: onChanged, activeColor: iconColor),
        ]),
      ),
    );
  }
}
