import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'sage_nav_models.dart';
import 'sage_nav_tokens.dart';

/// Length of the fan animation for [count] bubbles, including stagger.
Duration quickActionFanDuration(int count) {
  final stagger = SageNavTokens.fanStagger * (count - 1);
  return SageNavTokens.fanDuration + stagger;
}

/// Overlay content shown while the center button's menu is open.
///
/// Must be placed inside an [OverlayPortal] whose target is linked by [link]
/// to the center button. [progress] runs 0 (closed) to 1 (open) over
/// [quickActionFanDuration].
class QuickActionMenu extends StatelessWidget {
  const QuickActionMenu({
    required this.link,
    required this.actions,
    required this.progress,
    required this.closeLabel,
    required this.onDismiss,
    required this.onSelect,
    super.key,
  });

  final LayerLink link;
  final List<SageQuickAction> actions;
  final Animation<double> progress;
  final String closeLabel;
  final VoidCallback onDismiss;
  final ValueChanged<SageQuickAction> onSelect;

  static const _hitExtent =
      SageNavTokens.centerDiameter + 2 * SageNavTokens.haloWidth;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): onDismiss,
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDismiss,
              child: Semantics(
                button: true,
                label: closeLabel,
                child: FadeTransition(
                  opacity: progress,
                  child: const ColoredBox(color: SageNavTokens.scrimColor),
                ),
              ),
            ),
          ),
          // Positioned, so the fan keeps its own size instead of being
          // stretched to the whole screen (which would push the bubbles away
          // from the SAGE button).
          Positioned(
            left: 0,
            top: 0,
            child: CompositedTransformFollower(
              link: link,
              showWhenUnlinked: false,
              targetAnchor: Alignment.center,
              followerAnchor: Alignment.center,
              child: SizedBox.square(
                dimension: _hitExtent,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onDismiss,
                      ),
                    ),
                    for (var i = 0; i < actions.length; i++) _bubble(i),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(int index) {
    final action = actions[index];
    final offset = SageNavTokens.bubbleOffsets[index];
    final window = _window(index);
    final halfHit = _hitExtent / 2;
    const labelWidth = 96.0;
    final bubbleRadius = SageNavTokens.bubbleSize / 2;

    return Positioned(
      left: halfHit + offset.dx - labelWidth / 2,
      top: halfHit + offset.dy - bubbleRadius,
      width: labelWidth,
      child: AnimatedBuilder(
        animation: progress,
        builder: (context, child) {
          final t = window.transform(progress.value);
          final scale = 0.2 + 0.8 * t;
          return Opacity(
            opacity: t.clamp(0.0, 1.0).toDouble(),
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                button: true,
                label: action.label,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  autofocus: index == 0,
                  onTap: () => onSelect(action),
                  child: Container(
                    width: SageNavTokens.bubbleSize,
                    height: SageNavTokens.bubbleSize,
                    decoration: const BoxDecoration(
                      color: SageNavTokens.bubbleColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: _glyph(action),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              ExcludeSemantics(
                child: Text(
                  action.label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SageNavTokens.iconColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glyph(SageQuickAction action) {
    final svgAsset = action.svgAsset;
    if (svgAsset != null) {
      return SvgPicture.asset(svgAsset, width: 24, height: 24);
    }
    final icon = action.icon;
    if (icon != null) {
      return Icon(icon, size: 24, color: SageNavTokens.iconColor);
    }
    return Text(action.emoji!, style: const TextStyle(fontSize: 24));
  }

  Interval _window(int index) {
    final total = quickActionFanDuration(actions.length).inMilliseconds;
    final start = (SageNavTokens.fanStagger * index).inMilliseconds / total;
    final end = start + SageNavTokens.fanDuration.inMilliseconds / total;
    return Interval(start, end, curve: SageNavTokens.springCurve);
  }
}
