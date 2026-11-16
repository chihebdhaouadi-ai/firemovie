import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../luxe_palette.dart';
import 'quick_action_menu.dart';
import 'sage_nav_items.dart';
import 'sage_nav_models.dart';
import 'sage_nav_tokens.dart';

class SageNavEntry {
  const SageNavEntry({
    required this.item,
    required this.semanticsLabel,
    required this.onTap,
    this.selected = false,
  });

  final SageNavItem item;
  final String semanticsLabel;
  final VoidCallback onTap;
  final bool selected;
}

/// SAGE bottom nav bar: a matte arched bar with hairline edges, calm blue
/// tiles for the selected tab, and a glowing blue SAGE button in the middle
/// that opens the quick-action fan.
class SageNavBar extends StatelessWidget {
  const SageNavBar({
    required this.leading,
    required this.trailing,
    required this.centerSemanticsLabel,
    required this.closeLabel,
    required this.centerActions,
    super.key,
  })  : assert(leading.length == 2),
        assert(trailing.length == 2);

  final List<SageNavEntry> leading;
  final List<SageNavEntry> trailing;
  final String centerSemanticsLabel;
  final String closeLabel;
  final List<SageQuickAction> centerActions;

  static const double _barH = 78;
  static const double _hump = 16; // how much the bar arches up in the middle
  static const double _ringR = 46; // half of the SAGE ring (92)
  /// Height of the bar above the bottom system inset (home indicator).
  static const double height = _barH + _hump + _ringR + 4;

  @override
  Widget build(BuildContext context) {
    // The bar background reaches the very bottom of the screen; only the tiles
    // and the SAGE button are lifted above the home indicator.
    final inset = MediaQuery.paddingOf(context).bottom;
    return Align(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: SageNavTokens.maxBarWidth),
        child: SizedBox(
          height: height + inset,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // the bar itself, with a smooth arch in the middle
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: _barH + _hump + inset,
                child: const CustomPaint(painter: _BarPainter(_hump)),
              ),
              // the four tiles
              Positioned(
                left: 12,
                right: 12,
                bottom: 8 + inset,
                height: _barH - 14,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (final entry in leading)
                      Expanded(child: _BarTab(entry: entry)),
                    const SizedBox(width: _ringR * 2 + 4),
                    for (final entry in trailing)
                      Expanded(child: _BarTab(entry: entry)),
                  ],
                ),
              ),
              // SAGE button sitting on the arch
              Positioned(
                bottom: _barH + _hump - _ringR + inset,
                child: _CenterButton(
                  semanticsLabel: centerSemanticsLabel,
                  closeLabel: closeLabel,
                  actions: centerActions,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  const _BarPainter(this.hump);

  final double hump;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, cx = w / 2;
    // top edge only: flat at the sides (y = hump), arching up to y = 0 in the middle
    final edge = Path()
      ..moveTo(0, hump)
      ..lineTo(cx - 150, hump)
      ..cubicTo(cx - 90, hump, cx - 70, 0, cx, 0)
      ..cubicTo(cx + 70, 0, cx + 90, hump, cx + 150, hump)
      ..lineTo(w, hump);
    final shape = Path.from(edge)
      ..lineTo(w, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawShadow(shape, Colors.black, 14, true);
    canvas.drawPath(
      shape,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [LuxeColors.surface2, LuxeColors.surface],
        ).createShader(Offset.zero & size),
    );
    // hairline along the arch
    canvas.drawPath(
      edge,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = LuxeColors.hair,
    );
    // soft top highlight, drawn just inside the edge
    canvas.save();
    canvas.clipPath(shape);
    canvas.translate(0, 2);
    canvas.drawPath(
      edge,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: .06),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BarPainter oldDelegate) => oldDelegate.hump != hump;
}

class _BarTab extends StatefulWidget {
  const _BarTab({required this.entry});

  final SageNavEntry entry;

  @override
  State<_BarTab> createState() => _BarTabState();
}

class _BarTabState extends State<_BarTab> with SingleTickerProviderStateMixin {
  late final AnimationController _boing = AnimationController(
    vsync: this,
    duration: SageNavTokens.boingDuration,
  );

  @override
  void dispose() {
    _boing.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.entry.onTap();
    _boing.forward(from: 0).then((_) {
      if (mounted) _boing.reverse();
    });
  }

