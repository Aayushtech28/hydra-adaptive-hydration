import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../data/repositories/misc_repositories.dart';
import '../../domain/models/enums.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../services/ads/ad_policy.dart';
import '../../services/analytics/analytics_service.dart';
import '../common/widgets.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final p = ref.watch(profileProvider).value!;
    final isPro = ref.watch(isProProvider);
    final palette = ref.watch(paletteProvider).value ?? HydraPalette.ocean;
    final svc = ref.watch(servicesProvider);

    Future<void> setPalette(HydraPalette v) async {
      if (v != HydraPalette.ocean && !isPro) {
        unawaited(context.push('/pro'));
        return;
      }
      await svc.core.settings.setString('ui.palette', v.name);
    }

    String name(HydraPalette v) => switch (v) {
      HydraPalette.ocean => l.appearanceOcean,
      HydraPalette.aurora => l.appearanceAurora,
      HydraPalette.graphite => l.appearanceGraphite,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l.appearanceTitle)),
      body: SafeArea(
        child: PageBody(
          children: [
            Text(l.appearanceMode, style: context.text.titleMedium),
            const SizedBox(height: Gap.sm),
            SegmentedButton<ThemeChoice>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: ThemeChoice.system,
                  label: Text(l.appearanceSystem),
                ),
                ButtonSegment(
                  value: ThemeChoice.light,
                  label: Text(l.appearanceLight),
                ),
                ButtonSegment(
                  value: ThemeChoice.dark,
                  label: Text(l.appearanceDark),
                ),
              ],
              selected: {p.theme},
              onSelectionChanged: (s) =>
                  svc.core.updateProfile((x) => x.copyWith(theme: s.first)),
            ),
            SectionHeader(l.appearanceThemes),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final v in HydraPalette.values)
                  Semantics(
                    button: true,
                    selected: palette == v,
                    label: name(v),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(Radii.md),
                      onTap: () => setPalette(v),
                      child: Container(
                        width: 104,
                        padding: const EdgeInsets.all(Gap.md),
                        decoration: BoxDecoration(
                          color: context.hx.surface,
                          borderRadius: BorderRadius.circular(Radii.md),
                          border: Border.all(
                            color: palette == v
                                ? context.hx.accent
                                : context.hx.hairline,
                            width: palette == v ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Builder(
                              builder: (ctx) {
                                final t = HydraTokens.light.withPalette(
                                  v,
                                  Brightness.light,
                                );
                                return Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [t.waterTop, t.waterBottom],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              name(v),
                              style: context.text.labelMedium?.copyWith(
                                color: context.hx.ink,
                              ),
                            ),
                            if (v != HydraPalette.ocean && !isPro)
                              Text(
                                l.commonProBadge,
                                style: context.text.labelSmall,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (!isPro) ...[
              const SizedBox(height: Gap.md),
              Text(l.appearanceThemeProNote, style: context.text.bodySmall),
              const SizedBox(height: Gap.sm),
              OutlinedButton(
                onPressed: () async {
                  final earned = await svc.adCoordinator.showRewarded(
                    AdPlacement.rewardedTheme,
                  );
                  if (earned) {
                    await svc.core.settings.setTime(
                      SettingKeys.rewardedThemeUntil,
                      svc.clock.now().add(const Duration(hours: 24)),
                    );
                    await svc.core.settings.setString(
                      'ui.palette',
                      HydraPalette.aurora.name,
                    );
                    svc.analytics.log(AnalyticsEvent.rewardedCompleted, {
                      'placement': 'theme',
                    });
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.appearanceThemeUntil)),
                      );
                    }
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.recapMonthlyAdFailed)),
                    );
                  }
                },
                child: Text(l.appearanceWatchTheme),
              ),
            ],
            const SizedBox(height: Gap.xl),
            Text(l.appearanceReduceMotion, style: context.text.bodySmall),
          ],
        ),
      ),
    );
  }
}
