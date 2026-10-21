import '../../../l10n/app_localizations.dart';
import '../domain/film_reaction.dart';
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

String reactionChipLabel(AppLocalizations l10n, FilmReaction reaction) {
  return '${reactionEmoji(reaction)} ${reactionLabel(l10n, reaction)}';
}

String voteLabel(AppLocalizations l10n, VoteKind kind) {
  return switch (kind) {
    VoteKind.changedMyMind => l10n.reviewVoteChangedMyMind,
    VoteKind.wellArgued => l10n.reviewVoteWellArgued,
    VoteKind.disagreeButFair => l10n.reviewVoteDisagreeFair,
  };
}