  Widget _glyph(SageNavItem item, bool selected) {
    if (item.avatar != null) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.white : LuxeColors.hair,
            width: 1.5,
          ),
          color: LuxeColors.surface2,
          image: DecorationImage(image: item.avatar!, fit: BoxFit.cover),
        ),
      );
    }
    if (item.avatarInitial != null) {
      return Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.white : LuxeColors.hair,
            width: 1.5,
          ),
          color: LuxeColors.surface2,
        ),
        child: Text(
          item.avatarInitial!,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      );
    }
    if (item.svgAsset != null) {
      return SvgPicture.asset(item.svgAsset!, width: 28, height: 28);
    }
    return Icon(
      item.icon,
      size: 26,
      color: selected ? Colors.white : LuxeColors.muted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return Center(
      child: AnimatedBuilder(
        animation: _boing,
        builder: (context, _) {
          final b = Curves.easeOut.transform(_boing.value);
          return Transform.translate(
            offset: Offset(0, -SageNavTokens.boingLift * b),
            child: Transform.scale(
              scale: 1 + (SageNavTokens.boingScale - 1) * b,
              child: Semantics(
                button: true,
                selected: entry.selected,
                label: entry.semanticsLabel,
                child: ExcludeSemantics(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _LuxeTile(
                        selected: entry.selected,
                        onTap: _handleTap,
                        child: _glyph(entry.item, entry.selected),
                      ),
                      if (entry.item.showBadge)
                        const Positioned(
                          top: -3,
                          right: -3,
                          child: _UnreadBadge(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A matte tab tile. Selected tiles get a soft blue tint and glow; the rest
/// stay invisible until pressed.
class _LuxeTile extends StatefulWidget {
  const _LuxeTile({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_LuxeTile> createState() => _LuxeTileState();
}

class _LuxeTileState extends State<_LuxeTile> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? .9 : 1,
        duration: const Duration(milliseconds: 110),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          width: 50,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: sel
                ? LuxeColors.accent.withValues(alpha: .16)
                : Colors.transparent,
            border: Border.all(
              color: sel
                  ? LuxeColors.accent.withValues(alpha: .4)
                  : Colors.transparent,
            ),
            boxShadow: sel
                ? [
                    BoxShadow(
                      color: LuxeColors.accent.withValues(alpha: .25),
                      blurRadius: 14,
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatefulWidget {
  const _UnreadBadge();

  @override
  State<_UnreadBadge> createState() => _UnreadBadgeState();
}

class _UnreadBadgeState extends State<_UnreadBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ping = AnimationController(
    vsync: this,
    duration: SageNavTokens.badgePingDuration,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _ping.stop();
    } else if (!_ping.isAnimating) {
      _ping.repeat();
    }
  }

  @override
  void dispose() {
    _ping.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SageNavBadge(
      presence: kAlwaysCompleteAnimation,
      ping: MediaQuery.disableAnimationsOf(context) ? null : _ping,
    );
  }
}

class _CenterButton extends StatefulWidget {
  const _CenterButton({
    required this.semanticsLabel,
    required this.closeLabel,
    required this.actions,
  });

  final String semanticsLabel;
  final String closeLabel;
  final List<SageQuickAction> actions;

  @override
  State<_CenterButton> createState() => _CenterButtonState();
}

class _CenterButtonState extends State<_CenterButton>
    with TickerProviderStateMixin {
  static const _size = 92.0;

  late final AnimationController _fan = AnimationController(
    vsync: this,
    duration: quickActionFanDuration(widget.actions.length),
  );
  // one loop = 2.6s: pulse ring and breathing glow
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  final _portal = OverlayPortalController();
  final _link = LayerLink();
  bool _pressed = false;
  bool _open = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _loop.stop();
    } else if (!_loop.isAnimating) {
      _loop.repeat();
    }
  }

  @override
  void dispose() {
    _fan.dispose();
    _loop.dispose();
    super.dispose();
  }

  void _toggle() => _open ? _close() : _show();

  void _show() {
    setState(() => _open = true);
    if (!_portal.isShowing) _portal.show();
    _fan.forward();
  }

  void _close() {
    if (!_open) return;
    setState(() => _open = false);
    _fan.animateBack(0, duration: SageNavTokens.closeDuration).whenComplete(() {
      if (mounted && _fan.isDismissed) _portal.hide();
    });
  }

  void _select(SageQuickAction action) {
    _close();
    action.onTap();
  }

  Widget _visual(BuildContext context) {
    final animate = !MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _loop,
      builder: (context, _) {
        final t = animate ? _loop.value : 0.0;
        final pulse = (t / 0.7).clamp(0.0, 1.0); // ring grows during first 70%
        // soft breathing glow: 0 -> 1 -> 0 over one loop
        final breathe = animate ? .5 - .5 * math.cos(2 * math.pi * t) : .5;

        return SizedBox(
          width: _size,
          height: _size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // pulse ring
              if (animate && !_pressed)
                Opacity(
                  opacity: (1 - pulse) * 0.6,
                  child: Transform.scale(
                    scale: 0.85 + 0.5 * pulse,
                    child: Container(
                      width: _size,
                      height: _size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: LuxeColors.accent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              // matte outer ring
              Container(
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: LuxeColors.bg,
                  border: Border.all(color: LuxeColors.hair),
                ),
              ),
              // blue button with a breathing glow
              AnimatedScale(
                scale: _pressed ? .95 : 1,
                duration: const Duration(milliseconds: 110),
                child: Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: Colors.white.withValues(alpha: .18)),
                    gradient: LuxeColors.accentGradient,
                    boxShadow: [
                      BoxShadow(
                        color: LuxeColors.accent
                            .withValues(alpha: .16 + .16 * breathe),
                        blurRadius: 22 + 10 * breathe,
                      ),
                    ],
                  ),
                  child: const Text(
                    'SAGE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 1.4,
                      shadows: [
                        Shadow(
                          color: Color(0x55000000),
                          offset: Offset(0, 1.5),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (context) => QuickActionMenu(
        link: _link,
        actions: widget.actions,
        progress: _fan,
        closeLabel: widget.closeLabel,
        onDismiss: _close,
        onSelect: _select,
      ),
      child: CompositedTransformTarget(
        link: _link,
        child: Semantics(
          button: true,
          label: widget.semanticsLabel,
          expanded: _open,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) => setState(() => _pressed = false),
            onTap: _toggle,
            child: AnimatedScale(
              scale: _open ? 0.92 : 1.0,
              duration: SageNavTokens.pressDuration,
              child: ExcludeSemantics(child: _visual(context)),
            ),
          ),
        ),
      ),
    );
  }
}
