import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/time/hydra_time.dart';
import '../../core/units/formatters.dart';
import '../../core/util/validation.dart';
import '../../data/repositories/routine_repository.dart';
import '../../domain/models/entities.dart';
import '../../domain/models/enums.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/widgets.dart';
import '../insights/l10n_helpers.dart';
import 'schedule_screen.dart' show pickMinute;

IconData _kindIcon(RoutineKind k) => switch (k) {
      RoutineKind.weekday => Icons.work_outline,
      RoutineKind.weekend => Icons.weekend_outlined,
      RoutineKind.work => Icons.work_outline,
      RoutineKind.study => Icons.menu_book_outlined,
      RoutineKind.workout => Icons.fitness_center,
      RoutineKind.travel => Icons.flight_takeoff,
      RoutineKind.custom => Icons.tune,
    };

class RoutinesScreen extends ConsumerWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final p = ref.watch(profileProvider).value!;
    final routines = ref.watch(routinesProvider).value ?? const [];
    final locale = p.locale ?? 'en';
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    final isPro = ref.watch(isProProvider);
    String time(int m) => Formatters.minuteOfDay(m, locale, use24h: use24);

    String days(Set<int> d) {
      if (d.isEmpty) return '—';
      final sym = DateFormat.E(locale);
      final sorted = d.toList()..sort();
      return sorted.map((w) => sym.format(DateTime(2024, 1, w))).join(' · ');
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.routinesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (!isPro && routines.length >= RoutineRepository.freeLimit) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(l.routinesLimit('${RoutineRepository.freeLimit}')),
                action: SnackBarAction(label: l.healthProCta, onPressed: () => context.push('/pro')),
              ));
            return;
          }
          context.push('/you/routines/edit');
        },
        icon: const Icon(Icons.add),
        label: Text(l.routinesAdd),
      ),
      body: SafeArea(
        child: routines.isEmpty
            ? EmptyState(
                icon: Icons.event_repeat_outlined,
                title: l.routinesEmptyTitle,
                message: l.routinesEmptyBody,
                action: FilledButton(onPressed: () => context.push('/you/routines/edit'), child: Text(l.routinesAdd)),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(Gap.screen, Gap.sm, Gap.screen, 96),
                children: [
                  Text(l.routinesBody, style: context.text.bodyMedium),
                  const SizedBox(height: Gap.lg),
                  for (final r in routines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Gap.sm),
                      child: HCard(
                        onTap: () => context.push('/you/routines/edit?id=${r.id}'),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Icon(_kindIcon(r.kind), color: context.hx.accent),
                            const SizedBox(width: Gap.md),
                            Expanded(child: Text(r.name, style: context.text.titleSmall)),
                            if (p.activeRoutineId == r.id) StatusChip(kind: StatusKind.good, label: l.routinesActive),
                          ]),
                          const SizedBox(height: 4),
                          Text('${time(r.wakeMinute)} – ${time(r.sleepMinute)} · ${days(r.weekdays)}', style: context.text.bodySmall),
                          const SizedBox(height: Gap.sm),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: p.activeRoutineId == r.id
                                ? TextButton(
                                    onPressed: () => ref.read(coreProvider).updateProfile((x) => x.copyWith(clearActiveRoutine: true)),
                                    child: Text(l.routinesUseAuto),
                                  )
                                : OutlinedButton(
                                    onPressed: () => ref.read(coreProvider).updateProfile((x) => x.copyWith(activeRoutineId: r.id)),
                                    child: Text(l.routinesUse),
                                  ),
                          ),
                        ]),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class RoutineEditScreen extends ConsumerStatefulWidget {
  const RoutineEditScreen({super.key, this.routineId});
  final String? routineId;
  @override
  ConsumerState<RoutineEditScreen> createState() => _RoutineEditScreenState();
}

class _RoutineEditScreenState extends ConsumerState<RoutineEditScreen> {
  late Routine _r;
  late final TextEditingController _name;
  bool _loaded = false;
  bool _isNew = true;

