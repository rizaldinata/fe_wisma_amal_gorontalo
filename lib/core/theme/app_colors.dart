import 'package:flutter/material.dart';

class AppColorsLight {
  // Primary — clean rich blue, no violet tint
  static const Color primary        = Color(0xFF2563EB); // Blue 600
  static const Color primaryLight   = Color(0xFFEFF6FF); // Blue 50 (button bg, badge bg)
  static const Color primaryDark    = Color(0xFF1D4ED8); // Blue 700 (hover state)

  // Background & surface
  static const Color background     = Color(0xFFF0F2FA); // Light blue-tinted page bg
  static const Color surface        = Color(0xFFFFFFFF); // Card, dialog, panel
  static const Color surfaceVariant = Color(0xFFF5F6FB); // Table row alt, input bg

  // Text
  static const Color textPrimary    = Color(0xFF1E293B); // Slate 800
  static const Color textSecondary  = Color(0xFF64748B); // Slate 500
  static const Color textHint       = Color(0xFF94A3B8); // Slate 400

  // Border
  static const Color borderLight    = Color(0xFFE2E8F0); // Slate 200
  static const Color borderMedium   = Color(0xFFCBD5E1); // Slate 300

  // Sidebar — white sidebar seperti FlyScope
  static const Color sidebarBg      = Color(0xFFFFFFFF); // White
  static const Color sidebarBorder  = Color(0xFFE2E8F0); // Right border
  static const Color sidebarActive  = Color(0xFF2563EB); // Filled blue active item
  static const Color sidebarActiveText = Color(0xFFFFFFFF);
  static const Color sidebarHoverBg = Color(0xFFEFF6FF); // Very light blue hover
  static const Color sidebarText    = Color(0xFF1E293B); // Dark text
  static const Color sidebarMuted   = Color(0xFF64748B); // Icon inactive
  static const Color sidebarSection = Color(0xFF94A3B8); // Section label

  // Status — semantic, sama di light & dark
  static const Color statusWaiting      = Color(0xFFD97706);
  static const Color statusWaitingBg    = Color(0xFFFFFBEB);
  static const Color statusWaitingBorder= Color(0xFFFDE68A);
  static const Color statusProcess      = Color(0xFF2563EB);
  static const Color statusProcessBg    = Color(0xFFEFF6FF);
  static const Color statusProcessBorder= Color(0xFFBFDBFE);
  static const Color statusDone         = Color(0xFF16A34A);
  static const Color statusDoneBg       = Color(0xFFF0FDF4);
  static const Color statusDoneBorder   = Color(0xFFBBF7D0);
  static const Color statusCancelled    = Color(0xFFDC2626);
  static const Color statusCancelledBg  = Color(0xFFFEF2F2);
  static const Color statusCancelledBorder = Color(0xFFFECACA);

  // Kondisi inventaris
  static const Color conditionGood = Color(0xFF16A34A);
  static const Color conditionFair = Color(0xFFD97706);
  static const Color conditionPoor = Color(0xFFDC2626);
}

class AppColorsDark {
  // Primary — blue-violet vivid yang pop di atas gelap
  static const Color primary        = Color(0xFF5B6EF5); // Vivid blue-violet
  static const Color primaryLight   = Color(0xFF252844); // Dark tinted primary bg
  static const Color primaryDark    = Color(0xFF7B8BFF); // Lighter for text on dark

  // Background & surface
  static const Color background     = Color(0xFF141627); // Deep navy — halaman utama
  static const Color surface        = Color(0xFF1E2237); // Card, panel, dialog
  static const Color surfaceVariant = Color(0xFF252844); // Hover row, input bg, active item

  // Text
  static const Color textPrimary    = Color(0xFFE8EAF6); // Near-white with blue tint
  static const Color textSecondary  = Color(0xFF8B93B3); // Muted blue-gray
  static const Color textHint       = Color(0xFF555E7A); // Very muted

  // Border
  static const Color borderLight    = Color(0xFF2A2D45); // Subtle dark border
  static const Color borderMedium   = Color(0xFF363A58); // Slightly visible

  // Sidebar — unified dark seperti Homical
  static const Color sidebarBg      = Color(0xFF141627); // Same as background (seamless)
  static const Color sidebarActive  = Color(0xFF252844); // Slightly lighter box for active
  static const Color sidebarActiveText = Color(0xFFFFFFFF);
  static const Color sidebarActiveIcon = Color(0xFF5B6EF5); // Blue-violet icon saat aktif
  static const Color sidebarHoverBg = Color(0xFF1E2237);
  static const Color sidebarText    = Color(0xFFE8EAF6);
  static const Color sidebarMuted   = Color(0xFF8B93B3);
  static const Color sidebarSection = Color(0xFF555E7A);

  // Status — warna sama, background disesuaikan gelap
  static const Color statusWaiting      = Color(0xFFD97706);
  static const Color statusWaitingBg    = Color(0xFF2D2010);
  static const Color statusWaitingBorder= Color(0xFF78450A);
  static const Color statusProcess      = Color(0xFF5B6EF5);
  static const Color statusProcessBg    = Color(0xFF141A40);
  static const Color statusProcessBorder= Color(0xFF2D3A7A);
  static const Color statusDone         = Color(0xFF22C55E);
  static const Color statusDoneBg       = Color(0xFF0D2818);
  static const Color statusDoneBorder   = Color(0xFF166534);
  static const Color statusCancelled    = Color(0xFFEF4444);
  static const Color statusCancelledBg  = Color(0xFF2D0A0A);
  static const Color statusCancelledBorder = Color(0xFF7F1D1D);

  // Kondisi inventaris
  static const Color conditionGood = Color(0xFF22C55E);
  static const Color conditionFair = Color(0xFFD97706);
  static const Color conditionPoor = Color(0xFFEF4444);
}
