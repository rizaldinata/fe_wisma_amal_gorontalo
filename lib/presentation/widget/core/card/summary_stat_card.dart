import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_shadows.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/app_spacing.dart';

class SummaryStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String? trend;
  final Color? trendColor;

  const SummaryStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.trend,
    this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final surfaceColor = isDark ? AppColorsDark.surface : AppColorsLight.surface;
    final borderColor = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final primaryTextColor = isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
    final secondaryTextColor = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: borderColor),
        boxShadow: const [AppShadows.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: secondaryTextColor,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: primaryTextColor,
            ),
          ),
          if (trend != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              trend!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: trendColor ?? secondaryTextColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
