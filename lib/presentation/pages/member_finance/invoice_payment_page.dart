import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/navigation/auto_route.gr.dart';
import '../../../domain/entity/setting/midtrans_method_entity.dart';
import '../../../domain/usecase/finance/get_available_payment_methods_usecase.dart';
import '../../../domain/usecase/finance/get_member_invoice_by_id_usecase.dart';
import '../../bloc/member_finance/member_finance_bloc.dart';
import '../../bloc/member_finance/member_finance_event.dart';
import '../../bloc/member_finance/member_finance_state.dart';
import '../../widget/core/appbar/custom_appbar.dart';
import '../../widget/core/botton/button.dart';
import '../../widget/core/card/basic_card.dart';

const bool _kMidtransProduction = false;
const int _kMaxPollAttempts = 10;
const Duration _kPollInterval = Duration(seconds: 3);

// ── Metadata metode Midtrans (sama persis dengan reservation_detail_form_page) ──

class _MethodInfo {
  const _MethodInfo(this.name, this.desc, this.icon);
  final String name;
  final String desc;
  final IconData icon;
}

const Map<String, _MethodInfo> _kMethodMap = {
  'qris':        _MethodInfo('QRIS', 'Scan QR dari semua e-wallet & bank', Icons.qr_code),
  'gopay':       _MethodInfo('GoPay', 'Bayar dengan saldo GoPay', Icons.account_balance_wallet),
  'shopeepay':   _MethodInfo('ShopeePay', 'Bayar dengan saldo ShopeePay', Icons.shopping_bag),
  'dana':        _MethodInfo('DANA', 'Bayar dengan saldo DANA', Icons.account_balance_wallet),
  'linkaja':     _MethodInfo('LinkAja', 'Bayar dengan LinkAja', Icons.account_balance_wallet),
  'ovo':         _MethodInfo('OVO', 'Bayar dengan saldo OVO', Icons.account_balance_wallet),
  'bca_va':      _MethodInfo('BCA Virtual Account', 'Transfer via ATM / m-BCA', Icons.account_balance),
  'bni_va':      _MethodInfo('BNI Virtual Account', 'Transfer via ATM / BNI Mobile', Icons.account_balance),
  'bri_va':      _MethodInfo('BRI Virtual Account', 'Transfer via ATM / BRImo', Icons.account_balance),
  'mandiri_va':  _MethodInfo('Mandiri Virtual Account', 'Transfer via Mandiri Livin\'', Icons.account_balance),
  'echannel':    _MethodInfo('Mandiri Bill', 'Bayar via Mandiri Livin\'', Icons.account_balance),
  'permata_va':  _MethodInfo('Permata Virtual Account', 'Transfer via ATM Permata', Icons.account_balance),
  'other_va':    _MethodInfo('Virtual Account', 'Transfer via bank lain', Icons.account_balance),
  'alfamart':    _MethodInfo('Alfamart', 'Bayar di kasir Alfamart', Icons.store),
  'indomaret':   _MethodInfo('Indomaret', 'Bayar di kasir Indomaret', Icons.store),
  'credit_card': _MethodInfo('Kartu Kredit/Debit', 'Visa, Mastercard, JCB', Icons.credit_card),
  'akulaku':     _MethodInfo('Akulaku', 'Cicilan 0% via Akulaku', Icons.credit_card),
  'kredivo':     _MethodInfo('Kredivo', 'Cicilan via Kredivo', Icons.credit_card),
};

String _methodName(String code) => _kMethodMap[code]?.name ?? code.toUpperCase();

enum _PayPageState { selecting, midtransActive }

@RoutePage()
class InvoicePaymentPage extends StatefulWidget {
  const InvoicePaymentPage({
    super.key,
    required this.invoiceId,
    required this.invoiceNumber,
    required this.amount,
    this.roomNumber,
    this.invoiceType,
    this.dueDate,
    // Digunakan untuk widget test saja — produksi pakai serviceLocator
    this.bloc,
  });

