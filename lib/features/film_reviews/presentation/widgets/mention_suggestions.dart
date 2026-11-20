import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/widgets/luxe_palette.dart';
import '../../../social/data/social_models.dart';
import '../../../social/data/social_repository.dart';

/// The viewer's friends, fetched once and shared by every comment composer
/// so typing `@` can suggest who to tag.
abstract final class MentionFriends {
  static Future<List<SocialUser>>? _pending;

  /// The friends list; a failed fetch is retried on the next call.
  static Future<List<SocialUser>> load([SocialRepository? social]) {
    return _pending ??= (social ?? SocialRepository())
        .connections()
        .then((connections) => connections.friends)
        .catchError((Object _) {
      _pending = null;
      return const <SocialUser>[];
    });
  }

  /// Forgets the cached list (after sign-out or a new friendship).
  static void reset() => _pending = null;
}

final _mentionQuery = RegExp(r'(?:^|\s)@([\w.+-]*)$');

/// The partial name after an `@` right before the cursor, or null.
String? mentionQueryAt(TextEditingValue value) {
  final cursor = value.selection.baseOffset;
  if (cursor < 0 || cursor > value.text.length) return null;
  return _mentionQuery.firstMatch(value.text.substring(0, cursor))?.group(1);
}

/// [value] with the `@partial` before the cursor replaced by `@username `.
TextEditingValue insertMention(TextEditingValue value, String username) {
  final cursor = value.selection.baseOffset;
  final before = value.text.substring(0, cursor);
  final match = _mentionQuery.firstMatch(before);
  if (match == null) return value;
  final start = before.lastIndexOf('@');
  final inserted = '@$username ';
  final text = value.text.replaceRange(start, cursor, inserted);
  return TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: start + inserted.length),
  );
}

/// Friend chips shown above the comment box while the viewer types `@name`.
/// Picking one completes the name.
class MentionSuggestions extends StatelessWidget {
  const MentionSuggestions({
    super.key,
    required this.controller,
    required this.friends,
  });

  final TextEditingController controller;
  final List<SocialUser> friends;

  static const _maxShown = 6;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final query = mentionQueryAt(value)?.toLowerCase();
        if (query == null) return const SizedBox.shrink();
        final matches = [
          for (final friend in friends)
            if (friend.username.toLowerCase().startsWith(query) &&
                friend.username.toLowerCase() != query)
              friend,
        ].take(_maxShown).toList();
        if (matches.isEmpty) return const SizedBox.shrink();

        return Semantics(
          container: true,
          label: context.l10n.mentionSuggestionsLabel,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: matches.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final friend = matches[index];
                  return ActionChip(
                    key: ValueKey('mention-${friend.id}'),
                    backgroundColor: LuxeColors.surface2,
                    side: BorderSide(color: LuxeColors.hair),
                    avatar: CircleAvatar(
                      backgroundColor: LuxeColors.accentLo,
                      child: Text(
                        friend.username.isEmpty
                            ? '?'
                            : friend.username[0].toUpperCase(),
                        style: TextStyle(
                          color: LuxeColors.text,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    label: Text(
                      '@${friend.username}',
                      style: TextStyle(color: LuxeColors.text),
                    ),
                    onPressed: () => controller.value =
                        insertMention(controller.value, friend.username),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
