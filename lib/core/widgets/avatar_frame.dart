import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../avatar_frames.dart';
import '../theme/app_theme.dart';
import '../stable_image_key.dart';

/// Avatar wearing an animated cadre (frame). The frame ring is drawn at 180%
/// of the avatar size, centred on it, the same way the design lays it out.
class AvatarFrame extends StatelessWidget {
  const AvatarFrame({
    super.key,
    required this.size,
    this.frame,
    this.avatarUrl,
    this.initial = '',
    this.backgroundColor,
    this.animate = true,
    this.ringWidth = 2,
    this.framed = true,
    this.ringColor,
  });

  /// Diameter of the avatar itself (the frame overlays a bigger area).
  final double size;

  /// Frame key such as `explorer` or `gold`. Null falls back to the default.
  final String? frame;
  final String? avatarUrl;
  final String initial;

  /// Fill behind the avatar; defaults to [AppColors.surfaceRaised].
  final Color? backgroundColor;
  final bool animate;
  final double ringWidth;

  /// When false only the plain avatar is drawn (no cadre overlay).
  final bool framed;

  /// Colour of the thin ring around the photo, inside the frame.
  /// Ring colour; defaults to [AppColors.accentGlow].
  final Color? ringColor;

  static const _ringScale = 1.8;

  @override
  Widget build(BuildContext context) {
    final overlay = size * _ringScale;
    final frameKey = frameKeyOrDefault(frame);

    final face = _Face(
      size: size,
      avatarUrl: avatarUrl,
      initial: initial,
      backgroundColor: backgroundColor ?? AppColors.surfaceRaised,
      ringWidth: ringWidth,
      ringColor: ringColor ?? AppColors.accentGlow,
    );
    if (!framed) return face;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          face,
          IgnorePointer(
            child: OverflowBox(
              maxWidth: overlay,
              maxHeight: overlay,
              child: Lottie.asset(
                'assets/lottie/frame_$frameKey.json',
                width: overlay,
                height: overlay,
                fit: BoxFit.contain,
                repeat: animate,
                animate: animate,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The plain round avatar: photo when available, otherwise the initial.
class _Face extends StatelessWidget {
  const _Face({
    required this.size,
    required this.avatarUrl,
    required this.initial,
    required this.backgroundColor,
    required this.ringWidth,
    required this.ringColor,
  });

  final double size;
  final String? avatarUrl;
  final String initial;
  final Color backgroundColor;
  final double ringWidth;
  final Color ringColor;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    final theme = Theme.of(context);
    final letter = initial.isEmpty ? '' : initial.substring(0, 1).toUpperCase();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: ringWidth > 0
            ? Border.all(color: ringColor, width: ringWidth)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: url == null || url.isEmpty
          ? Text(
              letter,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontSize: size * 0.38,
                fontWeight: FontWeight.w600,
              ),
            )
          : CachedNetworkImage(
              imageUrl: url,
              cacheKey: stableImageKey(url),
              fit: BoxFit.cover,
              width: size,
              height: size,
              errorWidget: (context, url, error) => Text(
                letter,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontSize: size * 0.38,
                ),
              ),
            ),
    );
  }
}
