import 'dart:async';
import 'dart:typed_data';
import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/navigation/auto_route.gr.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entity/setting/bank_account_entity.dart';
import '../../../domain/usecase/finance/initiate_perpanjang_manual_usecase.dart';
import '../../../domain/usecase/setting/get_public_bank_accounts_usecase.dart';
import '../../bloc/member_finance/member_finance_bloc.dart';
import '../../bloc/member_finance/member_finance_event.dart';
import '../../bloc/member_finance/member_finance_state.dart';

// ── Midtrans method metadata ──────────────────────────────────────────────────

class _MidtransMethod {
  const _MidtransMethod(this.label, this.desc, this.icon);
  final String label;
  final String desc;
  final IconData icon;
}

const Map<String, _MidtransMethod> _kMidtransMethods = {
  'qris':       _MidtransMethod('QRIS',                   'Scan QR dari semua e-wallet & bank',  Icons.qr_code),
  'gopay':      _MidtransMethod('GoPay',                  'Bayar dengan saldo GoPay',            Icons.account_balance_wallet),
  'shopeepay':  _MidtransMethod('ShopeePay',              'Bayar dengan saldo ShopeePay',        Icons.shopping_bag),
  'dana':       _MidtransMethod('DANA',                   'Bayar dengan saldo DANA',             Icons.account_balance_wallet),
  'linkaja':    _MidtransMethod('LinkAja',                'Bayar dengan LinkAja',                Icons.account_balance_wallet),
  'ovo':        _MidtransMethod('OVO',                    'Bayar dengan saldo OVO',              Icons.account_balance_wallet),
  'bca_va':     _MidtransMethod('BCA Virtual Account',   'Transfer via ATM / m-BCA',            Icons.account_balance),
  'bni_va':     _MidtransMethod('BNI Virtual Account',   'Transfer via ATM / BNI Mobile',       Icons.account_balance),
  'bri_va':     _MidtransMethod('BRI Virtual Account',   'Transfer via ATM / BRImo',            Icons.account_balance),
  'mandiri_va': _MidtransMethod('Mandiri Virtual Account','Transfer via Mandiri Livin\'',        Icons.account_balance),
  'echannel':   _MidtransMethod('Mandiri Bill',           'Bayar via Mandiri Livin\'',           Icons.account_balance),
  'permata_va': _MidtransMethod('Permata Virtual Account','Transfer via ATM Permata',            Icons.account_balance),
  'other_va':   _MidtransMethod('Virtual Account',       'Transfer via bank lain',              Icons.account_balance),
  'alfamart':   _MidtransMethod('Alfamart',               'Bayar di kasir Alfamart',             Icons.store),
  'indomaret':  _MidtransMethod('Indomaret',              'Bayar di kasir Indomaret',            Icons.store),
  'credit_card':_MidtransMethod('Kartu Kredit/Debit',    'Visa, Mastercard, JCB',               Icons.credit_card),
};

@RoutePage()
class ExtendLeasePage extends StatefulWidget {
  const ExtendLeasePage({
    super.key,
    required this.leaseId,
    required this.roomNumber,
    required this.currentEndDate,
    required this.isMidtransEnabled,
  });

  final int leaseId;
  final String roomNumber;
  final DateTime currentEndDate;
  final bool isMidtransEnabled;

  @override
  State<ExtendLeasePage> createState() => _ExtendLeasePageState();
}

class _ExtendLeasePageState extends State<ExtendLeasePage> {
  // Step 1: pilih durasi + metode
  int _duration = 1;
  String _paymentMethod = 'manual';
  String? _selectedMidtransMethod;
  bool _isInitiating = false;

  // Step 2 (manual only): upload bukti
  int _step = 1;
  int? _invoiceId;
  double? _invoiceAmount;
  Uint8List? _proofBytes;
  String? _proofName;
  List<BankAccountEntity> _bankAccounts = [];

  // Countdown (dari server payment_expires_at)
  Timer? _countdownTimer;
  int _remainingSeconds = 0;
  bool _timerExpired = false;

