import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/units/formatters.dart';
import '../../core/units/volume_unit.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/widgets.dart';

class GoalScreen extends ConsumerStatefulWidget {
  const GoalScreen({super.key});
  @override
  ConsumerState<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends ConsumerState<GoalScreen> {
  late int _ml;
  late TextEditingController _ctrl;
  String? _error;
  VolumeUnit? _unit;

  @override
  void initState() {
    super.initState();
    final p = ref.read(profileProvider).value!;
    _ml = p.dailyTargetMl;
    _unit = p.unit;
    _ctrl = TextEditingController(text: _fmt(_ml, p.unit));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _fmt(int ml, VolumeUnit u) => u
      .fromMl(ml.toDouble())
      .toStringAsFixed(u.displayDecimals)
      .replaceFirst(RegExp(r'\.0+$'), '');

  void _change(String s) {
    final l = AppLocalizations.of(context);
    final u = _unit!;
    final locale = ref.read(profileProvider).value?.locale ?? 'en';
    final r = validateVolume(
      parseLocalizedNumber(s),
      u,
      minMl: VolumeLimits.minTargetMl,
      maxMl: VolumeLimits.maxTargetMl,
    );
    setState(() {
      if (r is VolumeOk) {
        _ml = r.ml;
        _error = null;
      } else {
        _error = l.onbTargetInvalid(
          Formatters.volume(VolumeLimits.minTargetMl, u, locale),
          Formatters.volume(VolumeLimits.maxTargetMl, u, locale),
        );
      }
    });
  }

  void _step(int dir) {
    final next = (_ml + dir * 100).clamp(
      VolumeLimits.minTargetMl,
      VolumeLimits.maxTargetMl,
    );
    setState(() {
      _ml = next;
      _error = null;
      _ctrl.text = _fmt(next, _unit!);
    });
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (_error != null) return;
    await ref
        .read(coreProvider)
        .updateProfile(
          (p) => p.copyWith(dailyTargetMl: _ml, targetIsUserChosen: true),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.goalSaved)));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = ref.watch(profileProvider).value!;
    return Scaffold(
      appBar: AppBar(title: Text(l.goalTitle)),
      body: SafeArea(
        child: PageBody(
          children: [
            Text(l.goalBody, style: context.text.bodyLarge),
            const SizedBox(height: Gap.xl),
            Row(
              children: [
                IconButton.filledTonal(
                  tooltip: '−',
                  onPressed: () => _step(-1),
                  icon: const Icon(Icons.remove),
                ),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    textAlign: TextAlign.center,
                    style: context.text.headlineMedium,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: _change,
                    decoration: InputDecoration(
                      labelText: l.goalCurrent,
                      suffixText: p.unit.symbol,
                      errorText: _error,
                    ),
                  ),
                ),
                const SizedBox(width: Gap.md),
                IconButton.filledTonal(
                  tooltip: '+',
                  onPressed: () => _step(1),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: Gap.md),
            Text(l.goalHotNote, style: context.text.bodySmall),
            const SizedBox(height: Gap.xl),
            FilledButton(
              onPressed: _error == null ? _save : null,
              child: Text(l.goalSave),
            ),
          ],
        ),
      ),
    );
  }
}
