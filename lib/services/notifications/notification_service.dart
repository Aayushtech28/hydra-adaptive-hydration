/// Platform-independent notification contract. The scheduler decides *when*;
/// this service only delivers that decision to the OS.
enum NotificationPermission { granted, denied, notDetermined }

enum NotificationActionKind { log, snooze, open }

/// A user interaction with a reminder (tap or action button).
class NotificationAction {
  const NotificationAction(this.kind, {this.ml, this.eventId});
  final NotificationActionKind kind;
  final int? ml;
  final String? eventId;

  static const String _logPrefix = 'log:';
  static const String snoozeId = 'snooze';

  static String logActionId(int ml) => '$_logPrefix$ml';

  /// Builds from the OS action id + payload. Returns [open] for a plain tap
  /// and null for anything malformed (never throws).
  static NotificationAction? parse({String? actionId, String? payload}) {
    final event = _eventIdFromPayload(payload);
    if (actionId == null || actionId.isEmpty) {
      return NotificationAction(NotificationActionKind.open, eventId: event);
    }
    if (actionId == snoozeId) {
      return NotificationAction(NotificationActionKind.snooze, eventId: event);
    }
    if (actionId.startsWith(_logPrefix)) {
      final ml = int.tryParse(actionId.substring(_logPrefix.length));
      if (ml == null || ml <= 0 || ml > 5000) return null;
      return NotificationAction(
        NotificationActionKind.log,
        ml: ml,
        eventId: event,
      );
    }
    return null;
  }

  static String payloadFor(String eventId) => 'v1|$eventId';

  static String? _eventIdFromPayload(String? payload) {
    if (payload == null) return null;
    final parts = payload.split('|');
    return parts.length == 2 && parts[0] == 'v1' && parts[1].isNotEmpty
        ? parts[1]
        : null;
  }
}

class ScheduledReminder {
  const ScheduledReminder({
    required this.id,
    required this.eventId,
    required this.at,
    required this.title,
    required this.body,
  });

  /// OS notification id (stable per slot).
  final int id;
  final String eventId;
  final DateTime at;
  final String title;
  final String body;
}

class ActionLabels {
  const ActionLabels({required this.logActions, required this.snooze});

  /// (ml, localized "+250 ml") pairs shown as buttons.
  final List<({int ml, String label})> logActions;
  final String snooze;
}

abstract class NotificationService {
  Future<void> init({
    required ActionLabels labels,
    required String channelName,
    required String channelDescription,
  });
  Future<NotificationPermission> permission();
  Future<NotificationPermission> requestPermission();

  /// Atomically replaces every scheduled reminder with [reminders].
  Future<void> replaceAll(
    List<ScheduledReminder> reminders, {
    required ActionLabels labels,
  });
  Future<void> cancelAll();
  Future<int> pendingCount();

  /// Shows an immediate notification (used by the notification check-up).
  Future<void> showTest({required String title, required String body});

  /// Interactions received while the app process is alive.
  Stream<NotificationAction> get actions;

  /// Launch action if the app was started by tapping a notification.
  Future<NotificationAction?> launchAction();
}
