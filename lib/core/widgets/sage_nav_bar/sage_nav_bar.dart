import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../motion.dart';
import '../../theme/app_palette.dart';
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

/// SAGE bottom nav bar: flat, with a hairline along the top and no shadow
/// or pill behind the icons. Tabs are light outlines in the muted colour and
/// turn filled and ink-coloured when selected; the profile avatar gets a thin
/// ring instead. A smaller flat SAGE button sits a little above the bar and
/// opens the quick-action fan.
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

  static const double _barH = 56;
  // A flat bar: no arch, just a hairline along the top.
  static const double _hump = 0;
  static const double _ringR = _CenterButtonState._size / 2;

  /// How far the SAGE button's bottom edge sits above the bar's bottom, so it
  /// rises a little above the hairline.
  static const double _sageLift = 17;

  /// Height of the bar above the bottom system inset (home indicator).
  static const double height = _sageLift + _ringR * 2 + 1;

  /// From this window width the bar floats as a rounded dock above the
  /// bottom edge instead of running along it.
  static const double dockFromWidth = 720;
  static const double _dockWidth = 460;
  static const double _dockGap = 16;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth >= dockFromWidth
          ? _dock(context)
          : _strip(context),
    );
  }

  /// Phones: the bar runs along the bottom edge. Its background reaches the
  /// very bottom of the screen; only the tiles and the SAGE button are lifted
  /// above the home indicator.
  Widget _strip(BuildContext context) {
    final inset = MediaQuery.paddingOf(context).bottom;
    return Align(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: SageNavTokens.maxBarWidth),
        child: SizedBox(
          height: height + inset,
          child: _bar(
            inset: inset,
            background: CustomPaint(
              painter: _BarPainter(_hump, AppPalette.current),
            ),
          ),
        ),
      ),
    );
  }

  /// Wide windows: a rounded dock in the middle, floating a little above the
  /// bottom edge, so it doesn't end abruptly partway across the page.
  Widget _dock(BuildContext context) {
    final inset = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: _dockGap + inset),
      child: Align(
        heightFactor: 1,
        child: SizedBox(
          width: _dockWidth,
          height: height,
          child: _bar(
            inset: 0,
            background: DecoratedBox(
              key: const Key('sage-nav-dock'),
              decoration: BoxDecoration(
                color: LuxeColors.bg,
                borderRadius: BorderRadius.circular(_barH / 2 + 6),
                border: Border.all(color: LuxeColors.hair),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The bar's background, the four tiles and the SAGE button on top.
  Widget _bar({required double inset, required Widget background}) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: _barH + _hump + inset,
          child: background,
        ),
        // the four tiles
        Positioned(
          left: 12,
          right: 12,
          // The tiles take almost the whole (low) bar, so the icons still
          // fit; the selected tile shrinks to this height.
          bottom: 2 + inset,
          height: _barH - 4,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (final entry in leading)
                Expanded(child: _BarTab(entry: entry)),
              const SizedBox(width: 84),
              for (final entry in trailing)
                Expanded(child: _BarTab(entry: entry)),
            ],
          ),
        ),
        // The SAGE button, a little below the bar's top line so it sits on it.
        Positioned(
          bottom: _sageLift + inset,
          child: _CenterButton(
            semanticsLabel: centerSemanticsLabel,
            closeLabel: closeLabel,
            actions: centerActions,
          ),
        ),
      ],
    );
  }
}

class _BarPainter extends CustomPainter {
  const _BarPainter(this.hump, this.palette);

  final double hump;

  /// The palette the bar was painted with; a mode switch repaints it.
  final AppPalette palette;

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

