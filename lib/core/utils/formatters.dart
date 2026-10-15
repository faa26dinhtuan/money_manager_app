/// Định dạng số tiền kiểu Việt Nam: 1.234.567 ₫
String formatMoney(double value) {
  final negative = value < 0;
  final digits = value.abs().round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '${negative ? '-' : ''}$buffer ₫';
}

String _two(int n) => n.toString().padLeft(2, '0');

/// dd/MM/yyyy
String formatDate(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

/// dd/MM
String formatDayMonth(DateTime d) => '${_two(d.day)}/${_two(d.month)}';

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
