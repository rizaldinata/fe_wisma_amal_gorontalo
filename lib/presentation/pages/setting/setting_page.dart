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

  // Controllers
  final _appNameController = TextEditingController();
  final _serverKeyController = TextEditingController();
  final _clientKeyController = TextEditingController();

  // Toggles
  bool _featureMidtrans = false;
  bool _featureDailyRental = false;
  
  // Payment Checkboxes
  bool _payCash = false;
  bool _payBankTransfer = false;
  bool _payQris = false;

  bool _isObscureServerKey = true;

  @override
  void initState() {
    super.initState();
    _bloc = serviceLocator.get<SettingBloc>();
    _bloc.add(FetchSettingsEvent());
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _serverKeyController.dispose();
    _clientKeyController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _populateData(Map<String, dynamic> settings) {
    _appNameController.text = _getString(settings, 'app_name') ?? 'Wisma Amal Gorontalo';
    _serverKeyController.text = _getString(settings, 'midtrans_server_key') ?? '';
    _clientKeyController.text = _getString(settings, 'midtrans_client_key') ?? '';

    _featureMidtrans = _getString(settings, 'feature-midtrans-payment') == 'true';
    _featureDailyRental = _getString(settings, 'feature-daily-rental') == 'true';

    final enabledPaymentsStr = _getString(settings, 'enabled-payments') ?? '[]';
    _payCash = enabledPaymentsStr.contains('cash');
    _payBankTransfer = enabledPaymentsStr.contains('bank_transfer');
    _payQris = enabledPaymentsStr.contains('qris');
  }

  String? _getString(Map<String, dynamic> src, String key) {
    if(!src.containsKey(key)) return null;
    return src[key].toString();
  }

  void _saveSettings() {
    List<String> enabledPayments = [];
    if (_payCash) enabledPayments.add('cash');
    if (_payBankTransfer) enabledPayments.add('bank_transfer');
    if (_payQris) enabledPayments.add('qris');

    final updated = {
      'app_name': _appNameController.text,
      'feature-midtrans-payment': _featureMidtrans.toString(),
      'feature-daily-rental': _featureDailyRental.toString(),
      'enabled-payments': enabledPayments,
    };

    if (_serverKeyController.text.isNotEmpty && !_serverKeyController.text.contains('****')) {
      updated['midtrans_server_key'] = _serverKeyController.text;
    }
    if (_clientKeyController.text.isNotEmpty && !_clientKeyController.text.contains('****')) {
      updated['midtrans_client_key'] = _clientKeyController.text;
    }

    _bloc.add(UpdateSettingsEvent(updated));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<SettingBloc, SettingState>(
        listener: (context, state) {
          if (state is SettingUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pengaturan berhasil diperbarui')),
            );
            _populateData(state.entity.settings);
          } else if (state is SettingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal: ${state.message}'), backgroundColor: Colors.red),
            );
          } else if (state is SettingLoaded) {
            _populateData(state.entity.settings);
          }
        },
        builder: (context, state) {
          if (state is SettingInitial || state is SettingLoading && _appNameController.text.isEmpty) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Pengaturan Aplikasi (SaaS Mode)'),
              actions: [
                if (state is SettingLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                  )
                else
                  TextButton.icon(
                    onPressed: _saveSettings,
                    icon: const Icon(Icons.save),
                    label: const Text('Simpan'),
                  ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: BasicCard(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Informasi Aplikasi'),
                      TextField(
                        controller: _appNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Kos / Wisma',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SwitchListTile(
                        title: const Text('Fitur Penyewaan Harian (Hotel)'),
                        subtitle: const Text('Izinkan pelanggan menyewa untuk durasi kurang dari 1 bulan.'),
                        value: _featureDailyRental,
                        onChanged: (val) => setState(() => _featureDailyRental = val),
                      ),
                      
                      const Divider(height: 40),
                      
                      _buildSectionTitle('Konfigurasi Pembayaran (Midtrans)'),
                      SwitchListTile(
                        title: const Text('Aktifkan Gateway Midtrans'),
                        subtitle: const Text('Bypass validasi manual untuk pembayaran via Midtrans.'),
                        value: _featureMidtrans,
                        onChanged: (val) => setState(() => _featureMidtrans = val),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _serverKeyController,
                        obscureText: _isObscureServerKey,
                        decoration: InputDecoration(
                          labelText: 'Midtrans Server Key',
                          helperText: 'Dienkripsi dengan aman di database. Hanya ubah jika Anda bermaksud me-reset kunci.',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_isObscureServerKey ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _isObscureServerKey = !_isObscureServerKey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _clientKeyController,
                        decoration: const InputDecoration(
                          labelText: 'Midtrans Client Key',
                          helperText: 'Akan dipanggil di Frontend untuk tokenisasi Snap.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Metode Pembayaran yang Diizinkan:', style: TextStyle(fontWeight: FontWeight.bold)),
                      CheckboxListTile(
                        title: const Text('Tunai (Manual)'),
                        value: _payCash,
                        onChanged: (val) => setState(() => _payCash = val ?? false),
                      ),
                      CheckboxListTile(
                        title: const Text('Transfer Bank (Manual / VA)'),
                        value: _payBankTransfer,
                        onChanged: (val) => setState(() => _payBankTransfer = val ?? false),
                      ),
                      CheckboxListTile(
                        title: const Text('QRIS'),
                        value: _payQris,
                        onChanged: (val) => setState(() => _payQris = val ?? false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
