import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/data/services/app_store.dart';

String groupDigits(String digits, [AppCurrency? currency]) {
  final sep = (currency ?? AppCurrency.current).thousandsSep;
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(sep);
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

String formatNumber(String minorDigits, [AppCurrency? override]) {
  final currency = override ?? AppCurrency.current;
  final padded = minorDigits.padLeft(currency.decimals + 1, '0');
  final split = padded.length - currency.decimals;
  final grouped = groupDigits(padded.substring(0, split), currency);
  if (currency.decimals == 0) return grouped;
  return '$grouped${currency.decimalSep}${padded.substring(split)}';
}

String withCurrencySymbol(
  String number, {
  bool negative = false,
  AppCurrency? currency,
}) {
  currency ??= AppCurrency.current;
  final sign = negative ? '-' : '';
  if (currency.symbolAfter) return '$sign$number ${currency.symbol}';
  final spaced = RegExp(r'[A-Za-z]$').hasMatch(currency.symbol);
  return '$sign${currency.symbol}${spaced ? ' ' : ''}$number';
}

String formatMoney(double value, [AppCurrency? currency]) {
  final target = currency ?? AppCurrency.current;
  final minor = (value.abs() * target.scale).round();
  return withCurrencySymbol(
    formatNumber(minor.toString(), target),
    negative: value < 0 && minor > 0,
    currency: target,
  );
}

String _two(int n) => n.toString().padLeft(2, '0');

String formatDate(DateTime d) {
  final day = _two(d.day);
  final month = _two(d.month);
  return switch (AppStore.instance.dateFormat) {
    'MM/dd/yyyy' => '$month/$day/${d.year}',
    'yyyy-MM-dd' => '${d.year}-$month-$day',
    _ => '$day/$month/${d.year}',
  };
}

String formatDayMonth(DateTime d) {
  final day = _two(d.day);
  final month = _two(d.month);
  return AppStore.instance.dateFormat == 'MM/dd/yyyy'
      ? '$month/$day'
      : AppStore.instance.dateFormat == 'yyyy-MM-dd'
      ? '$month-$day'
      : '$day/$month';
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String formatPercent(double value) {
  final text = value.toStringAsFixed(1);
  if (value > 0 && text == '0.0') return '<0,1%';
  return '${text.replaceAll('.', ',')}%';
}
