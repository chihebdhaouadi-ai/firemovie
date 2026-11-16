import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../film_reviews/domain/take.dart';
import '../../../film_reviews/domain/vote_kind.dart';

const _emberFloor = 0.1;
const _maxReach = 16.0;
const _heatCurveScale = 8.0;
const _samples = 96;
const _changeDuration = Duration(milliseconds: 1000);
const _flickerDuration = Duration(milliseconds: 2400);
const _emberColor = Color(0xFFFF8A3D);

int _weightOf(VoteKind kind) => switch (kind) {
      VoteKind.changedMyMind => 3,
      VoteKind.wellArgued => 2,
      VoteKind.disagreeButFair => 1,
    };

Color _colorOf(VoteKind kind) => switch (kind) {
      VoteKind.changedMyMind => const Color(0xFF4ADE80),
      VoteKind.wellArgued => const Color(0xFFFFC53D),
      VoteKind.disagreeButFair => const Color(0xFF4DA3FF),
    };

double fireHeatFor(Take take) {
  var score = 0;
  for (final kind in VoteKind.values) {
    score += take.votesOf(kind) * _weightOf(kind);
  }
  return 1 - math.exp(-score / _heatCurveScale);
}

Color fireColorFor(Take take) {
  VoteKind? leader;
  var leadCount = 0;
  for (final kind in VoteKind.values) {
    final count = take.votesOf(kind);
    if (count > leadCount) {
      leader = kind;
      leadCount = count;
    }
  }
  return leader == null ? _emberColor : _colorOf(leader);
}

class ReactiveFireBorder extends StatefulWidget {
  const ReactiveFireBorder({
    super.key,
    required this.take,
    required this.radius,
    required this.child,
  });

  final Take take;
  final double radius;
  final Widget child;

  @override
  State<ReactiveFireBorder> createState() => _ReactiveFireBorderState();
}

class _ReactiveFireBorderState extends State<ReactiveFireBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flicker = AnimationController(
    vsync: this,
    duration: _flickerDuration,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _flicker.stop();
    } else if (!_flicker.isAnimating) {
      _flicker.repeat();
    }
  }

  @override
  void dispose() {
    _flicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heat = fireHeatFor(widget.take);
    final color = fireColorFor(widget.take);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: heat),
      duration: _changeDuration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedHeat, _) => TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: color),
        duration: _changeDuration,
        builder: (context, animatedColor, _) => CustomPaint(
          painter: _FirePainter(
            flicker: _flicker,
            heat: animatedHeat,
            color: animatedColor ?? color,
            radius: widget.radius,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _FirePainter extends CustomPainter {
  _FirePainter({
    required this.flicker,
    required this.heat,
    required this.color,
    required this.radius,
  }) : super(repaint: flicker);

  final Animation<double> flicker;
  final double heat;
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final level = math.max(heat, _emberFloor);
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final outline = Path()..addRRect(rrect);
    final metric = outline.computeMetrics().first;
    final flames = Path();
    final phase = flicker.value;

    for (var i = 0; i < _samples; i++) {
      final tangent = metric.getTangentForOffset(
        metric.length * i / _samples,
      );
      if (tangent == null) continue;
      final normal = Offset(tangent.vector.dy, -tangent.vector.dx);
      final reach = _maxReach * level * _tongue(i, phase);
      final tip = tangent.position + normal * reach;
      if (i == 0) {
        flames.moveTo(tip.dx, tip.dy);
      } else {
        flames.lineTo(tip.dx, tip.dy);
      }
    }
    flames.close();

    canvas.drawPath(
      flames,
      Paint()
        ..color = color.withValues(alpha: 0.12 + 0.45 * level)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 + 6 * level),
    );
    canvas.drawPath(
      flames,
      Paint()
        ..color = color.withValues(alpha: 0.3 + 0.6 * level)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  double _tongue(int index, double phase) {
    final a = math.sin(index * 0.61 + phase * math.pi * 4);
    final b = math.sin(index * 1.37 - phase * math.pi * 6);
    final c = math.sin(index * 2.91 + phase * math.pi * 10);
    final wave = (a + b + c) / 3;
    return 0.35 + 0.65 * (wave + 1) / 2;
  }

  @override
  bool shouldRepaint(_FirePainter oldDelegate) =>
      oldDelegate.heat != heat ||
      oldDelegate.color != color ||
      oldDelegate.radius != radius;
}
