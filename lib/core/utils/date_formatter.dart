/// Tiny, dependency-free date formatter so we don't need to pull in intl
/// for two short strings used across the app.
class DateFormatter {
  DateFormatter._();

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', //
  ];

  static const List<String> _monthsFull = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December', //
  ];

  /// e.g. "Jul 16, 2026" — used for "date written" style meta text.
  static String short(DateTime date) {
    return '${_months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// e.g. "March 14, 2027" — used for the friendly unlock-date preview.
  static String friendly(DateTime date) {
    return '${_monthsFull[date.month - 1]} ${date.day}, ${date.year}';
  }
}
