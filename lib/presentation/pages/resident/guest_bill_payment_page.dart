import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/presentation/bloc/guest/my_guest_bloc.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:intl/intl.dart';

@RoutePage()
class GuestBillPaymentPage extends StatelessWidget {
  final int guestId;
  final String guestName;
  final double amount;
  final String? billNumber;

  const GuestBillPaymentPage({
    super.key,
    required this.guestId,
    required this.guestName,
    required this.amount,
    this.billNumber,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<MyGuestBloc>(),
      child: _GuestBillPaymentView(
        guestId: guestId,
        guestName: guestName,
        amount: amount,
        billNumber: billNumber,
      ),
    );
  }
}

class _GuestBillPaymentView extends StatefulWidget {
  final int guestId;
  final String guestName;
  final double amount;
  final String? billNumber;

  const _GuestBillPaymentView({
    required this.guestId,
    required this.guestName,
    required this.amount,
    this.billNumber,
  });

  @override
  State<_GuestBillPaymentView> createState() => _GuestBillPaymentViewState();
}

class _GuestBillPaymentViewState extends State<_GuestBillPaymentView> {
  PlatformFile? _selectedFile;
  bool _isSubmitting = false;

  final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        setState(() => _selectedFile = file);
      }
    }
  }

  void _submit() {
    if (_selectedFile == null || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    context.read<MyGuestBloc>().add(PayGuestBillManual(
          guestId: widget.guestId,
          proofBytes: _selectedFile!.bytes!,
          proofName: _selectedFile!.name,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<MyGuestBloc, MyGuestState>(
      listener: (context, state) {
        if (state is MyGuestActionSuccess) {
          AppSnackbar.showSuccess(state.message);
          context.router.pop(true);
        } else if (state is MyGuestActionError) {
          setState(() => _isSubmitting = false);
          AppSnackbar.showError(state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pembayaran Manual'),
          leading: BackButton(
            onPressed: () => context.router.pop(false),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(theme),
                  const SizedBox(height: 20),
                  _buildBankInfoCard(theme),
                  const SizedBox(height: 20),
                  _buildUploadCard(theme),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: BasicButton(
                      isLoading: _isSubmitting,
                      onPressed: (_selectedFile == null || _isSubmitting)
                          ? null
                          : _submit,
                      leadIcon: const Icon(Icons.send_outlined, color: Colors.white, size: 18),
                      label: _isSubmitting ? 'Mengirim...' : 'Kirim Bukti Pembayaran',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ringkasan Tagihan',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            _summaryRow(theme, 'Tamu', widget.guestName),
            if (widget.billNumber != null)
              _summaryRow(theme, 'No. Tagihan', widget.billNumber!),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Bayar',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  _currency.format(widget.amount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfoCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informasi Transfer',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(60),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: theme.colorScheme.primary.withAlpha(60)),
              ),
              child: Column(
                children: [
                  Text('Bank Syariah Indonesia (BSI)',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(
                    '7123456789',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('a.n. Wisma Amal Gorontalo',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Nominal Transfer: ',
                          style: theme.textTheme.bodyMedium),
                      Text(
                        _currency.format(widget.amount),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upload Bukti Pembayaran',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'Upload foto struk transfer atau kwitansi pembayaran (JPG, PNG, PDF — maks 5 MB)',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            if (_selectedFile != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedFile!.name,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.green),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () =>
                          setState(() => _selectedFile = null),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: BasicButton(
                type: ButtonType.secondary,
                onPressed: _pickFile,
                leadIcon: Icon(Icons.upload_file_outlined, color: theme.colorScheme.primary, size: 18),
                label: _selectedFile == null ? 'Pilih File Bukti' : 'Ganti File',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