  @override
  void initState() {
    super.initState();
    final core = ref.read(coreProvider);
    final p = ref.read(profileProvider).value!;
    _name = TextEditingController();
    _r = core.routines.blank(
      name: '',
      kind: RoutineKind.work,
      wake: p.wakeMinute,
      sleep: p.sleepMinute,
      weekdays: {1, 2, 3, 4, 5},
      mode: p.mode,
    );
    _load();
  }

  Future<void> _load() async {
    final id = widget.routineId;
    if (id != null) {
      final all = await ref.read(coreProvider).routines.getAll();
      final found = all.where((r) => r.id == id).firstOrNull;
      if (found != null) {
        _r = found;
        _isNew = false;
        _name.text = found.name;
      }
    }
    if (mounted) setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final isPro = ref.read(isProProvider);
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.routinesNameInvalid)));
      return;
    }
    if ((_r.kind == RoutineKind.workout || _r.kind == RoutineKind.travel) && !isPro) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.routinesProKind),
        action: SnackBarAction(label: l.healthProCta, onPressed: () => context.push('/pro')),
      ));
      return;
    }
    final nav = context;
    try {
      await ref.read(coreProvider).routines.upsert(
            _r.copyWith(name: _name.text),
            limit: (!isPro && _isNew) ? RoutineRepository.freeLimit : null,
          );
      await ref.read(coreProvider).reschedule(reason: 'routine');
      if (nav.mounted) nav.pop();
    } on ValidationException catch (e) {
      if (!mounted) return;
      final msg = e.code == ValidationCode.limitReached
          ? l.routinesLimit('${RoutineRepository.freeLimit}')
          : l.routinesInvalid;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<TimeSpan?> _pickSpan(BuildContext context, String locale, TimeSpan? initial) async {
    final l = AppLocalizations.of(context);
    final s = await pickMinute(context, initial: initial?.startMinute ?? 13 * 60, title: l.routinesFrom, locale: locale);
    if (s == null || !context.mounted) return null;
    final e = await pickMinute(context, initial: initial?.endMinute ?? (s + 60) % 1440, title: l.routinesTo, locale: locale);
    if (e == null || s == e) return null;
    return TimeSpan(s, e);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = ref.watch(profileProvider).value!;
    final locale = p.locale ?? 'en';
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    String time(int m) => Formatters.minuteOfDay(m, locale, use24h: use24);
    if (!_loaded) return const Scaffold(body: SizedBox());

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? l.routinesAdd : l.commonEdit),
        actions: [
          if (!_isNew)
            IconButton(
              tooltip: l.commonDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l.routinesDeleteTitle),
                    content: Text(l.routinesDeleteBody),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.commonCancel)),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.commonDelete)),
                    ],
                  ),
                );
                if (ok == true) {
                  await ref.read(coreProvider).routines.delete(_r.id);
                  await ref.read(coreProvider).reschedule(reason: 'routine');
                  if (context.mounted) context.pop();
                }
              },
            ),
        ],
      ),
      body: SafeArea(
        child: PageBody(children: [
          TextField(controller: _name, maxLength: 40, decoration: InputDecoration(labelText: l.routinesName, counterText: '')),
          const SizedBox(height: Gap.lg),
          Text(l.routinesKind, style: context.text.labelMedium),
          const SizedBox(height: Gap.sm),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final k in RoutineKind.values.where((k) => k != RoutineKind.weekday && k != RoutineKind.weekend))
              ChoiceChip(
                avatar: Icon(_kindIcon(k), size: 18),
                label: Text(routineKindName(l, k)),
                selected: _r.kind == k,
                onSelected: (_) => setState(() => _r = _r.copyWith(kind: k)),
              ),
          ]),
          const SizedBox(height: Gap.lg),
          Text(l.routinesDays, style: context.text.labelMedium),
          const SizedBox(height: Gap.sm),
          Wrap(spacing: 8, children: [
            for (var d = 1; d <= 7; d++)
              FilterChip(
                label: Text(DateFormat.E(locale).format(DateTime(2024, 1, d))),
                selected: _r.weekdays.contains(d),
                onSelected: (v) => setState(() {
                  final next = {..._r.weekdays};
                  v ? next.add(d) : next.remove(d);
                  _r = _r.copyWith(weekdays: next);
                }),
              ),
          ]),
          const SizedBox(height: Gap.lg),
          TileGroup(children: [
            HTile(
              leading: Icons.wb_sunny_outlined,
              title: l.scheduleWake,
              trailing: Text(time(_r.wakeMinute), style: context.text.titleMedium),
              onTap: () async {
                final m = await pickMinute(context, initial: _r.wakeMinute, title: l.scheduleWake, locale: locale);
                if (m != null) setState(() => _r = _r.copyWith(wakeMinute: m));
              },
            ),
            HTile(
              leading: Icons.bedtime_outlined,
              title: l.scheduleSleep,
              trailing: Text(time(_r.sleepMinute), style: context.text.titleMedium),
              onTap: () async {
                final m = await pickMinute(context, initial: _r.sleepMinute, title: l.scheduleSleep, locale: locale);
                if (m != null) setState(() => _r = _r.copyWith(sleepMinute: m));
              },
            ),
          ]),
          if (validateWakeSleep(_r.wakeMinute, _r.sleepMinute) != null)
            Padding(padding: const EdgeInsets.only(top: Gap.sm), child: Text('! ${l.routinesInvalid}', style: TextStyle(color: context.hx.attention))),
          const SizedBox(height: Gap.lg),
          Text(l.remindersStyle, style: context.text.labelMedium),
          const SizedBox(height: Gap.sm),
          SegmentedButton<ReminderMode>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: ReminderMode.gentle, label: Text(l.styleGentle)),
              ButtonSegment(value: ReminderMode.balanced, label: Text(l.styleBalanced)),
              ButtonSegment(value: ReminderMode.focus, label: Text(l.styleFocus)),
            ],
            selected: {_r.mode},
            onSelectionChanged: (s) => setState(() => _r = _r.copyWith(mode: s.first)),
          ),
          SectionHeader(l.routinesQuiet),
          for (var i = 0; i < _r.quietSpans.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${time(_r.quietSpans[i].startMinute)} – ${time(_r.quietSpans[i].endMinute)}'),
              trailing: IconButton(
                tooltip: l.commonDelete,
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _r = _r.copyWith(quietSpans: [..._r.quietSpans]..removeAt(i))),
              ),
            ),
          TextButton.icon(
            onPressed: () async {
              final s = await _pickSpan(context, locale, null);
              if (s != null) setState(() => _r = _r.copyWith(quietSpans: [..._r.quietSpans, s]));
            },
            icon: const Icon(Icons.add),
            label: Text(l.routinesQuietAdd),
          ),
          if (_r.kind == RoutineKind.workout) ...[
            SectionHeader(l.routinesWorkout),
            Text(l.routinesWorkoutBody, style: context.text.bodySmall),
            for (var i = 0; i < _r.workoutSpans.length; i++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${time(_r.workoutSpans[i].startMinute)} – ${time(_r.workoutSpans[i].endMinute)}'),
                trailing: IconButton(
                  tooltip: l.commonDelete,
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _r = _r.copyWith(workoutSpans: [..._r.workoutSpans]..removeAt(i))),
                ),
              ),
            TextButton.icon(
              onPressed: () async {
                final s = await _pickSpan(context, locale, const TimeSpan(18 * 60, 19 * 60 + 15));
                if (s != null) setState(() => _r = _r.copyWith(workoutSpans: [..._r.workoutSpans, s]));
              },
              icon: const Icon(Icons.add),
              label: Text(l.routinesWorkout),
            ),
          ],
          const SizedBox(height: Gap.xl),
          FilledButton(onPressed: _save, child: Text(l.commonSave)),
        ]),
      ),
    );
  }
}
