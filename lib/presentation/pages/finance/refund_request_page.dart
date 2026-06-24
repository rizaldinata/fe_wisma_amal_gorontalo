import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/domain/entity/refund_request_entity.dart';
import 'package:frontend/presentation/bloc/refund_request/refund_request_bloc.dart';
import 'package:frontend/presentation/bloc/refund_request/refund_request_event.dart';
import 'package:frontend/presentation/bloc/refund_request/refund_request_state.dart';
import 'package:intl/intl.dart';

@RoutePage()
class RefundRequestPage extends StatefulWidget {
  const RefundRequestPage({super.key});

  @override
  State<RefundRequestPage> createState() => _RefundRequestPageState();
}

class _RefundRequestPageState extends State<RefundRequestPage> {
  late final RefundRequestBloc _bloc;
  String? _activeFilter;

  @override
  void initState() {
    super.initState();
    _bloc = serviceLocator<RefundRequestBloc>();
    _bloc.add(LoadRefundRequestsEvent());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  final _filterOptions = const [
    (label: 'Semua', value: null),
    (label: 'Menunggu', value: 'pending'),
    (label: 'Diproses', value: 'processed'),
    (label: 'Ditolak', value: 'rejected'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<RefundRequestBloc, RefundRequestState>(
        listenWhen: (prev, curr) => prev.actionStatus != curr.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == FormzSubmissionStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Berhasil diproses'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state.actionStatus == FormzSubmissionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Terjadi kesalahan'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Permintaan Pembatalan DP'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _bloc.add(LoadRefundRequestsEvent(status: _activeFilter)),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildFilterBar(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filterOptions.map((opt) {
            final isActive = _activeFilter == opt.value;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(opt.label),
                selected: isActive,
                onSelected: (_) {
                  setState(() => _activeFilter = opt.value);
                  _bloc.add(LoadRefundRequestsEvent(status: opt.value));
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<RefundRequestBloc, RefundRequestState>(
      builder: (context, state) {
        if (state.loadStatus == FormzSubmissionStatus.inProgress ||
            state.loadStatus == FormzSubmissionStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.loadStatus == FormzSubmissionStatus.failure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.errorMessage ?? 'Terjadi kesalahan'),
                TextButton(
                  onPressed: () =>
                      _bloc.add(LoadRefundRequestsEvent(status: _activeFilter)),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          );
        }
        if (state.requests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text('Belum ada permintaan pembatalan',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async =>
              _bloc.add(LoadRefundRequestsEvent(status: _activeFilter)),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.requests.length,
            itemBuilder: (context, index) =>
                _RefundCard(request: state.requests[index]),
          ),
        );
      },
    );
  }
}

class _RefundCard extends StatelessWidget {
  final RefundRequestEntity request;
  const _RefundCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(request.status);
    final statusLabel = _statusLabel(request.status);
    final fmt = NumberFormat('#,###', 'id');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.tenantName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Kamar ${request.roomNumber} · ${request.invoiceNumber}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Eligibility chip
            Row(
              children: [
                Icon(
                  request.isRefundEligible
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  size: 14,
                  color: request.isRefundEligible
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  request.isRefundEligible
                      ? 'Berhak Refund'
                      : 'Tidak Berhak Refund',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: request.isRefundEligible
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Info rekening
            _infoRow(Icons.account_balance_outlined, 'Bank',
                request.bankName),
            const SizedBox(height: 4),
            _infoRow(Icons.numbers_outlined, 'No. Rekening',
                request.accountNumber),
            const SizedBox(height: 4),
            _infoRow(Icons.person_outline, 'Atas Nama',
                request.accountHolderName),
            const SizedBox(height: 4),
            _infoRow(Icons.payments_outlined, 'Jumlah Refund',
                'Rp ${fmt.format(request.refundAmount.toInt())}'),
            if (request.adminFee != null && request.adminFee! > 0) ...[
              const SizedBox(height: 4),
              _infoRow(Icons.receipt_outlined, 'Biaya Admin',
                  'Rp ${fmt.format(request.adminFee!.toInt())}'),
            ],
            if (request.adminNotes != null &&
                request.adminNotes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              _infoRow(
                  Icons.notes_outlined, 'Catatan', request.adminNotes!),
            ],
            if (request.status == 'pending') ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () =>
                        _showTolakDialog(context, request),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                    child: const Text('Tolak'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () =>
                        _showProsesDialog(context, request),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                    child: const Text('Setujui'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Text('$label: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'processed':
        return 'Diproses';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  void _showTolakDialog(BuildContext context, RefundRequestEntity request) {
    final notesCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tolak Permintaan Pembatalan'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: notesCtrl,
            decoration: const InputDecoration(
              labelText: 'Catatan Penolakan',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            maxLines: 3,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(dialogContext);
              context.read<RefundRequestBloc>().add(TolakRefundEvent(
                    id: request.id,
                    adminNotes: notesCtrl.text.trim(),
                  ));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  void _showProsesDialog(BuildContext context, RefundRequestEntity request) {
    if (!request.isRefundEligible) {
      _showProsesKonfirmasi(context, request);
    } else {
      _showProsesWithRefund(context, request);
    }
  }

  void _showProsesKonfirmasi(
      BuildContext context, RefundRequestEntity request) {
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Setujui Pembatalan (Tanpa Refund)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                'Penyewa tidak berhak mendapat pengembalian dana karena pembatalan kurang dari 3 hari sebelum tanggal masuk. Jadwal akan dibatalkan tanpa pengembalian dana.',
                style:
                    TextStyle(fontSize: 12, color: Colors.red.shade800, height: 1.4),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<RefundRequestBloc>().add(ProsesRefundEvent(
                    id: request.id,
                    adminNotes: notesCtrl.text.trim(),
                  ));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white),
            child: const Text('Konfirmasi Batalkan'),
          ),
        ],
      ),
    );
  }

  void _showProsesWithRefund(
      BuildContext context, RefundRequestEntity request) {
    final adminFeeCtrl = TextEditingController(text: '0');
    final notesCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    PlatformFile? selectedFile;
    String? selectedFileName;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Setujui & Upload Bukti Transfer'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Upload bukti transfer dana refund kepada penyewa.',
                      style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 12),
                  // Upload bukti
                  GestureDetector(
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.image,
                        withData: true,
                      );
                      if (result != null && result.files.isNotEmpty) {
                        setDialogState(() {
                          selectedFile = result.files.first;
                          selectedFileName = selectedFile!.name;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedFile != null
                              ? Colors.green
                              : Colors.grey.shade400,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selectedFile != null
                                ? Icons.check_circle_outline
                                : Icons.upload_file_outlined,
                            color: selectedFile != null
                                ? Colors.green
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedFileName ?? 'Pilih bukti transfer (wajib)',
                              style: TextStyle(
                                fontSize: 13,
                                color: selectedFile != null
                                    ? Colors.black87
                                    : Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: adminFeeCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Biaya Admin (opsional, boleh 0)',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final parsed = double.tryParse(v);
                      if (parsed == null || parsed < 0) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Catatan (opsional)',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            BlocBuilder<RefundRequestBloc, RefundRequestState>(
              builder: (_, state) {
                final isLoading =
                    state.actionStatus == FormzSubmissionStatus.inProgress;
                return ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (!formKey.currentState!.validate()) return;
                          if (selectedFile == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bukti transfer wajib diunggah'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          Navigator.pop(dialogContext);
                          final fee = double.tryParse(adminFeeCtrl.text) ?? 0;
                          context.read<RefundRequestBloc>().add(
                                ProsesRefundEvent(
                                  id: request.id,
                                  proof: selectedFile,
                                  adminFee: fee,
                                  adminNotes: notesCtrl.text.trim(),
                                ),
                              );
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white),
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Proses Refund'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
