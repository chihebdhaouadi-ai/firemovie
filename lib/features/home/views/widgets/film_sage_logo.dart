// film_sage_logo.dart
//
// Animated "FilmSage" wordmark for the top centre of the home page.
//
// Usage:
//   SafeArea(
//     child: Column(
//       children: [
//         const Padding(
//           padding: EdgeInsets.only(top: 12),
//           child: Center(child: FilmSageLogo()),
//         ),
//         // ...rest of the home page
//       ],
//     ),
//   )
//
// pubspec.yaml (bundle the font; do not fetch it at runtime):
//   flutter:
//     fonts:
//       - family: Poppins
//         fonts:
//           - asset: assets/fonts/Poppins-SemiBold.ttf
//             weight: 600
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Colours used by the wordmark. Move these into your theme tokens.
abstract final class _LogoTokens {
  static const Color film = Color(0xFFEEF3FF);
  static const Color sage = Color(0xFF5B9BFF);
  static const Color glow = Color(0xFF4D8BF0);
  static const Color gold = Color(0xFFF5C23A);
}

/// The animated FilmSage wordmark.
///
/// - Intro: the eight letters drop in one after another with a bounce.
/// - Idle: a shine sweeps across each letter in turn, the glow pulses, two
///   sparkles twinkle and a film-strip line scrolls under the name.
/// - Tap: replays the intro. A tap during the intro finishes it at once.
///
/// Reduced motion: with [MediaQueryData.disableAnimations] on, the finished
/// wordmark is shown still, with no shine, sparkles or scrolling strip.
/// The idle loop also stops while the app is in the background, and stops
/// when the route is not current because its tickers are muted by [TickerMode].
class FilmSageLogo extends StatefulWidget {
  /// Creates the wordmark.
  const FilmSageLogo({super.key});

  @override
  State<FilmSageLogo> createState() => _FilmSageLogoState();
}

class _FilmSageLogoState extends State<FilmSageLogo>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static const String _word = 'FilmSage';
  static const int _staggerMs = 70;
  static const int _dropMs = 700;

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: Duration(
      milliseconds: (_word.length - 1) * _staggerMs + _dropMs,
    ),
  );

  /// One curved animation per letter, each starting [_staggerMs] later.
  late final List<CurvedAnimation> _drops = List.generate(_word.length, (i) {
    final total = _intro.duration!.inMilliseconds;
    return CurvedAnimation(
      parent: _intro,
      curve: Interval(
        i * _staggerMs / total,
        (i * _staggerMs + _dropMs) / total,
        curve: const Cubic(0.3, 1.6, 0.5, 1),
      ),
    );
  });

  /// Seconds since the idle clock started; drives every looping effect.
  final ValueNotifier<double> _clock = ValueNotifier<double>(0);
  late final Ticker _ticker = createTicker(
    (elapsed) => _clock.value =
        elapsed.inMicroseconds / Duration.microsecondsPerSecond,
  );

  bool _foreground = true;
  bool _reduced = false;
  bool _introStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.disableAnimationsOf(context);
    if (_reduced) {
      _intro.value = 1; // end state, identical to the animated one
    } else if (!_introStarted) {
      _introStarted = true;
      _intro.forward(from: 0);
    }
    _syncTicker();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncTicker();
  }

  /// Runs the idle clock only when it is allowed to: foreground, motion on.
  void _syncTicker() {
    final shouldRun = _foreground && !_reduced;
    if (shouldRun && !_ticker.isActive) {
      _ticker.start();
    } else if (!shouldRun && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _replay() {
    if (_reduced) return;
    if (_intro.isAnimating) {
      _intro.value = 1; // a tap resolves a running animation to its end state
    } else {
      _intro.forward(from: 0);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    for (final drop in _drops) {
      drop.dispose();
    }
    _intro.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'FilmSage, replay animation',
      excludeSemantics: true,
      onTap: _replay,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _replay,
        child: RepaintBoundary(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < _word.length; i++)
                          _Letter(
                            char: _word[i],
                            index: i,
                            drop: _drops[i],
                            clock: _clock,
                            reduced: _reduced,
                            base: i < 4 ? _LogoTokens.film : _LogoTokens.sage,
                          ),
                      ],
                    ),
                    Positioned(
                      right: -12,
                      top: -5,
                      child: _Sparkle(
                        clock: _clock,
                        size: 11,
                        color: _LogoTokens.gold,
                        delaySeconds: 0,
                        hidden: _reduced,
                      ),
                    ),
                    Positioned(
                      left: 8,
                      bottom: -4,
                      child: _Sparkle(
                        clock: _clock,
                        size: 8,
                        color: Colors.white,
                        delaySeconds: 1.3,
                        hidden: _reduced,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                _FilmStrip(clock: _clock, reduced: _reduced),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Triangle wave 0 -> 1 -> 0 over one period, eased. [phase] is in periods.
double _wave(double phase) {
  final p = phase - phase.floorToDouble();
  return Curves.easeInOut.transform(1 - (2 * p - 1).abs());
}

/// One letter: drop-in, hard shadow, glow and a travelling shine.
class _Letter extends StatelessWidget {
  const _Letter({
    required this.char,
    required this.index,
    required this.drop,
    required this.clock,
    required this.reduced,
    required this.base,
  });

  final String char;
  final int index;
  final Animation<double> drop;
  final ValueListenable<double> clock;
  final bool reduced;
  final Color base;

  static const TextStyle _style = TextStyle(
    fontFamily: 'Inter',
    fontSize: 27,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.54,
    height: 1.15,
  );

  /// Shine position 0..1 across the letter; 0 means no highlight visible.
  /// Starts 1.2 s after the intro, staggered 0.1 s per letter, every 4.5 s.
  double _shine(double t) {
    final delay = 1.2 + index * 0.1;
    if (reduced || t < delay) return 0;
    final phase = ((t - delay) / 4.5) % 1;
    return phase < 0.3 ? Curves.easeInOut.transform(phase / 0.3) : 1;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([drop, clock]),
      builder: (context, _) {
        final t = clock.value;
        final v = reduced ? 1.0 : drop.value; // may overshoot 1 (the bounce)
        final shine = _shine(t);
        final glowAlpha = reduced ? 0.5 : 0.3 + 0.5 * _wave(t / 3.2);

        final glowPaint = Paint()
          ..color = _LogoTokens.glow.withAlpha((glowAlpha * 255).round())
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

        final body = Stack(
          children: [
            Text(char, style: _style.copyWith(foreground: glowPaint)),
            Transform.translate(
              offset: const Offset(0, 2),
              child: Text(
                char,
                style: _style.copyWith(color: const Color(0x8C000000)),
              ),
            ),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => LinearGradient(
                begin: const Alignment(-1, -0.3),
                end: const Alignment(1, 0.3),
                colors: [base, base, Colors.white, base, base],
                stops: const [0, 0.42, 0.5, 0.58, 1],
              ).createShader(
                Rect.fromLTWH(
                  bounds.left - 2 * bounds.width * shine,
                  bounds.top,
                  3 * bounds.width,
                  bounds.height,
                ),
              ),
              child: Text(
                char,
                style: _style.copyWith(color: Colors.white),
              ),
            ),
          ],
        );

        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, -24 * (1 - v)),
            child: Transform.rotate(
              angle: -14 * math.pi / 180 * (1 - v),
              child: Transform.scale(scale: 0.5 + 0.5 * v, child: body),
            ),
          ),
        );
      },
    );
  }
}

