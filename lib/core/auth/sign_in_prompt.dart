import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n_context.dart';
import '../theme/app_theme.dart';
import 'auth_gate.dart';

/// Shown in place of account-only content for guests. The button opens login
/// through [requireAuth]. Signing in rebuilds the parent, which then loads the
/// real content.
class SignInPrompt extends StatefulWidget {
  const SignInPrompt({
    super.key,
    required this.title,
    required this.reason,
    this.body,
  });

  final String title;

  /// Context line for the login page, for example "Log in to see your films".
  final String reason;
  final String? body;

  @override
  State<SignInPrompt> createState() => _SignInPromptState();
}

class _SignInPromptState extends State<SignInPrompt>
    with SingleTickerProviderStateMixin {
  static Color get _surface =>
      themed(const Color(0xFF1B1C21), const Color(0xFFE9E4DA));
  static const _hot = Color(0xFFFF3D2E);
  static Color get _edge =>
      themed(const Color(0xFF4A2420), const Color(0xFFD9B8AE));

  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  );
  late final _SignInParticles _particles = _SignInParticles.generate();
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      _animation
        ..stop()
        ..value = .25;
    } else if (!_animation.isAnimating) {
      _animation.repeat();
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final body = widget.body;

    final content = Stack(
      children: [
        Positioned.fill(
          child: ExcludeSemantics(
            child: CustomPaint(
              painter: _SignInCardPainter(
                animation: _animation,
                particles: _particles,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
                colors: [
                  themed(const Color(0xC71B1C21), const Color(0xD9E9E4DA)),
                  themed(const Color(0x591B1C21), const Color(0x73E9E4DA)),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            tokens.spaceLg,
            tokens.spaceLg + 6,
            tokens.spaceLg,
            tokens.spaceLg + 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text(
                  widget.title,
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (body != null) ...[
                SizedBox(height: tokens.spaceSm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Text(
                    body,
                    style: textTheme.bodyMedium?.copyWith(
                      color: themed(
                          const Color(0xFFC9CBD6), const Color(0xFF36322B)),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
              SizedBox(height: tokens.spaceLg),
              _SignInPromptButton(
                label: l10n.authSignIn,
                animation: _animation,
                nudging: !_reduceMotion,
                onPressed: () => requireAuth(
                  context,
                  reason: widget.reason,
                  startOnSignUp: true,
                  action: () async {},
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        child: content,
        builder: (context, child) {
          final t = _animation.value;
          final heartbeat = _heartbeat(t);
          final shake = _reduceMotion ? 0.0 : _shake(t);
          final glow = _reduceMotion ? 0.0 : heartbeat;
          return Transform.translate(
            offset: Offset(shake * 4, 0),
            child: Transform.rotate(
              angle: shake * .006,
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: _edge),
                  boxShadow: [
                    BoxShadow(
                      color: _hot.withValues(alpha: .1 + .3 * glow),
                      blurRadius: 8 + 36 * glow,
                      spreadRadius: 4 * glow,
                    ),
                    BoxShadow(
                      color: themed(
                          const Color(0xFF10141D), const Color(0x40000000)),
                      offset: Offset(0, 5),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .35),
                      offset: const Offset(0, 9),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SignInPromptButton extends StatefulWidget {
  const _SignInPromptButton({
    required this.label,
    required this.animation,
    required this.nudging,
    required this.onPressed,
  });

  final String label;
  final Animation<double> animation;
  final bool nudging;
  final VoidCallback onPressed;

  @override
  State<_SignInPromptButton> createState() => _SignInPromptButtonState();
}

class _SignInPromptButtonState extends State<_SignInPromptButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) => Transform.scale(
        scale: 1 + (widget.nudging ? .05 * _nudge(widget.animation.value) : 0),
        child: child,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: widget.onPressed,
          onHighlightChanged: (down) => setState(() => _down = down),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            transform: Matrix4.translationValues(0, _down ? 5 : 0, 0),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  themed(const Color(0xFF4F7BE8), const Color(0xFF34302A)),
                  themed(const Color(0xFF2B49A8), const Color(0xFF0B0A08)),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      themed(const Color(0xFF1B2F78), const Color(0xFF000000)),
                  offset: Offset(0, _down ? 1 : 6),
                ),
                BoxShadow(
                  color: const Color(0x73000000),
                  blurRadius: _down ? 10 : 22,
                  offset: Offset(0, _down ? 4 : 12),
                ),
              ],
            ),
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef _Ember = ({double x, double phase, double size, double sway});

class _SignInParticles {
  const _SignInParticles(this.embers);

  final List<_Ember> embers;

  factory _SignInParticles.generate() {
    final random = math.Random(7);
    double between(double min, double max) =>
        min + random.nextDouble() * (max - min);
    return _SignInParticles(
      List.generate(
        16,
        (_) => (
          x: between(.04, .96),
          phase: between(0, 1),
          size: between(1.5, 3.5),
          sway: between(-.05, .05),
        ),
      ),
    );
  }
}

class _SignInCardPainter extends CustomPainter {
  _SignInCardPainter({
    required this.animation,
    required this.particles,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final _SignInParticles particles;

  final Paint _blob = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
  final Paint _fill = Paint();
  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Size? _cachedSize;
  late Path _crack1;
  late Path _crack2;

  void _ensureGeometry(Size size) {
    if (_cachedSize == size) return;
    _cachedSize = size;

    Path polygon(List<Offset> points) {
      final path = Path()
        ..moveTo(points.first.dx * size.width, points.first.dy * size.height);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx * size.width, point.dy * size.height);
      }
      return path;
    }

    _crack1 = polygon(const [
      Offset(.63, 0),
      Offset(.6, .2),
      Offset(.65, .25),
      Offset(.58, .49),
      Offset(.63, .53),
      Offset(.56, .8),
    ]);
    _crack2 = polygon(const [
      Offset(.9, 0),
      Offset(.93, .23),
      Offset(.88, .28),
      Offset(.95, .54),
      Offset(.9, .58),
    ]);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _ensureGeometry(size);
    final t = animation.value;
    final phase = t * 2 * math.pi * 3;

    _blob.color = const Color(0xFFFF3D2E).withValues(alpha: .55);
    canvas.drawCircle(
      Offset(
        size.width * .78 + math.sin(phase) * size.width * .12,
        size.height * .27 + math.cos(phase) * size.height * .16,
      ),
      size.width * .15,
      _blob,
    );
    _blob.color = const Color(0xFFFF9A3C).withValues(alpha: .5);
    canvas.drawCircle(
      Offset(
        size.width * .9 + math.cos(phase + 1.3) * size.width * .1,
        size.height * .8 + math.sin(phase + 1.3) * size.height * .2,
      ),
      size.width * .13,
      _blob,
    );
    _blob.color = const Color(0xFFFF3D2E).withValues(alpha: .4);
    canvas.drawCircle(
      Offset(
        size.width * .17 + math.sin(phase + 2.1) * size.width * .1,
        size.height * .95 + math.cos(phase + 2.1) * size.height * .12,
      ),
      size.width * .13,
      _blob,
    );

    for (final ember in particles.embers) {
      final progress = (t * 3 + ember.phase) % 1;
      _fill.color = const Color(0xFFFF9A3C).withValues(
        alpha: math.sin(progress * math.pi) * .9,
      );
      canvas.drawCircle(
        Offset(
          size.width * (ember.x + ember.sway * progress),
          size.height + 6 - progress * size.height * .95,
        ),
        ember.size * (1 - progress * .7),
        _fill,
      );
    }

    _drawCrack(canvas, _crack1, _flash((t * 2) % 1));
    _drawCrack(canvas, _crack2, _flash((t * 2 + .5) % 1));
  }

  void _drawCrack(Canvas canvas, Path path, double alpha) {
    if (alpha < .01) return;
    _stroke
      ..strokeWidth = 7
      ..color = const Color(0xFFFFB347).withValues(alpha: alpha * .3);
    canvas.drawPath(path, _stroke);
    _stroke
      ..strokeWidth = 2.2
      ..color = const Color(0xFFFFE0A0).withValues(alpha: alpha);
    canvas.drawPath(path, _stroke);
  }

  @override
  bool shouldRepaint(_SignInCardPainter oldDelegate) =>
      oldDelegate.particles != particles;
}

double _heartbeat(double t) {
  final phase = (t * 6) % 1;
  double bump(double center, double width) =>
      math.exp(-math.pow((phase - center) / width, 2).toDouble());
  return math.max(bump(.08, .05), .7 * bump(.28, .06));
}

double _shake(double t) {
  final phase = (t * 2) % 1;
  if (phase < .86 || phase > .97) return 0;
  final progress = (phase - .86) / .11;
  return math.sin(progress * 2 * math.pi * 5.5) * (1 - progress);
}

double _flash(double phase) {
  if (phase < .84 || phase >= .94) return 0;
  if (phase < .86) return (phase - .84) / .02;
  if (phase < .88) return .15;
  if (phase < .91) return .9;
  return (.94 - phase) / .03 * .9;
}

double _nudge(double t) {
  final phase = (t * 2) % 1;
  if (phase < .74 || phase > .86) return 0;
  return math.sin((phase - .74) / .12 * 2 * math.pi).abs();
}
