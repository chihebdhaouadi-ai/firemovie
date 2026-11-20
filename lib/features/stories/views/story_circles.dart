import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/widgets/avatar_frame.dart';
import '../../../core/widgets/luxe_palette.dart';
import '../data/friend_story.dart';

/// Height of the row of story circles when the home header is expanded.
const storyStripHeight = 84.0;

const _ringSize = 56.0;
const _stackSize = 28.0;
const _stackOverlap = 12.0;
const _stackMax = 3;

/// A friend's avatar inside a story ring: a bright gradient ring while they
/// have something new, a faint one once it was all watched.
class StoryRing extends StatelessWidget {
  const StoryRing({
    super.key,
    required this.story,
    required this.seen,
    required this.size,
  });

  final FriendStory story;
  final bool seen;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ring = (size * .07).clamp(1.5, 3.0);
    final gap = (size * .05).clamp(1.0, 3.0);
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(ring),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: seen
            ? null
            : const SweepGradient(
                colors: [
                  Color(0xFFFF8A3D),
                  Color(0xFFFF3D7F),
                  Color(0xFF8A5CFF),
                  Color(0xFF3DA9FF),
                  Color(0xFFFF8A3D),
                ],
              ),
        color: seen ? LuxeColors.hair : null,
      ),
      child: Container(
        padding: EdgeInsets.all(gap),
        decoration: BoxDecoration(shape: BoxShape.circle, color: LuxeColors.bg),
        child: AvatarFrame(
          size: size - 2 * (ring + gap),
          avatarUrl: story.avatarUrl,
          initial:
              story.username.isEmpty ? '' : story.username[0].toUpperCase(),
          framed: false,
          animate: false,
          ringWidth: 0,
        ),
      ),
    );
  }
}

/// The friends' story circles in a scrolling row, with names under them.
/// [collapse] (0 expanded, 1 collapsed) shrinks and fades them as the header
/// folds away; the [StoryStack] takes over in the top row.
class StoryStrip extends StatelessWidget {
  const StoryStrip({
    super.key,
    required this.stories,
    required this.isSeen,
    required this.onOpen,
    required this.collapse,
  });

  final List<FriendStory> stories;
  final bool Function(FriendStory story) isSeen;
  final ValueChanged<int> onOpen;
  final double collapse;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = collapse.clamp(0.0, 1.0);
    final size = _ringSize - (_ringSize - _stackSize) * c;
    final nameOpacity = (1 - c * 3).clamp(0.0, 1.0);

    return Opacity(
      opacity: (1 - c * 1.4).clamp(0.0, 1.0),
      child: SizedBox(
        height: storyStripHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(top: 4),
          itemCount: stories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final story = stories[index];
            return Semantics(
              button: true,
              label: l10n.storyRingLabel(story.username),
              excludeSemantics: true,
              child: GestureDetector(
                key: Key('story-${story.userId}'),
                behavior: HitTestBehavior.opaque,
                onTap: () => onOpen(index),
                child: SizedBox(
                  width: _ringSize + 8,
                  child: Column(
                    children: [
                      SizedBox(
                        height: _ringSize,
                        child: Center(
                          child: StoryRing(
                            story: story,
                            seen: isSeen(story),
                            size: size,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Opacity(
                        opacity: nameOpacity,
                        child: Text(
                          story.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: LuxeColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The collapsed form: the first few friends' circles overlapping in a small
/// stack. Tapping it opens the first story that has something new.
class StoryStack extends StatelessWidget {
  const StoryStack({
    super.key,
    required this.stories,
    required this.isSeen,
    required this.onOpen,
  });

  final List<FriendStory> stories;
  final bool Function(FriendStory story) isSeen;
  final ValueChanged<int> onOpen;

  /// Width the stack takes for [count] stories.
  static double widthFor(int count) {
    final shown = count.clamp(0, _stackMax);
    return shown == 0
        ? 0
        : _stackSize + (shown - 1) * (_stackSize - _stackOverlap);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shown = stories.take(_stackMax).toList();
    final firstNew = stories.indexWhere((story) => !isSeen(story));

    return Semantics(
      button: true,
      label: l10n.storiesTitle,
      excludeSemantics: true,
      child: GestureDetector(
        key: const Key('story-stack'),
        behavior: HitTestBehavior.opaque,
        onTap: () => onOpen(firstNew < 0 ? 0 : firstNew),
        child: SizedBox(
          width: widthFor(stories.length),
          height: 44,
          child: Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [
              // Back to front, so the first friend sits on top.
              for (var i = shown.length - 1; i >= 0; i--)
                PositionedDirectional(
                  start: i * (_stackSize - _stackOverlap),
                  child: StoryRing(
                    story: shown[i],
                    seen: isSeen(shown[i]),
                    size: _stackSize,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
