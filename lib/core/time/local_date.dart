/// A calendar date without time or zone (the user's *logical* day).
class LocalDate implements Comparable<LocalDate> {
  const LocalDate(this.year, this.month, this.day);

  factory LocalDate.fromDateTime(DateTime d) =>
      LocalDate(d.year, d.month, d.day);

  /// Parses `yyyy-MM-dd`. Throws [FormatException] on malformed input.
  factory LocalDate.parse(String s) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s);
    if (m == null) throw FormatException('Invalid local date: $s');
    final y = int.parse(m.group(1)!);
    final mo = int.parse(m.group(2)!);
    final d = int.parse(m.group(3)!);
    final check = DateTime.utc(y, mo, d);
    if (check.year != y || check.month != mo || check.day != d) {
      throw FormatException('Invalid local date: $s');
    }
    return LocalDate(y, mo, d);
  }

  static LocalDate? tryParse(String? s) {
    if (s == null) return null;
    try {
      return LocalDate.parse(s);
    } on FormatException {
      return null;
    }
  }

  final int year;
  final int month;
  final int day;

  /// Pure calendar arithmetic (UTC midnight is used only as a calendar
  /// carrier, so DST can never skew it).
  LocalDate addDays(int n) {
    final d = DateTime.utc(year, month, day).add(Duration(days: n));
    return LocalDate(d.year, d.month, d.day);
  }

  int differenceInDays(LocalDate other) => DateTime.utc(
    year,
    month,
    day,
  ).difference(DateTime.utc(other.year, other.month, other.day)).inDays;

  /// ISO weekday: Monday = 1 … Sunday = 7.
  int get weekday => DateTime.utc(year, month, day).weekday;
  bool get isWeekend => weekday >= 6;

  String toIso() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  bool isBefore(LocalDate o) => compareTo(o) < 0;
  bool isAfter(LocalDate o) => compareTo(o) > 0;

  @override
  int compareTo(LocalDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}
