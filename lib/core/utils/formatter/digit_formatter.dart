import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsFormatter extends TextInputFormatter {
  static final NumberFormat _formatter = NumberFormat.decimalPattern('id');

  /// ✅ Untuk set nilai awal (edit mode)
  static String format(num value) {
    return _formatter.format(value);
  }

  /// ✅ Ambil nilai mentah (tanpa separator)
  static int parse(String text) {
    final raw = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(raw) ?? 0;
  }

  /// ✅ Realtime saat user mengetik
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final raw = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final number = int.tryParse(raw);

    if (number == null) {
      return oldValue;
    }

    final newText = _formatter.format(number);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
