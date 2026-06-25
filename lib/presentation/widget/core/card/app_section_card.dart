import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_shadows.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_theme.dart';

/// Section card generik — pengganti [BasicCard] dengan design system tokens.
///
/// Style mengikuti [SummaryStatCard]:
/// - Background : surface
/// - Border     : 1px borderLight
/// - Radius     : radiusLg
/// - Shadow     : cardShadow
/// - Padding    : all(AppSpacing.xl) = 20px
///
/// Jika [title] diberikan, ditampilkan baris header (ikon opsional di kiri,
/// [trailing] opsional di kanan) diikuti divider 1px [borderLight], lalu [child].
class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.padding,
    this.trailing,
  });

  final Widget child;
  final String? title;
  final IconData? icon;

  /// Override padding default (all 20px).
  final EdgeInsetsGeometry? padding;

  /// Widget opsional di kanan title (misal badge / chip).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final surfaceColor =
        isDark ? AppColorsDark.surface : AppColorsLight.surface;
    final borderColor =
        isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final textPrimaryColor =
        isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
    final textSecondaryColor =
        isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: borderColor),
        boxShadow: const [AppShadows.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            // ── Header row ───────────────────────────────────────────────────
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: textSecondaryColor),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Text(
                    title!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimaryColor,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // ── Divider tipis 1px ────────────────────────────────────────────
            Container(height: 1, color: borderColor),
            const SizedBox(height: AppSpacing.lg),
          ],
          child,
        ],
      ),
    );
  }
}
