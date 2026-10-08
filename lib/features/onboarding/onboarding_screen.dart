import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/time/hydra_time.dart';
import '../../core/units/formatters.dart';
import '../../core/units/volume_unit.dart';
import '../../domain/models/enums.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../services/analytics/analytics_service.dart';
import '../../services/notifications/notification_service.dart';
import '../common/time_wheel.dart';
import '../common/widgets.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const int _steps = 7;
  final _page = PageController();
  int _index = 0;

  int _wake = 7 * 60 + 30;
  int _sleep = 23 * 60;
  ReminderMode _mode = ReminderMode.balanced;
  VolumeUnit _unit = VolumeUnit.ml;
  int _targetMl = VolumeLimits.starterTargetMl;
  bool _customTarget = false;
  final _targetCtrl = TextEditingController();
  String? _targetError;
  bool _busy = false;

  String get _locale => ref.read(profileProvider).value?.locale ?? 'en';

  @override
  void initState() {
    super.initState();
    ref.read(servicesProvider).analytics.log(AnalyticsEvent.onboardingStarted);
  }

  @override
  void dispose() {
    _page.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  RoutineTimeError? get _timeError => validateWakeSleep(_wake, _sleep);

  bool get _canContinue {
    switch (_index) {
      case 1:
        return _wake >= kDayRolloverMinute;
      case 2:
        return _timeError == null;
      case 5:
        return _targetError == null;
      default:
        return true;
    }
  }

  void _go(int delta) {
    final next = (_index + delta).clamp(0, _steps - 1);
    _page.animateToPage(
      next,
      duration: context.reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish({required bool askPermission}) async {
    if (_busy) return;
    setState(() => _busy = true);
    final svc = ref.read(servicesProvider);
    try {
      await svc.core.updateProfile(
        (p) => p.copyWith(
          wakeMinute: _wake,
          sleepMinute: _sleep,
          mode: _mode,
          unit: _unit,
          dailyTargetMl: _targetMl,
          targetIsUserChosen: _customTarget,
        ),
      );
      if (askPermission) {
        final result = await svc.notifications.requestPermission();
        svc.analytics.log(
          result == NotificationPermission.granted
              ? AnalyticsEvent.notificationPermissionGranted
              : AnalyticsEvent.notificationPermissionDenied,
        );
      }
      await svc.core.completeOnboarding();
      if (mounted) context.go('/home');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _validateTarget(String text) {
    final l = AppLocalizations.of(context);
    final v = parseLocalizedNumber(text);
    final r = validateVolume(
      v,
      _unit,
      minMl: VolumeLimits.minTargetMl,
      maxMl: VolumeLimits.maxTargetMl,
    );
    setState(() {
      if (r is VolumeOk) {
        _targetMl = r.ml;
        _targetError = null;
      } else {
        _targetError = l.onbTargetInvalid(
          Formatters.volume(VolumeLimits.minTargetMl, _unit, _locale),
          Formatters.volume(VolumeLimits.maxTargetMl, _unit, _locale),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.hx;
    final last = _index == _steps - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Gap.screen,
                Gap.md,
                Gap.screen,
                0,
              ),
              child: Row(
                children: [
                  if (_index > 0)
                    IconButton(
                      tooltip: l.commonBack,
                      onPressed: () => _go(-1),
                      icon: const Icon(Icons.arrow_back),
                    )
                  else
                    const SizedBox(width: kMinTap),
                  Expanded(
                    child: Semantics(
                      label: l.onbStepOf('${_index + 1}', '$_steps'),
                      child: LinearProgressIndicator(
                        value: (_index + 1) / _steps,
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(4),
                        backgroundColor: t.hairline,
                        color: t.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: kMinTap),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _page,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  _welcome(l),
                  _wakeStep(l),
                  _sleepStep(l),
                  _styleStep(l),
                  _unitStep(l),
                  _targetStep(l),
                  _readyStep(l),
                ],
              ),
            ),
            if (!last)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Gap.screen,
                  0,
                  Gap.screen,
                  Gap.lg,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _canContinue ? () => _go(1) : null,
                    child: Text(
                      _index == 0 ? l.onbGetStarted : l.commonContinue,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _frame({required String title, String? body, required Widget child}) =>
      ListView(
        padding: const EdgeInsets.all(Gap.screen),
        children: [
          const SizedBox(height: Gap.lg),
          Semantics(
            header: true,
            child: Text(title, style: context.text.headlineMedium),
          ),
          if (body != null) ...[
            const SizedBox(height: Gap.sm),
            Text(
              body,
              style: context.text.bodyLarge?.copyWith(
                color: context.hx.inkMuted,
              ),
            ),
          ],
          const SizedBox(height: Gap.xl),
          child,
        ],
      );

  Widget _welcome(AppLocalizations l) {
    final t = context.hx;
    return Padding(
      padding: const EdgeInsets.all(Gap.screen),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [t.waterTop, t.waterBottom],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: Colors.white,
              size: 40,
              semanticLabel: '',
            ),
          ),
          const SizedBox(height: Gap.xl),
          Text(
            l.appName,
            style: context.text.labelLarge?.copyWith(
              letterSpacing: 4,
              color: t.accent,
            ),
          ),
          const SizedBox(height: Gap.sm),
          Semantics(
            header: true,
            child: Text(
              l.onbWelcomeTitle,
              style: context.text.displayMedium?.copyWith(fontSize: 38),
            ),
          ),
          const SizedBox(height: Gap.lg),
          Text(
            l.onbWelcomeBody,
            style: context.text.bodyLarge?.copyWith(color: t.inkMuted),
          ),
        ],
      ),
    );
  }

  Widget _wakeStep(AppLocalizations l) => _frame(
    title: l.onbWakeTitle,
    body: l.onbWakeBody,
    child: Column(
      children: [
        TimeWheel(
          minute: _wake,
          locale: _locale,
          semanticsLabel: l.onbWakeTitle,
          onChanged: (m) => setState(() => _wake = m),
        ),
        if (_wake < kDayRolloverMinute)
          Padding(
            padding: const EdgeInsets.only(top: Gap.md),
            child: Text(
              l.onbTimeWakeEarly,
              style: TextStyle(color: context.hx.attention),
            ),
          ),
      ],
    ),
  );

  Widget _sleepStep(AppLocalizations l) {
    final err = _timeError;
    return _frame(
      title: l.onbSleepTitle,
      body: l.onbSleepBody,
      child: Column(
        children: [
          TimeWheel(
            minute: _sleep,
            locale: _locale,
            semanticsLabel: l.onbSleepTitle,
            onChanged: (m) => setState(() => _sleep = m),
          ),
          if (err == RoutineTimeError.tooShort)
            _error(l.onbTimeTooShort)
          else if (err == RoutineTimeError.overnightPastRollover)
            _error(l.onbTimeOvernight),
        ],
      ),
    );
  }

  Widget _error(String s) => Padding(
    padding: const EdgeInsets.only(top: Gap.md),
    child: Row(
      children: [
        Text(
          '! ',
          style: TextStyle(
            color: context.hx.attention,
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: Text(s, style: TextStyle(color: context.hx.attention)),
        ),
      ],
    ),
  );

  Widget _choice({
    required bool selected,
    required String title,
    required String body,
    required VoidCallback onTap,
  }) {
    final t = context.hx;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: Semantics(
        selected: selected,
        inMutuallyExclusiveGroup: true,
        button: true,
        child: HCard(
          onTap: onTap,
          color: selected ? t.accentSoft : t.surface,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: context.text.bodyMedium?.copyWith(
                        color: t.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? t.accent : t.hairline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _styleStep(AppLocalizations l) => _frame(
    title: l.onbStyleTitle,
    body: l.onbStyleBody,
    child: Column(
      children: [
        _choice(
          selected: _mode == ReminderMode.gentle,
          title: l.styleGentle,
          body: l.styleGentleBody,
          onTap: () => setState(() => _mode = ReminderMode.gentle),
        ),
        _choice(
          selected: _mode == ReminderMode.balanced,
          title: l.styleBalanced,
          body: l.styleBalancedBody,
          onTap: () => setState(() => _mode = ReminderMode.balanced),
        ),
        _choice(
          selected: _mode == ReminderMode.focus,
          title: l.styleFocus,
          body: l.styleFocusBody,
          onTap: () => setState(() => _mode = ReminderMode.focus),
        ),
      ],
    ),
  );

  Widget _unitStep(AppLocalizations l) {
    String ex(VolumeUnit u) => Formatters.volume(250, u, _locale);
    Widget c(VolumeUnit u, String title) => _choice(
      selected: _unit == u,
      title: title,
      body: ex(u),
      onTap: () => setState(() {
        _unit = u;
        if (_customTarget) _targetCtrl.clear();
      }),
    );
    return _frame(
      title: l.onbUnitTitle,
      body: l.onbUnitBody,
      child: Column(
        children: [
          c(VolumeUnit.ml, l.unitMl),
          c(VolumeUnit.l, l.unitL),
          c(VolumeUnit.flOzUs, l.unitFlOz),
          c(VolumeUnit.cups, l.unitCups),
        ],
      ),
    );
  }

  Widget _targetStep(AppLocalizations l) {
    final t = context.hx;
    return _frame(
      title: l.onbTargetTitle,
      body: l.onbTargetBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _choice(
            selected: !_customTarget,
            title:
                '${l.onbStarterTarget} · ${Formatters.volume(VolumeLimits.starterTargetMl, _unit, _locale)}',
            body: l.onbStarterTargetBody,
            onTap: () => setState(() {
              _customTarget = false;
              _targetMl = VolumeLimits.starterTargetMl;
              _targetError = null;
            }),
          ),
          _choice(
            selected: _customTarget,
            title: l.onbCustomTarget,
            body: l.onbTargetBody,
            onTap: () => setState(() => _customTarget = true),
          ),
          if (_customTarget)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.md),
              child: TextField(
                controller: _targetCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: _validateTarget,
                decoration: InputDecoration(
                  labelText: '${l.onbYourTarget} (${_unit.symbol})',
                  errorText: _targetError,
                ),
              ),
            ),
          const SizedBox(height: Gap.sm),
          HCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.flag_outlined, color: t.accent, size: 20),
                    const SizedBox(width: 8),
                    Text(l.onbYourTarget, style: context.text.titleSmall),
                  ],
                ),
                const SizedBox(height: 2),
                Text(l.onbYourTargetBody, style: context.text.bodySmall),
                const SizedBox(height: Gap.md),
                Row(
                  children: [
                    Icon(Icons.schedule, color: t.accent, size: 20),
                    const SizedBox(width: 8),
                    Text(l.onbHydraSchedule, style: context.text.titleSmall),
                  ],
                ),
                const SizedBox(height: 2),
                Text(l.onbHydraScheduleBody, style: context.text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _readyStep(AppLocalizations l) {
    final t = context.hx;
    Widget item(IconData i, String title, String body) => Padding(
      padding: const EdgeInsets.only(bottom: Gap.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: t.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(i, color: t.accent, size: 20),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.titleSmall),
                Text(
                  body,
                  style: context.text.bodyMedium?.copyWith(color: t.inkMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return _frame(
      title: l.onbReadyTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          item(
            Icons.notifications_none,
            l.onbReadyNotifTitle,
            l.onbReadyNotifBody,
          ),
          item(
            Icons.lock_outline,
            l.onbReadyPrivacyTitle,
            l.onbReadyPrivacyBody,
          ),
          item(
            Icons.favorite_border,
            l.onbReadyHealthTitle,
            l.onbReadyHealthBody,
          ),
          const SizedBox(height: Gap.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _busy ? null : () => _finish(askPermission: true),
              child: Text(l.onbAllowNotifications),
            ),
          ),
          const SizedBox(height: Gap.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _busy ? null : () => _finish(askPermission: false),
              child: Text(l.onbStartWithout),
            ),
          ),
        ],
      ),
    );
  }
}
