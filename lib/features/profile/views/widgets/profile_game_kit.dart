import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/game_button.dart';

/// Game-style building blocks for the SAGE profile.
/// Three looks: RAISED (tappable), SUNK-IN + blue (selected), RECESSED (progress track).
///
/// Example:
///   Row(children: [
///     Expanded(child: GameStatCard(label: 'Reviews', value: '13', color: Color(0xFF6AA8FF))),
///     ...
///   ])
///   LevelPill(level: 4),
///   GameProgressBar(value: 11 / 250),
///   GameFrameTile(equipped: true, onTap: () {}, child: yourLottieFrame),
///   GameAchievementCard(icon: yourIcon, title: 'Film critic', subtitle: 'Write 10 reviews.', progress: 13, goal: 10),
///   GameChip(label: 'helmi90', avatar: NetworkImage(url), onTap: () {}),

Color get _edge => themed(const Color(0xFF10141D), const Color(0xFFD6CFC2));
Color get _deep => themed(const Color(0xFF0B0E14), const Color(0xFFCFC8BA));
const _blue1 = Color(0xFF4A8CF0);
const _blue2 = Color(0xFF1D4CB5);
const _blueEdge = Color(0xFF12306F);

/// Raised dark panel.
class GameCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const GameCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _edge, width: 2),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              themed(const Color(0xFF2A3142), const Color(0xFFEEEAE1)),
              themed(const Color(0xFF1B2030), const Color(0xFFE6E0D5)),
            ],
          ),
          boxShadow: [
            BoxShadow(color: _deep, offset: Offset(0, 5)),
            BoxShadow(
                color: themed(Colors.black.withValues(alpha: .4),
                    const Color(0x221A1814)),
                offset: const Offset(0, 9),
                blurRadius: 12),
          ],
        ),
        child: child,
      );
}

/// Reviews / Reactions / Comments.
class GameStatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const GameStatCard(
      {super.key,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) => GameCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: themed(
                      const Color(0xFFAAB2C5), const Color(0xFF615B50)))),
          Text(value,
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800, color: color)),
        ]),
      );
}

/// "LEVEL 4" pill. [label] overrides the English text so it can be localized.
class LevelPill extends StatelessWidget {
  final int level;
  final String? label;
  const LevelPill({super.key, required this.level, this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_blue1, _blue2]),
          border: Border.all(color: _blueEdge, width: 2),
          boxShadow: const [BoxShadow(color: _blueEdge, offset: Offset(0, 3))],
        ),
        child: Text(label ?? 'LEVEL $level',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 2.4,
              shadows: [Shadow(color: Color(0x66000000), offset: Offset(0, 1))],
            )),
      );
}

/// Recessed track + glossy blue fill. Animates from 0 when it first appears.
class GameProgressBar extends StatelessWidget {
  final double value; // 0..1
  final double height;
  const GameProgressBar({super.key, required this.value, this.height = 14});

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: v),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height),
          border: Border.all(color: _edge, width: 2),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                themed(const Color(0xFF05070B), const Color(0xFFCFC8BA)),
                _deep
              ]), // darker at the top = sunk in
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: t == 0 ? 0 : t.clamp(0.04, 1.0),
              heightFactor: 1,
              child: Stack(fit: StackFit.expand, children: [
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF5B9BFF), Color(0xFF2B5FD0)]),
                  ),
                ),
                Positioned(
                  left: 4,
                  right: 4,
                  top: 2,
                  height: height * .3,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Frame picker tile. equipped = sunk-in + blue, locked = dimmed with a lock.
class GameFrameTile extends StatelessWidget {
  final Widget child; // your Lottie frame / avatar
  final bool equipped, locked;
  final VoidCallback? onTap;
  const GameFrameTile(
      {super.key,
      required this.child,
      this.equipped = false,
      this.locked = false,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final edge = equipped ? _blueEdge : _edge;
    return GestureDetector(
      onTap: locked ? null : onTap,
      child: Opacity(
        opacity: locked ? .6 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 92,
          height: 92,
          margin:
              EdgeInsets.only(top: equipped ? 3 : 0, bottom: equipped ? 2 : 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: edge, width: 2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: equipped
                  ? const [_blue1, _blue2]
                  : [
                      themed(const Color(0xFF2A3142), const Color(0xFFEEEAE1)),
                      themed(const Color(0xFF1B2030), const Color(0xFFE6E0D5))
                    ],
            ),
            boxShadow: [
              BoxShadow(color: edge, offset: Offset(0, equipped ? 2 : 5))
            ],
          ),
          child: Stack(alignment: Alignment.center, children: [
            child,
            if (locked)
              const Positioned(
                  right: 6,
                  bottom: 4,
                  child: Icon(BootstrapIcons.lock_fill,
                      size: 16, color: Colors.white70)),
          ]),
        ),
      ),
    );
  }
}

