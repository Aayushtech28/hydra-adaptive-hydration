import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/units/formatters.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/widgets.dart';

class YouScreen extends ConsumerWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.hx;
    final p = ref.watch(profileProvider).value;
    final isPro = ref.watch(isProProvider);
    final svc = ref.watch(servicesProvider);
    if (p == null) return const Scaffold(body: SizedBox());
    final locale = p.locale ?? 'en';
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    String time(int m) => Formatters.minuteOfDay(m, locale, use24h: use24);

    return Scaffold(
      appBar: AppBar(title: Text(l.youTitle)),
      body: SafeArea(
        child: PageBody(
          children: [
            HCard(
              onTap: () => context.push('/pro'),
              color: isPro ? t.surface : t.accentSoft,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [t.waterTop, t.waterBottom],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPro ? l.youProActive : l.youProCardTitle,
                          style: context.text.titleMedium,
                        ),
                        Text(
                          isPro ? l.youProManage : l.youProCardBody,
                          style: context.text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            SectionHeader(l.youSectionPlan),
            TileGroup(
              children: [
                HTile(
                  leading: Icons.flag_outlined,
                  title: l.youGoal,
                  subtitle: Formatters.volume(p.dailyTargetMl, p.unit, locale),
                  onTap: () => context.push('/you/goal'),
                ),
                HTile(
                  leading: Icons.wb_twilight,
                  title: l.youSchedule,
                  subtitle: '${time(p.wakeMinute)} – ${time(p.sleepMinute)}',
                  onTap: () => context.push('/you/schedule'),
                ),
                HTile(
                  leading: Icons.event_repeat_outlined,
                  title: l.youRoutines,
                  onTap: () => context.push('/you/routines'),
                ),
                HTile(
                  leading: Icons.local_drink_outlined,
                  title: l.youVessels,
                  onTap: () => context.push('/you/vessels'),
                ),
              ],
            ),
            SectionHeader(l.youSectionReminders),
            TileGroup(
              children: [
                HTile(
                  leading: Icons.notifications_none,
                  title: l.youNotifications,
                  subtitle: p.remindersEnabled ? l.commonOn : l.commonOff,
                  onTap: () => context.push('/you/notifications'),
                ),
              ],
            ),
            SectionHeader(l.youSectionData),
            TileGroup(
              children: [
                HTile(
                  leading: Icons.favorite_border,
                  title: l.youHealth,
                  badge: isPro ? null : l.commonProBadge,
                  onTap: () => context.push('/you/health'),
                ),
                HTile(
                  leading: Icons.lock_outline,
                  title: l.youPrivacy,
                  onTap: () => context.push('/you/privacy'),
                ),
              ],
            ),
            SectionHeader(l.youSectionApp),
            TileGroup(
              children: [
                HTile(
                  leading: Icons.palette_outlined,
                  title: l.youAppearance,
                  onTap: () => context.push('/you/appearance'),
                ),
                HTile(
                  leading: Icons.help_outline,
                  title: l.youSupport,
                  onTap: () => context.push('/you/support'),
                ),
                if (svc.debugToolsAvailable)
                  HTile(
                    leading: Icons.bug_report_outlined,
                    title: l.youDebug,
                    onTap: () => context.push('/you/debug'),
                  ),
              ],
            ),
            const SizedBox(height: Gap.lg),
            Text(l.disclaimerShort, style: context.text.bodySmall),
          ],
        ),
      ),
    );
  }
}
