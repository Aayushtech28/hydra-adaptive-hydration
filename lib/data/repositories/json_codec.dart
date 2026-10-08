import 'dart:convert';

/// Defensive JSON helpers: malformed stored data degrades to defaults and is
/// never fatal.
List<int> decodeIntList(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  try {
    final v = jsonDecode(raw);
    if (v is List) return v.whereType<num>().map((e) => e.toInt()).toList();
  } catch (_) {}
  return const [];
}

List<Map<String, Object?>> decodeMapList(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  try {
    final v = jsonDecode(raw);
    if (v is List) {
      return v
          .whereType<Map<dynamic, dynamic>>()
          .map((m) => m.cast<String, Object?>())
          .toList();
    }
  } catch (_) {}
  return const [];
}

Map<String, Object?> decodeMap(String? raw) {
  if (raw == null || raw.isEmpty) return const {};
  try {
    final v = jsonDecode(raw);
    if (v is Map) return v.cast<String, Object?>();
  } catch (_) {}
  return const {};
}
