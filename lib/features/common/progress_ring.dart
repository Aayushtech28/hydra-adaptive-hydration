import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// Today's progress: a ring with a gently moving water level inside.
/// Motion is subtle and fully disabled under reduced-motion settings; the
/// semantics label carries the same information for screen readers.
class ProgressRing extends StatefulWidget {
  const ProgressRing({
    super.key,
    required this.fraction,
    required this.centerTop,
    required this.centerBottom,
    required this.semanticsLabel,
    this.pulse = 0,
    this.size = 260,
  });

  /// 0–1 (values above 1 clamp visually).
  final double fraction;
  final String centerTop;
  final String centerBottom;
  final String semanticsLabel;

  /// Increment to trigger a ripple after a log has already been persisted.
  final int pulse;
  final double size;

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with TickerProviderStateMixin {
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );
  late final AnimationController _ripple = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final AnimationController _level = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late Animation<double> _levelAnim = AlwaysStoppedAnimation(
    widget.fraction.clamp(0, 1),
  );
  double _shown = 0;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _shown = widget.fraction.clamp(0.0, 1.0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = context.reduceMotion;
    if (!reduce && !_started) {
      _wave.repeat();
      _started = true;
    } else if (reduce && _started) {
      _wave.stop();
      _started = false;
    }
  }

  @override
  void didUpdateWidget(ProgressRing old) {
    super.didUpdateWidget(old);
    final target = widget.fraction.clamp(0.0, 1.0);
    if (target != _shown) {
      if (context.reduceMotion) {
        _levelAnim = AlwaysStoppedAnimation(target);
        _shown = target;
      } else {
        _levelAnim = Tween<double>(
          begin: _shown,
          end: target,
        ).animate(CurvedAnimation(parent: _level, curve: Curves.easeOutCubic));
        _shown = target;
        _level
          ..reset()
          ..forward();
      }
    }
    if (widget.pulse != old.pulse && !context.reduceMotion) {
      _ripple
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _wave.dispose();
    _ripple.dispose();
    _level.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.hx;
    return Semantics(
      label: widget.semanticsLabel,
      container: true,
      excludeSemantics: true,
      child: RepaintBoundary(
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: Listenable.merge([_wave, _ripple, _level]),
            builder: (context, _) => CustomPaint(
              painter: _RingPainter(
                level: _levelAnim.value,
                wave: _wave.value,
                ripple: _ripple.value,
                tokens: t,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.centerTop,
                      style: context.text.displayMedium?.copyWith(
                        color: _levelAnim.value > 0.52 ? Colors.white : t.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.centerBottom,
                      style: context.text.bodyMedium?.copyWith(
                        color: _levelAnim.value > 0.40
                            ? Colors.white.withValues(alpha: 0.92)
                            : t.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.level,
    required this.wave,
    required this.ripple,
    required this.tokens,
  });

  final double level;
  final double wave;
  final double ripple;
  final HydraTokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final stroke = size.width * 0.055;
    final outer = size.width / 2 - stroke / 2;
    final inner = outer - stroke * 1.2;

    // Track
    canvas.drawCircle(
      c,
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = tokens.hairline,
    );

    // Progress arc
    if (level > 0) {
      final rect = Rect.fromCircle(center: c, radius: outer);
      final sweep = 2 * math.pi * level.clamp(0.0, 1.0);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = stroke
          ..shader = SweepGradient(
            startAngle: -math.pi / 2,
            endAngle: -math.pi / 2 + 2 * math.pi,
            colors: [tokens.waterBottom, tokens.waterTop, tokens.waterBottom],
            transform: const GradientRotation(0),
          ).createShader(rect),
      );
    }

    // Water body clipped to inner circle
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: inner)));
    canvas.drawCircle(c, inner, Paint()..color = tokens.surface);
    final top = c.dy + inner - (2 * inner * level.clamp(0.0, 1.0));
    if (level > 0.0) {
      final amp = size.width * 0.012 * (level < 0.97 ? 1 : 0.2);
      Path wavePath(double phase) {
        final p = Path()..moveTo(c.dx - inner, c.dy + inner);
        p.lineTo(c.dx - inner, top);
        for (double x = 0; x <= 2 * inner; x += 4) {
          final y =
              top +
              math.sin((x / (2 * inner)) * 2 * math.pi * 1.4 + phase) * amp;
          p.lineTo(c.dx - inner + x, y);
        }
        p.lineTo(c.dx + inner, c.dy + inner);
        p.close();
        return p;
      }

      final shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [tokens.waterTop, tokens.waterBottom],
      ).createShader(Rect.fromCircle(center: c, radius: inner));
      canvas.drawPath(
        wavePath(wave * 2 * math.pi + 1.2),
        Paint()..color = tokens.waterTop.withValues(alpha: 0.45),
      );
      canvas.drawPath(wavePath(wave * 2 * math.pi), Paint()..shader = shader);
    }
    canvas.restore();

    // Ripple after logging
    if (ripple > 0 && ripple < 1) {
      canvas.drawCircle(
        c,
        inner * (0.55 + 0.45 * ripple),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = tokens.waterTop.withValues(alpha: (1 - ripple) * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter o) =>
      o.level != level ||
      o.wave != wave ||
      o.ripple != ripple ||
      o.tokens != tokens;
}
