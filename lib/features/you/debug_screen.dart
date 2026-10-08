// Developer tooling. Dev-only copy is intentionally not localized.
// Reachable only when AppConfig.debugToolsAvailable (non-release, non-prod).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../application/diagnostics.dart';
import '../../data/database/app_database.dart';
import '../../domain/models/enums.dart';
import '../common/widgets.dart';

class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});
  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  String _report = '';

  Future<void> _refresh() async {
    final svc = ref.read(servicesProvider);
    final r = await buildDiagnosticsReport(svc, version: 'debug');
    if (mounted) setState(() => _report = r);
    ref.invalidate(dashboardProvider);
    ref.invalidate(statsProvider);
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final svc = ref.watch(servicesProvider);
    if (!svc.debugToolsAvailable)
      return const Scaffold(body: Center(child: Text('Not available')));
    final core = svc.core;
    final dash = ref.watch(dashboardProvider).value;
    final d = dash?.decision;
    final s = dash?.snapshot;
    final pro = ref.watch(proOverrideProvider);

    Widget act(String label, Future<void> Function() fn) => OutlinedButton(
      onPressed: () async {
        await fn();
        await _refresh();
      },
      child: Text(label),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Developer tools')),
      body: SafeArea(
        child: PageBody(
          children: [
            if (d != null && s != null)
              HCard(
                child: Text(
                  'HYDRA ENGINE ${d.algorithmVersion}\n'
                  'state: ${d.state.name}\n'
                  'target: ${s.targetMl} ml · consumed: ${s.consumedMl} ml\n'
                  'expected: ${s.expectedMl.round()} ml · gap: ${s.gapMl.round()} ml\n'
                  'next: ${d.nextReminder?.toLocal()}\n'
                  'interval: ${d.intervalMinutes} min · adjustment: ${d.adjustment.name}\n'
                  'reasons: ${d.reasons.map((r) => r.name).join(', ')}\n'
                  'explanation: ${d.explanation.name}\n'
                  'fatigue: ${dash!.ctx.input.fatigue.level.name} (${dash.ctx.input.fatigue.index.toStringAsFixed(2)})\n'
                  'unanswered: ${dash.ctx.input.consecutiveUnanswered} · confidence: ${d.confidence.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                  ),
                ),
              ),
            const SizedBox(height: Gap.md),
            HCard(
              child: Text(
                _report,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5),
              ),
            ),
            const SectionHeader('Simulate'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                act('Tomorrow (+1 day)', () async {
                  svc.clock.offset += const Duration(days: 1);
                  await core.reschedule(reason: 'debug');
                }),
                act('Reset clock', () async {
                  svc.clock.offset = Duration.zero;
                  await core.reschedule(reason: 'debug');
                }),
                act(
                  'Log 250 ml',
                  () async => core.log(volumeMl: 250).then((_) {}),
                ),
                act('Resolve elapsed (missed)', () async {
                  await core.coordinator.resolveElapsed(
                    svc.clock.now().add(const Duration(hours: 2)),
                  );
                }),
                act(
                  'Snooze 30 min',
                  () => core.snooze(const Duration(minutes: 30)),
                ),
                act(
                  'Reschedule now',
                  () async => core.reschedule(reason: 'debug'),
                ),
                act(
                  'Pro: ${pro == null
                      ? 'real'
                      : pro
                      ? 'forced on'
                      : 'forced off'}',
                  () async {
                    ref
                        .read(proOverrideProvider.notifier)
                        .set(pro == null ? true : (pro ? false : null));
                  },
                ),
                act('Reset ad consent', svc.consent.resetForTesting),
                act('Notification test', () async {
                  await svc.notifications.showTest(
                    title: 'HYDRA',
                    body: 'Debug notification',
                  );
                }),
                act(
                  'Mode → Focus',
                  () => core.updateProfile(
                    (p) => p.copyWith(mode: ReminderMode.focus),
                  ),
                ),
              ],
            ),
            const SectionHeader('Environment'),
            Text(
              'DB schema: $kSchemaVersion · clock offset: ${svc.clock.offset}',
              style: context.text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
