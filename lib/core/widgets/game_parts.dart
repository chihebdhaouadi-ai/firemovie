import 'package:flutter/material.dart';

import 'game_button.dart';

/// SAGE game palette used by the home screen cards and chips.
abstract final class GameColors {
  static const background = Color(0xFF121214);
  static const panel = Color(0xFF1A1C22);
  static const edge = Color(0xFF10141D);
  static const deep = Color(0xFF0B0E14);
  static const blue1 = Color(0xFF4A8CF0);
  static const blue2 = Color(0xFF1D4CB5);
  static const blueEdge = Color(0xFF12306F);
  static const hotTop = Color(0xFFFF8A4A);
  static const hotBottom = Color(0xFFD83A1C);
  static const hotEdge = Color(0xFF6B1A0A);
  static const muted = Color(0xFF9A9CA6);
  static const goldText = Color(0xFF3A2600);
  static const gold = GameButtonStyle(
    Color(0xFFFFD75E),
    Color(0xFFD9961A),
    Color(0xFF6B4A0C),
  );
}

/// Raised dark panel with a 3D lip underneath. Taps are optional.
class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.radius = 16,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final body = Padding(padding: padding, child: child);
    return Container(
      decoration: BoxDecoration(
        color: GameColors.panel,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: GameColors.edge, width: 2),
        boxShadow: [
          const BoxShadow(color: GameColors.edge, offset: Offset(0, 5)),
          BoxShadow(
            color: Colors.black.withValues(alpha: .4),
            offset: const Offset(0, 9),
            blurRadius: 12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 2),
        child: onTap == null ? body : InkWell(onTap: onTap, child: body),
      ),
    );
  }
}

/// Glossy 3D square icon button.
class GameIconButton extends StatelessWidget {
  const GameIconButton({
    super.key,
    this.icon,
    this.child,
    this.size = 22,
    this.tooltip,
    this.onPressed,
  }) : assert(icon != null || child != null);

  final IconData? icon;
  final Widget? child;
  final double size;
  final String? tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final button = GameButton(
      onPressed: onPressed ?? () {},
      radius: 14,
      padding: const EdgeInsets.all(9),
      child: child ?? Icon(icon, size: size, color: Colors.white),
    );
    final message = tooltip;
    return message == null ? button : Tooltip(message: message, child: button);
  }
}

/// Colour of a [GameTag].
enum GameTagTone { blue, orange, green }

/// "QUESTION" / "DEBATE" label in the chosen [tone].
class GameTag extends StatelessWidget {
  const GameTag(this.label, {super.key, this.tone = GameTagTone.blue});

  final String label;
  final GameTagTone tone;

  static const _greenTop = Color(0xFF6BE58F);
  static const _greenBottom = Color(0xFF1FA655);
  static const _greenEdge = Color(0xFF0B5A2E);

  @override
  Widget build(BuildContext context) {
    final (edge, colors) = switch (tone) {
      GameTagTone.blue => (
          GameColors.blueEdge,
          const [GameColors.blue1, GameColors.blue2],
        ),
      GameTagTone.orange => (
          GameColors.hotEdge,
          const [GameColors.hotTop, GameColors.hotBottom],
        ),
      GameTagTone.green => (
          _greenEdge,
          const [_greenTop, _greenBottom],
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: edge, width: 2),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
        boxShadow: [BoxShadow(color: edge, offset: const Offset(0, 2))],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: .9,
          shadows: [Shadow(color: Color(0x66000000), offset: Offset(0, 1))],
        ),
      ),
    );
  }
}

/// Small raised counter such as 💬 2 or 👍 0. Non-interactive unless [onTap].
class GameCounter extends StatelessWidget {
  const GameCounter({
    super.key,
    required this.icon,
    required this.count,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final int count;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GameButton(
      pressed: active,
      onPressed: onTap ?? () {},
      radius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
