import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/repositories/hydration_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/routine_repository.dart';
import '../../data/repositories/vessel_repository.dart';
import '../../domain/models/entities.dart';

/// Documented export schema (also in docs/PRIVACY_ARCHITECTURE.md).
///
/// CSV columns: `id,date,timestamp_utc,timezone,volume_ml,beverage,vessel,source`
/// JSON: `{schema, exportedAt, profile, vessels[], routines[], entries[]}`.
/// Volumes are always canonical millilitres. External health ids are included
/// only as opaque strings; no analytics identifiers exist to export.
class ExportService {
  ExportService({
    required this.hydration,
    required this.vessels,
    required this.routines,
    required this.profile,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final HydrationRepository hydration;
  final VesselRepository vessels;
  final RoutineRepository routines;
  final ProfileRepository profile;
  final DateTime Function() _now;

  static const String schemaVersion = 'hydra.export.v1';

  /// RFC-4180 style field escaping (+ spreadsheet formula-injection guard).
  static String csvField(String v) {
    var s = v;
    if (s.isNotEmpty && '=+-@\t\r'.contains(s[0])) s = "'$s";
    if (s.contains(',') ||
        s.contains('"') ||
        s.contains('\n') ||
        s.contains('\r')) {
      s = '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  Future<String> buildCsv() async {
    final entries = await hydration.all();
    final vesselNames = {for (final v in await vessels.getAll()) v.id: v.name};
    final b = StringBuffer(
      'id,date,timestamp_utc,timezone,volume_ml,beverage,vessel,source\r\n',
    );
    for (final e in entries) {
      b.write(
        [
          e.id,
          e.localDate.toIso(),
          e.timestampUtc.toIso8601String(),
          e.timezone,
          e.volumeMl.toString(),
          e.beverage.name,
          vesselNames[e.vesselId] ?? '',
          e.source.name,
        ].map(csvField).join(','),
      );
      b.write('\r\n');
    }
    return b.toString();
  }

  Future<String> buildJson() async {
    final entries = await hydration.all();
    final p = await profile.get();
    final vs = await vessels.getAll();
    final rs = await routines.getAll();
    final map = <String, Object?>{
      'schema': schemaVersion,
      'exportedAt': _now().toUtc().toIso8601String(),
      'profile': p == null
          ? null
          : {
              'unit': p.unit.storageKey,
              'dailyTargetMl': p.dailyTargetMl,
              'wakeMinute': p.wakeMinute,
              'sleepMinute': p.sleepMinute,
              'reminderMode': p.mode.name,
              'timezone': p.timezone,
            },
      'vessels': [
        for (final v in vs)
          {'id': v.id, 'name': v.name, 'volumeMl': v.volumeMl, 'icon': v.icon},
      ],
      'routines': [for (final r in rs) _routine(r)],
      'entries': [
        for (final e in entries)
          {
            'id': e.id,
            'date': e.localDate.toIso(),
            'timestampUtc': e.timestampUtc.toIso8601String(),
            'timezone': e.timezone,
            'volumeMl': e.volumeMl,
            'beverage': e.beverage.name,
            'vesselId': e.vesselId,
            'source': e.source.name,
            'externalRecordId': e.externalRecordId,
          },
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  Map<String, Object?> _routine(Routine r) => {
    'id': r.id,
    'name': r.name,
    'kind': r.kind.name,
    'weekdays': (r.weekdays.toList()..sort()),
    'wakeMinute': r.wakeMinute,
    'sleepMinute': r.sleepMinute,
    'mode': r.mode.name,
  };

  /// Writes the export to a temporary file and returns it.
  Future<File> writeFile({required bool csv}) async {
    final dir = await getTemporaryDirectory();
    final stamp = _now().toUtc().toIso8601String().substring(0, 10);
    final file = File(
      '${dir.path}/hydra-export-$stamp.${csv ? 'csv' : 'json'}',
    );
    await file.writeAsString(
      csv ? await buildCsv() : await buildJson(),
      flush: true,
    );
    return file;
  }

  /// Hands the file to the platform share sheet (save to Files, email, ...).
  Future<void> share({required bool csv}) async {
    final f = await writeFile(csv: csv);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(f.path)], subject: 'HYDRA data export'),
    );
  }

  /// Best-effort removal of the temporary export after sharing.
  Future<void> cleanup() async {
    final dir = await getTemporaryDirectory();
    for (final f in dir.listSync().whereType<File>()) {
      if (f.path.contains('hydra-export-')) {
        try {
          f.deleteSync();
        } catch (_) {}
      }
    }
  }
}
