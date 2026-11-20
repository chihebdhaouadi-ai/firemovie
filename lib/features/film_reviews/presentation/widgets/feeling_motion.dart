import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/widgets/luxe_palette.dart';
import '../../domain/film_reaction.dart';
import '../../domain/movie_review_summary.dart';
import '../reaction_labels.dart';
import '../../../../core/l10n_context.dart';

/// Animation pace: 1 is brisk, 1.7 is the calmer pace of the design.
const _pace = 1.7;

Duration _paced(int milliseconds) =>
    Duration(milliseconds: (milliseconds * _pace).round());

/// A feeling's icon. Painted in the feeling's gradient unless [color] is
/// given. When [animate] is true it loops a small motion of its own (a heart
/// beat, a falling tear, a tilting trophy…), unless the platform asks for
/// reduced motion.
class FeelingIcon extends StatefulWidget {
  const FeelingIcon({
    super.key,
    required this.feeling,
    this.size = 24,
    this.animate = false,
    this.color,
  });

  final FilmReaction feeling;
  final double size;
  final bool animate;
  final Color? color;

  @override
  State<FeelingIcon> createState() => _FeelingIconState();
}

class _FeelingIconState extends State<FeelingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _loopFor(widget.feeling),
  );

  static Duration _loopFor(FilmReaction feeling) => switch (feeling) {
        FilmReaction.loved => _paced(1200),
        FilmReaction.brokeHeart => _paced(1800),
        FilmReaction.madeCry => _paced(1800),
        FilmReaction.blewMind => _paced(1600),
        FilmReaction.madeThink => _paced(1800),
        FilmReaction.masterpiece => _paced(2200),
        FilmReaction.shocked => _paced(1400),
        FilmReaction.madeLaugh => _paced(1000),
        FilmReaction.bored => _paced(2600),
        FilmReaction.disappointed => _paced(2200),
      };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(FeelingIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.feeling != widget.feeling) {
      _controller.duration = _loopFor(widget.feeling);
    }
    _sync();
  }

  void _sync() {
    final run = widget.animate && !MediaQuery.disableAnimationsOf(context);
    if (run && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!run && (_controller.isAnimating || _controller.value != 0)) {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (icon, _) = reactionLook(widget.feeling);
    final (light, _) = reactionColors(widget.feeling);
    final color = widget.color;

    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final glow = widget.feeling == FilmReaction.madeThink && t > 0
              ? 0.5 - 0.5 * math.cos(2 * math.pi * t)
              : 0.0;
          Widget glyph = Icon(
            icon,
            size: widget.size,
            color: color ?? Colors.white,
            shadows: glow == 0
                ? null
                : [
                    Shadow(
                      color: light.withValues(alpha: .95 * glow),
                      blurRadius: 10 * glow,
                    ),
                  ],
          );
          if (color == null) {
            glyph = ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: reactionGradient(widget.feeling).createShader,
              child: glyph,
            );
          }
          return _move(widget.feeling, t, widget.size, glyph);
        },
      ),
    );
  }
}

/// One loop of a feeling's motion at progress [t] (0..1).
Widget _move(FilmReaction feeling, double t, double size, Widget child) {
  if (t == 0) return child;
  final wave = math.sin(2 * math.pi * t);
  final swell = 0.5 - 0.5 * math.cos(2 * math.pi * t);
  final unit = size / 48;

  switch (feeling) {
    case FilmReaction.loved:
      // Double beat: up, down, smaller up, rest.
      final scale = t < .15
          ? 1 + .18 * (t / .15)
          : t < .3
              ? 1.18 - .18 * ((t - .15) / .15)
              : t < .45
                  ? 1 + .12 * ((t - .3) / .15)
                  : t < .6
                      ? 1.12 - .12 * ((t - .45) / .15)
                      : 1.0;
      return Transform.scale(scale: scale, child: child);
    case FilmReaction.brokeHeart:
      return Transform.translate(
        offset: Offset(0, unit * swell),
        child: Transform.rotate(angle: wave * 7 * math.pi / 180, child: child),
      );
    case FilmReaction.madeCry:
      // The drop falls and fades, then forms again at the top.
      final y = t < .25
          ? -6 + 6 * (t / .25)
          : t < .75
              ? 4 * ((t - .25) / .5)
              : 4 + 5 * ((t - .75) / .25);
      final opacity = t < .25
          ? t / .25
          : t < .75
              ? 1.0
              : 1 - (t - .75) / .25;
      return Opacity(
        opacity: opacity.clamp(0, 1),
        child: Transform.translate(offset: Offset(0, y * unit), child: child),
      );
    case FilmReaction.blewMind:
      return Transform.rotate(
        angle: swell * math.pi / 4,
        child: Transform.scale(scale: .75 + .35 * swell, child: child),
      );
    case FilmReaction.madeThink:
      return Transform.scale(scale: 1 + .04 * swell, child: child);
    case FilmReaction.masterpiece:
      return Transform.rotate(
        alignment: Alignment.bottomCenter,
        angle: (swell * 12 - 6) * math.pi / 180,
        child: Transform.scale(scale: 1 + .06 * swell, child: child),
      );
    case FilmReaction.shocked:
      final shake = t < .35 ? math.sin(t / .35 * 6 * math.pi) * 2 * unit : 0.0;
      return Transform.translate(offset: Offset(shake, 0), child: child);
    case FilmReaction.madeLaugh:
      return Transform.translate(
        offset: Offset(0, -wave.abs() * 3 * unit),
        child: child,
      );
    case FilmReaction.bored:
      return Opacity(
        opacity: 1 - .35 * swell,
        child: Transform.rotate(angle: wave * .12, child: child),
      );
    case FilmReaction.disappointed:
      return Transform.translate(
        offset: Offset(0, 2.5 * unit * swell),
        child: child,
      );
  }
}

