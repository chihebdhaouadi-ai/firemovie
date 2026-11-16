import 'package:flutter/material.dart';

import 'luxe_palette.dart';

/// SAGE pill button, styled like the selected Home tab. Usage:
///   GameButton(label: 'Add film', icon: Icons.add, style: GameButtonStyle.blue, onPressed: () {})
///   GameButton(label: 'Explore', style: GameButtonStyle.blue, pressed: true, onPressed: () {})
class GameButtonStyle {
  final Color top, bottom, edge;
  const GameButtonStyle(this.top, this.bottom, this.edge);
  static const dark =
      GameButtonStyle(Color(0xFF4C566B), Color(0xFF262D3D), Color(0xFF10141D));
  static const blue =
      GameButtonStyle(Color(0xFF4A8CF0), Color(0xFF2A57B8), Color(0xFF12306F));
}

class GameButton extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final Widget?
      child; // custom content (e.g. your own icon), overrides label/icon
  final GameButtonStyle style;
  final VoidCallback? onPressed;
  final bool pressed; // selected state (for tabs)
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

  @override
  Widget build(BuildContext context) {
    final s = widget.pressed ? GameButtonStyle.blue : widget.style;
    // One button look for the whole app, matching the selected "You" tab:
    // a rounded pill with the blue accent gradient and a soft glow. The dark
    // style is the quiet version: matte surface with a hairline border.
    final quiet = identical(s, GameButtonStyle.dark);
    final gradient = identical(s, GameButtonStyle.blue)
        ? LuxeColors.accentGradient
        : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [s.top, s.bottom],
          );
    final textColor = s.bottom.computeLuminance() > .5
        ? const Color(0xFF1A1300)
        : Colors.white;

    final content = widget.child ??
        Row(mainAxisSize: MainAxisSize.min, children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 20, color: textColor),
            const SizedBox(width: 8),
          ],
          if (widget.label != null)
            Flexible(
              child: Text(
                widget.label!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: .2,
                ),
              ),
            ),
        ]);

    final radius =
        BorderRadius.circular(widget.radius.clamp(10, 14).toDouble());

    return Opacity(
      opacity: widget.onPressed == null ? .45 : 1,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _down ? .97 : 1,
          duration: const Duration(milliseconds: 110),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              color: quiet ? LuxeColors.surface2 : null,
              gradient: quiet ? null : gradient,
              border: quiet ? Border.all(color: LuxeColors.hair) : null,
              boxShadow: quiet
                  ? null
                  : [
                      BoxShadow(
                        color: s.top.withValues(alpha: .35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Padding(
              padding: widget.padding,
              child: Center(widthFactor: 1, heightFactor: 1, child: content),
            ),
          ),
        ),
      ),
    );
  }
}