/// Badge circle. locked = gray + dim, owned = blue glow.
class GameBadge extends StatelessWidget {
  final Widget child; // your Lottie badge / icon
  final bool locked, owned;
  const GameBadge(
      {super.key,
      required this.child,
      this.locked = false,
      this.owned = false});

  static const _gray = ColorFilter.matrix([
    .2126,
    .7152,
    .0722,
    0,
    0,
    .2126,
    .7152,
    .0722,
    0,
    0,
    .2126,
    .7152,
    .0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);

  @override
  Widget build(BuildContext context) {
    Widget w = Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: owned ? _blue1 : _edge, width: 3),
        boxShadow: [
          BoxShadow(
              color: owned ? _blueEdge : _edge, offset: const Offset(0, 4)),
          if (owned)
            BoxShadow(color: _blue1.withValues(alpha: .7), blurRadius: 18),
        ],
      ),
      child: ClipOval(child: child),
    );
    if (locked)
      w = Opacity(
          opacity: .55, child: ColorFiltered(colorFilter: _gray, child: w));
    return w;
  }
}

/// Achievement row. done = gold icon ring and a check.
/// [comingSoonLabel] is shown instead of the bar when the item is not tracked yet.
class GameAchievementCard extends StatelessWidget {
  final Widget icon;
  final String title, subtitle;
  final int progress, goal;
  final bool comingSoon;
  final String comingSoonLabel;
  const GameAchievementCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.progress = 0,
    this.goal = 1,
    this.comingSoon = false,
    this.comingSoonLabel = 'Coming soon',
  });

  @override
  Widget build(BuildContext context) {
    final done = progress >= goal && !comingSoon;
    return Opacity(
      opacity: comingSoon ? .65 : 1,
      child: GameCard(
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: done ? const Color(0xFFFFD75E) : _edge, width: 3),
              boxShadow: [
                BoxShadow(color: _edge, offset: Offset(0, 3)),
                if (done)
                  BoxShadow(
                      color: const Color(0xFFFFC83C).withValues(alpha: .5),
                      blurRadius: 14),
              ],
            ),
            child: ClipOval(child: icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 13,
                      color: themed(
                          const Color(0xFFAAB2C5), const Color(0xFF615B50)))),
              const SizedBox(height: 8),
              if (comingSoon)
                Text(comingSoonLabel,
                    style: TextStyle(
                        fontSize: 12,
                        color: themed(
                            const Color(0xFF9A9CA6), const Color(0xFF615B50))))
              else
                Row(children: [
                  Expanded(child: GameProgressBar(value: progress / goal)),
                  const SizedBox(width: 8),
                  Text('$progress/$goal${done ? ' ✓' : ''}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Following / Followers chip = a small raised GameButton.
class GameChip extends StatelessWidget {
  final String label;
  final ImageProvider? avatar;
  final VoidCallback? onTap;
  const GameChip({super.key, required this.label, this.avatar, this.onTap});

  @override
  Widget build(BuildContext context) => GameButton(
        onPressed: onTap,
        radius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: const Color(0xFF2D4D78),
            backgroundImage: avatar,
            child: avatar == null
                ? Text(label.isEmpty ? '?' : label[0].toUpperCase(),
                    style: const TextStyle(fontSize: 11, color: Colors.white))
                : null,
          ),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  color: themed(Colors.white, const Color(0xFF1A1814)),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  shadows: AppPalette.current.isDark
                      ? const [
                          Shadow(
                              color: Color(0x73000000), offset: Offset(0, 1.5))
                        ]
                      : null)),
        ]),
      );
}

/// Round icon button for back / search / bell / edit / camera.
/// Pass [icon] or [child] (for custom content such as an SVG). [tooltip] keeps it accessible.
class GameIconButton extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final GameButtonStyle style;
  final double size;
  final String? tooltip;
  final VoidCallback? onPressed;
  const GameIconButton({
    super.key,
    this.icon,
    this.child,
    this.style = GameButtonStyle.dark,
    this.size = 22,
    this.tooltip,
    this.onPressed,
  }) : assert(icon != null || child != null);

  @override
  Widget build(BuildContext context) {
    final button = GameButton(
      style: style,
      radius: 30,
      padding: const EdgeInsets.all(9),
      onPressed: onPressed,
      child: child ??
          Icon(
            icon,
            size: size,
            // Quiet buttons are paper in light mode, so the icon is ink;
            // the blue (black in light mode) style keeps a white icon.
            color: identical(style, GameButtonStyle.dark)
                ? themed(Colors.white, const Color(0xFF1A1814))
                : Colors.white,
          ),
    );
    final message = tooltip;
    return message == null ? button : Tooltip(message: message, child: button);
  }
}
