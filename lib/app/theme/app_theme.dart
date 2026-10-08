import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'tokens.dart';

abstract final class AppTheme {
  static ThemeData light([HydraPalette p = HydraPalette.ocean]) => _build(
    HydraTokens.light.withPalette(p, Brightness.light),
    Brightness.light,
  );
  static ThemeData dark([HydraPalette p = HydraPalette.ocean]) =>
      _build(HydraTokens.dark.withPalette(p, Brightness.dark), Brightness.dark);

  static ThemeData _build(HydraTokens t, Brightness b) {
    final scheme = ColorScheme.fromSeed(seedColor: t.accent, brightness: b)
        .copyWith(
          primary: t.accent,
          onPrimary: t.onAccent,
          surface: t.surface,
          onSurface: t.ink,
          surfaceContainerHighest: t.surfaceRaised,
          outline: t.hairline,
          error: t.attention,
        );
    final base = ThemeData(
      brightness: b,
      useMaterial3: true,
      colorScheme: scheme,
    );
    TextStyle s(double size, FontWeight w, {double? h, double? ls, Color? c}) =>
        TextStyle(
          fontSize: size,
          fontWeight: w,
          height: h,
          letterSpacing: ls,
          color: c ?? t.ink,
        );
    final text = base.textTheme.copyWith(
      displayLarge: s(56, FontWeight.w700, h: 1.0, ls: -1.5),
      displayMedium: s(44, FontWeight.w700, h: 1.05, ls: -1),
      headlineMedium: s(28, FontWeight.w700, h: 1.15, ls: -0.4),
      headlineSmall: s(22, FontWeight.w700, h: 1.2, ls: -0.2),
      titleLarge: s(20, FontWeight.w600, h: 1.25),
      titleMedium: s(16, FontWeight.w600, h: 1.3),
      titleSmall: s(14, FontWeight.w600, h: 1.3),
      bodyLarge: s(16, FontWeight.w400, h: 1.45),
      bodyMedium: s(14, FontWeight.w400, h: 1.45),
      bodySmall: s(12.5, FontWeight.w400, h: 1.4, c: t.inkMuted),
      labelLarge: s(15, FontWeight.w600, h: 1.2),
      labelMedium: s(13, FontWeight.w600, h: 1.2, c: t.inkMuted),
      labelSmall: s(11.5, FontWeight.w600, h: 1.2, ls: 0.3, c: t.inkMuted),
    );
    return base.copyWith(
      scaffoldBackgroundColor: t.bg,
      textTheme: text,
      extensions: [t],
      appBarTheme: AppBarTheme(
        backgroundColor: t.bg,
        foregroundColor: t.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      dividerTheme: DividerThemeData(color: t.hairline, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: t.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          side: BorderSide(color: t.hairline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: t.accent,
          foregroundColor: t.onAccent,
          minimumSize: const Size(kMinTap, kMinTap),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.pill),
          ),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: t.ink,
          minimumSize: const Size(kMinTap, kMinTap),
          side: BorderSide(color: t.hairline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.pill),
          ),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: t.accent,
          minimumSize: const Size(kMinTap, kMinTap),
          textStyle: text.labelLarge,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.lg)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: t.ink,
        contentTextStyle: text.bodyMedium?.copyWith(color: t.bg),
        actionTextColor: t.waterTop,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.onAccent : t.inkMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.accent : t.hairline,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: t.surface,
        indicatorColor: t.accentSoft,
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(
          text.labelSmall?.copyWith(color: t.ink),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? t.accent : t.inkMuted,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: t.surface,
        side: BorderSide(color: t.hairline),
        labelStyle: text.labelMedium?.copyWith(color: t.ink),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.pill),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.surfaceRaised,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
