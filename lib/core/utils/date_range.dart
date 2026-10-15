import 'package:money_manager_app/core/utils/formatters.dart';

enum Period {
  day('Ngày'),
  week('Tuần'),
  month('Tháng'),
  year('Năm');

  const Period(this.label);
  final String label;
}

class DateRange {
  const DateRange(this.start, this.end);
  final DateTime start;
  final DateTime end;

  bool contains(DateTime d) => !d.isBefore(start) && d.isBefore(end);

  static DateRange of(Period p, DateTime a) {
    switch (p) {
      case Period.day:
        return DateRange(
          DateTime(a.year, a.month, a.day),
          DateTime(a.year, a.month, a.day + 1),
        );
      case Period.week:
        final monday = a.day - (a.weekday - 1);
        return DateRange(
          DateTime(a.year, a.month, monday),
          DateTime(a.year, a.month, monday + 7),
        );
      case Period.month:
        return DateRange(
          DateTime(a.year, a.month),
          DateTime(a.year, a.month + 1),
        );
      case Period.year:
        return DateRange(DateTime(a.year), DateTime(a.year + 1));
    }
  }

  static DateTime shift(Period p, DateTime a, int delta) {
    switch (p) {
      case Period.day:
        return DateTime(a.year, a.month, a.day + delta);
      case Period.week:
        return DateTime(a.year, a.month, a.day + 7 * delta);
      case Period.month:
        return DateTime(a.year, a.month + delta);
      case Period.year:
        return DateTime(a.year + delta);
    }
  }

  static String label(Period p, DateTime a) {
    switch (p) {
      case Period.day:
        return isSameDay(a, DateTime.now())
            ? 'Hôm nay, ${formatDayMonth(a)}'
            : formatDate(a);
      case Period.week:
        final r = of(p, a);
        final last = r.end.subtract(const Duration(days: 1));
        return '${formatDayMonth(r.start)} – ${formatDayMonth(last)}';
      case Period.month:
        return 'Tháng ${a.month}, ${a.year}';
      case Period.year:
        return 'Năm ${a.year}';
    }
  }
}
