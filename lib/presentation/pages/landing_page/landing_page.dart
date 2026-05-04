import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';

@RoutePage()
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LandingPalette.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1000;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroSection(isWide: isWide),
                const _ValueSection(),
                const _RoomSection(),
                _FeatureSection(isWide: isWide),
                const _TestimonialSection(),
                const _FooterSection(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LandingPalette {
  static const Color surface = Color(0xFFF6F7F3);
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color accent = Color(0xFF9CCC65);
  static const Color ink = Color(0xFF1F2A1F);
  static const Color muted = Color(0xFF5C6A5E);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8E2);
  static const Color heroGlow = Color(0xFFE9F2DF);
  static const Color banner = Color(0xFF0F2C1A);
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE9F2DF), Color(0xFFF6F7F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -120,
            top: -80,
            child: Container(
              height: 260,
              width: 260,
              decoration: const BoxDecoration(
                color: LandingPalette.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -160,
            bottom: -120,
            child: Container(
              height: 320,
              width: 320,
              decoration: BoxDecoration(
                color: LandingPalette.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 72 : 24,
              vertical: isWide ? 56 : 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _BrandMark(isWide: isWide),
                    if (isWide)
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: const Text('Fasilitas'),
                          ),
                          const SizedBox(width: 16),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Tipe Kamar'),
                          ),
                          const SizedBox(width: 16),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Testimoni'),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            height: 44,
                            child: BasicButton(
                              onPressed: () {
                                context.router.navigate(
                                  const AppLayoutRoute(
                                    children: [ReservationRoute()],
                                  ),
                                );
                              },
                              label: 'Reservasi Sekarang',
                              leadIcon: const Icon(
                                Icons.calendar_month,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 48),
                Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: isWide ? 6 : 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: LandingPalette.card,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: LandingPalette.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.check_circle, size: 16),
                                SizedBox(width: 8),
                                Text('Reservasi online tanpa ribet'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Temukan Kenyamanan Tinggal di Wisma Amal Gorontalo',
                            style: textTheme.displayLarge?.copyWith(
                              color: LandingPalette.ink,
                              fontSize: isWide ? 40 : 30,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Satu portal untuk calon penghuni mengecek ketersediaan kamar, melihat fasilitas, dan melakukan reservasi secara cepat.',
                            style: textTheme.bodyLarge?.copyWith(
                              color: LandingPalette.muted,
                              fontSize: 16,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                height: 48,
                                child: BasicButton(
                                  onPressed: () {
                                    context.router.navigate(
                                      const AppLayoutRoute(
                                        children: [ReservationRoute()],
                                      ),
                                    );
                                  },
                                  label: 'Cek Ketersediaan',
                                  leadIcon: const Icon(
                                    Icons.search,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 48,
                                child: BasicButton(
                                  type: ButtonType.secondary,
                                  onPressed: () {},
                                  label: 'Lihat Fasilitas',
                                  leadIcon: const Icon(
                                    Icons.star_border,
                                    size: 18,
                                    color: LandingPalette.primary,
                                  ),
                                  foregroundColor: LandingPalette.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Wrap(
                            spacing: 24,
                            runSpacing: 12,
                            children: const [
                              _HeroStat(label: '30+ Kamar', value: 'Tersedia'),
                              _HeroStat(label: '4.8/5', value: 'Rating'),
                              _HeroStat(label: '24/7', value: 'Layanan'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32, height: 32),
                    Expanded(
                      flex: isWide ? 5 : 0,
                      child: _HeroImage(isWide: isWide),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: LandingPalette.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.home_work, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wisma Amal',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: LandingPalette.ink,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              'Kenyamanan tinggal di Gorontalo',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: LandingPalette.muted,
                  ),
            ),
          ],
        ),
        if (!isWide)
          const SizedBox(
            width: 0,
          ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isWide ? 420 : 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LandingPalette.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: LandingPalette.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0F2C1A),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: LandingPalette.heroGlow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.apartment,
                size: 120,
                color: LandingPalette.primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _Badge(label: 'WiFi 100 Mbps'),
              _Badge(label: 'Keamanan 24 Jam'),
            ],
          ),
          const SizedBox(height: 10),
          const _Badge(label: 'Dekat Kampus & Pusat Kota'),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: LandingPalette.muted,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: LandingPalette.ink,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: LandingPalette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LandingPalette.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: LandingPalette.primaryDark,
            ),
      ),
    );
  }
}

class _ValueSection extends StatelessWidget {
  const _ValueSection();

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      background: LandingPalette.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            eyebrow: 'Mengapa memilih kami',
            title: 'Nilai utama Wisma Amal Gorontalo',
            description:
                'Pengalaman tinggal yang rapi, aman, dan serba mudah untuk penghuni baru maupun lama.',
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: const [
              _ValueCard(
                icon: Icons.location_on,
                title: 'Lokasi Strategis',
                description: 'Dekat kampus, pusat kuliner, dan akses transportasi.',
              ),
              _ValueCard(
                icon: Icons.security,
                title: 'Keamanan Terjamin',
                description: 'CCTV dan penjagaan untuk kenyamanan penghuni 24 jam.',
              ),
              _ValueCard(
                icon: Icons.clean_hands,
                title: 'Fasilitas Lengkap',
                description: 'Kamar bersih, area komunal, laundry, dan parkir aman.',
              ),
              _ValueCard(
                icon: Icons.app_registration,
                title: 'Aplikasi Mandiri',
                description:
                    'Reservasi, pembayaran, hingga laporan keluhan dalam satu portal.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LandingPalette.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LandingPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: LandingPalette.heroGlow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: LandingPalette.primaryDark),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: LandingPalette.ink,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: LandingPalette.muted,
                ),
          ),
        ],
      ),
    );
  }
}

