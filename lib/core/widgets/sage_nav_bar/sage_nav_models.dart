import 'package:flutter/widgets.dart';

class SageNavItem {
  const SageNavItem({
    required this.icon,
    required this.label,
    this.svgAsset,
    this.showBadge = false,
    this.avatar,
    this.avatarInitial,
  });

  /// Material icon used when no [svgAsset] is given, and as the avatar fallback.
  final IconData icon;

  /// Asset path of a SAGE SVG icon (for example `assets/svg/home.svg`). When
  /// set, it is drawn instead of [icon] in the tab.
  final String? svgAsset;
  final String label;
  final bool showBadge;
  final ImageProvider? avatar;
  final String? avatarInitial;
}

class SageQuickAction {
  const SageQuickAction({
    required this.label,
    required this.onTap,
    this.icon,
    this.emoji,
    this.svgAsset,
  }) : assert(
          (icon != null ? 1 : 0) +
                  (emoji != null ? 1 : 0) +
                  (svgAsset != null ? 1 : 0) ==
              1,
          'Provide exactly one of icon, emoji or svgAsset.',
        );

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final String? emoji;
  final String? svgAsset;
}
