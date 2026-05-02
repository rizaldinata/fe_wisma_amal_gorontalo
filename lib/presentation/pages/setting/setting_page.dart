import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
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

  final _wismaNameController = TextEditingController();
  bool _featureDailyRental = false;
  bool _featureWhatsappReceipt = false;
  bool _featureWhatsappPdfLink = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _bloc = serviceLocator.get<SettingBloc>();
    _bloc.add(FetchSettingsEvent());
  }

  @override
  void dispose() {
    _wismaNameController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _populateData(Map<String, dynamic> settings) {
    _wismaNameController.text = settings['wisma_name']?.toString() ?? 'Wisma Amal Gorontalo';
    _featureDailyRental      = settings['feature_daily_rental'] == true || settings['feature_daily_rental']?.toString() == 'true';
    _featureWhatsappReceipt  = settings['feature_whatsapp_receipt'] == true || settings['feature_whatsapp_receipt']?.toString() == 'true';
    _featureWhatsappPdfLink  = settings['feature_whatsapp_pdf_link'] == true || settings['feature_whatsapp_pdf_link']?.toString() == 'true';
    _hasChanges = false;
  }

  void _markChanged() => setState(() => _hasChanges = true);

  void _saveSettings() {
    final payload = {
      'wisma_name': _wismaNameController.text.trim(),
      'feature_daily_rental': _featureDailyRental,
      'feature_whatsapp_receipt': _featureWhatsappReceipt,
      'feature_whatsapp_pdf_link': _featureWhatsappPdfLink,
    };
    _bloc.add(UpdateSettingsEvent(payload));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
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
                const SizedBox(height: 20),

                // ── Info Midtrans (read-only dari ENV) ─────────────────
                _SectionCard(
                  icon: Icons.payment_outlined,
                  color: Colors.orange.shade600,
                  title: 'Konfigurasi Pembayaran (Midtrans)',
                  subtitle: 'Konfigurasi Midtrans dikelola melalui file .env di server.',
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade800, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Dikelola via Environment Variable', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            SizedBox(height: 4),
                            Text(
                              'Konfigurasi Midtrans (Server Key & Client Key) kini dibaca langsung dari file .env di server backend untuk keamanan yang lebih baik. '
                              'Untuk mengubahnya, edit file .env dan restart server.',
                              style: TextStyle(fontSize: 13, height: 1.5),
                            ),
                          ]),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    // Info item
                    _EnvInfoRow(label: 'MIDTRANS_SERVER_KEY', hint: 'SB-Mid-server-xxxx... / Mid-server-xxxx...'),
                    const SizedBox(height: 8),
                    _EnvInfoRow(label: 'MIDTRANS_CLIENT_KEY', hint: 'SB-Mid-client-xxxx... / Mid-client-xxxx...'),
                    const SizedBox(height: 8),
                    _EnvInfoRow(label: 'MIDTRANS_IS_PRODUCTION', hint: 'true = Production, false = Sandbox'),
                  ]),
                ),
                const SizedBox(height: 20),

                // ── Info WhatsApp (ENV) ─────────────────────────────────
                _SectionCard(
                  icon: Icons.phone_android_outlined,
                  color: Colors.green.shade600,
                  title: 'Token WhatsApp (Fonnte)',
                  subtitle: 'Token API Fonnte untuk pengiriman notifikasi WhatsApp.',
                  child: Column(children: [
                    _EnvInfoRow(label: 'FONNTE_API_TOKEN', hint: 'Token API dari dashboard Fonnte.com'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)),
                      child: Row(children: [
                        Icon(Icons.info_outline, color: Colors.green.shade700, size: 16),
                        const SizedBox(width: 10),
                        const Expanded(child: Text('Token dikelola di file .env server. Aktifkan toggle notifikasi WA di atas untuk mulai mengirim struk otomatis.', style: TextStyle(fontSize: 12, height: 1.4))),
                      ]),
                    ),
                  ]),
                ),

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

// ── ENV Info Row ──────────────────────────────────────────────────────────────
class _EnvInfoRow extends StatelessWidget {
  final String label;
  final String hint;

  const _EnvInfoRow({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(children: [
        const Icon(Icons.key_outlined, size: 16, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.w600)),
          Text(hint, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
          child: Text('.env', style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}
