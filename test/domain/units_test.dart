import 'package:flutter_test/flutter_test.dart';
import 'package:hydra/core/units/volume_unit.dart';

void main() {
  group('conversion', () {
    test('canonical ml round trips for every unit within rounding', () {
      for (final u in VolumeUnit.values) {
        for (final ml in [1, 150, 250, 500, 1000, 2400, 5000]) {
          expect(u.toMl(u.fromMl(ml.toDouble())), closeTo(ml, 1e-9));
        }
      }
    });
    test('known constants', () {
      expect(VolumeUnit.flOzUs.toMl(8), closeTo(236.588, 0.01));
      expect(VolumeUnit.cups.toMl(1), closeTo(236.588, 0.01));
      expect(VolumeUnit.l.toMl(1.5), 1500);
    });
    test('display unit never changes stored volume', () {
      const stored = 750;
      for (final u in VolumeUnit.values) {
        final shown = u.fromMl(stored.toDouble());
        final back = (validateVolume(shown, u) as VolumeOk).ml;
        expect(back, stored);
      }
    });
  });

  group('validation', () {
    test('rejects NaN, infinity, zero, negative, huge', () {
      expect(validateVolume(double.nan, VolumeUnit.ml), isA<VolumeInvalid>());
      expect(
        validateVolume(double.infinity, VolumeUnit.ml),
        isA<VolumeInvalid>(),
      );
      expect(validateVolume(0, VolumeUnit.ml), isA<VolumeInvalid>());
      expect(validateVolume(-5, VolumeUnit.ml), isA<VolumeInvalid>());
      expect(validateVolume(null, VolumeUnit.ml), isA<VolumeInvalid>());
      expect(
        (validateVolume(9, VolumeUnit.l) as VolumeInvalid).error,
        VolumeError.tooLarge,
      );
      expect(
        (validateVolume(0.2, VolumeUnit.ml) as VolumeInvalid).error,
        VolumeError.tooSmall,
      );
    });
    test('accepts decimals in other units', () {
      expect((validateVolume(1.5, VolumeUnit.l) as VolumeOk).ml, 1500);
      expect((validateVolume(8.5, VolumeUnit.flOzUs) as VolumeOk).ml, 251);
    });
  });

  group('parseLocalizedNumber', () {
    test('handles dot and comma decimals and grouping', () {
      expect(parseLocalizedNumber('1.5'), 1.5);
      expect(parseLocalizedNumber('1,5'), 1.5);
      expect(parseLocalizedNumber('1,234.5'), 1234.5);
      expect(parseLocalizedNumber('1.234,5'), 1234.5);
      expect(parseLocalizedNumber(' 250 '), 250);
    });
    test('rejects garbage', () {
      expect(parseLocalizedNumber(''), isNull);
      expect(parseLocalizedNumber('abc'), isNull);
      expect(parseLocalizedNumber('1.2.3'), isNull);
      expect(parseLocalizedNumber('-5'), isNull);
    });
  });
}
