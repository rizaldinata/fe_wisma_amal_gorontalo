import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/presentation/bloc/room_list/room_bloc.dart';
import 'package:frontend/presentation/bloc/room_list/room_event.dart';
import 'package:frontend/presentation/bloc/room_list/room_state.dart';
import 'package:frontend/domain/usecase/setting/get_public_settings_usecase.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';
import 'package:frontend/core/constant/permission_key.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

Color _shade(Color c, [double t = 0.12]) =>
    Color.alphaBlend(Colors.black.withValues(alpha: t), c);

@RoutePage()
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _facilityKey = GlobalKey();
  final GlobalKey _roomKey = GlobalKey();
  final GlobalKey _testimonialKey = GlobalKey();
  bool _isDarkMode = false;
  String _headerTitle = 'Temukan Kenyamanan\nTinggal di Wisma Amal Gorontalo';
  String _headerSubtitle =
      'Mengecek ketersediaan kamar, melihat fasilitas, dan melakukan reservasi secara cepat.';
  List<String> _facilities = [];

  String _wismaName = 'Wisma Amal Gorontalo';
  String _wismaAddress = 'Jalan Palma No. 24, Kota Gorontalo';
  String _wismaPhone = '+62 812-0000-0000';
  String _wismaEmail = 'wismaamal@email.com';
  String _wismaMapsLink = 'https://maps.google.com';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await serviceLocator
          .get<GetPublicSettingsUseCase>()
          .execute();
      if (mounted) {
        setState(() {
          _headerTitle =
              settings.getString('landing_header_title') ?? _headerTitle;
          _headerSubtitle =
              settings.getString('landing_header_subtitle') ?? _headerSubtitle;
          _wismaName = settings.getString('wisma_name') ?? _wismaName;
          _wismaAddress = settings.getString('wisma_address') ?? _wismaAddress;
          _wismaPhone = settings.getString('wisma_phone') ?? _wismaPhone;
          _wismaEmail = settings.getString('wisma_email') ?? _wismaEmail;
          _wismaMapsLink = settings.getString('wisma_maps_link') ?? _wismaMapsLink;

          final facilitiesStr = settings.getString('landing_facilities') ?? '';
          if (facilitiesStr.isNotEmpty) {
            _facilities = facilitiesStr
                .split(',')
                .map((e) => e.trim())
                .toList();
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollTo(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
      alignment: 0.08,
    );
  }

  void _toggleTheme() => setState(() => _isDarkMode = !_isDarkMode);

  @override
  Widget build(BuildContext context) {
    final themeData = _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

    return BlocProvider(
      create: (context) =>
          serviceLocator<RoomBloc>()
            ..add(const GetRoomsEvent(isHighlighted: true)),
      child: Theme(
        data: themeData,
        child: Builder(
          builder: (context) {
            final isDark = _isDarkMode;
            return Scaffold(
              backgroundColor: isDark
                  ? AppColorsDark.background
                  : AppColorsLight.background,
              body: Column(
                children: [
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state.isLoggedIn &&
                          (state.userInfo?.permissions?.can(
                                PermissionKeys.settingUpdate,
                              ) ??
                              false)) {
                        return Container(
                          width: double.infinity,
                          color: isDark
                              ? AppColorsDark.surfaceVariant
                              : AppColorsLight.surfaceVariant,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Anda sedang melihat Landing Page sebagai Admin.',
                                style: TextStyle(
                                  color: isDark
                                      ? AppColorsDark.textPrimary
                                      : AppColorsLight.textPrimary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => context.router.navigate(
                                  const AppLayoutRoute(children: [LandingCmsRoute()]),
                                ),
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Edit Landing Page'),
                                style: TextButton.styleFrom(
                                  foregroundColor: isDark
                                      ? AppColorsDark.primary
                                      : AppColorsLight.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, box) {
                        final isWide = box.maxWidth >= 1000;
                        return SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _HeroSection(
                                isWide: isWide,
                                isDark: isDark,
                                title: _headerTitle,
                                subtitle: _headerSubtitle,
                                facilities: _facilities,
                                onFacilityTap: () => _scrollTo(_facilityKey),
                                onRoomTap: () => _scrollTo(_roomKey),
                                onTestimonialTap: () =>
                                    _scrollTo(_testimonialKey),
                                onToggleTheme: _toggleTheme,
                              ),
                              _StatsStrip(isDark: isDark),
                              _ValueSection(isDark: isDark),
                              _RoomSection(key: _roomKey, isDark: isDark),
                              _FeatureSection(
                                key: _facilityKey,
                                isWide: isWide,
                                isDark: isDark,
                              ),
                              _TestimonialSection(
                                key: _testimonialKey,
                                isDark: isDark,
                              ),
                              _FooterSection(
                                isDark: isDark,
                                wismaName: _wismaName,
                                wismaAddress: _wismaAddress,
                                wismaPhone: _wismaPhone,
                                wismaEmail: _wismaEmail,
                                wismaMapsLink: _wismaMapsLink,
                              ),
                            ],
                          ),
                        );
                      },
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

void _goToReservation(BuildContext context) {
  context.router.navigate(const AppLayoutRoute(children: [RoomRoute()]));
}

// ─── Reusable Widgets ────────────────────────────────────────────────────────

class _GradientPillButton extends StatefulWidget {
  const _GradientPillButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  State<_GradientPillButton> createState() => _GradientPillButtonState();
}

class _GradientPillButtonState extends State<_GradientPillButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final primary = isDark ? AppColorsDark.primary : AppColorsLight.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0.0, _hovered ? -2.0 : 0.0, 0.0),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: _hovered ? 0.45 : 0.25),
                blurRadius: _hovered ? 24 : 12,
                offset: Offset(0, _hovered ? 8 : 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
              ],
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlinePillButton extends StatefulWidget {
  const _OutlinePillButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  State<_OutlinePillButton> createState() => _OutlinePillButtonState();
}

class _OutlinePillButtonState extends State<_OutlinePillButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final primary = isDark ? AppColorsDark.primary : AppColorsLight.primary;
    final border = isDark
        ? AppColorsDark.borderMedium
        : AppColorsLight.borderMedium;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0.0, _hovered ? -2.0 : 0.0, 0.0),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
          decoration: BoxDecoration(
            color: _hovered
                ? primary.withValues(alpha: 0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: _hovered ? primary : border, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: primary, size: 20),
                const SizedBox(width: 10),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoverLiftCard extends StatefulWidget {
  const _HoverLiftCard({required this.child, this.color});
  final Widget child;
  final Color? color;

  @override
  State<_HoverLiftCard> createState() => _HoverLiftCardState();
}

class _HoverLiftCardState extends State<_HoverLiftCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final primary = isDark ? AppColorsDark.primary : AppColorsLight.primary;
    final surface =
        widget.color ??
        (isDark ? AppColorsDark.surface : AppColorsLight.surface);
    final border = isDark
        ? AppColorsDark.borderLight
        : AppColorsLight.borderLight;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: MouseCursor.defer,
      child: GestureDetector(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0.0, _hovered ? -6.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovered ? primary.withValues(alpha: 0.35) : border,
            ),
            boxShadow: [
              BoxShadow(
                color: _hovered
                    ? primary.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: _hovered ? 28 : 8,
                offset: Offset(0, _hovered ? 12 : 2),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}


class _SectionShell extends StatelessWidget {
  const _SectionShell({required this.color, required this.child});
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: 72,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: child,
        ),
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final primary = isDark ? AppColorsDark.primary : AppColorsLight.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.isWide,
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.facilities,
    required this.onFacilityTap,
    required this.onRoomTap,
    required this.onTestimonialTap,
    required this.onToggleTheme,
  });

  final bool isWide;
  final bool isDark;
  final String title;
  final String subtitle;
  final List<String> facilities;
  final VoidCallback onFacilityTap;
  final VoidCallback onRoomTap;
  final VoidCallback onTestimonialTap;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColorsDark.primary : AppColorsLight.primary;
    final surface = isDark ? AppColorsDark.surface : AppColorsLight.surface;
    final bg = isDark ? AppColorsDark.background : AppColorsLight.background;
    final textPri = isDark
        ? AppColorsDark.textPrimary
        : AppColorsLight.textPrimary;
    final textSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;
    final borderCol = isDark
        ? AppColorsDark.borderLight
        : AppColorsLight.borderLight;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [surface, bg],
        ),
      ),
      child: Stack(
        children: [
          // Decorative gradient orb
          Positioned(
            right: -140,
            top: -80,
            child: Container(
              height: 420,
              width: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withValues(alpha: 0.07),
                    primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -200,
            bottom: -100,
            child: Container(
              height: 360,
              width: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withValues(alpha: 0.05),
                    primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 72 : AppSpacing.xxl,
            ),
            child: Column(
              children: [
                // ── Navbar ──
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    children: [
                      // Brand
                      Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.home_work_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Wisma Amal',
                        style: TextStyle(
                          color: textPri,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      const Spacer(),
                      if (isWide) ...[
                        _NavLink('Fasilitas', onFacilityTap, isDark),
                        const SizedBox(width: 8),
                        _NavLink('Tipe Kamar', onRoomTap, isDark),
                        const SizedBox(width: 8),
                        _NavLink('Testimoni', onTestimonialTap, isDark),
                        const SizedBox(width: 20),
                      ],
                      // Theme toggle
                      _ThemeToggle(isDark: isDark, onToggle: onToggleTheme),
                      if (isWide) ...[
                        const SizedBox(width: 16),
                        _GradientPillButton(
                          label: 'Reservasi Sekarang',
                          icon: Icons.calendar_month_rounded,
                          onPressed: () => _goToReservation(context),
                        ),
                      ],
                    ],
                  ),
                ),

                Divider(height: 1, thickness: 1, color: borderCol),

                // ── Hero Content (centered) ──
                Padding(
                  padding: EdgeInsets.symmetric(vertical: isWide ? 80 : 48),
                  child: Column(
                    children: [
                      const _Eyebrow('Reservasi online tanpa ribet'),
                      const SizedBox(height: 28),
                      Text(
                        title.replaceAll('\\n', '\n'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textPri,
                          fontSize: isWide ? 52 : 32,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textSec,
                            fontSize: 16,
                            height: 1.7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        alignment: WrapAlignment.center,
                        children: [
                          _GradientPillButton(
                            label: 'Cek Ketersediaan',
                            icon: Icons.search_rounded,
                            onPressed: onRoomTap,
                          ),
                          _OutlinePillButton(
                            label: 'Lihat Fasilitas',
                            icon: Icons.star_border_rounded,
                            onPressed: onFacilityTap,
                          ),
                        ],
                      ),
                      const SizedBox(height: 44),
                      // Feature highlights
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: facilities.isNotEmpty
                            ? facilities.take(5).map((f) {
                                IconData icon = Icons.check_circle_outline;
                                final lower = f.toLowerCase();
                                if (lower.contains('wifi'))
                                  icon = Icons.wifi_rounded;
                                if (lower.contains('aman') ||
                                    lower.contains('security'))
                                  icon = Icons.verified_user_outlined;
                                if (lower.contains('parkir'))
                                  icon = Icons.local_parking_rounded;
                                if (lower.contains('ac'))
                                  icon = Icons.ac_unit_rounded;
                                if (lower.contains('kampus') ||
                                    lower.contains('kota'))
                                  icon = Icons.place_outlined;
                                return _FeatureHighlight(
                                  icon: icon,
                                  label: f,
                                  isDark: isDark,
                                );
                              }).toList()
                            : [
                                _FeatureHighlight(
                                  icon: Icons.wifi_rounded,
                                  label: 'WiFi 100 Mbps',
                                  isDark: isDark,
                                ),
                                _FeatureHighlight(
                                  icon: Icons.verified_user_outlined,
                                  label: 'Keamanan 24 Jam',
                                  isDark: isDark,
                                ),
                                _FeatureHighlight(
                                  icon: Icons.place_outlined,
                                  label: 'Dekat Kampus & Pusat Kota',
                                  isDark: isDark,
                                ),
                              ],
                      ),
                    ],
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

class _NavLink extends StatefulWidget {
  const _NavLink(this.label, this.onTap, this.isDark);
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final primary = widget.isDark
        ? AppColorsDark.primary
        : AppColorsLight.primary;
    final textSec = widget.isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: _hovered ? primary : textSec,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                width: _hovered ? 20 : 0,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.isDark, required this.onToggle});
  final bool isDark;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final textSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;
    return GestureDetector(
      onTap: onToggle,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                RotationTransition(turns: anim, child: child),
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey(isDark),
              color: textSec,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureHighlight extends StatelessWidget {
  const _FeatureHighlight({
    required this.icon,
    required this.label,
    required this.isDark,
  });
  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final border = isDark
        ? AppColorsDark.borderLight
        : AppColorsLight.borderLight;
    final textSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;
    final primary = isDark ? AppColorsDark.primary : AppColorsLight.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: border),
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: textSec,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Strip ─────────────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColorsDark.primary : AppColorsLight.primary;

    return Container(
      decoration: BoxDecoration(
        color: primary,
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.3),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 36,
        horizontal: AppSpacing.xxl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(value: '30+', label: 'Kamar Tersedia'),
              Container(height: 40, width: 1, color: Colors.white24),
              _StatItem(value: '4.8/5', label: 'Rating'),
              Container(height: 40, width: 1, color: Colors.white24),
              _StatItem(value: '24/7', label: 'Layanan'),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Value Section ───────────────────────────────────────────────────────────

class _ValueSection extends StatelessWidget {
  const _ValueSection({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColorsDark.background : AppColorsLight.background;
    final textPri = isDark
        ? AppColorsDark.textPrimary
        : AppColorsLight.textPrimary;
    final textSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;

    return _SectionShell(
      color: bg,
      child: Column(
        children: [
          _Eyebrow('Mengapa memilih kami'),
          const SizedBox(height: 16),
          Text(
            'Nilai utama Wisma Amal Gorontalo',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textPri,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Text(
              'Pengalaman tinggal yang rapi, aman, dan serba mudah untuk penghuni baru maupun lama.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSec, fontSize: 15, height: 1.6),
            ),
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: const [
              _ValueCard(
                icon: Icons.location_on_outlined,
                title: 'Lokasi Strategis',
                desc: 'Dekat kampus, pusat kuliner, dan akses transportasi.',
              ),
              _ValueCard(
                icon: Icons.shield_outlined,
                title: 'Keamanan Terjamin',
                desc: 'CCTV dan penjagaan untuk kenyamanan penghuni 24 jam.',
              ),
              _ValueCard(
                icon: Icons.auto_awesome_outlined,
                title: 'Fasilitas Lengkap',
                desc: 'Kamar bersih, area komunal, laundry, dan parkir aman.',
              ),
              _ValueCard(
                icon: Icons.phone_android_outlined,
                title: 'Aplikasi Mandiri',
                desc:
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
    required this.desc,
  });
  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final primary = isDark ? AppColorsDark.primary : AppColorsLight.primary;
    final textPri = isDark
        ? AppColorsDark.textPrimary
        : AppColorsLight.textPrimary;
    final textSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;

    return _HoverLiftCard(
      child: Container(
        width: 265,
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              style: TextStyle(
                color: textPri,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              style: TextStyle(color: textSec, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Room Section ────────────────────────────────────────────────────────────

class _RoomSection extends StatelessWidget {
  const _RoomSection({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColorsDark.surface : AppColorsLight.surface;
    final textPri = isDark
        ? AppColorsDark.textPrimary
        : AppColorsLight.textPrimary;
    final textSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;

    return _SectionShell(
      color: surface,
      child: Column(
        children: [
          _Eyebrow('Tipe kamar'),
          const SizedBox(height: 16),
          Text(
            'Pilih kamar sesuai kebutuhan anda',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textPri,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Status ketersediaan diperbarui secara real-time untuk memudahkan reservasi.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textSec, fontSize: 15, height: 1.6),
          ),
          BlocBuilder<RoomBloc, RoomState>(
            builder: (context, state) {
              if (state.status == FormzSubmissionStatus.inProgress) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (state.status == FormzSubmissionStatus.failure) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text('Gagal memuat kamar: ${state.errorMessage}'),
                  ),
                );
              }
              if (state.rooms.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('Belum ada data kamar.'),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24), // padding for the scrollable area
                  child: Row(
                    children: state.rooms.map((room) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: SizedBox(
                          height: 550,
                          child: _RoomCard(
                            title: room.title,
                            price: room.priceFormatted,
                            period: '/ bulan',
                            status: room.status.displayName,
                            statusColor: room.status.getColor,
                            detail: room.description.isNotEmpty
                                ? room.description
                                : (room.facilities.isNotEmpty
                                    ? 'Fasilitas: ${room.facilities.take(3).join(", ")}'
                                    : 'Kamar nyaman dan strategis.'),
                            icon: Icons.bed_outlined,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
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
    required this.period,
    required this.status,
    required this.statusColor,
    required this.detail,
    required this.icon,
  });

  final String title;
  final String price;
  final String period;
  final String status;
  final Color statusColor;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final primary = isDark ? AppColorsDark.primary : AppColorsLight.primary;
    final textPri = isDark
        ? AppColorsDark.textPrimary
        : AppColorsLight.textPrimary;
    final textSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;

    return _HoverLiftCard(
      child: SizedBox(
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient header
            Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, _shade(primary, 0.25)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Center(child: Icon(icon, size: 56, color: Colors.white)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 180,
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textPri,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        // _StatusPill(label: status, color: statusColor),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          price,
                          style: TextStyle(
                            color: primary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            period,
                            style: TextStyle(color: textSec, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: Text(
                        detail,
                        maxLines: 8,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textSec,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: _OutlinePillButton(
                        label: 'Lihat Detail',
                        onPressed: () => _goToReservation(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Feature Section ─────────────────────────────────────────────────────────

class _FeatureSection extends StatelessWidget {
  const _FeatureSection({
    super.key,
    required this.isWide,
    required this.isDark,
  });
  final bool isWide;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColorsDark.background : AppColorsLight.background;
    final textPri = isDark
        ? AppColorsDark.textPrimary
        : AppColorsLight.textPrimary;
    final textSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;
    final primary = isDark ? AppColorsDark.primary : AppColorsLight.primary;
    final primaryLight = isDark
        ? AppColorsDark.primaryLight
        : AppColorsLight.primaryLight;

    return _SectionShell(
      color: bg,
      child: Column(
        children: [
          _Eyebrow('Fitur aplikasi'),
          const SizedBox(height: 16),
          Text(
            'Semua kebutuhan penghuni ada di genggaman',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textPri,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              'Mulai reservasi sampai pelaporan masalah, semuanya tercatat rapi melalui aplikasi penghuni.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSec, fontSize: 15, height: 1.6),
            ),
          ),
          const SizedBox(height: 52),

          // Steps
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Expanded(
                      child: _FeatureStep(
                        number: '01',
                        icon: Icons.calendar_today_outlined,
                        title: 'Reservasi online',
                        desc:
                            'Pilih kamar, tanggal, dan bayar langsung dari aplikasi.',
                      ),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: _FeatureStep(
                        number: '02',
                        icon: Icons.receipt_long_outlined,
                        title: 'Manajemen tagihan',
                        desc:
                            'Cek tagihan bulanan, riwayat pembayaran, dan bukti transaksi.',
                      ),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: _FeatureStep(
                        number: '03',
                        icon: Icons.report_problem_outlined,
                        title: 'Laporan keluhan',
                        desc:
                            'Laporkan kerusakan kamar dan pantau status perbaikannya.',
                      ),
                    ),
                  ],
                )
              : Column(
                  children: const [
                    _FeatureStep(
                      number: '',
                      icon: Icons.calendar_today_outlined,
                      title: 'Reservasi online',
                      desc:
                          'Pilih kamar, tanggal, dan bayar langsung dari aplikasi.',
                    ),
                    SizedBox(height: 24),
                    _FeatureStep(
                      number: '02',
                      icon: Icons.receipt_long_outlined,
                      title: 'Manajemen tagihan',
                      desc:
                          'Cek tagihan bulanan, riwayat pembayaran, dan bukti transaksi.',
                    ),
                    SizedBox(height: 24),
                    _FeatureStep(
                      number: '03',
                      icon: Icons.report_problem_outlined,
                      title: 'Laporan keluhan',
                      desc:
                          'Laporkan kerusakan kamar dan pantau status perbaikannya.',
                    ),
                  ],
                ),

          const SizedBox(height: 48),

          // Bottom highlight (preserves illustration text)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            decoration: BoxDecoration(
              color: primaryLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primary.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.smartphone_outlined, color: primary, size: 28),
                const SizedBox(width: 14),
                Flexible(
                  child: Text(
                    'Akses informasi kamar, tagihan, dan bantuan dalam satu aplikasi.',
                    style: TextStyle(
                      color: textPri,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
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

class _FeatureStep extends StatelessWidget {
  const _FeatureStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.desc,
  });
  final String number;
  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final primary = isDark ? AppColorsDark.primary : AppColorsLight.primary;
    final textPri = isDark
        ? AppColorsDark.textPrimary
        : AppColorsLight.textPrimary;
    final textSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;

    return _HoverLiftCard(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(icon, color: primary, size: 28),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textPri,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(color: textSec, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Testimonial Section ─────────────────────────────────────────────────────

class _TestimonialSection extends StatelessWidget {
  const _TestimonialSection({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColorsDark.surface : AppColorsLight.surface;
    final textPri = isDark
        ? AppColorsDark.textPrimary
        : AppColorsLight.textPrimary;
    final textSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;

    return _SectionShell(
      color: surface,
      child: Column(
        children: [
          _Eyebrow('Testimoni penghuni'),
          const SizedBox(height: 16),
          Text(
            'Pengalaman nyata dari penghuni Wisma Amal',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textPri,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Cerita singkat yang membuat calon penghuni lebih yakin sebelum reservasi.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textSec, fontSize: 15, height: 1.6),
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
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
    final isDark = AppTheme.isDark(context);
    final primary = isDark ? AppColorsDark.primary : AppColorsLight.primary;
    final textPri = isDark
        ? AppColorsDark.textPrimary
        : AppColorsLight.textPrimary;
    final textSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;
    final borderCol = isDark
        ? AppColorsDark.borderLight
        : AppColorsLight.borderLight;
    final bg = isDark ? AppColorsDark.background : AppColorsLight.background;

    return _HoverLiftCard(
      color: bg,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stars
            Row(
              children: List.generate(
                5,
                (_) => const Padding(
                  padding: EdgeInsets.only(right: 3),
                  child: Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFBBF24),
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Quote
            Text(
              '"$quote"',
              style: TextStyle(
                color: textPri,
                fontSize: 15,
                height: 1.65,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 22),
            Divider(color: borderCol),
            const SizedBox(height: 16),
            // Author
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: primary.withValues(alpha: 0.12),
                  child: Text(
                    name.substring(0, 1),
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: textPri,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(role, style: TextStyle(color: textSec, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Footer ──────────────────────────────────────────────────────────────────

class _FooterSection extends StatelessWidget {
  const _FooterSection({
    required this.isDark,
    required this.wismaName,
    required this.wismaAddress,
    required this.wismaPhone,
    required this.wismaEmail,
    required this.wismaMapsLink,
  });
  final bool isDark;
  final String wismaName;
  final String wismaAddress;
  final String wismaPhone;
  final String wismaEmail;
  final String wismaMapsLink;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0F1221);
    const textPri = AppColorsDark.textPrimary;
    const textSec = AppColorsDark.textSecondary;
    const textHint = AppColorsDark.textHint;
    const border = AppColorsDark.borderLight;
    final primary = isDark ? AppColorsDark.primary : AppColorsLight.primary;

    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: 56,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: brand + contact
              Wrap(
                spacing: 64,
                runSpacing: 32,
                children: [
                  // Brand column
                  SizedBox(
                    width: 320,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                                color: primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.home_work_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              wismaName,
                              style: const TextStyle(
                                color: textPri,
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          wismaAddress,
                          style: const TextStyle(
                            color: textSec,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Contact column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'KONTAK',
                        style: TextStyle(
                          color: textSec,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _FooterLink(
                        icon: Icons.phone_outlined,
                        label: wismaPhone,
                      ),
                      const SizedBox(height: 10),
                      _FooterLink(
                        icon: Icons.email_outlined,
                        label: wismaEmail,
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          final uri = Uri.tryParse(wismaMapsLink);
                          if (uri != null) {
                            launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        child: const _FooterLink(
                          icon: Icons.map_outlined,
                          label: 'Lihat di Google Maps',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Map placeholder
              InkWell(
                onTap: () {
                  final uri = Uri.tryParse(wismaMapsLink);
                  if (uri != null) {
                    launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D34),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map_outlined, color: textSec, size: 26),
                        SizedBox(height: 8),
                        Text(
                          'Buka peta pusat Kota Gorontalo',
                          style: TextStyle(color: textSec, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
              const Divider(color: border),
              const SizedBox(height: 20),
              const Text(
                'Kebijakan Privasi  •  Syarat & Ketentuan  •  Portal Penghuni',
                style: TextStyle(color: textHint, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColorsDark.textSecondary, size: 17),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: AppColorsDark.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
