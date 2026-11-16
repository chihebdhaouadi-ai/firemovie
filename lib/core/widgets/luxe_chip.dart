import 'package:flutter/material.dart';

import 'luxe_palette.dart';

/// Pill-shaped control in the same style as the You / Friends / Films tab bar:
/// a dark surface with a hairline border when idle, and the blue accent
/// gradient with a soft glow when [selected].
class LuxeChip extends StatelessWidget {
  const LuxeChip({
    super.key,
    required this.child,
    this.selected = false,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  final Widget child;
  final bool selected;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  static final _radius = BorderRadius.circular(12);

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : LuxeColors.muted;

    final body = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: padding,
      decoration: BoxDecoration(
        color: selected ? null : LuxeColors.surface,
        gradient: selected ? LuxeColors.accentGradient : null,
        borderRadius: _radius,
        border: selected ? null : Border.all(color: LuxeColors.hair),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: LuxeColors.accent.withValues(alpha: .35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: .2,
        ),
        child: IconTheme(
          data: IconThemeData(color: foreground, size: 16),
          child: child,
        ),
      ),
    );

    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: _radius,
        onTap: onTap,
        child: body,
      ),
    );
  }
}

/// Icon + count button in the Luxe style, e.g. 👍 3 or 💬 12.
class LuxeCounter extends StatelessWidget {
  const LuxeCounter({
    super.key,
    required this.icon,
    required this.count,
    this.selected = false,
    this.onTap,
  });

  final IconData icon;
  final int count;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LuxeChip(
      selected: selected,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 6),
          Text('$count'),
        ],
      ),
    );
  }
}
