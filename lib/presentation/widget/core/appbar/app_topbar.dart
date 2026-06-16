import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/app_spacing.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? breadcrumb;
  final Widget? action;
  final Widget? leading;

  const AppTopBar({
    super.key,
    required this.title,
    this.breadcrumb,
    this.action,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final surfaceColor = isDark ? AppColorsDark.surface : AppColorsLight.surface;
    final borderLightColor = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final textSecondaryColor = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    final textPrimaryColor = isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          bottom: BorderSide(color: borderLightColor),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.lg),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (breadcrumb != null)
                  Text(
                    breadcrumb!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: textSecondaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                if (breadcrumb != null) const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