/// A big square tile for the feelings sheet: icon over label. Picked tiles
/// fill with the feeling's gradient, glow, animate their icon and throw a
/// little burst of dots when first picked.
class FeelingTile extends StatefulWidget {
  const FeelingTile({
    super.key,
    required this.feeling,
    required this.selected,
    required this.onTap,
    this.dimmed = false,
  });

  final FilmReaction feeling;
  final bool selected;
  final bool dimmed;
  final VoidCallback? onTap;

  @override
  State<FeelingTile> createState() => _FeelingTileState();
}

class _FeelingTileState extends State<FeelingTile>
    with SingleTickerProviderStateMixin {
  static const _radius = BorderRadius.all(Radius.circular(22));

  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  @override
  void didUpdateWidget(FeelingTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected &&
        !oldWidget.selected &&
        !MediaQuery.disableAnimationsOf(context)) {
      _burst.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feeling = widget.feeling;
    final selected = widget.selected;
    final (light, deep) = reactionColors(feeling);
    final label = reactionLabel(context.l10n, feeling);

    return Semantics(
      button: true,
      selected: selected,
      enabled: widget.onTap != null,
      label: label,
      excludeSemantics: true,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: widget.dimmed && !selected ? .45 : 1,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 108),
              decoration: BoxDecoration(
                color: selected ? null : LuxeColors.surface2,
                gradient: selected ? reactionGradient(feeling) : null,
                borderRadius: _radius,
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: deep.withValues(alpha: .35),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: _radius,
                  onTap: widget.onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 14,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: selected ? 1 : .6,
                          child: FeelingIcon(
                            feeling: feeling,
                            size: 44,
                            animate: selected,
                            color: selected ? Colors.white : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selected ? Colors.white : LuxeColors.text,
                            fontSize: 15,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _burst,
                  builder: (context, _) => _burst.isAnimating
                      ? CustomPaint(
                          painter: _BurstPainter(_burst.value, light),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Eight dots flying out from the tile's icon.
class _BurstPainter extends CustomPainter {
  _BurstPainter(this.progress, this.color);

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final eased = Curves.easeOut.transform(progress);
    final centre = Offset(size.width / 2, size.height * .4);
    final paint = Paint()..color = color.withValues(alpha: 1 - progress);
    for (var n = 0; n < 8; n++) {
      final angle = n / 8 * 2 * math.pi;
      final point =
          centre + Offset(math.cos(angle), math.sin(angle)) * 40 * eased;
      canvas.drawCircle(point, 3 * (1 - eased), paint);
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) =>
      old.progress != progress || old.color != color;
}

/// The feelings sheet's tiles: two per row on phones, three on wide sheets.
/// At the limit the rest fade and ignore taps.
class FeelingTileGrid extends StatelessWidget {
  const FeelingTileGrid({
    super.key,
    required this.picked,
    required this.onToggle,
  });

  final List<FilmReaction> picked;
  final ValueChanged<FilmReaction> onToggle;

  static const _gap = 12.0;

  @override
  Widget build(BuildContext context) {
    final full = picked.length >= MovieReviewSummary.maxFeelings;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 480 ? 3 : 2;
        final width = (constraints.maxWidth - _gap * (columns - 1)) / columns;
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final feeling in FilmReaction.values)
              SizedBox(
                width: width,
                child: FeelingTile(
                  feeling: feeling,
                  selected: picked.contains(feeling),
                  dimmed: full,
                  onTap: full && !picked.contains(feeling)
                      ? null
                      : () => onToggle(feeling),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Empty state of the feelings card: a smiling face that breathes, winks
/// and shows a "+" (Lottie), over a button-like pill, so the card reads as
/// something to tap. Still when the platform asks for reduced motion.
class FeelingsEmptyInvite extends StatelessWidget {
  const FeelingsEmptyInvite({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final play = !MediaQuery.disableAnimationsOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        children: [
          ExcludeSemantics(
            child: Lottie.asset(
              'assets/lottie/feel_smile.json',
              width: 64,
              height: 64,
              animate: play,
              repeat: true,
            ),
          ),
          const SizedBox(height: 6),
          // Looks like a button so the whole card reads as tappable.
          Container(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 7, 14, 7),
            decoration: BoxDecoration(
              color: LuxeColors.accent.withValues(alpha: .14),
              borderRadius: const BorderRadius.all(Radius.circular(18)),
              border: Border.all(
                color: LuxeColors.accent.withValues(alpha: .55),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  BootstrapIcons.emoji_smile,
                  size: 16,
                  color: LuxeColors.accentHi,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: LuxeColors.accentHi,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
