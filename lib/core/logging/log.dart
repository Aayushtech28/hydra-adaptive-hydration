import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error, critical }

/// A structured log record. Fields are scrubbed by [Redactor] before leaving
/// the process (crash reporters) and verbose levels are dropped in release.
class LogRecord {
  const LogRecord(this.level, this.area, this.message, this.fields, this.at);
  final LogLevel level;
  final String area;
  final String message;
  final Map<String, Object?> fields;
  final DateTime at;
}

typedef LogSink = void Function(LogRecord);

/// Redacts anything that could be health or personal data before it reaches
/// logs or crash reports. Allow-list approach for field values: only
/// primitives with whitelisted keys survive; message text is scrubbed of
/// numbers followed by volume units and ISO dates.
abstract final class Redactor {
  static const Set<String> allowedFieldKeys = {
    'area', 'code', 'state', 'count', 'durationMs', 'version', 'platform',
    'reason', 'status', 'permission', 'algorithm', 'attempt', 'type',
  };

  static final RegExp _volume = RegExp(
    r'\b\d+(?:[.,]\d+)?\s?(?:ml|l|fl\s?oz|oz|cups?)\b',
    caseSensitive: false,
  );
  static final RegExp _isoDate = RegExp(r'\b\d{4}-\d{2}-\d{2}(?:[T ]\d{2}:\d{2}(?::\d{2})?)?\b');
  static final RegExp _email = RegExp(r'[\w.+-]+@[\w-]+\.[\w.-]+');

  static String scrub(String s) => s
      .replaceAll(_volume, '‹volume›')
      .replaceAll(_isoDate, '‹date›')
      .replaceAll(_email, '‹email›');

  static Map<String, Object?> fields(Map<String, Object?> f) => {
        for (final e in f.entries)
          if (allowedFieldKeys.contains(e.key) &&
              (e.value is num || e.value is bool || e.value is String))
            e.key: e.value is String ? scrub(e.value! as String) : e.value,
      };
}

/// App-wide structured logger. Never log hydration history, health records or
/// identifiers; pass only coarse codes in [fields] (see [Redactor]).
abstract final class Log {
  static final List<LogRecord> _ring = <LogRecord>[];
  static const int ringSize = 200;
  static final List<LogSink> _sinks = [];

  /// Minimum level emitted. Release builds default to warning.
  static LogLevel minLevel = kReleaseMode ? LogLevel.warning : LogLevel.debug;

  static void addSink(LogSink s) => _sinks.add(s);
  static void clearSinks() => _sinks.clear();

  static List<LogRecord> get recent => List.unmodifiable(_ring);

  static void debug(String area, String message, {Map<String, Object?> fields = const {}}) =>
      _emit(LogLevel.debug, area, message, fields);
  static void info(String area, String message, {Map<String, Object?> fields = const {}}) =>
      _emit(LogLevel.info, area, message, fields);
  static void warning(String area, String message, {Map<String, Object?> fields = const {}}) =>
      _emit(LogLevel.warning, area, message, fields);
  static void error(String area, String message,
          {Object? error, StackTrace? stack, Map<String, Object?> fields = const {}}) =>
      _emit(LogLevel.error, area, message, {...fields, if (error != null) 'type': error.runtimeType.toString()}, stack: stack);
  static void critical(String area, String message,
          {Object? error, StackTrace? stack, Map<String, Object?> fields = const {}}) =>
      _emit(LogLevel.critical, area, message, {...fields, if (error != null) 'type': error.runtimeType.toString()}, stack: stack);

  static void _emit(LogLevel level, String area, String message, Map<String, Object?> fields,
      {StackTrace? stack}) {
    if (level.index < minLevel.index) return;
    final rec = LogRecord(level, area, Redactor.scrub(message), Redactor.fields(fields), DateTime.now());
    _ring.add(rec);
    if (_ring.length > ringSize) _ring.removeAt(0);
    for (final s in _sinks) {
      try {
        s(rec);
      } catch (_) {}
    }
    if (!kReleaseMode) {
      debugPrint('[${level.name.toUpperCase()}][$area] ${rec.message} ${rec.fields.isEmpty ? '' : rec.fields}');
    }
  }
}
