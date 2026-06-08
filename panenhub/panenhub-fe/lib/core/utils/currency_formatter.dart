import 'package:intl/intl.dart';

/// Rupiah currency formatter
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  /// Format integer to Rupiah string e.g. Rp32.000
  static String format(int amount) {
    return _formatter.format(amount);
  }

  /// Format with /kg suffix e.g. Rp32.000/kg
  static String formatPerKg(int amount) {
    return '${_formatter.format(amount)}/kg';
  }
}
