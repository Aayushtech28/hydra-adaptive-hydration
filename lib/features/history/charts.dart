import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../../domain/hre/types.dart';
import '../../domain/models/entities.dart';

/// Plan curve vs cumulative actual intake for one day. Drawn with CustomPaint;
/// the surrounding widget supplies a text summary for screen readers.
class TrajectoryChart extends StatelessWidget {
  const TrajectoryChart({
    super.key,
    required this.trajectory,
    required this.entries,
    required this.semanticsLabel,
    this.now,
  });

  final PlanTrajectory trajectory;
  final List<HydrationEntry> entries;
  final String semanticsLabel;

  /// When set (today), the actual line stops here instead of at plan end.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final t = context.hx;
    return Semantics(
      label: semanticsLabel,
      image: true,
      child: ExcludeSemantics(
        child: SizedBox(
          height: 150,
          width: double.infinity,
          child: CustomPaint(
            painter: _TrajectoryPainter(trajectory, entries, t, now),
          ),
        ),
      ),
    );
  }
}

class _TrajectoryPainter extends CustomPainter {
  _TrajectoryPainter(this.traj, this.entries, this.t, this.now);
  final PlanTrajectory traj;
  final List<HydrationEntry> entries;
  final HydraTokens t;
  final DateTime? now;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 4.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;
    final start = traj.window.wake;
    final totalSecs = math.max(
      1,
      traj.window.sleep.difference(start).inSeconds,
    );
    final maxMl = math.max(
      traj.targetMl.toDouble(),
      entries.fold<int>(0, (s, e) => s + e.volumeMl).toDouble(),
    );
    Offset pt(DateTime time, double ml) {
      final x = (time.difference(start).inSeconds / totalSecs).clamp(0.0, 1.0);
      return Offset(pad + x * w, pad + h - (ml / maxMl).clamp(0.0, 1.0) * h);
    }

    // grid
    final grid = Paint()
      ..color = t.hairline
      ..strokeWidth = 1;
    for (final f in [0.0, 0.5, 1.0]) {
      final y = pad + h - f * h;
      canvas.drawLine(Offset(pad, y), Offset(pad + w, y), grid);
    }

    // plan
    final plan = Path();
    for (var i = 0; i <= 48; i++) {
      final time = start.add(Duration(seconds: (totalSecs * i / 48).round()));
      final p = pt(time, traj.expectedMlAt(time));
      if (i == 0) {
        plan.moveTo(p.dx, p.dy);
      } else {
        plan.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      plan,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = t.inkMuted.withValues(alpha: 0.6),
    );

    // actual (step line)
    final sorted = [...entries]
      ..sort((a, b) => a.timestampUtc.compareTo(b.timestampUtc));
    final endT = now ?? traj.window.sleep;
    final actual = Path()..moveTo(pt(start, 0).dx, pt(start, 0).dy);
    var cum = 0.0;
    for (final e in sorted) {
      final before = pt(e.timestampUtc, cum);
      actual.lineTo(before.dx, before.dy);
      cum += e.volumeMl;
      final after = pt(e.timestampUtc, cum);
      actual.lineTo(after.dx, after.dy);
    }
    final tail = pt(endT, cum);
    actual.lineTo(tail.dx, tail.dy);
    canvas.drawPath(
      actual,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..color = t.accent,
    );
    var running = 0.0;
    for (final e in sorted) {
      running += e.volumeMl;
      canvas.drawCircle(
        pt(e.timestampUtc, running),
        3.5,
        Paint()..color = t.accent,
      );
    }
  }

  @override
  bool shouldRepaint(_TrajectoryPainter old) =>
      old.entries != entries ||
      old.traj != traj ||
      old.t != t ||
      old.now != now;
}

/// A horizontal progress bar with an accessible text value.
class MeterBar extends StatelessWidget {
  const MeterBar({
    super.key,
    required this.fraction,
    this.height = 10,
    this.color,
  });
  final double fraction;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = context.hx;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: fraction.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: t.surfaceRaised,
        color: color ?? t.accent,
      ),
    );
  }
}
