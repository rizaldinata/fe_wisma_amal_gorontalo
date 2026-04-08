import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

// --- Core Widget Imports ---
import 'package:frontend/presentation/widget/core/card/basic_card.dart';

@RoutePage()
class ProfileUserPage extends StatelessWidget {
  const ProfileUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Sesuai warna background mockup
      body: SingleChildScrollView(
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
            const SizedBox(height: 32),

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
                  child: const Icon(
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
                      'Rasyidatur Rahma',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF141414),
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Kamar 3 - Lantai 1',
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
              showEditButton: true,
              child: Wrap(
                spacing: 24,    // Jarak horizontal antar kolom
                runSpacing: 24, // Jarak vertikal antar baris
                children: const [
                  _InfoItem(label: 'Nama Lengkap', value: 'Rasyidatur Rahma'),
                  _InfoItem(label: 'Nomor Telepon', value: '0853 - 8686 - 8686'),
                  _InfoItem(label: 'Alamat Email', value: 'apaaja@gmail.com'),
                  _InfoItem(label: 'Jenis Kelamin', value: 'Perempuan'),
                  _InfoItem(label: 'Nomor Kamar', value: 'Kamar 3 - Lantai 1'),
                  _InfoItem(label: 'Status', value: 'Mahasiswa'),
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
                children: const [
                  _InfoItem(label: 'Tipe Kamar', value: 'AC'),
                  _InfoItem(label: 'Tanggal Berakhir Kontrak', value: '05 Juni 2026'),
                  _InfoItem(label: 'Harga Sewa', value: '1.200.000,-'),
                  _InfoItem(label: 'Status Penghuni', value: 'Aktif'),
                  _InfoItem(label: 'Tanggal Mulai Sewa', value: '05 Mei 2024'),
                  _InfoItem(label: 'Status Pembayaran', value: 'Lunas'),
                ],
              ),
            ),
          ],
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
  });

  final String title;
  final Widget child;
  final bool showEditButton;

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
                    onTap: () {
                      // TODO: Aksi tombol edit
                    },
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