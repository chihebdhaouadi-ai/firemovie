import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/motion.dart';
import '../../../../core/widgets/luxe_palette.dart';
import '../../data/home_models.dart';
import 'film_tile.dart';

/// A wall of tiny, blurry, pixel-like covers. Dragging a finger over it
/// bends the whole wall in a wave around the finger: covers near it swell
/// and spread, the rest stay small and dim. Only the cover under the finger
/// shows clearly, with its name. The pick stays after the finger lifts, with
/// buttons to open or remove it.
///
/// The films repeat to fill the wall, so even a short list feels full.
class PosterLensField extends StatefulWidget {
  const PosterLensField({
    super.key,
    required this.films,
    required this.onOpen,
    required this.onRemove,
    this.randomStart = false,
    this.rollSignal = 0,
  });

  final List<Film> films;
  final ValueChanged<Film> onOpen;
  final ValueChanged<Film> onRemove;

  /// Glides to a random cover as soon as the wall shows.
  final bool randomStart;

  /// Each change glides to another random cover.
  final int rollSignal;

  @override
  State<PosterLensField> createState() => _PosterLensFieldState();
}

class _PosterLensFieldState extends State<PosterLensField>
    with TickerProviderStateMixin {
  late final AnimationController _strength = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  /// Keeps the rings moving outward.
  late final AnimationController _ripple = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  /// Moves the wave to a random cover.
  late final AnimationController _glide = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..addListener(_onGlide);
  Offset _glideFrom = Offset.zero;
  Offset _glideTo = Offset.zero;
  final math.Random _random = math.Random();

  /// The wall as last laid out, so a roll knows where covers are.
  _Wall? _wall;

  /// Where the wave is centered, in the wall's coordinates.
  Offset? _finger;

  /// The picked tile on the wall (films repeat, so tiles, not films).
  int? _tile;

  /// A few pixels of each poster: drawn stretched, they read as blurry
  /// blocks of color.
  final Map<String, ui.Image> _thumbs = {};
  final List<(ImageStream, ImageStreamListener)> _streams = [];

  @override
  void initState() {
    super.initState();
    if (widget.randomStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _roll());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadThumbs();
  }

  @override
  void didUpdateWidget(covariant PosterLensField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A removed film drops the pick; the wall reflows.
    if (oldWidget.films.length != widget.films.length) {
      _tile = null;
      _finger = null;
      _strength.value = 0;
      _ripple.stop();
    }
    if (oldWidget.rollSignal != widget.rollSignal) _roll();
    _loadThumbs();
  }

  /// Glides the wave to a random cover away from the wall's edges.
  void _roll() {
    final wall = _wall;
    if (!mounted || wall == null || widget.films.isEmpty) return;
    int pick(int count) {
      final low = (count * .2).floor();
      final high = math.max(low + 1, (count * .75).ceil());
      return low + _random.nextInt(high - low);
    }

    final tile = pick(wall.rows) * wall.columns + pick(wall.columns);
    _glideTo = wall.rect(tile).center;
    _glideFrom = _finger ?? _glideTo.translate(0, -wall.tile.height * 3);
    _strength.duration =
        motionDuration(context, const Duration(milliseconds: 320));
    _strength.forward();
    _startRipple();
    _glide.duration =
        motionDuration(context, const Duration(milliseconds: 700));
    _glide.forward(from: 0).whenCompleteOrCancel(() {
      if (mounted) HapticFeedback.mediumImpact();
    });
  }

  void _onGlide() {
    final wall = _wall;
    if (wall == null) return;
    final t = Curves.easeInOutCubic.transform(_glide.value);
    final position = Offset.lerp(_glideFrom, _glideTo, t)!;
    setState(() {
      _finger = position;
      _tile = wall.nearest(position);
    });
  }

  void _loadThumbs() {
    for (final film in widget.films) {
      final url = film.posterUrl;
      if (url == null || _thumbs.containsKey(url)) continue;
      final stream = ResizeImage(
        CachedNetworkImageProvider(url),
        width: 6,
        height: 9,
      ).resolve(createLocalImageConfiguration(context));
      late final ImageStreamListener listener;
      listener = ImageStreamListener(
        (info, _) {
          if (!mounted) return;
          setState(() => _thumbs[url] = info.image);
        },
        onError: (_, __) {},
      );
      stream.addListener(listener);
      _streams.add((stream, listener));
    }
  }

  @override
  void dispose() {
    for (final (stream, listener) in _streams) {
      stream.removeListener(listener);
    }
    _ripple.dispose();
    _glide.dispose();
    _strength.dispose();
    super.dispose();
  }

  Film _film(int tile) => widget.films[tile % widget.films.length];

  Film? get _picked {
    final tile = _tile;
    if (tile == null || widget.films.isEmpty) return null;
    return _film(tile);
  }

  /// Starts the rings, unless the system asks for less motion.
  void _startRipple() {
    if (_ripple.isAnimating) return;
    if (MediaQuery.disableAnimationsOf(context)) return;
    _ripple.repeat();
  }

  void _moveTo(Offset position, _Wall wall) {
    // A finger takes over from a glide.
    _glide.stop();
    final tile = wall.nearest(position);
    if (tile != _tile) HapticFeedback.selectionClick();
    setState(() {
      _finger = position;
      _tile = tile;
    });
    _strength.duration =
        motionDuration(context, const Duration(milliseconds: 320));
    _strength.forward();
    _startRipple();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final picked = _picked;

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final wall = _Wall(box.biggest, widget.films.length);
              _wall = wall;
              return GestureDetector(
                key: const Key('lens-field'),
                behavior: HitTestBehavior.opaque,
                onPanDown: (d) => _moveTo(d.localPosition, wall),
                onPanUpdate: (d) => _moveTo(d.localPosition, wall),
                child: ClipRect(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_strength, _ripple]),
                    builder: (context, _) {
                      final wave = _Wave(
                        wall,
                        _finger,
                        _strength.value,
                        _ripple.value * 2 * math.pi,
                      );
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _WallPainter(
                                wave: wave,
                                thumbFor: (i) {
                                  final url = _film(i).posterUrl;
                                  return url == null ? null : _thumbs[url];
                                },
                                fallback: LuxeColors.surface2,
                              ),
                            ),
                          ),
                          ..._clearCover(wave),
                          if (_finger == null && !widget.randomStart)
                            Center(
                              child: _Pill(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      BootstrapIcons.hand_index,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(l10n.homeLensHint),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        AnimatedSize(
          duration: motionDuration(context, const Duration(milliseconds: 220)),
          curve: Curves.easeOutCubic,
          child: picked == null
              ? const SizedBox(width: double.infinity)
              : _PickedCard(
                  film: picked,
                  onOpen: () => widget.onOpen(picked),
                  onRemove: () => widget.onRemove(picked),
                ),
        ),
      ],
    );
  }

  /// The one sharp cover, over the picked blob, and its name above it.
  List<Widget> _clearCover(_Wave wave) {
    final tile = _tile;
    if (tile == null || wave.strength == 0) return const [];
    final blob = wave.rect(tile);
    final width = wave.wall.tile.width * 4.4 * wave.strength +
        blob.width * (1 - wave.strength);
    final rect = Rect.fromCenter(
      center: blob.center,
      width: width,
      height: width * 1.5,
    );
    const labelWidth = 180.0;
    final left = (rect.center.dx - labelWidth / 2)
        .clamp(4.0, math.max(4.0, wave.wall.size.width - labelWidth - 4))
        .toDouble();
    return [
      Positioned.fromRect(
        rect: rect,
        child: Opacity(
          opacity: wave.strength,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FilmPoster(
              film: _film(tile),
              width: rect.width,
              height: rect.height,
              radius: 8,
            ),
          ),
        ),
      ),
      Positioned(
        left: left,
        top: math.max(4.0, rect.top - 40),
        width: labelWidth,
        child: Opacity(
          opacity: wave.strength,
          child: Center(
            child: _Pill(
              key: const Key('lens-label'),
              child: Text(
                _film(tile).displayTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

/// Where each tile sits once the wave bends the wall around the finger.
class _Wave {
  _Wave(this.wall, this.finger, this.strength, this.phase)
      : radius = wall.tile.width * 5.5;

  final _Wall wall;
  final Offset? finger;
  final double strength;
  final double radius;

  /// Moves the rings outward over time (0..2π).
  final double phase;

  /// 1 at the finger, fading smoothly to 0 far away.
  double pull(int i) {
    final f = finger;
    if (f == null) return 0;
    final d = (wall.rect(i).center - f).distance / radius;
    return math.exp(-d * d) * strength;
  }

  /// How strongly the wall around the finger bends: wider than [pull], so
  /// the curve reaches covers that barely swell.
  double reach(int i) {
    final f = finger;
    if (f == null) return 0;
    final d = (wall.rect(i).center - f).distance / (radius * 1.8);
    return math.exp(-d * d) * strength;
  }

  Rect rect(int i) {
    final base = wall.rect(i);
    final f = finger;
    if (f == null || strength == 0) return base;
    final p = pull(i);
    final v = base.center - f;
    final d = v.distance;
    final dir = d == 0 ? Offset.zero : v / d;
    // Rings travel out from the finger, like water after a drop: covers
    // rise and swell as a ring passes.
    final ring = math.sin(d / (wall.tile.width * 1.6) - phase) * reach(i);
    final center = f + v * (1 + 1.2 * p) + dir * ring * wall.tile.width * .5;
    final scale = (1 + 2.2 * p) * (1 + .18 * ring);
    return Rect.fromCenter(
      center: center,
      width: base.width * scale,
      height: base.height * scale,
    );
  }
}

class _WallPainter extends CustomPainter {
  _WallPainter({
    required this.wave,
    required this.thumbFor,
    required this.fallback,
  });

  final _Wave wave;
  final ui.Image? Function(int tile) thumbFor;
  final Color fallback;

  @override
  void paint(Canvas canvas, Size size) {
    // A dark backing, so turned covers never show light gaps.
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFF14110E));
    final wall = wave.wall;
    final order = List<int>.generate(wall.count, (i) => i);
    final pulls = [for (var i = 0; i < wall.count; i++) wave.pull(i)];
    // Swollen blobs draw last, on top of the small ones.
    order.sort((a, b) => pulls[a].compareTo(pulls[b]));

    final paint = Paint()..filterQuality = FilterQuality.low;
    for (final i in order) {
      // Covers fill their cells, so no background shows between them.
      final rect = wave.rect(i);
      final p = pulls[i];
      // Covers are solid (nothing shows through); far ones are shaded
      // darker and the wave lights them up.
      final shade = Colors.black.withValues(alpha: .55 * (1 - p));
      final rrect = RRect.fromRectAndRadius(
        rect,
        // Square on the flat wall (no gaps at corners), rounder in the wave.
        Radius.circular(rect.width * .14 * wave.reach(i)),
      );
      final image = thumbFor(i);
      canvas.save();
      if (image == null) {
        canvas.drawRRect(
          rrect,
          Paint()..color = Color.alphaBlend(shade, fallback),
        );
        canvas.restore();
        continue;
      }
      canvas.clipRRect(rrect);
      paint.colorFilter = ColorFilter.mode(shade, BlendMode.srcATop);
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(
          0,
          0,
          image.width.toDouble(),
          image.height.toDouble(),
        ),
        rect,
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_WallPainter old) => true;
}

/// The wall's grid: small 2:3 tiles filling the space, columns first.
class _Wall {
  _Wall(this.size, int films)
      : columns = films == 0 ? 1 : math.max(14, (size.width / 19).floor()) {
    final width = size.width / columns;
    tile = Size(width, width * 1.5);
    rows = (size.height / tile.height).ceil();
    // Center the last, partial row's overflow above and below.
    offsetY = (size.height - rows * tile.height) / 2;
  }

  final Size size;
  final int columns;
  late final Size tile;
  late final int rows;
  late final double offsetY;

  int get count => columns * rows;

  Rect rect(int i) => Rect.fromLTWH(
        (i % columns) * tile.width,
        offsetY + (i ~/ columns) * tile.height,
        tile.width,
        tile.height,
      );

  int nearest(Offset p) {
    final col = (p.dx / tile.width).floor().clamp(0, columns - 1);
    final row = ((p.dy - offsetY) / tile.height).floor().clamp(0, rows - 1);
    return row * columns + col;
  }
}

class _Pill extends StatelessWidget {
  const _Pill({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: LuxeColors.text,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: LuxeColors.bg,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: LuxeColors.bg),
          child: child,
        ),
      ),
    );
  }
}

/// The picked film under the wall, with open and remove.
class _PickedCard extends StatelessWidget {
  const _PickedCard({
    required this.film,
    required this.onOpen,
    required this.onRemove,
  });

  final Film film;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = film.displayTitle;
    return Container(
      key: const Key('lens-picked'),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 4, 8),
      decoration: BoxDecoration(
        color: LuxeColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LuxeColors.hair),
      ),
      child: Row(
        children: [
          FilmPoster(film: film, width: 40, height: 60, radius: 6),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: LuxeColors.text,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          IconButton(
            key: const Key('lens-open'),
            tooltip: l10n.homeLensOpen(name),
            onPressed: onOpen,
            icon: Icon(BootstrapIcons.box_arrow_up_right,
                size: 18, color: LuxeColors.text),
          ),
          IconButton(
            key: const Key('lens-remove'),
            tooltip: l10n.homeEditListRemove(name),
            onPressed: onRemove,
            icon:
                Icon(BootstrapIcons.trash3, size: 18, color: LuxeColors.muted),
          ),
        ],
      ),
    );
  }
}
