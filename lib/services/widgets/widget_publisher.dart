import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../../core/logging/log.dart';

/// Minimal, glanceable widget state. Only a rounded percentage and short
/// labels are shared with the OS widget host — never entry-level history.
class WidgetSnapshot {
  const WidgetSnapshot({
    required this.percent,
    required this.progressLabel,
    required this.nextReminderLabel,
    required this.quickAddsMl,
    required this.stateSymbol,
    required this.updatedAtMs,
    required this.hideAmounts,
  });

  final int percent;

  /// e.g. "1,390 / 2,400 ml" — blank when [hideAmounts].
  final String progressLabel;
  final String nextReminderLabel;
  final List<int> quickAddsMl;

  /// ✓ on pace · ! needs attention · → adjusted (never colour alone).
  final String stateSymbol;
  final int updatedAtMs;
  final bool hideAmounts;
}

abstract class WidgetPublisher {
  Future<void> publish(WidgetSnapshot s);
}

/// Pushes state to Android App Widgets / iOS WidgetKit (via an App Group).
///
/// Refresh strategy (no polling, no background loops):
///  * on every hydration change, reminder reschedule and app resume,
///  * plus the widget's own system-driven `updatePeriodMillis`/timeline
///    reload so the displayed "next reminder" never goes stale indefinitely.
class HomeWidgetPublisher implements WidgetPublisher {
  static const String iosAppGroup = 'group.com.hydra.hydra';
  static const String androidProvider = 'HydraWidgetProvider';
  static const String iosWidget = 'HydraWidget';

  bool _ready = false;

  Future<void> _ensure() async {
    if (_ready) return;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await HomeWidget.setAppGroupId(iosAppGroup);
    }
    _ready = true;
  }

  @override
  Future<void> publish(WidgetSnapshot s) async {
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    try {
      await _ensure();
      await HomeWidget.saveWidgetData<int>('percent', s.percent);
      await HomeWidget.saveWidgetData<String>(
        'progress',
        s.hideAmounts ? '' : s.progressLabel,
      );
      await HomeWidget.saveWidgetData<String>('next', s.nextReminderLabel);
      await HomeWidget.saveWidgetData<String>('symbol', s.stateSymbol);
      await HomeWidget.saveWidgetData<int>('updatedAt', s.updatedAtMs);
      for (var i = 0; i < 3; i++) {
        await HomeWidget.saveWidgetData<int>(
          'qa$i',
          i < s.quickAddsMl.length ? s.quickAddsMl[i] : 0,
        );
      }
      await HomeWidget.updateWidget(
        androidName: androidProvider,
        iOSName: iosWidget,
      );
    } catch (e, st) {
      Log.error('widgets', 'publish failed', error: e, stack: st);
    }
  }
}

class NoWidgetPublisher implements WidgetPublisher {
  @override
  Future<void> publish(WidgetSnapshot s) async {}
}
