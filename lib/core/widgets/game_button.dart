import 'package:flutter/material.dart';

/// SAGE glossy 3D button (no texture). Usage:
///   GameButton(label: 'Add film', icon: Icons.add, style: GameButtonStyle.blue, onPressed: () {})
///   GameButton(label: 'Explore', style: GameButtonStyle.blue, pressed: true, onPressed: () {})
class GameButtonStyle {
  final Color top, bottom, edge;
  const GameButtonStyle(this.top, this.bottom, this.edge);
  static const dark = GameButtonStyle(Color(0xFF4C566B), Color(0xFF262D3D), Color(0xFF10141D));
  static const blue = GameButtonStyle(Color(0xFF3F7FE8), Color(0xFF1D4CB5), Color(0xFF12306F));
}

class GameButton extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final Widget? child;            // custom content (e.g. your own icon), overrides label/icon
  final GameButtonStyle style;
  final VoidCallback? onPressed;
  final bool pressed;             // selected state (for tabs)
  final double radius;
  final EdgeInsets padding;

  const GameButton({
    super.key,
    this.label,
    this.icon,
    this.child,
    this.style = GameButtonStyle.dark,
    this.onPressed,
    this.pressed = false,
    this.radius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _down = false;
  static const double lip = 6;

  @override
  Widget build(BuildContext context) {
    final s = widget.pressed ? GameButtonStyle.blue : widget.style;
    final down = _down || widget.pressed;
    final offset = down ? lip - 2 : 0.0;

    final content = widget.child ??
        Row(mainAxisSize: MainAxisSize.min, children: [
          if (widget.icon != null) ...[Icon(widget.icon, size: 20, color: Colors.white), const SizedBox(width: 9)],
          if (widget.label != null)
            Text(widget.label!,
                style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: .5,
                  shadows: [Shadow(color: Color(0x73000000), offset: Offset(0, 1.5))],
                )),
        ]);

    return Opacity(
      opacity: widget.onPressed == null ? .45 : 1,
      child: GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: EdgeInsets.only(top: offset, bottom: lip - offset),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(color: s.edge, width: 2),
          boxShadow: [
            BoxShadow(color: s.edge, offset: Offset(0, down ? 2 : lip)),                 // 3D lip
            BoxShadow(color: Colors.black.withOpacity(.45), offset: Offset(0, down ? 5 : lip + 4), blurRadius: 12),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius - 2),
          child: Stack(alignment: Alignment.center, children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [s.top, s.bottom]),
                ),
              ),
            ),
            // glossy highlight
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5, 3, 5, 0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: FractionallySizedBox(
                    heightFactor: .42,
                    widthFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12), bottom: Radius.circular(22)),
                        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.white.withOpacity(.34), Colors.white.withOpacity(.03)]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(padding: widget.padding, child: content),
          ]),
        ),
      ),
      ),
    );
  }
}
