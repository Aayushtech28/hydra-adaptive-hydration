import 'dart:math' as math;

/// Display units. All persisted/calculated volumes are canonical millilitres;
/// conversion happens only at the UI boundary.
enum VolumeUnit {
  ml,
  l,
  flOzUs,
  cups;

  /// Millilitres per one display unit. Fluid ounce and cup are US customary
  /// (1 US fl oz = 29.5735295625 ml, 1 US cup = 8 US fl oz).
  double get mlPerUnit => switch (this) {
        VolumeUnit.ml => 1,
        VolumeUnit.l => 1000,
        VolumeUnit.flOzUs => 29.5735295625,
        VolumeUnit.cups => 236.588236500,
      };

  String get storageKey => name;

  static VolumeUnit fromStorage(String? v) => VolumeUnit.values.firstWhere(
        (u) => u.name == v,
        orElse: () => VolumeUnit.ml,
      );

  /// Number of decimals shown for this unit.
  int get displayDecimals => switch (this) {
        VolumeUnit.ml => 0,
        VolumeUnit.l => 2,
        VolumeUnit.flOzUs => 0,
        VolumeUnit.cups => 1,
      };

  /// Short symbol. Not localized: unit symbols are internationally stable.
  String get symbol => switch (this) {
        VolumeUnit.ml => 'ml',
        VolumeUnit.l => 'L',
        VolumeUnit.flOzUs => 'fl oz',
        VolumeUnit.cups => 'cups',
      };

  double fromMl(double ml) => ml / mlPerUnit;
  double toMl(double value) => value * mlPerUnit;
}

/// Validation bounds (canonical ml).
abstract final class VolumeLimits {
  static const int minEntryMl = 1;
  static const int maxEntryMl = 5000;
  static const int minTargetMl = 500;
  static const int maxTargetMl = 8000;
  static const int starterTargetMl = 2400;
}

/// Result of validating user-supplied numeric input.
sealed class VolumeParse {
  const VolumeParse();
}

class VolumeOk extends VolumeParse {
  const VolumeOk(this.ml);
  final int ml;
}

enum VolumeError { empty, notANumber, notPositive, tooSmall, tooLarge }

class VolumeInvalid extends VolumeParse {
  const VolumeInvalid(this.error);
  final VolumeError error;
}

/// Converts a user-entered value in [unit] into a validated canonical ml amount.
VolumeParse validateVolume(
  double? value,
  VolumeUnit unit, {
  int minMl = VolumeLimits.minEntryMl,
  int maxMl = VolumeLimits.maxEntryMl,
}) {
  if (value == null) return const VolumeInvalid(VolumeError.empty);
  if (value.isNaN || value.isInfinite) {
    return const VolumeInvalid(VolumeError.notANumber);
  }
  if (value <= 0) return const VolumeInvalid(VolumeError.notPositive);
  final ml = unit.toMl(value).round();
  if (ml < minMl) return const VolumeInvalid(VolumeError.tooSmall);
  if (ml > maxMl) return const VolumeInvalid(VolumeError.tooLarge);
  return VolumeOk(ml);
}

/// Parses text using a locale's decimal separator. Accepts either '.' or ','
/// as a decimal mark when unambiguous. Returns null when not a finite number.
double? parseLocalizedNumber(String raw, {String decimalSeparator = '.'}) {
  var s = raw.trim().replaceAll(RegExp(r'[\s  ]'), '');
  if (s.isEmpty) return null;
  final hasDot = s.contains('.');
  final hasComma = s.contains(',');
  if (hasDot && hasComma) {
    // The right-most separator is the decimal mark; the other is grouping.
    final decimalIsComma = s.lastIndexOf(',') > s.lastIndexOf('.');
    s = decimalIsComma
        ? s.replaceAll('.', '').replaceAll(',', '.')
        : s.replaceAll(',', '');
  } else if (hasComma) {
    s = s.replaceAll(',', '.');
  }
  if (!RegExp(r'^\d*\.?\d+$|^\d+\.$').hasMatch(s)) return null;
  final v = double.tryParse(s);
  if (v == null || v.isNaN || v.isInfinite) return null;
  return v;
}

/// Rounds ml to a "friendly" step for suggestions (never for storage).
int roundMlForSuggestion(num ml, {int step = 10}) =>
    (math.max(0, ml) / step).round() * step;