  @override
  void initState() {
    super.initState();
    _loadBankAccounts();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownFromExpiry(DateTime expiresAt) {
    _countdownTimer?.cancel();
    final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    setState(() {
      _remainingSeconds = remaining > 0 ? remaining : 0;
      _timerExpired = _remainingSeconds <= 0;
    });
    if (_timerExpired) { _onTimerExpired(); return; }
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timerExpired = true;
          timer.cancel();
          _onTimerExpired();
        }
      });
    });
  }

  void _onTimerExpired() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Waktu pembayaran habis. Invoice dibatalkan otomatis. Silakan ulangi.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
    context.router.maybePop();
  }

  String get _timerLabel {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color _timerColor(BuildContext context) {
    if (_remainingSeconds <= 60) return Colors.red;
    if (_remainingSeconds <= 120) return Colors.orange;
    return Theme.of(context).colorScheme.primary;
  }

  Future<void> _loadBankAccounts() async {
    try {
      final accounts = await serviceLocator.get<GetPublicBankAccountsUseCase>().execute();
      if (mounted) setState(() => _bankAccounts = accounts);
    } catch (_) {}
  }

  Future<void> _initiateManualPayment() async {
    setState(() => _isInitiating = true);
    try {
      final invoice = await serviceLocator
          .get<InitiatePerpanjangManualUseCase>()
          .execute(widget.leaseId, _duration);
      if (!mounted) return;
      setState(() {
        _invoiceId    = invoice.id;
        _invoiceAmount = invoice.amount;
        _step = 2;
        _isInitiating = false;
      });
      if (invoice.paymentExpiresAt != null) {
        _startCountdownFromExpiry(invoice.paymentExpiresAt!);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isInitiating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  DateTime _addMonths(DateTime date, int months) {
    final totalMonths = date.month + months;
    final year = date.year + (totalMonths - 1) ~/ 12;
    final month = ((totalMonths - 1) % 12) + 1;
    final maxDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, date.day > maxDay ? maxDay : date.day);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _proofBytes = result.files.first.bytes;
        _proofName = result.files.first.name;
      });
    }
  }

  bool get _canSubmitStep2 => _proofBytes != null && !_timerExpired;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final newEndDate = _addMonths(widget.currentEndDate, _duration);

    final surfaceColor    = isDark ? AppColorsDark.surface        : AppColorsLight.surface;
    final surfaceVariant  = isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
    final borderColor     = isDark ? AppColorsDark.borderLight    : AppColorsLight.borderLight;
    final textPrimary     = isDark ? AppColorsDark.textPrimary    : AppColorsLight.textPrimary;
    final textSecondary   = isDark ? AppColorsDark.textSecondary  : AppColorsLight.textSecondary;
    final textHint        = isDark ? AppColorsDark.textHint       : AppColorsLight.textHint;
    final doneColor       = isDark ? AppColorsDark.statusDone     : AppColorsLight.statusDone;
    final doneBg          = isDark ? AppColorsDark.statusDoneBg   : AppColorsLight.statusDoneBg;
    final waitingColor    = isDark ? AppColorsDark.statusWaiting  : AppColorsLight.statusWaiting;
    final waitingBg       = isDark ? AppColorsDark.statusWaitingBg: AppColorsLight.statusWaitingBg;
    final cancelColor     = isDark ? AppColorsDark.statusCancelled: AppColorsLight.statusCancelled;

    final daysLeft       = widget.currentEndDate.difference(DateTime.now()).inDays;
    final isNearExpiry   = daysLeft <= 30;
    final leaseStatusColor = isNearExpiry ? waitingColor : doneColor;
    final leaseStatusBg    = isNearExpiry ? waitingBg    : doneBg;

    return BlocProvider(
      create: (_) => serviceLocator.get<MemberFinanceBloc>(),
      child: BlocListener<MemberFinanceBloc, MemberFinanceState>(
        listener: (context, state) {
          if (state.status == MemberFinanceStatus.paymentSuccess) {
            // Navigasi ke halaman pembayaran dengan data yang sudah ada
            context.router.push(ExtendLeasePaymentRoute(
              invoiceId:   state.paymentInvoiceId ?? 0,
              roomNumber:  widget.roomNumber,
              amount:      state.paymentAmount ?? 0,
              snapToken:   state.snapToken,
              paymentData: state.paymentData,
            ));
          } else if (state.status == MemberFinanceStatus.extensionSuccess) {
            // Manual yang tidak perlu halaman pembayaran (sudah selesai langsung)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(children: [
                  Icon(Icons.check_circle_outline, color: doneColor, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  const Text('Perpanjangan sewa berhasil diproses'),
                ]),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                margin: const EdgeInsets.all(AppSpacing.lg),
                duration: const Duration(seconds: 3),
              ),
            );
            context.router.maybePop();
          } else if (state.status == MemberFinanceStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(children: [
                  Icon(Icons.error_outline, color: cancelColor, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(state.errorMessage ?? 'Terjadi kesalahan')),
                ]),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                margin: const EdgeInsets.all(AppSpacing.lg),
              ),
            );
          }
        },
        child: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────────
                Row(children: [
                  IconButton(
                    onPressed: () => context.router.maybePop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Perpanjang Sewa',
                      style: Theme.of(context).textTheme.headlineLarge),
                ]),
                const SizedBox(height: AppSpacing.xxl),

                // ── Info sewa aktif ───────────────────────────────────────
                _buildLeaseInfoCard(
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  leaseStatusBg: leaseStatusBg,
                  leaseStatusColor: leaseStatusColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  textHint: textHint,
                  daysLeft: daysLeft,
                ),
                const SizedBox(height: AppSpacing.xl),

                if (_step == 1) ...[
                  // ── Durasi + preview tanggal ────────────────────────────
                  _buildDurationCard(
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    textHint: textHint,
                    textSecondary: textSecondary,
                    doneColor: doneColor,
                    doneBg: doneBg,
                    newEndDate: newEndDate,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Metode pembayaran ───────────────────────────────────
                  _buildPaymentMethodCard(
                    surfaceColor: surfaceColor,
                    surfaceVariant: surfaceVariant,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    textHint: textHint,
                    doneColor: doneColor,
                    doneBg: doneBg,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Tombol step 1 ───────────────────────────────────────
                  if (_paymentMethod == 'manual') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isInitiating ? null : _initiateManualPayment,
                        icon: _isInitiating
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.arrow_forward, size: 18),
                        label: Text(_isInitiating ? 'Memproses…' : 'Lanjutkan ke Upload Bukti'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ] else ...[
                    BlocBuilder<MemberFinanceBloc, MemberFinanceState>(
                      builder: (context, state) {
                        final isLoading = state.status == MemberFinanceStatus.loading;
                        final label = _selectedMidtransMethod != null
                            ? 'Bayar dengan ${_kMidtransMethods[_selectedMidtransMethod]?.label ?? _selectedMidtransMethod!.toUpperCase()}'
                            : 'Lanjutkan ke Pembayaran';
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () => context.read<MemberFinanceBloc>().add(
                                      ExtendLeaseEvent(
                                        widget.leaseId,
                                        _duration,
                                        _paymentMethod,
                                        preferredPaymentType: _selectedMidtransMethod,
                                      ),
                                    ),
                            icon: isLoading
                                ? const SizedBox(
                                    width: 18, height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.payment_outlined, size: 18),
                            label: Text(isLoading ? 'Memproses…' : label),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ] else ...[
                  // ── STEP 2: Upload bukti dengan countdown ───────────────
                  _buildCountdownBanner(context),
                  const SizedBox(height: AppSpacing.md),
                  _buildStep2UploadCard(
                    surfaceColor: surfaceColor,
                    surfaceVariant: surfaceVariant,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    textHint: textHint,
                    doneColor: doneColor,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  BlocBuilder<MemberFinanceBloc, MemberFinanceState>(
                    builder: (context, state) {
                      final isLoading = state.status == MemberFinanceStatus.loading;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: (isLoading || !_canSubmitStep2)
                              ? null
                              : () => context.read<MemberFinanceBloc>().add(
                                    PayInvoiceEvent(
                                      _invoiceId!,
                                      'manual',
                                      paymentProofBytes: _proofBytes,
                                      paymentProofName: _proofName,
                                    ),
                                  ),
                          icon: isLoading
                              ? const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.send_outlined, size: 18),
                          label: Text(isLoading ? 'Mengirim…' : 'Kirim Bukti Pembayaran'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Info sewa aktif ───────────────────────────────────────────────────────

  Widget _buildLeaseInfoCard({
    required Color surfaceColor,
    required Color borderColor,
    required Color leaseStatusBg,
    required Color leaseStatusColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color textHint,
    required int daysLeft,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: borderColor),
        boxShadow: const [AppShadows.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SEWA AKTIF',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: textHint, letterSpacing: 0.8)),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: leaseStatusBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(Icons.meeting_room_outlined, color: leaseStatusColor, size: 24),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kamar ${widget.roomNumber}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                        color: textPrimary)),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.calendar_today_outlined, size: 13, color: textHint),
                  const SizedBox(width: 4),
                  Text(
                    'Berakhir: ${DateFormat('dd MMMM yyyy').format(widget.currentEndDate)}',
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                ]),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: leaseStatusBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: leaseStatusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    daysLeft < 0 ? 'Sudah berakhir'
                        : daysLeft == 0 ? 'Berakhir hari ini'
                        : 'Sisa $daysLeft hari',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        color: leaseStatusColor),
                  ),
                ),
              ],
            )),
          ]),
        ],
      ),
    );
  }

  // ── Durasi ────────────────────────────────────────────────────────────────

  Widget _buildDurationCard({
    required Color surfaceColor,
    required Color borderColor,
    required Color textHint,
    required Color textSecondary,
    required Color doneColor,
    required Color doneBg,
    required DateTime newEndDate,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: borderColor),
        boxShadow: const [AppShadows.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DURASI PERPANJANGAN',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: textHint, letterSpacing: 0.8)),
          const SizedBox(height: AppSpacing.md),
          Text('Pilih berapa bulan Anda ingin memperpanjang masa sewa.',
              style: TextStyle(fontSize: 13, color: textSecondary)),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<int>(
            initialValue: _duration,
            items: List.generate(12, (i) => i + 1)
                .map((m) => DropdownMenuItem(value: m, child: Text('$m Bulan')))
                .toList(),
            onChanged: (val) => setState(() => _duration = val ?? 1),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.md),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: doneBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: doneColor.withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: doneColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(Icons.event_available, size: 18, color: doneColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Tanggal berakhir baru',
                    style: TextStyle(fontSize: 11, color: doneColor.withValues(alpha: 0.8))),
                Text(DateFormat('dd MMMM yyyy').format(newEndDate),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                        color: doneColor)),
              ]),
            ]),
          ),
        ],
      ),
    );
  }

  // ── Metode pembayaran ─────────────────────────────────────────────────────

  Widget _buildPaymentMethodCard({
    required Color surfaceColor,
    required Color surfaceVariant,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color textHint,
    required Color doneColor,
    required Color doneBg,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: borderColor),
        boxShadow: const [AppShadows.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('METODE PEMBAYARAN',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: textHint, letterSpacing: 0.8)),
          const SizedBox(height: AppSpacing.lg),

          // Pilihan transfer bank (manual)
          _PaymentMethodTile(
            value: 'manual',
            groupValue: _paymentMethod,
            icon: Icons.account_balance_outlined,
            label: 'Transfer Bank',
            description: 'Upload bukti transfer ke rekening wisma',
            isDark: AppTheme.isDark(context),
            onChanged: (v) => setState(() => _paymentMethod = v),
          ),

          if (widget.isMidtransEnabled) ...[
            const SizedBox(height: AppSpacing.sm),
            _PaymentMethodTile(
              value: 'midtrans',
              groupValue: _paymentMethod,
              icon: Icons.payment_outlined,
              label: 'Midtrans',
              description: 'Bayar online via QRIS, GoPay, VA Bank, dll.',
              isDark: AppTheme.isDark(context),
              onChanged: (v) => setState(() {
                _paymentMethod = v;
                _proofBytes = null;
                _proofName = null;
              }),
            ),
          ],

          const SizedBox(height: AppSpacing.xl),

          // ── Detail sesuai metode ──────────────────────────────────────
          if (_paymentMethod == 'manual') ...[
            // Countdown timer
            _buildCountdownBanner(context),
            const SizedBox(height: AppSpacing.md),

            // Info rekening
            if (_bankAccounts.isNotEmpty) ...[
              Text('Transfer ke salah satu rekening berikut:',
                  style: TextStyle(fontSize: 12, color: textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              ..._bankAccounts.map((account) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(account.bankName,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary)),
                    const SizedBox(height: 2),
                    Text(account.accountNumber,
                        style: TextStyle(fontSize: 16, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: textPrimary)),
                    Text('a.n. ${account.accountHolder}',
                        style: TextStyle(fontSize: 12, color: textHint)),
                    if (account.paymentInstructions != null && account.paymentInstructions!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(account.paymentInstructions!,
                          style: TextStyle(fontSize: 12, color: textSecondary)),
                    ],
                  ]),
                ),
              )),
              const SizedBox(height: AppSpacing.sm),
            ],

            // Upload bukti
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: _proofBytes != null ? doneBg : surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: _proofBytes != null
                        ? doneColor.withValues(alpha: 0.5)
                        : borderColor,
                  ),
                ),
                child: Row(children: [
                  Icon(
                    _proofBytes != null
                        ? Icons.check_circle_outline
                        : Icons.upload_file_outlined,
                    color: _proofBytes != null ? doneColor : textSecondary,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _proofBytes != null
                            ? 'Bukti transfer dipilih'
                            : 'Upload Bukti Transfer',
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: _proofBytes != null ? doneColor : textPrimary,
                        ),
                      ),
                      if (_proofName != null)
                        Text(_proofName!,
                            style: TextStyle(fontSize: 11, color: textSecondary),
                            maxLines: 1, overflow: TextOverflow.ellipsis)
                      else
                        Text('Tap untuk memilih gambar (JPG/PNG)',
                            style: TextStyle(fontSize: 11, color: textHint)),
                    ],
                  )),
                  if (_proofBytes != null)
                    Icon(Icons.edit_outlined, size: 16, color: textSecondary),
                ]),
              ),
            ),
          ] else ...[
            // ── Grid pilihan metode Midtrans ──────────────────────────
            Text('Pilih metode pembayaran Midtrans',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: textPrimary)),
            const SizedBox(height: 4),
            Text(
              'Kosongkan pilihan untuk diarahkan ke halaman Midtrans '
              'dengan semua metode tersedia.',
              style: TextStyle(fontSize: 11, color: textHint),
            ),
            const SizedBox(height: AppSpacing.md),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                mainAxisExtent: 72,
              ),
              itemCount: _kMidtransMethods.length,
              itemBuilder: (context, index) {
                final code = _kMidtransMethods.keys.elementAt(index);
                final info = _kMidtransMethods[code]!;
                final isSelected = _selectedMidtransMethod == code;

                return GestureDetector(
                  onTap: () => setState(() =>
                      _selectedMidtransMethod = isSelected ? null : code),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isSelected ? doneBg : surfaceVariant,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: isSelected
                            ? doneColor.withValues(alpha: 0.6)
                            : borderColor,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(
                              color: doneColor.withValues(alpha: 0.12),
                              blurRadius: 6, offset: const Offset(0, 2))]
                          : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: Row(children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? doneColor.withValues(alpha: 0.15)
                                : borderColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(info.icon, size: 18,
                              color: isSelected ? doneColor : textSecondary),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(info.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.5,
                                  color: isSelected ? doneColor : textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            Text(info.desc,
                                style: TextStyle(fontSize: 10, color: textHint),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        )),
                      ]),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep2UploadCard({
    required Color surfaceColor,
    required Color surfaceVariant,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color textHint,
    required Color doneColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('INFORMASI TRANSFER',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: textHint, letterSpacing: 0.8)),
          const SizedBox(height: AppSpacing.md),
          if (_bankAccounts.isNotEmpty) ...[
            Text('Transfer ke salah satu rekening berikut:',
                style: TextStyle(fontSize: 12, color: textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            ..._bankAccounts.map((account) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: borderColor),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(account.bankName,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary)),
                  Text(account.accountNumber,
                      style: TextStyle(fontSize: 16, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: textPrimary)),
                  Text('a.n. ${account.accountHolder}',
                      style: TextStyle(fontSize: 12, color: textHint)),
                  if (account.paymentInstructions != null && account.paymentInstructions!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(account.paymentInstructions!,
                        style: TextStyle(fontSize: 12, color: textSecondary)),
                  ],
                ]),
              ),
            )),
            const SizedBox(height: AppSpacing.md),
          ],
          if (_invoiceAmount != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: doneColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: doneColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Jumlah Transfer:',
                      style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
                  Text(
                    'Rp ${_invoiceAmount!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: doneColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Text('UPLOAD BUKTI TRANSFER',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: textHint, letterSpacing: 0.8)),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: _timerExpired ? null : _pickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: _proofBytes != null
                    ? doneColor.withValues(alpha: 0.08)
                    : surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: _proofBytes != null
                      ? doneColor.withValues(alpha: 0.5)
                      : borderColor,
                ),
              ),
              child: Row(children: [
                Icon(
                  _proofBytes != null ? Icons.check_circle_outline : Icons.upload_file_outlined,
                  color: _proofBytes != null ? doneColor : textSecondary,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _proofBytes != null ? 'Bukti transfer dipilih' : 'Upload Bukti Transfer',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                          color: _proofBytes != null ? doneColor : textPrimary),
                    ),
                    if (_proofName != null)
                      Text(_proofName!,
                          style: TextStyle(fontSize: 11, color: textSecondary),
                          maxLines: 1, overflow: TextOverflow.ellipsis)
                    else
                      Text('Tap untuk memilih gambar (JPG/PNG)',
                          style: TextStyle(fontSize: 11, color: textHint)),
                  ],
                )),
                if (_proofBytes != null)
                  Icon(Icons.edit_outlined, size: 16, color: textSecondary),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownBanner(BuildContext context) {
    final color = _timerColor(context);
    final bgColor = color.withValues(alpha: 0.1);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            _timerExpired ? Icons.timer_off_outlined : Icons.timer_outlined,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _timerExpired
                  ? 'Waktu pembayaran habis'
                  : 'Selesaikan dalam $_timerLabel',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color),
            ),
          ),
          if (!_timerExpired)
            Text(
              _timerLabel,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: color),
            ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.label,
    required this.description,
    required this.isDark,
    required this.onChanged,
  });

  final String value;
  final String groupValue;
  final IconData icon;
  final String label;
  final String description;
  final bool isDark;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    final doneColor   = isDark ? AppColorsDark.statusDone    : AppColorsLight.statusDone;
    final doneBg      = isDark ? AppColorsDark.statusDoneBg  : AppColorsLight.statusDoneBg;
    final borderColor = isDark ? AppColorsDark.borderLight   : AppColorsLight.borderLight;
    final textPrimary    = isDark ? AppColorsDark.textPrimary    : AppColorsLight.textPrimary;
    final textSecondary  = isDark ? AppColorsDark.textSecondary  : AppColorsLight.textSecondary;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? doneBg : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
              color: isSelected ? doneColor.withValues(alpha: 0.5) : borderColor),
        ),
        child: Row(children: [
          Radio<String>(
            value: value, groupValue: groupValue,
            onChanged: (v) => onChanged(v!),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            activeColor: doneColor,
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected
                  ? doneColor.withValues(alpha: 0.15)
                  : borderColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, size: 18,
                color: isSelected ? doneColor : textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w600, color: textPrimary)),
              Text(description, style: TextStyle(
                  fontSize: 11, color: textSecondary)),
            ],
          )),
        ]),
      ),
    );
  }
}

class _BankRow extends StatelessWidget {
  const _BankRow({
    required this.label, required this.value,
    required this.textPrimary, required this.textSecondary,
  });
  final String label, value;
  final Color textPrimary, textSecondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: textSecondary)),
          Text(value, style: TextStyle(fontSize: 13,
              fontWeight: FontWeight.w700, color: textPrimary)),
        ],
      ),
    );
  }
}
