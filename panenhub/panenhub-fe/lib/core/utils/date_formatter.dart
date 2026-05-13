import 'package:intl/intl.dart';

/// Indonesian date formatter
class DateFormatter {
  DateFormatter._();

  static final _fullDate = DateFormat('dd MMMM yyyy', 'id_ID');
  static final _shortDate = DateFormat('dd MMM yyyy', 'id_ID');
  static final _monthYear = DateFormat('MMMM yyyy', 'id_ID');
  static final _dayMonth = DateFormat('dd MMM', 'id_ID');
  static final _dateTime = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  static final _relative = DateFormat('dd MMM', 'id_ID');

  /// e.g. "12 Juni 2026"
  static String full(DateTime date) => _fullDate.format(date);

  /// e.g. "12 Jun 2026"
  static String short(DateTime date) => _shortDate.format(date);

  /// e.g. "Juni 2026"
  static String monthYear(DateTime date) => _monthYear.format(date);

  /// e.g. "12 Jun"
  static String dayMonth(DateTime date) => _dayMonth.format(date);

  /// e.g. "12 Jun 2026, 14:30"
  static String dateTime(DateTime date) => _dateTime.format(date);

  /// e.g. "3 hari lagi" or "12 Jun"
  static String relative(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Besok';
    if (diff > 1 && diff <= 7) return '$diff hari lagi';
    return _relative.format(date);
  }
}
