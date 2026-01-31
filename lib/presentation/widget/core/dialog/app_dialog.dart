import 'package:flutter/material.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';

enum AppDialogType { info, warning, danger, success }

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.type = AppDialogType.info,
    this.showCancel = true,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final AppDialogType type;
  final bool showCancel;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    AppDialogType type = AppDialogType.info,
    bool showCancel = true,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        type: type,
        showCancel: showCancel,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case AppDialogType.info:
        return Icons.info_outline_rounded;
      case AppDialogType.warning:
        return Icons.warning_amber_rounded;
      case AppDialogType.danger:
        return Icons.error_outline_rounded;
      case AppDialogType.success:
        return Icons.check_circle_outline_rounded;
    }
  }

  Color _getColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case AppDialogType.info:
        return colorScheme.primary;
      case AppDialogType.warning:
        return Colors.orange;
      case AppDialogType.danger:
        return colorScheme.error;
      case AppDialogType.success:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context);
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIcon(), color: color, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                if (showCancel)
                  Expanded(
                    child: BasicButton(
                      type: ButtonType.secondary,
                      onPressed: onCancel,
                      label: cancelLabel,
                    ),
                  ),
                if (showCancel) const SizedBox(width: 12),
                Expanded(
                  child: BasicButton(
                    type: type == AppDialogType.danger
                        ? ButtonType.danger
                        : ButtonType.primary,
                    onPressed: onConfirm,
                    label: confirmLabel,
                    foregroundColor: type == AppDialogType.danger
                        ? Colors.white
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
