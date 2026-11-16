import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Shows a subtle right-edge cue while a horizontal list has more content.
class HorizontalScrollHint extends StatefulWidget {
  const HorizontalScrollHint({
    super.key,
    required this.controller,
    required this.child,
    required this.height,
  });

  final ScrollController controller;
  final Widget child;
  final double height;

  @override
  State<HorizontalScrollHint> createState() => _HorizontalScrollHintState();
}

class _HorizontalScrollHintState extends State<HorizontalScrollHint> {
  bool _hasMore = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateHasMore);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHasMore());
  }

  @override
  void didUpdateWidget(covariant HorizontalScrollHint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_updateHasMore);
    widget.controller.addListener(_updateHasMore);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHasMore());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateHasMore);
    super.dispose();
  }

  void _updateHasMore() {
    if (!mounted || !widget.controller.hasClients) return;
    final position = widget.controller.position;
    if (!position.hasContentDimensions) return;
    final hasMore = position.extentAfter > 1;
    if (hasMore != _hasMore) setState(() => _hasMore = hasMore);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: NotificationListener<ScrollMetricsNotification>(
        onNotification: (_) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _updateHasMore());
          return false;
        },
        child: Stack(
          children: [
            Positioned.fill(child: widget.child),
            if (_hasMore)
              const PositionedDirectional(
                end: 0,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: SizedBox(
                    width: 42,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: AlignmentDirectional.centerStart,
                          end: AlignmentDirectional.centerEnd,
                          colors: [
                            Color(0x00121414),
                            Color(0xE6121214),
                          ],
                        ),
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
