import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/units/formatters.dart';
import '../../core/units/volume_unit.dart';
import '../../core/util/validation.dart';
import '../../domain/models/entities.dart';
import '../../l10n/gen/app_localizations.dart';

/// Result of the sheet: either a new log or an edit.
Future<void> showLogSheet(
  BuildContext context, {
  HydrationEntry? editing,
  int? presetMl,
  Vessel? preset,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _LogSheet(
      editing: editing,
      presetMl: presetMl ?? preset?.volumeMl,
      presetVessel: preset,
    ),
  );
}

class _LogSheet extends ConsumerStatefulWidget {
  const _LogSheet({this.editing, this.presetMl, this.presetVessel});
  final HydrationEntry? editing;
  final int? presetMl;
  final Vessel? presetVessel;
  @override
  ConsumerState<_LogSheet> createState() => _LogSheetState();
}

class _LogSheetState extends ConsumerState<_LogSheet> {
  late final TextEditingController _ctrl;
  int? _ml;
  String? _vesselId;
  late DateTime _at;
  bool _busy = false;
  String? _error;

  UserProfile get _profile => ref.read(profileProvider).value!;

  @override
  void initState() {
    super.initState();
    final p = _profile;
    final core = ref.read(coreProvider);
    _ml = widget.editing?.volumeMl ?? widget.presetMl ?? p.quickAddsMl.first;
    _vesselId = widget.editing?.vesselId ?? widget.presetVessel?.id;
    _at = widget.editing?.timestampUtc.toLocal() ?? core.clock.now();
    _ctrl = TextEditingController(text: _fmtInput(_ml!, p.unit));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _fmtInput(int ml, VolumeUnit u) {
    final v = u.fromMl(ml.toDouble());
    final d = u.displayDecimals;
    return v.toStringAsFixed(d).replaceFirst(RegExp(r'\.0+$'), '');
  }

  void _onText(String s) {
    final u = _profile.unit;
    final r = validateVolume(parseLocalizedNumber(s), u);
    setState(() {
      if (r is VolumeOk) {
        _ml = r.ml;
        _error = null;
      } else {
        _ml = null;
        _error = AppLocalizations.of(context).logFailed;
      }
    });
  }

  void _step(int dir) {
    final u = _profile.unit;
    final stepMl = switch (u) {
      VolumeUnit.ml => 50,
      VolumeUnit.l => 100,
      VolumeUnit.flOzUs => 30,
      VolumeUnit.cups => 60,
    };
    final next = ((_ml ?? 250) + dir * stepMl).clamp(
      VolumeLimits.minEntryMl,
      VolumeLimits.maxEntryMl,
    );
    setState(() {
      _ml = next;
      _error = null;
      _ctrl.text = _fmtInput(next, u);
    });
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_at),
    );
    if (t == null) return;
    setState(
      () => _at = DateTime(_at.year, _at.month, _at.day, t.hour, t.minute),
    );
  }

  Future<void> _pickDate() async {
    final now = ref.read(coreProvider).clock.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _at,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
    );
    if (d == null) return;
    setState(
      () => _at = DateTime(d.year, d.month, d.day, _at.hour, _at.minute),
    );
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final core = ref.read(coreProvider);
    final ml = _ml;
    if (ml == null || _busy) return;
    if (_at.isAfter(core.clock.now().add(const Duration(minutes: 1)))) {
      setState(() => _error = l.logSheetFuture);
      return;
    }
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      unawaited(HapticFeedback.lightImpact());
      if (widget.editing != null) {
        await core.editEntry(widget.editing!.id, volumeMl: ml, at: _at.toUtc());
        messenger.showSnackBar(SnackBar(content: Text(l.logSheetSaved)));
      } else {
        final r = await core.log(
          volumeMl: ml,
          vesselId: _vesselId,
          at: _at.toUtc(),
        );
        ref.read(logPulseProvider.notifier).fire();
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              l.logged(
                Formatters.volume(ml, _profile.unit, _profile.locale ?? 'en'),
              ),
            ),
            action: SnackBarAction(
              label: l.commonUndo,
              onPressed: () => core.deleteEntry(r.entry.id),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      nav.pop();
    } on ValidationException {
      if (mounted) setState(() => _error = l.logFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.hx;
    final p = _profile;
    final locale = p.locale ?? 'en';
    final vessels = ref.watch(vesselsProvider).value ?? const [];
    final editing = widget.editing != null;
    final now = ref.read(coreProvider).clock.now();
    final isToday =
        _at.year == now.year && _at.month == now.month && _at.day == now.day;
    final isYesterday =
        !isToday &&
        now.difference(DateTime(_at.year, _at.month, _at.day)).inHours < 48 &&
        DateTime(
              now.year,
              now.month,
              now.day,
            ).difference(DateTime(_at.year, _at.month, _at.day)).inDays ==
            1;
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    final timeLabel = Formatters.minuteOfDay(
      _at.hour * 60 + _at.minute,
      locale,
      use24h: use24,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Gap.screen, 0, Gap.screen, Gap.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                editing ? l.logSheetEditing : l.logSheetTitle,
                style: context.text.titleLarge,
              ),
            ),
            const SizedBox(height: Gap.lg),
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
                    onChanged: _onText,
                    decoration: InputDecoration(
                      suffixText: p.unit.symbol,
                      hintText: l.logSheetAmountHint,
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
            if (!editing) ...[
              const SizedBox(height: Gap.lg),
              Text(l.quickAddVessels, style: context.text.labelMedium),
              const SizedBox(height: Gap.sm),
              if (vessels.isEmpty)
                Text(l.logSheetVesselsEmpty, style: context.text.bodySmall)
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final v in vessels)
                      ChoiceChip(
                        label: Text(
                          '${v.name} · ${Formatters.volume(v.volumeMl, p.unit, locale)}',
                        ),
                        selected: _vesselId == v.id,
                        onSelected: (_) => setState(() {
                          _vesselId = v.id;
                          _ml = v.volumeMl;
                          _error = null;
                          _ctrl.text = _fmtInput(v.volumeMl, p.unit);
                        }),
                      ),
                  ],
                ),
            ],
            const SizedBox(height: Gap.lg),
            Text(l.logSheetLogAt, style: context.text.labelMedium),
            const SizedBox(height: Gap.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l.entryNow),
                  selected:
                      !editing &&
                      isToday &&
                      now.difference(_at).inMinutes.abs() < 2,
                  onSelected: (_) =>
                      setState(() => _at = ref.read(coreProvider).clock.now()),
                ),
                ChoiceChip(
                  label: Text(l.entryYesterday),
                  selected: isYesterday,
                  onSelected: (_) => setState(() {
                    final y = now.subtract(const Duration(days: 1));
                    _at = DateTime(
                      y.year,
                      y.month,
                      y.day,
                      _at.hour,
                      _at.minute,
                    );
                  }),
                ),
                ActionChip(
                  avatar: const Icon(Icons.schedule, size: 18),
                  label: Text(timeLabel),
                  onPressed: _pickTime,
                ),
                ActionChip(
                  avatar: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    MaterialLocalizations.of(context).formatShortDate(_at),
                  ),
                  onPressed: _pickDate,
                ),
              ],
            ),
            const SizedBox(height: Gap.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (_ml == null || _busy) ? null : _submit,
                child: Text(editing ? l.commonSave : l.logSheetLog),
              ),
            ),
            if (editing)
              Center(
                child: TextButton(
                  onPressed: () async {
                    final core = ref.read(coreProvider);
                    final nav = Navigator.of(context);
                    final entry = widget.editing!;
                    await core.deleteEntry(entry.id);
                    nav.pop();
                  },
                  child: Text(
                    l.commonDelete,
                    style: TextStyle(color: t.attention),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
