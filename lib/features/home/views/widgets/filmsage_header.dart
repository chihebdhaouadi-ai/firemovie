import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/app_theme.dart';

const _kBarHeight = 56.0;
const _kTipHeight = 56.0;
const _kTabBarHeight = 48.0;
const _kMuted = Color(0xFFC9CBD8);

const _kTips = <String>[
  'See your friends’ movie suggestions',
  'Stay connected with your circle',
  'Write reviews & interact',
  'More interaction = more notifications + XP',
];

/// Pinned home header, collapsing like a SliverAppBar. The expanded tip row
/// shrinks away on scroll while the top row and the You / Friends / Films tab
/// bar stay pinned at the top.
class FilmsageHeaderDelegate extends SliverPersistentHeaderDelegate {
  FilmsageHeaderDelegate({
    required this.padding,
    required this.tabBar,
    required this.tabBarVerticalPadding,
    required this.notificationCount,
    required this.onAddFilm,
    required this.onOpenNotifications,
    required this.addLabel,
    required this.notificationsLabel,
  });

  final EdgeInsets padding;
  final Widget tabBar;
  final double tabBarVerticalPadding;
  final int notificationCount;
  final VoidCallback onAddFilm;
  final VoidCallback onOpenNotifications;
  final String addLabel;
  final String notificationsLabel;

  /// Top row + tab bar (always visible).
  double get _pinnedHeight =>
      padding.vertical +
      _kBarHeight +
      _kTabBarHeight +
      tabBarVerticalPadding * 2;

  @override
  double get minExtent => _pinnedHeight;

  @override
  double get maxExtent => _pinnedHeight + _kTipHeight;

  // Always rebuild: the tab bar's selection and unread dot come from the parent.
  @override
  bool shouldRebuild(covariant FilmsageHeaderDelegate oldDelegate) => true;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = maxExtent - minExtent;
    final progress = (shrinkOffset / range).clamp(0.0, 1.0);
    // Never shorter than the pinned part, even if scroll overshoot reports a
    // shrinkOffset slightly past the collapse point.
    return SizedBox(
      height: math.max(minExtent, maxExtent - shrinkOffset),
      child: Padding(
        padding: padding,
        child: FilmsageHeader(
          progress: progress,
          tabBar: tabBar,
          tabBarVerticalPadding: tabBarVerticalPadding,
          notificationCount: notificationCount,
          onAddFilm: onAddFilm,
          onOpenNotifications: onOpenNotifications,
          addLabel: addLabel,
          notificationsLabel: notificationsLabel,
        ),
      ),
    );
  }
}

class FilmsageHeader extends StatefulWidget {
  const FilmsageHeader({
    super.key,
    required this.progress,
    required this.tabBar,
    required this.tabBarVerticalPadding,
    required this.notificationCount,
    required this.onAddFilm,
    required this.onOpenNotifications,
    required this.addLabel,
    required this.notificationsLabel,
  });

  /// 0 = fully expanded, 1 = fully collapsed.
  final double progress;
  final Widget tabBar;
  final double tabBarVerticalPadding;
  final int notificationCount;
  final VoidCallback onAddFilm;
  final VoidCallback onOpenNotifications;
  final String addLabel;
  final String notificationsLabel;

  @override
  State<FilmsageHeader> createState() => _FilmsageHeaderState();
}

class _FilmsageHeaderState extends State<FilmsageHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _xpController;
  Timer? _tipTimer;
  int _tipIndex = 0;

  @override
  void initState() {
    super.initState();
    _xpController = AnimationController(vsync: this);
    _tipTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() => _tipIndex = (_tipIndex + 1) % _kTips.length);
    });
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    _xpController.dispose();
    super.dispose();
  }

  void _onNotificationsTap() {
    _xpController.forward(from: 0);
    widget.onOpenNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.progress;
    final tipOpacity = math.max(0.0, 1 - p * 1.6);

    return ClipRect(
      // The tip row's height shrinks with the scroll; its content is clipped
      // rather than overflowing while it collapses.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: _kBarHeight, child: _buildTopRow(p)),
          SizedBox(
            height: _kTipHeight * (1 - p),
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.topCenter,
                minHeight: _kTipHeight,
                maxHeight: _kTipHeight,
                child: Opacity(
                  opacity: tipOpacity,
                  child: _buildTipRow(),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: widget.tabBarVerticalPadding,
            ),
            child: SizedBox(height: _kTabBarHeight, child: widget.tabBar),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRow(double p) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Clapper + sparkles behind the wordmark, fading out as it collapses.
        Positioned.fill(
          child: Opacity(
            opacity: 1 - p,
            child: Lottie.asset(
              'assets/lottie/header_sparkles.json',
              repeat: true,
              fit: BoxFit.contain,
            ),
          ),
        ),
        // The wordmark is fitted between the two buttons so it can never
        // overflow them, even on narrow screens or large text scales.
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _kBarHeight),
            child: Center(
              child: Transform.scale(
                scale: 1 - p * 0.2,
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'FILMSAGE',
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: AppFonts.brand,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: _HeaderButton(
            onTap: widget.onAddFilm,
            tooltip: widget.addLabel,
            child: const Icon(Icons.add, size: 28, color: Colors.white),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: _HeaderButton(
            onTap: _onNotificationsTap,
            tooltip: widget.notificationsLabel,
            child: Badge(
              isLabelVisible: widget.notificationCount > 0,
              label: Text('${widget.notificationCount}'),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 26,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // XP star burst, played once per notifications tap.
        Positioned(
          right: 6,
          top: 2,
          width: 64,
          height: 64,
          child: IgnorePointer(
            child: Lottie.asset(
              'assets/lottie/header_xp_star.json',
              controller: _xpController,
              onLoaded: (composition) {
                _xpController.duration = composition.duration;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Transform.rotate(
                  angle: -135 * math.pi / 180,
                  child: const SizedBox.square(
                    dimension: 34,
                    child: _HeaderArrow(),
                  ),
                ),
                const SizedBox(width: 2),
                const Flexible(
                  child: Text(
                    'Create your topic',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: Text(
                      _kTips[_tipIndex],
                      key: ValueKey<int>(_tipIndex),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _kMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Transform.rotate(
                  angle: -45 * math.pi / 180,
                  child: const SizedBox.square(
                    dimension: 34,
                    child: _HeaderArrow(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderArrow extends StatelessWidget {
  const _HeaderArrow();

  @override
  Widget build(BuildContext context) {
    return Lottie.asset('assets/lottie/header_arrow.json', repeat: true);
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.onTap,
    required this.tooltip,
    required this.child,
    this.background,
  });

  final VoidCallback onTap;
  final String tooltip;
  final Widget child;
  final Widget? background;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: _kBarHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (background != null)
                Positioned.fill(
                  child: IgnorePointer(child: background!),
                ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
