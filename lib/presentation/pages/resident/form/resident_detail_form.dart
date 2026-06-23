import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/domain/entity/resident/resident_detail_entity.dart';
import 'package:frontend/presentation/bloc/resident_detail/resident_detail_bloc.dart';
import 'package:frontend/presentation/widget/core/image/image_network.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';

class ResidentDetailForm extends StatelessWidget {
  const ResidentDetailForm({super.key, required this.residentId});

  final String residentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          serviceLocator<ResidentDetailBloc>()..add(FetchResidentDetail(residentId)),
      child: const _ResidentDetailBody(),
    );
  }
}

class _ResidentDetailBody extends StatelessWidget {
  const _ResidentDetailBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResidentDetailBloc, ResidentDetailState>(
      builder: (context, state) {
        if (state is ResidentDetailLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ResidentDetailError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              state.message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        if (state is ResidentDetailLoaded) {
          return _ResidentDetailContent(data: state.data);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _ResidentDetailContent extends StatelessWidget {
  const _ResidentDetailContent({required this.data});

  final ResidentDetailEntity data;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Penghuni',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 20),
              _SectionTitle(title: 'Kontrak'),
              _DetailRow(label: 'ID', value: data.id),
              _DetailRow(label: 'Status', value: data.status),
              _DetailRow(label: 'Mulai', value: data.startDate),
              _DetailRow(label: 'Selesai', value: data.endDate),
              _DetailRow(label: 'Dibatalkan', value: data.finishedAt ?? '-'),
              const SizedBox(height: 16),
              _SectionTitle(title: 'Bukti Pembayaran'),
              if (data.paymentProofUrl != null && data.paymentProofUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ImageNetwork(imageUrl: data.paymentProofUrl),
                )
              else
                const Text('-'),
              const SizedBox(height: 16),
              _SectionTitle(title: 'Kamar'),
              _DetailRow(label: 'ID Kamar', value: data.room.id?.toString() ?? '-'),
              _DetailRow(label: 'Nomor', value: data.room.number),
              _DetailRow(label: 'Nama', value: data.room.title),
              _DetailRow(
                label: 'Harga',
                value: data.room.price != null ? data.room.price.toString() : '-',
              ),
              const SizedBox(height: 16),
              _SectionTitle(title: 'Penghuni'),
              _DetailRow(label: 'ID Penghuni', value: data.resident.id ?? '-'),
              _DetailRow(label: 'Nama', value: data.resident.name),
              _DetailRow(label: 'Email', value: data.resident.email),
              _DetailRow(label: 'NIK', value: data.resident.idCardNumber),
              _DetailRow(label: 'No HP', value: data.resident.phoneNumber),
              _DetailRow(label: 'Gender', value: data.resident.gender),
              _DetailRow(label: 'Pekerjaan', value: data.resident.job),
              _DetailRow(label: 'Alamat KTP', value: data.resident.addressKtp),
              _DetailRow(
                label: 'Kontak Darurat',
                value: data.resident.emergencyContactName,
              ),
              _DetailRow(
                label: 'No Kontak Darurat',
                value: data.resident.emergencyContactPhone,
              ),
              const SizedBox(height: 12),
              _SectionTitle(title: 'KTP'),
              if (data.resident.ktpPhotoUrl != null &&
                  data.resident.ktpPhotoUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ImageNetwork(imageUrl: data.resident.ktpPhotoUrl),
                )
              else
                const Text('-'),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: BasicButton(
                  type: ButtonType.secondary,
                  onPressed: () => Navigator.of(context).pop(),
                  label: 'Tutup',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7) ?? Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
