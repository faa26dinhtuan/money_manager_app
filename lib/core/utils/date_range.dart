enum Period { day, week, month, year, custom }

class DateRange {
  const DateRange(this.start, this.end);
  final DateTime start;
  final DateTime end;

  bool contains(DateTime d) => !d.isBefore(start) && d.isBefore(end);

  static DateRange of(Period p, DateTime a, [DateRange? custom]) {
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
      case Period.custom:
        return custom ?? of(Period.day, a);
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
      case Period.custom:
        return a;
    }
  }
}