  final int invoiceId;
  final String invoiceNumber;
  final double amount;
  final String? roomNumber;
  final String? invoiceType;
  final DateTime? dueDate;
  final MemberFinanceBloc? bloc;

  @override
  State<InvoicePaymentPage> createState() => _InvoicePaymentPageState();
}

class _InvoicePaymentPageState extends State<InvoicePaymentPage> {
  late final MemberFinanceBloc _bloc;

  // Metode pembayaran utama: 'manual' | 'online'
  String _selectedMethod = 'manual';

  // Metode Midtrans spesifik yang dipilih (code, mis. 'qris', 'gopay')
  String? _selectedMidtransMethod;

  // Daftar metode Midtrans tersedia dari setting
  List<MidtransMethodEntity> _midtransMethods = [];
  bool _methodsLoading = false;

  // Upload bukti (manual)
  PlatformFile? _selectedFile;

  // State halaman setelah submit Midtrans
  _PayPageState _pageState = _PayPageState.selecting;
  String? _snapToken;
  Map<String, dynamic>? _midtransData;
  bool _snapOpened = false;
  bool _isPolling = false;
  bool _paymentConfirmed = false;
  int _pollAttempts = 0;
  Timer? _pollTimer;

  final _currencyFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _dateFmt = DateFormat('dd MMMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? serviceLocator<MemberFinanceBloc>();
    _loadMidtransMethods();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMidtransMethods() async {
    setState(() => _methodsLoading = true);
    try {
      final methods = await serviceLocator.get<GetAvailablePaymentMethodsUseCase>().execute();
      if (mounted) setState(() => _midtransMethods = methods);
    } catch (_) {}
    if (mounted) setState(() => _methodsLoading = false);
  }

  // ── Labels ────────────────────────────────────────────────────────────────

  String get _pageTitle => switch (widget.invoiceType) {
        'pelunasan' => 'Bayar Pelunasan',
        'dp'        => 'Bayar Uang Muka (DP)',
        'extension' => 'Bayar Perpanjangan Sewa',
        'fine'      => 'Bayar Denda',
        _           => 'Bayar Tagihan',
      };

  String get _invoiceTypeLabel => switch (widget.invoiceType) {
        'pelunasan' => 'Pelunasan',
        'dp'        => 'Uang Muka (DP)',
        'extension' => 'Perpanjangan',
        'fine'      => 'Denda',
        'sewa'      => 'Sewa Bulanan',
        _           => 'Tagihan',
      };

  Color get _invoiceTypeColor => switch (widget.invoiceType) {
        'pelunasan' => Colors.teal.shade700,
        'dp'        => Colors.amber.shade700,
        'extension' => Colors.blue.shade700,
        'fine'      => Colors.red.shade700,
        _           => Colors.indigo.shade600,
      };

  // ── Actions ───────────────────────────────────────────────────────────────

  void _submitManual() {
    if (_selectedFile == null) return;
    _bloc.add(PayInvoiceEvent(
      widget.invoiceId,
      'manual',
      paymentProofBytes: _selectedFile!.bytes,
      paymentProofName: _selectedFile!.name,
    ));
  }

  void _submitOnline() {
    _bloc.add(PayInvoiceEvent(
      widget.invoiceId,
      'midtrans',
      preferredPaymentType: _selectedMidtransMethod,
    ));
  }

  Future<void> _openSnapUrl(String token) async {
    final env = _kMidtransProduction ? '' : 'sandbox.';
    final url = Uri.parse('https://app.${env}midtrans.com/snap/v2/vtweb/$token');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      setState(() => _snapOpened = true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka halaman pembayaran')),
        );
      }
    }
  }

  void _startPolling() {
    setState(() { _isPolling = true; _pollAttempts = 0; });
    _pollTimer = Timer.periodic(_kPollInterval, (timer) async {
      if (!mounted) { timer.cancel(); return; }
      _pollAttempts++;
      try {
        final invoice = await serviceLocator
            .get<GetMemberInvoiceByIdUseCase>()
            .execute(widget.invoiceId);
        if (invoice.status.toLowerCase() == 'paid') {
          timer.cancel();
          if (mounted) setState(() { _isPolling = false; _paymentConfirmed = true; });
          return;
        }
      } catch (_) {}

      if (_pollAttempts >= _kMaxPollAttempts) {
        timer.cancel();
        if (mounted) {
          setState(() => _isPolling = false);
          _showPendingDialog();
        }
      }
    });
  }

  void _showPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          const Icon(Icons.hourglass_top, color: Colors.orange, size: 28),
          const SizedBox(width: 8),
          const Text('Pembayaran Diproses'),
        ]),
        content: const Text(
          'Konfirmasi pembayaran belum diterima. '
          'Status akan diperbarui otomatis. '
          'Pantau di halaman keuangan Anda.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.router.replaceAll([const MemberFinanceRoute()]);
            },
            child: const Text('Lihat Status Pembayaran'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<MemberFinanceBloc, MemberFinanceState>(
        listenWhen: (prev, curr) =>
            prev.status == MemberFinanceStatus.loading &&
            (curr.status == MemberFinanceStatus.paymentSuccess ||
                curr.status == MemberFinanceStatus.failure),
        listener: (context, state) {
          if (state.status == MemberFinanceStatus.paymentSuccess) {
            if (state.snapToken != null || state.paymentData != null) {
              // Online: tampilkan kode pembayaran di halaman ini
              setState(() {
                _pageState = _PayPageState.midtransActive;
                _snapToken = state.snapToken;
                _midtransData = state.paymentData;
              });
            } else {
              // Manual: sukses → snackbar + kembali ke keuangan
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bukti pembayaran berhasil diunggah. Menunggu verifikasi admin.'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 4),
                ),
              );
              context.router.replaceAll([const MemberFinanceRoute()]);
            }
          } else if (state.status == MemberFinanceStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Gagal memproses pembayaran'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (_paymentConfirmed) return _buildSuccessView(context);

          final isLoading = state.status == MemberFinanceStatus.loading;

          return PopScope(
            canPop: !isLoading && !_isPolling,
            child: Scaffold(
              appBar: CustomAppbar(
                title: _pageTitle,
                icon: const Icon(Icons.arrow_back),
                onPressed: (isLoading || _isPolling)
                    ? null
                    : () => context.router.maybePop(),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStepIndicator(),
                        const SizedBox(height: 24),
                        if (isLoading && _pageState == _PayPageState.selecting)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 48),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _pageState == _PayPageState.midtransActive
                                    ? _buildMidtransPaymentCard(state)
                                    : _buildSelectingContent(state, isLoading),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 2,
                                child: _buildSummarySection(state, isLoading),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Step indicator ────────────────────────────────────────────────────────

  Widget _buildStepIndicator() {
    final step = _pageState == _PayPageState.midtransActive ? 2 : 1;
    return Row(
      children: [
        _stepCircle('1', 'Tagihan', step >= 1, done: step > 1),
        _stepLine(step > 1),
        _stepCircle('2', 'Pembayaran', step >= 2, done: _paymentConfirmed),
        _stepLine(_paymentConfirmed),
        _stepCircle('3', 'Selesai', _paymentConfirmed),
      ],
    );
  }

  Widget _stepCircle(String num, String label, bool isActive, {bool done = false}) {
    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(num, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.blue : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isActive ? Colors.blue : Colors.grey.shade300,
      ),
    );
  }

  // ── Selecting content ─────────────────────────────────────────────────────

  Widget _buildSelectingContent(MemberFinanceState state, bool isLoading) {
    final bankAccounts = state.bankAccounts;
    final isMidtrans = state.isMidtransEnabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Card pemilihan metode utama ────────────────────────────────────
        BasicCard(
          title: 'Metode Pembayaran',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  if (isMidtrans)
                    _mainMethodCard(
                      title: 'Pembayaran Online',
                      subtitle: _onlineSubtitle(),
                      icon: Icons.account_balance_wallet,
                      selected: _selectedMethod == 'online',
                      onTap: () => setState(() => _selectedMethod = 'online'),
                    ),
                  _mainMethodCard(
                    title: 'Pembayaran Manual',
                    subtitle: 'Transfer atau Cash dengan Bukti',
                    icon: Icons.payments,
                    selected: _selectedMethod == 'manual',
                    onTap: () => setState(() => _selectedMethod = 'manual'),
                  ),
                ],
              ),

              // Grid metode Midtrans
              if (_selectedMethod == 'online') ...[
                const SizedBox(height: 20),
                Text(
                  'Pilih Metode Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey.shade800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kode pembayaran akan ditampilkan langsung di aplikasi setelah Anda mengklik Proses Pembayaran.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 12),
                if (_methodsLoading)
                  const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ))
                else if (_midtransMethods.isEmpty)
                  _infoBox(
                    icon: Icons.info_outline,
                    color: Colors.grey,
                    text: 'Tidak ada metode pembayaran online yang aktif. Hubungi pengelola atau gunakan Pembayaran Manual.',
                  )
                else if (_midtransMethods.every((m) => !m.available))
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(children: [
                      Icon(Icons.build_outlined, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Semua metode sedang maintenance',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange.shade800)),
                          const SizedBox(height: 4),
                          Text('Coba lagi nanti atau gunakan Pembayaran Manual.',
                              style: TextStyle(fontSize: 12, color: Colors.orange.shade700)),
                        ],
                      )),
                    ]),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      mainAxisExtent: 72,
                    ),
                    itemCount: _midtransMethods.length,
                    itemBuilder: (context, index) {
                      final method = _midtransMethods[index];
                      final isSelected = _selectedMidtransMethod == method.code;
                      return _midtransMethodCard(
                        method: method,
                        selected: isSelected,
                        onTap: method.available
                            ? () => setState(() => _selectedMidtransMethod = isSelected ? null : method.code)
                            : () {},
                      );
                    },
                  ),
              ],

              // Info manual
              if (_selectedMethod == 'manual') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pembayaran Manual',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange.shade700)),
                        const SizedBox(height: 4),
                        Text('Lakukan transfer bank atau bayar cash, lalu unggah bukti pembayaran.',
                            style: TextStyle(fontSize: 12, color: Colors.orange.shade600)),
                      ],
                    )),
                  ]),
                ),
              ],
            ],
          ),
        ),

        // ── Konten sesuai metode ────────────────────────────────────────────
        if (_selectedMethod == 'manual') ...[
          const SizedBox(height: 16),
          _buildTransferBankCard(bankAccounts),
          const SizedBox(height: 16),
          _buildCashCard(),
          const SizedBox(height: 16),
          _buildUploadCard(isLoading),
        ],
      ],
    );
  }

  // ── Main method card (Online / Manual) ────────────────────────────────────

  Widget _mainMethodCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 200, maxWidth: 320),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.blue : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.blue : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? Colors.blue : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // ── Midtrans method card (grid item) ──────────────────────────────────────

  Widget _midtransMethodCard({
    required MidtransMethodEntity method,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final info = _kMethodMap[method.code] ??
        _MethodInfo(method.code.toUpperCase(), 'Metode Midtrans', Icons.payment);
    final displayName = method.label.isNotEmpty ? method.label : info.name;

    return Opacity(
      opacity: method.available ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.blue.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? Colors.blue : Colors.grey.shade300,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(info.icon,
                  size: 22,
                  color: selected ? Colors.blue : (method.maintenance ? Colors.grey.shade400 : Colors.grey.shade600)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: selected ? Colors.blue.shade800 : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (method.maintenance)
                      Text('Maintenance', style: TextStyle(fontSize: 10, color: Colors.orange.shade700))
                    else
                      Text(info.desc,
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? Colors.blue : Colors.grey.shade400,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Transfer bank card ────────────────────────────────────────────────────

  Widget _buildTransferBankCard(bankAccounts) {
    return BasicCard(
      title: 'Pembayaran via Transfer Bank',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _instructionStep(1, 'Transfer ke Rekening Berikut',
              'Pastikan nominal transfer sesuai dengan total tagihan.'),
          const SizedBox(height: 16),
          if (bankAccounts.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Text(
                'Hubungi pengelola wisma untuk informasi rekening transfer.',
                style: TextStyle(fontSize: 13),
              ),
            )
          else
            ...bankAccounts.map((acc) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(acc.bankName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    _bankInfoRow('No. Rekening', acc.accountNumber),
                    _bankInfoRow('Atas Nama', acc.accountHolder),
                    if (acc.paymentInstructions != null && acc.paymentInstructions!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(acc.paymentInstructions!,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Jumlah Transfer:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(
                            _currencyFmt.format(widget.amount),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
          const SizedBox(height: 16),
          _instructionStep(2, 'Simpan Bukti Transfer',
              'Screenshot atau foto struk transfer dari mobile banking / ATM.'),
        ],
      ),
    );
  }

  // ── Cash card ─────────────────────────────────────────────────────────────

  Widget _buildCashCard() {
    return BasicCard(
      title: 'Pembayaran Cash (Tunai)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _instructionStep(1, 'Datang ke Pengelola Wisma',
              'Kunjungi kantor pengelola Wisma Amal Gorontalo secara langsung.'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bankInfoRow('Alamat', 'Jl. Wisma Amal No. 1, Gorontalo'),
                _bankInfoRow('Jam Operasional', 'Senin – Sabtu, 08.00 – 17.00 WITA'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _instructionStep(2, 'Bayar & Minta Kwitansi',
              'Lakukan pembayaran tunai dan minta kwitansi resmi dari pengelola.'),
          const SizedBox(height: 12),
          _instructionStep(3, 'Foto Kwitansi',
              'Foto kwitansi pembayaran dengan jelas sebagai bukti.'),
        ],
      ),
    );
  }

  // ── Upload card ───────────────────────────────────────────────────────────

  Widget _buildUploadCard(bool isLoading) {
    return BasicCard(
      title: 'Upload Bukti Pembayaran',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _instructionStep(1, 'Pilih File Bukti',
              'Pilih foto struk transfer atau kwitansi cash yang jelas dan terbaca.'),
          const SizedBox(height: 16),
          if (_selectedFile != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('File terpilih: ${_selectedFile!.name}',
                      style: const TextStyle(fontSize: 13, color: Colors.green)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _selectedFile = null),
                ),
              ]),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isLoading
                  ? null
                  : () async {
                      final result = await FilePicker.platform
                          .pickFiles(type: FileType.image, withData: true);
                      if (result != null) setState(() => _selectedFile = result.files.first);
                    },
              icon: const Icon(Icons.image_outlined),
              label: Text(_selectedFile == null ? 'Pilih Gambar Bukti' : 'Ganti Gambar'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Midtrans payment display (setelah submit berhasil) ────────────────────

  Widget _buildMidtransPaymentCard(MemberFinanceState state) {
    final data = _midtransData;
    final token = _snapToken;

    if (data != null) {
      return _buildCoreApiCard(data);
    }
    if (token != null && token.isNotEmpty) {
      return _buildSnapCard(token);
    }
    return const SizedBox.shrink();
  }

  Widget _buildCoreApiCard(Map<String, dynamic> data) {
    final paymentType = data['payment_type'] as String? ?? '';

    Widget paymentWidget;
    if (_hasQrCode(data)) {
      paymentWidget = _buildQrCodeUI(data, paymentType);
    } else if (data.containsKey('va_numbers')) {
      paymentWidget = _buildVaNumberUI(data);
    } else if (data.containsKey('bill_key')) {
      paymentWidget = _buildMandiriBillUI(data);
    } else if (data.containsKey('payment_code')) {
      paymentWidget = _buildCStoreUI(data);
    } else {
      paymentWidget = _buildGenericPaymentUI();
    }

    return BasicCard(
      title: 'Kode Pembayaran',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          paymentWidget,
          const SizedBox(height: 24),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildSnapCard(String token) {
    final methodName = _selectedMidtransMethod != null
        ? _methodName(_selectedMidtransMethod!)
        : 'Midtrans';

    return BasicCard(
      title: 'Pembayaran via $methodName',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoBox(
            icon: Icons.security,
            color: Colors.blue,
            text: 'Pembayaran akan dilanjutkan di halaman $methodName. '
                'Setelah selesai bayar, kembali ke sini dan klik konfirmasi.',
          ),
          const SizedBox(height: 20),
          _instructionStep(1, 'Klik "Bayar Sekarang"',
              'Anda akan diarahkan ke halaman $methodName.'),
          const SizedBox(height: 10),
          _instructionStep(2, 'Selesaikan Pembayaran',
              'Ikuti instruksi pada halaman $methodName.'),
          const SizedBox(height: 10),
          _instructionStep(3, 'Kembali ke Aplikasi',
              'Setelah selesai bayar, kembali dan klik tombol konfirmasi.'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isPolling ? null : () => _openSnapUrl(token),
              icon: const Icon(Icons.payment, color: Colors.white),
              label: Text('Bayar Sekarang',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (_snapOpened) ...[
            const SizedBox(height: 12),
            _buildConfirmButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    if (_isPolling) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue.shade700),
            ),
            const SizedBox(width: 12),
            Text('Memverifikasi pembayaran…',
                style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _startPolling,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        label: const Text('Saya Sudah Bayar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ── Summary section (right col) ───────────────────────────────────────────

  Widget _buildSummarySection(MemberFinanceState state, bool isLoading) {
    // Breakdown biaya Midtrans (tersedia setelah payment diinisiasi)
    final grossAmount   = state.paymentGrossAmount;
    final midtransFee   = state.paymentMidtransFee ?? 0;
    final isCustomer    = state.paymentFeeBearer == 'customer';
    final hasFee        = isCustomer && midtransFee > 0 && _pageState == _PayPageState.midtransActive;

    final isSelectingManual = _pageState == _PayPageState.selecting && _selectedMethod == 'manual';
    final isSelectingOnline = _pageState == _PayPageState.selecting && _selectedMethod == 'online';

    // Validasi submit online
    final canSubmitOnline = _selectedMidtransMethod != null &&
        _midtransMethods.any((m) => m.code == _selectedMidtransMethod && m.available);

    return Column(
      children: [
        BasicCard(
          title: 'Ringkasan Tagihan',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge tipe invoice
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _invoiceTypeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _invoiceTypeColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  _invoiceTypeLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _invoiceTypeColor,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _summaryRow('No. Invoice', widget.invoiceNumber),
              if (widget.roomNumber != null)
                _summaryRow('Kamar', 'Kamar ${widget.roomNumber}'),
              if (widget.dueDate != null)
                _summaryRow('Jatuh Tempo', _dateFmt.format(widget.dueDate!)),
              const Divider(height: 28),

              // Breakdown biaya jika ada Midtrans fee
              if (hasFee) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tagihan', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    Text(_currencyFmt.format(widget.amount),
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Biaya Transaksi', style: TextStyle(fontSize: 13, color: Colors.orange.shade700)),
                    Text(_currencyFmt.format(midtransFee),
                        style: TextStyle(fontSize: 13, color: Colors.orange.shade700)),
                  ],
                ),
                const Divider(height: 16),
              ],

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Bayar', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    _currencyFmt.format(hasFee && grossAmount != null ? grossAmount : widget.amount),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 18),
                  ),
                ],
              ),

              if (hasFee) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(children: [
                    Icon(Icons.info_outline, size: 13, color: Colors.orange.shade700),
                    const SizedBox(width: 5),
                    Expanded(child: Text(
                      'Biaya transaksi Midtrans ditanggung penghuni dan sudah termasuk dalam total di atas.',
                      style: TextStyle(fontSize: 10, color: Colors.orange.shade700, height: 1.3),
                    )),
                  ]),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tombol submit — hanya saat selecting
        if (isSelectingManual)
          BasicButton(
            label: isLoading ? 'Mengirim...' : 'Kirim Bukti Pembayaran',
            isLoading: isLoading,
            onPressed: (isLoading || _selectedFile == null) ? null : _submitManual,
          ),

        if (isSelectingOnline)
          BasicButton(
            label: isLoading ? 'Memproses...' : 'Proses Pembayaran',
            isLoading: isLoading,
            onPressed: (isLoading || !canSubmitOnline) ? null : _submitOnline,
          ),

        if (isSelectingOnline && _selectedMidtransMethod == null) ...[
          const SizedBox(height: 8),
          Text(
            'Pilih metode pembayaran terlebih dahulu.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  // ── Success view ──────────────────────────────────────────────────────────

  Widget _buildSuccessView(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96, height: 96,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green.shade200, width: 2),
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 56),
              ),
              const SizedBox(height: 24),
              const Text('Pembayaran Berhasil!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                'Pembayaran telah dikonfirmasi.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.router.replaceAll([const MemberFinanceRoute()]),
                  icon: const Icon(Icons.home, color: Colors.white),
                  label: const Text('Lihat Keuangan Saya',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Core API sub-widgets ──────────────────────────────────────────────────

  bool _hasQrCode(Map<String, dynamic> data) {
    final actions = data['actions'] as List?;
    if (actions == null) return false;
    return actions.any((a) =>
        a is Map && (a['name'] == 'generate-qr-code' || a['name'] == 'get-qr-code'));
  }

  String? _getQrUrl(Map<String, dynamic> data) {
    final actions = data['actions'] as List?;
    if (actions == null) return null;
    for (final a in actions) {
      if (a is Map && (a['name'] == 'generate-qr-code' || a['name'] == 'get-qr-code')) {
        return a['url'] as String?;
      }
    }
    return null;
  }

  String? _getDeeplinkUrl(Map<String, dynamic> data) {
    final actions = data['actions'] as List?;
    if (actions == null) return null;
    for (final a in actions) {
      if (a is Map && a['name'] == 'deeplink-redirect') return a['url'] as String?;
    }
    return null;
  }

  Widget _buildQrCodeUI(Map<String, dynamic> data, String paymentType) {
    final qrUrl = _getQrUrl(data);
    final deeplinkUrl = _getDeeplinkUrl(data);
    final expiryTime = data['expiry_time'] as String?;
    final methodLabel = _kMethodMap[paymentType]?.name ?? paymentType.toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _infoBox(
          icon: Icons.qr_code_2,
          color: Colors.indigo,
          text: 'Scan QR Code berikut menggunakan aplikasi $methodLabel atau kamera ponsel Anda.',
        ),
        const SizedBox(height: 20),
        if (qrUrl != null)
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.network(
                qrUrl,
                width: 200, height: 200, fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const SizedBox(
                        width: 200, height: 200,
                        child: Center(child: CircularProgressIndicator())),
                errorBuilder: (_, __, ___) => const SizedBox(
                    width: 200, height: 200,
                    child: Center(child: Text('Gagal memuat QR Code'))),
              ),
            ),
          ),
        if (expiryTime != null) ...[
          const SizedBox(height: 12),
          _expiryChip(expiryTime),
        ],
        if (deeplinkUrl != null) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(deeplinkUrl);
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
              icon: const Icon(Icons.open_in_new),
              label: Text('Buka di $methodLabel'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVaNumberUI(Map<String, dynamic> data) {
    final vaNumbers = data['va_numbers'] as List? ?? [];
    final expiryTime = data['expiry_time'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoBox(
          icon: Icons.account_balance,
          color: Colors.blue,
          text: 'Transfer ke nomor Virtual Account berikut sebelum waktu kadaluarsa.',
        ),
        const SizedBox(height: 16),
        for (final va in vaNumbers)
          if (va is Map) ...[
            _vaCard(
              bank: (va['bank'] as String? ?? '').toUpperCase(),
              vaNumber: va['va_number'] as String? ?? '-',
            ),
            const SizedBox(height: 8),
          ],
        if (expiryTime != null) _expiryChip(expiryTime),
      ],
    );
  }

  Widget _buildMandiriBillUI(Map<String, dynamic> data) {
    final billKey = data['bill_key'] as String? ?? '-';
    final billerCode = data['biller_code'] as String? ?? '-';
    final expiryTime = data['expiry_time'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoBox(
          icon: Icons.account_balance,
          color: Colors.blue,
          text: "Bayar melalui Mandiri Livin' atau ATM Mandiri menggunakan kode berikut.",
        ),
        const SizedBox(height: 16),
        _codeCard(label: 'Biller Code', value: billerCode),
        const SizedBox(height: 8),
        _codeCard(label: 'Bill Key', value: billKey),
        if (expiryTime != null) ...[const SizedBox(height: 12), _expiryChip(expiryTime)],
      ],
    );
  }

  Widget _buildCStoreUI(Map<String, dynamic> data) {
    final paymentCode = data['payment_code'] as String? ?? '-';
    final store = data['store'] as String? ?? 'Minimarket';
    final expiryTime = data['expiry_time'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoBox(
          icon: Icons.store,
          color: Colors.red,
          text: 'Tunjukkan kode berikut ke kasir $store untuk menyelesaikan pembayaran.',
        ),
        const SizedBox(height: 16),
        _codeCard(label: 'Kode Pembayaran $store', value: paymentCode),
        if (expiryTime != null) ...[const SizedBox(height: 12), _expiryChip(expiryTime)],
      ],
    );
  }

  Widget _buildGenericPaymentUI() {
    return _infoBox(
      icon: Icons.payment,
      color: Colors.grey,
      text: 'Lanjutkan pembayaran dan klik "Saya Sudah Bayar" setelah selesai.',
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  String _onlineSubtitle() {
    if (_midtransMethods.isEmpty) return 'Tidak ada metode aktif';
    final available = _midtransMethods.where((m) => !m.maintenance).toList();
    if (available.isEmpty) return 'Semua metode sedang maintenance';
    final names = available
        .map((m) => m.label.isNotEmpty ? m.label : (_kMethodMap[m.code]?.name ?? m.code.toUpperCase()))
        .take(3)
        .join(', ');
    return available.length > 3 ? '$names, +${available.length - 3} lainnya' : names;
  }

  Widget _instructionStep(int num, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(num.toString(),
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 3),
              Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bankInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ),
          const Text(': ', style: TextStyle(fontSize: 13)),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Flexible(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _vaCard({required String bank, required String vaNumber}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Virtual Account $bank',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Text(vaNumber,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: vaNumber));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nomor VA disalin'), duration: Duration(seconds: 2)),
              );
            },
            icon: const Icon(Icons.copy, color: Colors.blue),
            tooltip: 'Salin',
          ),
        ],
      ),
    );
  }

  Widget _codeCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kode disalin'), duration: Duration(seconds: 2)),
              );
            },
            icon: const Icon(Icons.copy, color: Colors.blue),
            tooltip: 'Salin',
          ),
        ],
      ),
    );
  }

  Widget _expiryChip(String expiryTime) {
    return Row(
      children: [
        const Icon(Icons.schedule, size: 14, color: Colors.orange),
        const SizedBox(width: 6),
        Text('Berlaku hingga: $expiryTime',
            style: TextStyle(fontSize: 12, color: Colors.orange.shade700)),
      ],
    );
  }

  Widget _infoBox({required IconData icon, required Color color, required String text}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }
}
