import 'package:equatable/equatable.dart';

import 'film_reaction.dart';
import 'vote_kind.dart';

class Take extends Equatable {
  const Take({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.isMine,
    required this.reaction,
    required this.body,
    required this.votes,
    required this.myVotes,
    required this.commentCount,
    required this.isMostHelpful,
  });

  final int id;
  final int authorId;
  final String authorName;
  final bool isMine;
  final FilmReaction reaction;
  final String body;
  final Map<VoteKind, int> votes;
  final Set<VoteKind> myVotes;
  final int commentCount;
  final bool isMostHelpful;

  int votesOf(VoteKind kind) => votes[kind] ?? 0;

  bool hasVoted(VoteKind kind) => myVotes.contains(kind);

  @override
  List<Object?> get props => [
        id,
        authorId,
        authorName,
        isMine,
        reaction,
        body,
        votes,
        myVotes,
        commentCount,
        isMostHelpful,
      ];
}

class TakeComment extends Equatable {
  const TakeComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.body,
    required this.isWriter,
  });

  final int id;
  final int authorId;
  final String authorName;
  final String body;
  final bool isWriter;

  @override
  List<Object?> get props => [id, authorId, authorName, body, isWriter];
}
