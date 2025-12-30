import 'package:flutter/material.dart';
import 'package:frontend/main.dart';

class AppSnackbar {
  static void showSuccess(String message) {
    _showBase(
      message,
      backgroundColor: Colors.green.shade600,
      icon: Icons.check_circle,
    );
  }

  static void showError(String message) {
    _showBase(
      message,
      backgroundColor: Colors.red.shade600,
      icon: Icons.error_outline,
    );
  }

  static void showInfo(String message) {
    _showBase(
      message,
      backgroundColor: Colors.blue.shade600,
      icon: Icons.info_outline,
    );
  }

  static void _showBase(
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar() // biar nggak numpuk
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          // margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: backgroundColor,

          elevation: 6,
          duration: const Duration(seconds: 5),
          width: 500,
          content: Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