    // Same paper as the page, with a single hairline on top.
    canvas.drawPath(shape, Paint()..color = LuxeColors.bg);
    canvas.drawPath(
      edge,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = LuxeColors.hair,
    );
  }

  @override
  bool shouldRepaint(_BarPainter oldDelegate) =>
      oldDelegate.hump != hump || oldDelegate.palette != palette;
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
    if (!motionEnabled(context)) return;
    _boing.forward(from: 0).then((_) {
      if (mounted) _boing.reverse();
    });
  }

  /// The avatar inside a thin ring that only shows while selected.
  Widget _ringed(bool selected, Widget avatar) => AnimatedContainer(
        duration: motionDuration(context, const Duration(milliseconds: 150)),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? _selectedInk : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: avatar,
      );

  Widget _glyph(SageNavItem item, bool selected) {
    if (item.avatar != null) {
      return _ringed(
        selected,
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: LuxeColors.surface2,
            image: DecorationImage(image: item.avatar!, fit: BoxFit.cover),
          ),
        ),
      );
    }
    if (item.avatarInitial != null) {
      return _ringed(
        selected,
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: LuxeColors.surface2,
          ),
          child: Text(
            item.avatarInitial!,
            style: TextStyle(
              color: _selectedInk,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      );
    }
    if (item.svgAsset != null) {
      return SvgPicture.asset(item.svgAsset!, width: 26, height: 26);
    }
    return Icon(
      selected ? _filled(item.icon) : item.icon,
      size: 24,
      color: selected ? _selectedInk : LuxeColors.muted,
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

/// A tab's tap area: no background, it only shrinks a little while pressed.
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? .9 : 1,
        duration: motionDuration(context, const Duration(milliseconds: 110)),
        child: AnimatedContainer(
          duration: motionDuration(context, const Duration(milliseconds: 240)),
          curve: Curves.easeOutCubic,
          width: 50,
          height: 46,
          alignment: Alignment.center,
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
  static const _size = 58.0;

  late final AnimationController _fan = AnimationController(
    vsync: this,
    duration: quickActionFanDuration(widget.actions.length),
  );
  final _portal = OverlayPortalController();
  final _link = LayerLink();
  bool _pressed = false;
  bool _open = false;

  @override
  void dispose() {
    _fan.dispose();
    super.dispose();
  }

  void _toggle() => _open ? _close() : _show();

  void _show() {
    setState(() => _open = true);
    if (!_portal.isShowing) _portal.show();
    if (motionEnabled(context)) {
      _fan.forward();
    } else {
      _fan.value = 1; // the menu appears at once
    }
  }

  void _close() {
    if (!_open) return;
    setState(() => _open = false);
    if (!motionEnabled(context)) {
      _fan.value = 0;
      _portal.hide();
      return;
    }
    _fan.animateBack(0, duration: SageNavTokens.closeDuration).whenComplete(() {
      if (mounted && _fan.isDismissed) _portal.hide();
    });
  }

  void _select(SageQuickAction action) {
    _close();
    action.onTap();
  }

  /// A flat ink circle with SAGE in the bar's colour, and a ring in the
  /// bar's colour that separates it from the hairline.
  Widget _visual(BuildContext context) => AnimatedScale(
        scale: _pressed ? .95 : 1,
        duration: motionDuration(context, const Duration(milliseconds: 110)),
        child: Container(
          width: _size,
          height: _size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: LuxeColors.text,
            border: Border.all(color: LuxeColors.bg, width: 4),
          ),
          child: Text(
            'SAGE',
            style: TextStyle(
              color: LuxeColors.bg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.6,
            ),
          ),
        ),
      );

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
              duration: motionDuration(context, SageNavTokens.pressDuration),
              child: ExcludeSemantics(child: _visual(context)),
            ),
          ),
        ),
      ),
    );
  }
}

/// The filled version of an outline tab icon, shown while a tab is
/// selected; icons without one stay as they are.
IconData _filled(IconData icon) {
  if (icon == BootstrapIcons.house) return BootstrapIcons.house_fill;
  if (icon == BootstrapIcons.compass) return BootstrapIcons.compass_fill;
  if (icon == BootstrapIcons.person) return BootstrapIcons.person_fill;
  if (icon == BootstrapIcons.chat) return BootstrapIcons.chat_fill;
  if (icon == BootstrapIcons.bell) return BootstrapIcons.bell_fill;
  return icon;
}

/// Selected tab ink: white on the dark bar, near-black on the light one.
Color get _selectedInk => themed(Colors.white, LuxeColors.text);
