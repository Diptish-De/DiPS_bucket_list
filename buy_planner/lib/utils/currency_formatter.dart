import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    // Remove non-digits
    String digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));

    // Format with Indian number system
    final number = int.tryParse(digits);
    if (number == null) return newValue;

    String formatted = NumberFormat('#,##,###', 'en_IN').format(number);
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}

/// Strip formatting to get the raw number
double parseCurrencyInput(String text) {
  String clean = text.replaceAll(RegExp(r'[^\d.]'), '');
  return double.tryParse(clean) ?? 0.0;
}
