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
    this.bankName = '',
    this.bankAccount = '',
    this.bankHolder = '',
  });

  final int leaseId;
  final String roomNumber;
  final DateTime currentEndDate;
  final bool isMidtransEnabled;
  final String bankName;
  final String bankAccount;
  final String bankHolder;

  @override
  State<ExtendLeasePage> createState() => _ExtendLeasePageState();
}

class _ExtendLeasePageState extends State<ExtendLeasePage> {
  int _duration = 1;
  String _paymentMethod = 'manual';
  String? _selectedMidtransMethod;
  Uint8List? _proofBytes;
  String? _proofName;

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

  bool get _canSubmit {
    if (_paymentMethod == 'manual') return _proofBytes != null;
    // midtrans: bisa submit tanpa pilih sub-metode (gunakan Snap sebagai fallback)
    return true;
  }

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

                // ── Durasi + preview tanggal ──────────────────────────────
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

                // ── Metode pembayaran ─────────────────────────────────────
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

                // ── Tombol submit ─────────────────────────────────────────
                BlocBuilder<MemberFinanceBloc, MemberFinanceState>(
                  builder: (context, state) {
                    final isLoading = state.status == MemberFinanceStatus.loading;
                    final label = _paymentMethod == 'midtrans'
                        ? (_selectedMidtransMethod != null
                            ? 'Bayar dengan ${_kMidtransMethods[_selectedMidtransMethod]?.label ?? _selectedMidtransMethod!.toUpperCase()}'
                            : 'Lanjutkan ke Pembayaran')
                        : 'Kirim Bukti Pembayaran';

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading || !_canSubmit
                            ? null
                            : () {
                                context.read<MemberFinanceBloc>().add(
                                  ExtendLeaseEvent(
                                    widget.leaseId,
                                    _duration,
                                    _paymentMethod,
                                    paymentProofBytes: _proofBytes,
                                    paymentProofName: _proofName,
                                    preferredPaymentType: _selectedMidtransMethod,
                                  ),
                                );
                              },
                        icon: isLoading
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Icon(
                                _paymentMethod == 'midtrans'
                                    ? Icons.payment_outlined
                                    : Icons.send_outlined,
                                size: 18),
                        label: Text(isLoading ? 'Memproses…' : label),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                          textStyle: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  },
                ),
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
            // Info rekening
            if (widget.bankName.isNotEmpty || widget.bankAccount.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: borderColor),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Transfer ke rekening berikut:',
                      style: TextStyle(fontSize: 12, color: textSecondary)),
                  const SizedBox(height: AppSpacing.sm),
                  if (widget.bankName.isNotEmpty)
                    _BankRow(label: 'Bank', value: widget.bankName,
                        textPrimary: textPrimary, textSecondary: textSecondary),
                  if (widget.bankAccount.isNotEmpty)
                    _BankRow(label: 'No. Rekening', value: widget.bankAccount,
                        textPrimary: textPrimary, textSecondary: textSecondary),
                  if (widget.bankHolder.isNotEmpty)
                    _BankRow(label: 'Atas Nama', value: widget.bankHolder,
                        textPrimary: textPrimary, textSecondary: textSecondary),
                ]),
              ),
              const SizedBox(height: AppSpacing.lg),
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
