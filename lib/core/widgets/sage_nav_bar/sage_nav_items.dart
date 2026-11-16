import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'sage_nav_models.dart';
import 'sage_nav_tokens.dart';

class SageNavTabItem extends StatelessWidget {
  const SageNavTabItem({
    required this.item,
    required this.semanticsLabel,
    required this.selected,
    required this.boing,
    required this.onTap,
    this.badge,
    super.key,
  });

  final SageNavItem item;
  final String semanticsLabel;
  final bool selected;

  /// 0 at rest, 1 at the peak of the tap bounce.
  final double boing;
  final VoidCallback onTap;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final lift = -SageNavTokens.boingLift * boing;
    final scale = 1 + (SageNavTokens.boingScale - 1) * boing;
    final hasAvatar = item.avatar != null || item.avatarInitial != null;

    final Widget glyph = hasAvatar
        ? SageAvatar(
            icon: item.icon,
            image: item.avatar,
            initial: item.avatarInitial,
            halo: selected ? 1 : 0,
          )
        : item.svgAsset != null
            ? SvgPicture.asset(
                item.svgAsset!,
                width: SageNavTokens.tabIconSize,
                height: SageNavTokens.tabIconSize,
              )
            : Icon(
                item.icon,
                size: SageNavTokens.tabIconSize,
                color: SageNavTokens.iconColor,
              );

    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: SageNavTokens.minTapTarget,
            minHeight: SageNavTokens.minTapTarget,
          ),
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, lift),
                  child: Transform.scale(
                    scale: scale,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        glyph,
                        if (badge != null)
                          Positioned(right: -4, top: -2, child: badge!),
                      ],
                    ),
                  ),
                ),
                if (item.label.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: SageNavTokens.iconColor,
                      fontSize: SageNavTokens.tabLabelSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Unread dot. [presence] is 1 while shown and 0 once hidden; [ping] drives
/// the outward ring and is null when motion is disabled.
class SageNavBadge extends StatelessWidget {
  const SageNavBadge({required this.presence, this.ping, super.key});

  final Animation<double> presence;
  final Animation<double>? ping;

  @override
  Widget build(BuildContext context) {
    final pingAnimation = ping;
    return AnimatedBuilder(
      animation: Listenable.merge([
        presence,
        if (pingAnimation != null) pingAnimation,
      ]),
      builder: (context, _) {
        final visible = math.max(0.0, presence.value);
        final pingValue = pingAnimation?.value ?? 0.0;
        return SizedBox.square(
          dimension: SageNavTokens.unreadDotSize,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (pingAnimation != null)
                Opacity(
                  opacity: ((1 - pingValue) * 0.7 * visible.clamp(0.0, 1.0))
                      .clamp(0.0, 1.0)
                      .toDouble(),
                  child: Transform.scale(
                    scale:
                        1 + (SageNavTokens.badgePingMaxScale - 1) * pingValue,
                    child: const _Dot(),
                  ),
                ),
              Transform.scale(scale: visible, child: const _Dot()),
            ],
          ),
        );
      },
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SageNavTokens.unreadDotSize,
      height: SageNavTokens.unreadDotSize,
      decoration: const BoxDecoration(
        color: SageNavTokens.unreadColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

class SageAvatar extends StatelessWidget {
  const SageAvatar({
    required this.icon,
    this.image,
    this.initial,
    this.halo = 0,
    super.key,
  });

  final IconData icon;
  final ImageProvider? image;
  final String? initial;

  /// 0 to 1, strength of the soft blue halo.
  final double halo;

  @override
  Widget build(BuildContext context) {
    final fallback = _AvatarFallback(icon: icon, initial: initial);
    final photo = image;
    final inner = photo == null
        ? fallback
        : Stack(
            fit: StackFit.expand,
            children: [
              fallback,
              Image(
                image: photo,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => fallback,
              ),
            ],
          );

    final haloStrength = halo.clamp(0.0, 1.0).toDouble();
    return Container(
      width: SageNavTokens.avatarSize,
      height: SageNavTokens.avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: SageNavTokens.avatarRing,
          width: SageNavTokens.avatarRingWidth,
        ),
        boxShadow: haloStrength == 0
            ? null
            : [
                BoxShadow(
                  color: SageNavTokens.avatarRing.withValues(
                    alpha: 0.55 * haloStrength,
                  ),
                  blurRadius: 14 * haloStrength,
                  spreadRadius: 1.5 * haloStrength,
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(SageNavTokens.avatarRingWidth),
        child: ClipOval(child: inner),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.icon, this.initial});

  final IconData icon;
  final String? initial;

  @override
  Widget build(BuildContext context) {
    final name = initial?.trim();
    return ColoredBox(
      color: SageNavTokens.bubbleColor,
      child: Center(
        child: name == null || name.isEmpty
            ? Icon(icon, size: 18, color: SageNavTokens.iconColor)
            : Text(
                name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: SageNavTokens.iconColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
