import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

// --- Core Widget Imports ---
import 'package:frontend/presentation/widget/core/card/basic_card.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/presentation/bloc/profile/profile_bloc.dart';
import 'package:frontend/presentation/bloc/resident/complete_profile/complete_profile_bloc.dart';
import 'package:frontend/presentation/bloc/resident/complete_profile/complete_profile_event.dart';
import 'package:frontend/presentation/bloc/resident/complete_profile/complete_profile_state.dart';
import 'package:frontend/presentation/bloc/my_reservation/my_reservation_bloc.dart';
import 'package:frontend/presentation/bloc/my_reservation/my_reservation_event.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';

@RoutePage()
class ProfileUserPage extends StatelessWidget {
  const ProfileUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Sesuai warna background mockup
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => serviceLocator<ProfileBloc>()..add(FetchProfile()),
          ),
          BlocProvider(
            create: (context) => serviceLocator<CompleteProfileBloc>()..add(LoadProfileEvent()),
          ),
          BlocProvider(
            create: (context) => serviceLocator<MyReservationBloc>()..add(GetMyReservationsEvent()),
          ),
        ],
        child: Builder(
          builder: (context) {
            final profileState = context.watch<ProfileBloc>().state;
            final completeProfileState = context.watch<CompleteProfileBloc>().state;
            final myReservationState = context.watch<MyReservationBloc>().state;

            final isLoading = profileState is ProfileLoading ||
                completeProfileState is CompleteProfileLoading ||
                myReservationState.status == FormzSubmissionStatus.inProgress;

            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Extract User data
            String name = '-';
            String email = '-';
            String phone = '-';
            String? role;
            if (profileState is ProfileLoaded) {
              name = profileState.user.name;
              email = profileState.user.email;
              phone = profileState.user.phoneNumber ?? '-';
              role = profileState.user.role;
            }

            final roleLower = (role ?? '').toLowerCase();
            final isAdmin = roleLower.contains('admin');
            final isTenant = roleLower.contains('resident') ||
                roleLower.contains('member') ||
                roleLower.contains('tenant') ||
                roleLower.contains('penyewa');

            // Extract Resident Profile data
            String gender = '-';
            String job = '-';
            String ktpPhotoUrl = '';
            if (completeProfileState is CompleteProfileLoaded) {
              final p = completeProfileState.profile;
              gender = p.gender == 'male' ? 'Laki-laki' : (p.gender == 'female' ? 'Perempuan' : p.gender);
              job = p.job ?? '-';
              ktpPhotoUrl = p.ktpPhotoUrl ?? '';
              if (phone == '-') phone = p.phoneNumber; // fallback
            }

            // Extract Lease data
            String roomNumber = '-';
            String rentalType = '-';
            String endDate = '-';
            String startDate = '-';
            String paymentStatus = '-';
            String residentStatus = 'Aktif'; // Default for logged in users
            if (myReservationState.status == FormzSubmissionStatus.success &&
                myReservationState.reservations.isNotEmpty) {
              // Get the most recent active lease
              final res = myReservationState.reservations.first;
              roomNumber = res.roomTitle;
              if (res.roomNumber.isNotEmpty) {
                roomNumber += ' - ${res.roomNumber}';
              }
              rentalType = res.rentalType;
              endDate = res.endDate;
              startDate = res.startDate;
              paymentStatus = res.paymentStatus == 'paid' ? 'Lunas' : (res.paymentStatus == 'unpaid' ? 'Belum Lunas' : res.paymentStatus);
              residentStatus = res.status == 'active' ? 'Aktif' : res.status;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- JUDUL HALAMAN ---
                  Text(
                    'Profile Penghuni',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontSize: 32, // Disesuaikan proporsinya
                          fontWeight: FontWeight.w700,
                          height: 1,
                          color: const Color(0xFF121212),
                        ),
                  ),
                  const SizedBox(height: 16),

                  if (isTenant && !isAdmin && completeProfileState is! CompleteProfileLoaded)
                    BasicCard(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Color(0xFF111827),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Data profil belum lengkap. Lengkapi untuk melanjutkan sebagai penyewa.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF374151),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: () async {
                              await context.router.push(
                                const CompleteProfileRoute(),
                              );
                              if (context.mounted) {
                                context.read<ProfileBloc>().add(FetchProfile());
                                context.read<CompleteProfileBloc>().add(
                                      LoadProfileEvent(),
                                    );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Lengkapi'),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // --- HEADER PROFILE ---
                  Row(
                    children: [
                      // Avatar Lingkaran (Diperbesar proporsinya sesuai mockup)
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF141414),
                            width: 2.5,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: ktpPhotoUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: Image.network(
                                  ktpPhotoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person_outline,
                                    size: 48,
                                    color: Color(0xFF141414),
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.person_outline,
                                size: 48,
                                color: Color(0xFF141414),
                              ),
                      ),
                      const SizedBox(width: 20),
                      // Nama dan Kamar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF141414),
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            roomNumber,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 15,
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // --- CARD 1: INFORMASI PRIBADI ---
                  _InfoSectionCard(
                    title: 'Informasi Pribadi',
                    showEditButton: isTenant && !isAdmin,
                    onEditTap: () async {
                      await context.router.push(const CompleteProfileRoute());
                      if (context.mounted) {
                        context.read<ProfileBloc>().add(FetchProfile());
                        context.read<CompleteProfileBloc>().add(LoadProfileEvent());
                      }
                    },
                    child: Wrap(
                      spacing: 24,    // Jarak horizontal antar kolom
                      runSpacing: 24, // Jarak vertikal antar baris
                      children: [
                        _InfoItem(label: 'Nama Lengkap', value: name),
                        _InfoItem(label: 'Nomor Telepon', value: phone),
                        _InfoItem(label: 'Alamat Email', value: email),
                        _InfoItem(label: 'Jenis Kelamin', value: gender),
                        _InfoItem(label: 'Nomor Kamar', value: roomNumber),
                        _InfoItem(label: 'Status', value: job),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- CARD 2: INFORMASI KONTRAK SEWA ---
                  _InfoSectionCard(
                    title: 'Informasi Kontrak Sewa',
                    child: Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: [
                        _InfoItem(label: 'Tipe Kamar', value: rentalType),
                        _InfoItem(label: 'Tanggal Berakhir Kontrak', value: endDate),
                        _InfoItem(label: 'Harga Sewa', value: '-'), // API doesn't return price in rentals/my
                        _InfoItem(label: 'Status Penghuni', value: residentStatus),
                        _InfoItem(label: 'Tanggal Mulai Sewa', value: startDate),
                        _InfoItem(label: 'Status Pembayaran', value: paymentStatus),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PRIVATE WIDGETS (Helper khusus untuk layout card dan teks)
// -----------------------------------------------------------------------------

class _InfoSectionCard extends StatelessWidget {
  const _InfoSectionCard({
    required this.title,
    required this.child,
    this.showEditButton = false,
    this.onEditTap,
  });

  final String title;
  final Widget child;
  final bool showEditButton;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    return BasicCard(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(32), // Padding diperlebar sesuai mockup
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
              ),
              const Spacer(),
              if (showEditButton)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(99),
                    onTap: onEditTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFD1D5DB)),
                        borderRadius: BorderRadius.circular(99),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Edit',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFF374151),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: Color(0xFF374151),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          child, // Konten Wrap dimuat di sini
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    // Memberikan lebar tetap agar susunannya mengunci rapi di kiri seperti mockup
    return SizedBox(
      width: 320, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  color: const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  color: const Color(0xFF111827),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}