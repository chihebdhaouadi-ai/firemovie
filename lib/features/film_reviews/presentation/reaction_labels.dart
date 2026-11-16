import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/film_reaction.dart';
import '../domain/take.dart';
import '../domain/take_tag.dart';
import '../domain/vote_kind.dart';

String reactionLabel(AppLocalizations l10n, FilmReaction reaction) {
  return switch (reaction) {
    FilmReaction.loved => l10n.reviewReactionLoved,
    FilmReaction.brokeHeart => l10n.reviewReactionBrokeHeart,
    FilmReaction.blewMind => l10n.reviewReactionBlewMind,
    FilmReaction.madeCry => l10n.reviewReactionMadeCry,
    FilmReaction.shocked => l10n.reviewReactionShocked,
    FilmReaction.madeLaugh => l10n.reviewReactionMadeLaugh,
    FilmReaction.bored => l10n.reviewReactionBored,
    FilmReaction.disappointed => l10n.reviewReactionDisappointed,
    FilmReaction.madeThink => l10n.reviewReactionMadeThink,
    FilmReaction.masterpiece => l10n.reviewReactionMasterpiece,
  };
}

String reactionEmoji(FilmReaction reaction) {
  return switch (reaction) {
    FilmReaction.loved => '❤️',
    FilmReaction.brokeHeart => '💔',
    FilmReaction.blewMind => '🤯',
    FilmReaction.madeCry => '😭',
    FilmReaction.shocked => '😱',
    FilmReaction.madeLaugh => '😂',
    FilmReaction.bored => '🥱',
    FilmReaction.disappointed => '😞',
    FilmReaction.madeThink => '🧠',
    FilmReaction.masterpiece => '🏆',
  };
}

/// Two-stop colours for a feeling: its gradient (chips, audience bar) runs
/// from the first colour to the second, and the first is its icon colour.
(Color, Color) reactionColors(FilmReaction reaction) => switch (reaction) {
      FilmReaction.loved => (const Color(0xFFFF6B88), const Color(0xFFFF2D55)),
      FilmReaction.brokeHeart => (
          const Color(0xFFF59BC1),
          const Color(0xFFC2478F)
        ),
      FilmReaction.madeCry => (
          const Color(0xFF5BB6FF),
          const Color(0xFF2F6BFF)
        ),
      FilmReaction.blewMind => (
          const Color(0xFF43E0D0),
          const Color(0xFF1BA6C9)
        ),
      FilmReaction.madeThink => (
          const Color(0xFFC08BFF),
          const Color(0xFF7C4DFF)
        ),
      FilmReaction.masterpiece => (
          const Color(0xFFFFD54A),
          const Color(0xFFE8A100)
        ),
      FilmReaction.shocked => (
          const Color(0xFFFFA45B),
          const Color(0xFFF2600C)
        ),
      FilmReaction.madeLaugh => (
          const Color(0xFFB5F06A),
          const Color(0xFF4CB944)
        ),
      FilmReaction.bored => (const Color(0xFFB4B8C8), const Color(0xFF6E7387)),
      FilmReaction.disappointed => (
          const Color(0xFF9DB4CC),
          const Color(0xFF4F6A85)
        ),
    };

/// The feeling's gradient, light at the start and deep at the end.
LinearGradient reactionGradient(
  FilmReaction reaction, {
  AlignmentGeometry begin = Alignment.topLeft,
  AlignmentGeometry end = Alignment.bottomRight,
}) {
  final (light, deep) = reactionColors(reaction);
  return LinearGradient(begin: begin, end: end, colors: [light, deep]);
}

/// Icon and colour for a feeling. Icons rather than emoji: emoji glyphs do not
/// render reliably in every Flutter build (boxes on the iOS 26 simulator).
(IconData, Color) reactionLook(FilmReaction reaction) => (
      switch (reaction) {
        FilmReaction.loved => Icons.favorite,
        FilmReaction.brokeHeart => Icons.heart_broken,
        FilmReaction.blewMind => Icons.auto_awesome,
        FilmReaction.madeCry => Icons.water_drop,
        FilmReaction.shocked => Icons.bolt,
        FilmReaction.madeLaugh => Icons.sentiment_very_satisfied,
        FilmReaction.bored => Icons.bedtime,
        FilmReaction.disappointed => Icons.sentiment_dissatisfied,
        FilmReaction.madeThink => Icons.psychology,
        FilmReaction.masterpiece => Icons.emoji_events,
      },
      reactionColors(reaction).$1,
    );

/// The feeling's coloured icon, for chips and rows.
Widget reactionIcon(FilmReaction reaction, {double size = 16}) {
  final (icon, color) = reactionLook(reaction);
  return Icon(icon, size: size, color: color);
}

String reactionChipLabel(AppLocalizations l10n, FilmReaction reaction) {
  return '${reactionEmoji(reaction)} ${reactionLabel(l10n, reaction)}';
}

String topicTagLabel(AppLocalizations l10n, TakeTag tag) {
  return switch (tag) {
    TakeTag.review => l10n.topicTagReview,
    TakeTag.question => l10n.topicTagQuestion,
    TakeTag.discussion => l10n.topicTagDiscussion,
    TakeTag.hotTake => l10n.topicTagHotTake,
    TakeTag.poll => l10n.topicTagPoll,
    TakeTag.scene => l10n.topicTagScene,
  };
}

/// Reaction chip for reviews; the tag name for questions and discussions.
String takeBadgeLabel(AppLocalizations l10n, Take take) {
  final reaction = take.reaction;
  return reaction == null
      ? topicTagLabel(l10n, take.tag)
      : reactionChipLabel(l10n, reaction);
}

String voteLabel(AppLocalizations l10n, VoteKind kind) {
  return switch (kind) {
    VoteKind.changedMyMind => l10n.reviewVoteChangedMyMind,
    VoteKind.wellArgued => l10n.reviewVoteWellArgued,
    VoteKind.disagreeButFair => l10n.reviewVoteDisagreeFair,
  };
}
