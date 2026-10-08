import 'package:flutter/material.dart';

/// HYDRA design tokens. Calm, precise, non-judgmental: deep ink, cool aquatic
/// accent, restrained gradients. Status colours are **always** paired with a
/// symbol and text (never colour alone).
@immutable
class HydraTokens extends ThemeExtension<HydraTokens> {
  const HydraTokens({
    required this.bg,
    required this.surface,
    required this.surfaceRaised,
    required this.ink,
    required this.inkMuted,
    required this.hairline,
    required this.accent,
    required this.accentSoft,
    required this.aqua,
    required this.good,
    required this.adjust,
    required this.attention,
    required this.onAccent,
    required this.waterTop,
    required this.waterBottom,
  });

  final Color bg;
  final Color surface;
  final Color surfaceRaised;
  final Color ink;
  final Color inkMuted;
  final Color hairline;
  final Color accent;
  final Color accentSoft;
  final Color aqua;
  final Color good;
  final Color adjust;
  final Color attention;
  final Color onAccent;
  final Color waterTop;
  final Color waterBottom;

  static const HydraTokens light = HydraTokens(
    bg: Color(0xFFF5F8FB),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFEAF1F7),
    ink: Color(0xFF0B1B2B),
    inkMuted: Color(0xFF55677A),
    hairline: Color(0xFFDCE5EE),
    accent: Color(0xFF1479C9),
    accentSoft: Color(0xFFDCEBF8),
    aqua: Color(0xFF14A3B8),
    good: Color(0xFF117A68),
    adjust: Color(0xFF2F5FD0),
    attention: Color(0xFF9A5B00),
    onAccent: Color(0xFFFFFFFF),
    waterTop: Color(0xFF5CC2F0),
    waterBottom: Color(0xFF1479C9),
  );

  static const HydraTokens dark = HydraTokens(
    bg: Color(0xFF060E18),
    surface: Color(0xFF0F1B2A),
    surfaceRaised: Color(0xFF16273B),
    ink: Color(0xFFEAF2FA),
    inkMuted: Color(0xFF9DB0C3),
    hairline: Color(0xFF223850),
    accent: Color(0xFF64B8F2),
    accentSoft: Color(0xFF14304A),
    aqua: Color(0xFF4CCBDD),
    good: Color(0xFF5ED3BC),
    adjust: Color(0xFF8DB0FF),
    attention: Color(0xFFF0B45A),
    onAccent: Color(0xFF04101C),
    waterTop: Color(0xFF58BDEE),
    waterBottom: Color(0xFF1F6FB3),
  );

  /// Accent-only variants. The base ink/surface scale never changes, so
  /// contrast guarantees hold for every palette.
  HydraTokens withPalette(HydraPalette palette, Brightness b) {
    final dark = b == Brightness.dark;
    return switch (palette) {
      HydraPalette.ocean => this,
      HydraPalette.aurora => _recolor(
        accent: dark ? const Color(0xFFB69CFF) : const Color(0xFF5B3FD0),
        accentSoft: dark ? const Color(0xFF2A2250) : const Color(0xFFE9E3FB),
        aqua: dark ? const Color(0xFF5FE0C9) : const Color(0xFF0E9C86),
        waterTop: dark ? const Color(0xFF8FE3D2) : const Color(0xFF58D6C0),
        waterBottom: dark ? const Color(0xFF6C54D8) : const Color(0xFF5B3FD0),
      ),
      HydraPalette.graphite => _recolor(
        accent: dark ? const Color(0xFFC9D5E2) : const Color(0xFF2B3A4B),
        accentSoft: dark ? const Color(0xFF1E2C3B) : const Color(0xFFE3E9EF),
        aqua: dark ? const Color(0xFF9FB4C8) : const Color(0xFF44586C),
        waterTop: dark ? const Color(0xFFA8BBCE) : const Color(0xFF7C93AA),
        waterBottom: dark ? const Color(0xFF51677D) : const Color(0xFF2B3A4B),
      ),
    };
  }

  HydraTokens _recolor({
    required Color accent,
    required Color accentSoft,
    required Color aqua,
    required Color waterTop,
    required Color waterBottom,
  }) => HydraTokens(
    bg: bg,
    surface: surface,
    surfaceRaised: surfaceRaised,
    ink: ink,
    inkMuted: inkMuted,
    hairline: hairline,
    accent: accent,
    accentSoft: accentSoft,
    aqua: aqua,
    good: good,
    adjust: adjust,
    attention: attention,
    onAccent: onAccent,
    waterTop: waterTop,
    waterBottom: waterBottom,
  );

  @override
  HydraTokens copyWith() => this;

  @override
  HydraTokens lerp(ThemeExtension<HydraTokens>? other, double t) {
    if (other is! HydraTokens) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return HydraTokens(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      surfaceRaised: l(surfaceRaised, other.surfaceRaised),
      ink: l(ink, other.ink),
      inkMuted: l(inkMuted, other.inkMuted),
      hairline: l(hairline, other.hairline),
      accent: l(accent, other.accent),
      accentSoft: l(accentSoft, other.accentSoft),
      aqua: l(aqua, other.aqua),
      good: l(good, other.good),
      adjust: l(adjust, other.adjust),
      attention: l(attention, other.attention),
      onAccent: l(onAccent, other.onAccent),
      waterTop: l(waterTop, other.waterTop),
      waterBottom: l(waterBottom, other.waterBottom),
    );
  }
}

enum HydraPalette {
  ocean,
  aurora,
  graphite;

  static HydraPalette parse(String? v) => HydraPalette.values.firstWhere(
    (p) => p.name == v,
    orElse: () => HydraPalette.ocean,
  );
}

/// Spacing scale (4-pt grid).
abstract final class Gap {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double screen = 20;
}

abstract final class Radii {
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 24;
  static const double pill = 999;
}

/// Minimum interactive size (accessibility).
const double kMinTap = 48;

extension HydraThemeX on BuildContext {
  HydraTokens get hx => Theme.of(this).extension<HydraTokens>()!;
  TextTheme get text => Theme.of(this).textTheme;
  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);
}
