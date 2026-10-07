import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import 'volume_unit.dart';

/// Locale-aware formatting at the UI boundary. Stored values stay in ml.
abstract final class Formatters {
  static String number(num v, String locale, {int decimals = 0}) {
    final f = NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: decimals);
    return f.format(v);
  }

  /// "1,390" / "1.39" / "47" depending on unit and locale (no unit symbol).
  static String volumeValue(int ml, VolumeUnit unit, String locale) =>
      number(unit.fromMl(ml.toDouble()), locale, decimals: unit.displayDecimals);

  static String volume(int ml, VolumeUnit unit, String locale) =>
      '${volumeValue(ml, unit, locale)} ${unit.symbol}';

  /// "250 ml" style with a leading plus.
  static String plusVolume(int ml, VolumeUnit unit, String locale) =>
      '+${volume(ml, unit, locale)}';

  /// Local time in [zone] honouring the locale's 12/24-hour convention.
  static String time(DateTime instant, tz.Location zone, String locale, {bool? use24h}) {
    final t = tz.TZDateTime.from(instant.toUtc(), zone);
    final f = (use24h ?? false) ? DateFormat.Hm(locale) : DateFormat.jm(locale);
    return f.format(DateTime(t.year, t.month, t.day, t.hour, t.minute));
  }

  static String minuteOfDay(int minute, String locale, {bool? use24h}) {
    final f = (use24h ?? false) ? DateFormat.Hm(locale) : DateFormat.jm(locale);
    return f.format(DateTime(2000, 1, 1, minute ~/ 60, minute % 60));
  }

  static String percent(num fraction, String locale) =>
      NumberFormat.percentPattern(locale).format(fraction);
}