/// A four-point sparkle that fades, scales and turns every 2.8 s.
class _Sparkle extends StatelessWidget {
  const _Sparkle({
    required this.clock,
    required this.size,
    required this.color,
    required this.delaySeconds,
    required this.hidden,
  });

  final ValueListenable<double> clock;
  final double size;
  final Color color;
  final double delaySeconds;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    if (hidden) return SizedBox.square(dimension: size); // flourish omitted
    return ValueListenableBuilder<double>(
      valueListenable: clock,
      builder: (context, t, _) {
        final v = t < delaySeconds ? 0.0 : _wave((t - delaySeconds) / 2.8);
        return Opacity(
          opacity: v,
          child: Transform.rotate(
            angle: v * math.pi / 4,
            child: Transform.scale(
              scale: 0.3 + 0.9 * v,
              child: CustomPaint(
                size: Size.square(size),
                painter: _StarPainter(color),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StarPainter extends CustomPainter {
  const _StarPainter(this.color);

  final Color color;

  static const List<Offset> _points = [
    Offset(50, 0), Offset(62, 38), Offset(100, 50), Offset(62, 62),
    Offset(50, 100), Offset(38, 62), Offset(0, 50), Offset(38, 38),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addPolygon(
        [for (final p in _points) Offset(p.dx * size.width / 100, p.dy * size.height / 100)],
        true,
      );
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.color != color;
}

/// The scrolling film-strip line under the name, faded at both ends.
class _FilmStrip extends StatelessWidget {
  const _FilmStrip({required this.clock, required this.reduced});

  final ValueListenable<double> clock;
  final bool reduced;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 6,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => const LinearGradient(
          colors: [
            Color(0x00FFFFFF),
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF),
            Color(0x00FFFFFF),
          ],
          stops: [0, 0.25, 0.75, 1],
        ).createShader(rect),
        child: ValueListenableBuilder<double>(
          valueListenable: clock,
          builder: (context, t, _) => CustomPaint(
            painter: _StripPainter(reduced ? 0 : (t / 1.4 % 1) * 14),
          ),
        ),
      ),
    );
  }
}

class _StripPainter extends CustomPainter {
  const _StripPainter(this.offset);

  final double offset;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    final paint = Paint()..color = const Color(0xCC4D8BF0);
    for (var x = offset - 14; x < size.width; x += 14) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 8, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_StripPainter old) => old.offset != offset;
}
