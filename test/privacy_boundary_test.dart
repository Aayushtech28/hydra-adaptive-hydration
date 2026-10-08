import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Architectural guard: the advertising layer must not be able to see
/// hydration or health data. If someone imports it there, this fails.
void main() {
  const forbidden = [
    'hydration_repository',
    'reminder_repository',
    'profile_repository',
    'vessel_repository',
    'routine_repository',
    '/domain/',
    'services/health/',
    'application/',
    'analytics_service',
  ];

  test('lib/services/ads never imports hydration, health or domain code', () {
    final files = Directory('lib/services/ads')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    expect(files, isNotEmpty);
    for (final f in files) {
      final imports = f.readAsLinesSync().where((l) => l.startsWith('import '));
      for (final line in imports) {
        for (final bad in forbidden) {
          expect(
            line.contains(bad),
            isFalse,
            reason: '${f.path} imports "$bad": $line',
          );
        }
      }
    }
  });

  test('ad requests carry no targeting data', () {
    final src = File('lib/services/ads/ad_service.dart')
        .readAsLinesSync()
        .where((l) => !l.trim().startsWith('//'))
        .join('\n');
    expect(src.contains('keywords'), isFalse);
    expect(src.contains('contentUrl'), isFalse);
    expect(
      src.contains('nonPersonalizedAds: AppConfig.forceContextualAds'),
      isTrue,
    );
  });

  test('no advertising placement exists for core flows', () {
    final src = File('lib/services/ads/ad_policy.dart').readAsStringSync();
    final enumBody = src.substring(
      src.indexOf('enum AdPlacement'),
      src.indexOf('enum AdFormat'),
    );
    for (final core in [
      'dashboard',
      'home',
      'log',
      'onboarding',
      'permission',
      'privacy',
      'notification',
      'widget',
    ]) {
      expect(
        RegExp(core, caseSensitive: false).hasMatch(enumBody),
        isFalse,
        reason: 'placement mentions $core',
      );
    }
  });

  test(
    'Android manifest strips AD_ID and requests no exact-alarm permission',
    () {
      final m = File('android/app/src/main/AndroidManifest.xml')
          .readAsStringSync();
      expect(m.contains('permission.AD_ID" tools:node="remove"'), isTrue);
      expect(
        m.contains(
          '<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM',
        ),
        isFalse,
      );
      expect(
        m.contains(
          '<uses-permission android:name="android.permission.USE_EXACT_ALARM',
        ),
        isFalse,
      );
      // Only water intake is requested from Health Connect.
      final health = RegExp(r'android\.permission\.health\.(\w+)')
          .allMatches(m)
          .map((x) => x.group(1))
          .toSet();
      expect(health, {'READ_HYDRATION', 'WRITE_HYDRATION'});
    },
  );

  test('iOS does not declare tracking and only declares health usage', () {
    final p = File('ios/Runner/Info.plist').readAsStringSync();
    expect(p.contains('NSUserTrackingUsageDescription'), isFalse);
    expect(p.contains('NSHealthShareUsageDescription'), isTrue);
  });
}
