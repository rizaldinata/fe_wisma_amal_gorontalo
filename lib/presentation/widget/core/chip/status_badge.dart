import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';

class StatusBadgeConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color dotColor;
  final Color textColor;
  final String label;

  const StatusBadgeConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.dotColor,
    required this.textColor,
    required this.label,
  });
}

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  StatusBadgeConfig _getConfig(BuildContext context, String status) {
    final isDark = AppTheme.isDark(context);
    final String normalizedStatus = status.toLowerCase().trim();

    if (normalizedStatus == 'menunggu') {
      return StatusBadgeConfig(
        backgroundColor: isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg,
        borderColor: isDark ? AppColorsDark.statusWaitingBorder : AppColorsLight.statusWaitingBorder,
        dotColor: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting,
        textColor: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting,
        label: 'Menunggu',
      );
    } else if (normalizedStatus == 'dalam_proses' || normalizedStatus == 'proses' || normalizedStatus == 'dalam proses') {
      return StatusBadgeConfig(
        backgroundColor: isDark ? AppColorsDark.statusProcessBg : AppColorsLight.statusProcessBg,
        borderColor: isDark ? AppColorsDark.statusProcessBorder : AppColorsLight.statusProcessBorder,
        dotColor: isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess,
        textColor: isDark ? AppColorsDark.statusProcess : AppColorsLight.statusProcess,
        label: 'Dalam Proses',
      );
    } else if (normalizedStatus == 'selesai') {
      return StatusBadgeConfig(
        backgroundColor: isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg,
        borderColor: isDark ? AppColorsDark.statusDoneBorder : AppColorsLight.statusDoneBorder,
        dotColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
        textColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
        label: 'Selesai',
      );
    } else if (normalizedStatus == 'dibatalkan' || normalizedStatus == 'batal') {
      return StatusBadgeConfig(
        backgroundColor: isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg,
        borderColor: isDark ? AppColorsDark.statusCancelledBorder : AppColorsLight.statusCancelledBorder,
        dotColor: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
        textColor: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
        label: 'Dibatalkan',
      );
    } else if (normalizedStatus == 'active' || normalizedStatus == 'aktif') {
      return StatusBadgeConfig(
        backgroundColor: isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg,
        borderColor: isDark ? AppColorsDark.statusDoneBorder : AppColorsLight.statusDoneBorder,
        dotColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
        textColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
        label: 'Aktif',
      );
    } else if (normalizedStatus == 'pending') {
      return StatusBadgeConfig(
        backgroundColor: isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg,
        borderColor: isDark ? AppColorsDark.statusWaitingBorder : AppColorsLight.statusWaitingBorder,
        dotColor: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting,
        textColor: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting,
        label: 'Pending',
      );
    } else if (normalizedStatus == 'lunas') {
      return StatusBadgeConfig(
        backgroundColor: isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg,
        borderColor: isDark ? AppColorsDark.statusDoneBorder : AppColorsLight.statusDoneBorder,
        dotColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
        textColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
        label: 'Lunas',
      );
    } else if (normalizedStatus == 'belum lunas' || normalizedStatus == 'belum_lunas') {
      return StatusBadgeConfig(
        backgroundColor: isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg,
        borderColor: isDark ? AppColorsDark.statusCancelledBorder : AppColorsLight.statusCancelledBorder,
        dotColor: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
        textColor: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
        label: 'Belum Lunas',
      );
    } else if (normalizedStatus == 'unpaid' || normalizedStatus == 'belum bayar') {
      return StatusBadgeConfig(
        backgroundColor: isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg,
        borderColor: isDark ? AppColorsDark.statusWaitingBorder : AppColorsLight.statusWaitingBorder,
        dotColor: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting,
        textColor: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting,
        label: 'Belum Bayar',
      );
    } else if (normalizedStatus == 'paid' || normalizedStatus == 'verified') {
      return StatusBadgeConfig(
        backgroundColor: isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg,
        borderColor: isDark ? AppColorsDark.statusDoneBorder : AppColorsLight.statusDoneBorder,
        dotColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
        textColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
        label: normalizedStatus == 'paid' ? 'Lunas' : 'Terverifikasi',
      );
    } else if (normalizedStatus == 'rejected' || normalizedStatus == 'failed') {
      return StatusBadgeConfig(
        backgroundColor: isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg,
        borderColor: isDark ? AppColorsDark.statusCancelledBorder : AppColorsLight.statusCancelledBorder,
        dotColor: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
        textColor: isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled,
        label: normalizedStatus == 'rejected' ? 'Ditolak' : 'Gagal',
      );
    } else {
      // Default / Unknown
      return StatusBadgeConfig(
        backgroundColor: isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant,
        borderColor: isDark ? AppColorsDark.borderMedium : AppColorsLight.borderMedium,
        dotColor: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
        textColor: isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
        label: status,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(context, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: TextStyle(
              color: config.textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
