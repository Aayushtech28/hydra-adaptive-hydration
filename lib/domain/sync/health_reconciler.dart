import '../models/entities.dart';
import '../models/enums.dart';

/// A hydration sample read from HealthKit / Health Connect.
class ExternalHydration {
  const ExternalHydration({
    required this.id,
    required this.at,
    required this.ml,
    this.writtenByHydra = false,
  });

  final String id;
  final DateTime at;
  final int ml;

  /// True when the record's source app is HYDRA itself.
  final bool writtenByHydra;
}

enum SyncDirection { importOnly, exportOnly, twoWay }

class SyncPlan {
  const SyncPlan({
    required this.toImport,
    required this.toLink,
    required this.toExport,
    required this.toRemoveLocal,
    required this.duplicatesSkipped,
  });

  final List<ExternalHydration> toImport;

  /// Local entry id → external record id (matched, not re-imported).
  final Map<String, String> toLink;
  final List<HydrationEntry> toExport;

  /// Local entry ids originally imported from health whose external record
  /// no longer exists in the queried window (deleted in Health).
  final List<String> toRemoveLocal;
  final int duplicatesSkipped;
}

/// Pure reconciliation of local entries and external health samples.
///
/// Guarantees (tested): a HYDRA entry and its corresponding external record
/// never both count; a record the user deleted is never resurrected;
/// repeated syncs are idempotent.
abstract final class HealthReconciler {
  static const Duration matchTolerance = Duration(minutes: 2);

  static SyncPlan plan({
    required EntrySource platform,
    required List<HydrationEntry> local,
    required List<ExternalHydration> external,
    required Set<String> tombstones,
    required SyncDirection direction,
    required DateTime windowStart,
    required DateTime windowEnd,
  }) {
    final knownIds = <String>{
      for (final e in local)
        if (e.externalRecordId != null) e.externalRecordId!,
    };
    final claimedLocal = <String>{};
    final toImport = <ExternalHydration>[];
    final toLink = <String, String>{};
    var dups = 0;

    final canImport = direction != SyncDirection.exportOnly;
    final canExport = direction != SyncDirection.importOnly;

    for (final x in external) {
      if (knownIds.contains(x.id)) {
        dups++;
        continue;
      }
      if (tombstones.contains(x.id)) {
        dups++;
        continue;
      }
      // Look for a HYDRA-originated local entry representing the same drink.
      final match = local.where((e) {
        if (e.externalRecordId != null || e.source.isExternal) return false;
        if (claimedLocal.contains(e.id)) return false;
        return e.volumeMl == x.ml &&
            e.timestampUtc.difference(x.at).abs() <= matchTolerance;
      }).firstOrNull;
      if (match != null) {
        toLink[match.id] = x.id;
        claimedLocal.add(match.id);
        dups++;
        continue;
      }
      if (x.writtenByHydra) {
        // We wrote it but no longer have the local entry (e.g. deleted
        // locally with data deletion): never re-import our own output.
        dups++;
        continue;
      }
      if (canImport) toImport.add(x);
    }

    final toExport = canExport
        ? local
              .where(
                (e) =>
                    e.externalRecordId == null &&
                    !e.source.isExternal &&
                    !claimedLocal.contains(e.id),
              )
              .toList()
        : <HydrationEntry>[];

    final externalIds = {for (final x in external) x.id};
    final toRemove = <String>[];
    if (canImport) {
      for (final e in local) {
        if (e.source != platform || e.externalRecordId == null) continue;
        final inWindow =
            !e.timestampUtc.isBefore(windowStart) &&
            !e.timestampUtc.isAfter(windowEnd);
        if (inWindow && !externalIds.contains(e.externalRecordId)) {
          toRemove.add(e.id);
        }
      }
    }

    return SyncPlan(
      toImport: toImport,
      toLink: toLink,
      toExport: toExport,
      toRemoveLocal: toRemove,
      duplicatesSkipped: dups,
    );
  }
}
