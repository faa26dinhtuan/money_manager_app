import 'package:money_manager_app/core/utils/currency.dart';

String groupDigits(String digits) {
  final sep = AppCurrency.current.thousandsSep;
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(sep);
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

String formatNumber(String minorDigits) {
  final currency = AppCurrency.current;
  final padded = minorDigits.padLeft(currency.decimals + 1, '0');
  final split = padded.length - currency.decimals;
  final grouped = groupDigits(padded.substring(0, split));
  if (currency.decimals == 0) return grouped;
  return '$grouped${currency.decimalSep}${padded.substring(split)}';
}

String withCurrencySymbol(String number, {bool negative = false}) {
  final currency = AppCurrency.current;
  final sign = negative ? '-' : '';
  if (currency.symbolAfter) return '$sign$number ${currency.symbol}';
  final spaced = RegExp(r'[A-Za-z]$').hasMatch(currency.symbol);
  return '$sign${currency.symbol}${spaced ? ' ' : ''}$number';
}

String formatMoney(double value) {
  final minor = (value.abs() * AppCurrency.current.scale).round();
  return withCurrencySymbol(
    formatNumber(minor.toString()),
    negative: value < 0 && minor > 0,
  );
}

String _two(int n) => n.toString().padLeft(2, '0');

String formatDate(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

String formatDayMonth(DateTime d) => '${_two(d.day)}/${_two(d.month)}';

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String formatPercent(double value) {
  final text = value.toStringAsFixed(1);
  if (value > 0 && text == '0.0') return '<0,1%';
  return '${text.replaceAll('.', ',')}%';
}
