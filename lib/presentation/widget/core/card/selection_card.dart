import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/presentation/widget/core/hover/hover_tap.dart';

/// Reusable card untuk pilihan radio-style.
///
/// Dua layout tersedia:
/// - [SelectionCard.vertical]   — judul + subtitle + valueLabel menumpuk
/// - [SelectionCard.horizontal] — icon di kiri, teks di tengah
class SelectionCard extends StatelessWidget {
  const SelectionCard._({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.valueLabel,
    this.icon,
    this.iconColor,
    this.accentColor,
    this.badge,
    this.minWidth,
    this.maxWidth,
    required _SelectionLayout layout,
  }) : _layout = layout;

  /// Vertical layout: judul + subtitle + valueLabel menumpuk.
  factory SelectionCard.vertical({
    Key? key,
    required String title,
    required bool selected,
    required VoidCallback onTap,
    String? subtitle,
    String? valueLabel,
    Color? accentColor,
    Widget? badge,
    double? minWidth,
    double? maxWidth,
  }) {
    return SelectionCard._(
      key: key,
      title: title,
      selected: selected,
      onTap: onTap,
      subtitle: subtitle,
      valueLabel: valueLabel,
      accentColor: accentColor,
      badge: badge,
      minWidth: minWidth,
      maxWidth: maxWidth,
      layout: _SelectionLayout.vertical,
    );
  }

  /// Horizontal layout: icon di kiri, teks di tengah, radio di kanan.
  factory SelectionCard.horizontal({
    Key? key,
    required String title,
    required bool selected,
    required VoidCallback onTap,
    String? subtitle,
    IconData? icon,
    Color? iconColor,
    Color? accentColor,
    double? minWidth,
    double? maxWidth,
  }) {
    return SelectionCard._(
      key: key,
      title: title,
      selected: selected,
      onTap: onTap,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      accentColor: accentColor,
      minWidth: minWidth,
      maxWidth: maxWidth,
      layout: _SelectionLayout.horizontal,
    );
  }

  final String title;
  final bool selected;
  final VoidCallback onTap;
  final String? subtitle;

  /// Vertical only: harga / jumlah yang ditampilkan besar di bawah.
  final String? valueLabel;

  /// Horizontal only: ikon di kiri.
  final IconData? icon;

  /// Horizontal only: warna ikon (default primary).
  final Color? iconColor;

  /// Override warna accent (border, radio, valueLabel) dari primary.
  final Color? accentColor;

  /// Vertical only: chip opsional di pojok kanan atas.
  final Widget? badge;

  final double? minWidth;
  final double? maxWidth;

  final _SelectionLayout _layout;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    // ── Warna tokens ──────────────────────────────────────────────────────────
    final primary = isDark ? AppColorsDark.primary : AppColorsLight.primary;
    final primaryLight =
        isDark ? AppColorsDark.surfaceVariant : AppColorsLight.primaryLight;
    final surfaceColor =
        isDark ? AppColorsDark.surface : AppColorsLight.surface;
    final borderColor =
        isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final textPrimary =
        isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
    final textSecondary =
        isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    final textHint = isDark ? AppColorsDark.textHint : AppColorsLight.textHint;

    final accent = accentColor ?? primary;
    final resolvedIconColor = iconColor ?? (selected ? accent : textSecondary);

    // ── State-dependent styling ───────────────────────────────────────────────
    final bgColor = selected ? primaryLight : surfaceColor;
    final borderSideColor = selected ? accent : borderColor;
    final borderWidth = selected ? 1.5 : 1.0;
    final radioIcon =
        selected ? Icons.radio_button_checked : Icons.radio_button_off;
    final radioColor = selected ? accent : textHint;

    return HoverTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      hoverColor: accent.withValues(alpha: 0.05),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: BoxConstraints(
          minWidth: minWidth ?? 0,
          maxWidth: maxWidth ?? double.infinity,
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: borderSideColor, width: borderWidth),
        ),
        child: _layout == _SelectionLayout.vertical
            ? _buildVertical(
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                accent: accent,
                radioIcon: radioIcon,
                radioColor: radioColor,
              )
            : _buildHorizontal(
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                accent: accent,
                resolvedIconColor: resolvedIconColor,
                radioIcon: radioIcon,
                radioColor: radioColor,
              ),
      ),
    );
  }

  // ── Vertical layout ─────────────────────────────────────────────────────────
  Widget _buildVertical({
    required Color textPrimary,
    required Color textSecondary,
    required Color accent,
    required IconData radioIcon,
    required Color radioColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: textPrimary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (badge != null) ...[
              badge!,
              const SizedBox(width: AppSpacing.xs),
            ],
            Icon(radioIcon, color: radioColor, size: 20),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 12,
              color: textSecondary,
              height: 1.4,
            ),
          ),
        ],
        if (valueLabel != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            valueLabel!,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: selected ? accent : textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  // ── Horizontal layout ────────────────────────────────────────────────────────
  Widget _buildHorizontal({
    required Color textPrimary,
    required Color textSecondary,
    required Color accent,
    required Color resolvedIconColor,
    required IconData radioIcon,
    required Color radioColor,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: resolvedIconColor, size: 22),
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Icon(radioIcon, color: radioColor, size: 20),
      ],
    );
  }
}

enum _SelectionLayout { vertical, horizontal }