class _RoomSection extends StatelessWidget {
  const _RoomSection();

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      background: LandingPalette.heroGlow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            eyebrow: 'Tipe kamar',
            title: 'Pilih kamar sesuai gaya hidupmu',
            description:
                'Status ketersediaan diperbarui secara real-time untuk memudahkan reservasi.',
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: const [
              _RoomCard(
                title: 'Standard',
                price: 'Mulai Rp 800.000 / bulan',
                status: 'Tersedia',
                statusColor: LandingPalette.primary,
                detail: 'Kamar nyaman dengan meja belajar dan lemari.',
              ),
              _RoomCard(
                title: 'Premium',
                price: 'Mulai Rp 1.200.000 / bulan',
                status: 'Sisa 2 kamar',
                statusColor: Color(0xFFF9A825),
                detail: 'Ruang lebih luas, kamar mandi dalam, AC.',
              ),
              _RoomCard(
                title: 'VIP',
                price: 'Mulai Rp 1.600.000 / bulan',
                status: 'Penuh',
                statusColor: Color(0xFFE53935),
                detail: 'Fasilitas lengkap dengan balkon pribadi.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.title,
    required this.price,
    required this.status,
    required this.statusColor,
    required this.detail,
  });

  final String title;
  final String price;
  final String status;
  final Color statusColor;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LandingPalette.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LandingPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: LandingPalette.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(
                Icons.bed,
                size: 52,
                color: LandingPalette.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: LandingPalette.ink,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            price,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: LandingPalette.muted,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            detail,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: LandingPalette.muted,
                ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: statusColor,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('Lihat Detail'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureSection extends StatelessWidget {
  const _FeatureSection({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      background: LandingPalette.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            eyebrow: 'Fitur aplikasi',
            title: 'Semua kebutuhan penghuni ada di genggaman',
            description:
                'Mulai reservasi sampai pelaporan masalah, semuanya tercatat rapi melalui aplikasi penghuni.',
          ),
          const SizedBox(height: 28),
          Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: const [
                    _FeatureCard(
                      icon: Icons.calendar_today,
                      title: 'Reservasi online',
                      description: 'Pilih kamar, tanggal, dan bayar langsung dari aplikasi.',
                    ),
                    SizedBox(height: 16),
                    _FeatureCard(
                      icon: Icons.receipt_long,
                      title: 'Manajemen tagihan',
                      description:
                          'Cek tagihan bulanan, riwayat pembayaran, dan bukti transaksi.',
                    ),
                    SizedBox(height: 16),
                    _FeatureCard(
                      icon: Icons.report_problem,
                      title: 'Laporan keluhan',
                      description:
                          'Laporkan kerusakan kamar dan pantau status perbaikannya.',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24, height: 24),
              Expanded(
                child: Container(
                  height: 360,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: LandingPalette.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: LandingPalette.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: LandingPalette.heroGlow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.phone_iphone,
                          size: 120,
                          color: LandingPalette.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Akses informasi kamar, tagihan, dan bantuan dalam satu aplikasi.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: LandingPalette.muted,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LandingPalette.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LandingPalette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: LandingPalette.heroGlow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: LandingPalette.primaryDark),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: LandingPalette.ink,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: LandingPalette.muted,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TestimonialSection extends StatelessWidget {
  const _TestimonialSection();

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      background: LandingPalette.heroGlow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            eyebrow: 'Testimoni penghuni',
            title: 'Pengalaman nyata dari penghuni Wisma Amal',
            description:
                'Cerita singkat yang membuat calon penghuni lebih yakin sebelum reservasi.',
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: const [
              _TestimonialCard(
                name: 'Ayu Lestari',
                role: 'Mahasiswa',
                quote:
                    'Proses reservasi cepat, kamar bersih, dan pengelola responsif.',
              ),
              _TestimonialCard(
                name: 'Fajar Prasetyo',
                role: 'Karyawan',
                quote:
                    'Lokasinya strategis dan fasilitasnya lengkap, cocok untuk kerja.',
              ),
              _TestimonialCard(
                name: 'Rina Oktavia',
                role: 'Mahasiswa',
                quote:
                    'Aplikasinya membantu banget untuk bayar dan lapor masalah.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({
    required this.name,
    required this.role,
    required this.quote,
  });

  final String name;
  final String role;
  final String quote;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LandingPalette.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LandingPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: LandingPalette.heroGlow,
                child: Text(
                  name.substring(0, 1),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: LandingPalette.primaryDark,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: LandingPalette.ink,
                        ),
                  ),
                  Text(
                    role,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: LandingPalette.muted,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            quote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: LandingPalette.muted,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LandingPalette.banner,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wisma Amal Gorontalo',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Jalan Palma No. 24, Kota Gorontalo',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 24,
            runSpacing: 8,
            children: const [
              _FooterItem(icon: Icons.phone, label: '+62 812-0000-0000'),
              _FooterItem(icon: Icons.email, label: 'wismaamal@email.com'),
              _FooterItem(icon: Icons.map, label: 'Lihat di Google Maps'),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'Placeholder peta lokasi',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Kebijakan Privasi  •  Syarat & Ketentuan  •  Portal Penghuni',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }
}

class _FooterItem extends StatelessWidget {
  const _FooterItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: LandingPalette.primaryDark,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: LandingPalette.ink,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: LandingPalette.muted,
                height: 1.6,
              ),
        ),
      ],
    );
  }
}

class _SectionContainer extends StatelessWidget {
  const _SectionContainer({required this.background, required this.child});

  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: child,
        ),
      ),
    );
  }
}
