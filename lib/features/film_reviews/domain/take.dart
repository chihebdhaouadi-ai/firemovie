import 'package:equatable/equatable.dart';

import 'film_reaction.dart';
import 'poll_option.dart';
import 'review_stance.dart';
import 'take_skin.dart';
import 'take_tag.dart';
import 'topic_vote.dart';
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
    this.createdAt,
    this.authorAvatarUrl,
    this.tag = TakeTag.review,
    this.imageUrl,
    this.topicVotes = const {},
    this.myTopicVotes = const {},
    this.spoiler = false,
    this.scene = '',
    this.timecode = '',
    this.pollOptions = const [],
    this.myPollOptionId,
    this.authorReactions = const [],
    this.authorFrame,
    this.skin = TakeSkin.normal,
    this.edited = false,
    this.title = '',
    this.isSaved = false,
  });

  /// Whether the viewer saved this take to come back to (from their profile).
  final bool isSaved;

  /// Topics only, optional: a short headline shown above the body; empty
  /// when the topic has none.
  final String title;

  final int id;
  final int authorId;
  final String authorName;
  final bool isMine;

  /// Null for questions and discussions, which have no reaction.
  final FilmReaction? reaction;
  final String body;
  final Map<VoteKind, int> votes;
  final Set<VoteKind> myVotes;
  final int commentCount;
  final bool isMostHelpful;
  final DateTime? createdAt;
  final String? authorAvatarUrl;
  final TakeTag tag;

  /// Photo attached to a question or discussion, when there is one.
  final String? imageUrl;

  /// Likes and dislikes on a question or discussion (empty for reviews).
  final Map<TopicVote, int> topicVotes;
  final Set<TopicVote> myTopicVotes;

  /// Whether the body should be hidden behind a spoiler warning.
  final bool spoiler;

  /// Name of the moment a scene post is about. Empty for other tags.
  final String scene;

  /// Optional position in the film, such as `1h 12m`. Empty when none.
  final String timecode;

  /// Choices on a poll. Empty for other tags.
  final List<PollOption> pollOptions;

  /// The option the viewer picked on a poll, if they have voted.
  final int? myPollOptionId;

  /// The author's current feelings for the film (up to three, pick order).
  /// Empty when the server did not send them.
  final List<FilmReaction> authorReactions;

  /// The author's equipped avatar frame key (`bronze`, `gold`…), if sent.
  final String? authorFrame;

  /// The card background the author picked when sharing.
  final TakeSkin skin;

  /// Whether the author changed the body after posting.
  final bool edited;

  /// The author's feelings, falling back to the one stored on the take.
  List<FilmReaction> get authorFeelings => authorReactions.isNotEmpty
      ? authorReactions
      : [if (reaction case final reaction?) reaction];

  int votesOf(VoteKind kind) => votes[kind] ?? 0;

  int topicVotesOf(TopicVote kind) => topicVotes[kind] ?? 0;

  int get totalVotes => votes.values.fold(0, (sum, count) => sum + count);

  int get totalPollVotes =>
      pollOptions.fold(0, (sum, option) => sum + option.votes);

  bool hasVoted(VoteKind kind) => myVotes.contains(kind);

  /// This poll with the viewer's choice moved to [optionId] (null clears it).
  /// Counts move with it, so the UI can update before the server answers.
  Take withPollVote(int? optionId) {
    final previous = myPollOptionId;
    if (previous == optionId) return this;
    return copyWith(
      pollOptions: [
        for (final option in pollOptions)
          PollOption(
            id: option.id,
            label: option.label,
            votes: option.votes -
                (option.id == previous ? 1 : 0) +
                (option.id == optionId ? 1 : 0),
          ),
      ],
      myPollOptionId: optionId,
      clearMyPollOptionId: optionId == null,
    );
  }

  Take copyWith({
    int? commentCount,
    List<PollOption>? pollOptions,
    int? myPollOptionId,
    bool clearMyPollOptionId = false,
    bool? isSaved,
  }) =>
      Take(
        id: id,
        authorId: authorId,
        authorName: authorName,
        isMine: isMine,
        reaction: reaction,
        body: body,
        votes: votes,
        myVotes: myVotes,
        commentCount: commentCount ?? this.commentCount,
        isMostHelpful: isMostHelpful,
        createdAt: createdAt,
        authorAvatarUrl: authorAvatarUrl,
        tag: tag,
        imageUrl: imageUrl,
        topicVotes: topicVotes,
        myTopicVotes: myTopicVotes,
        spoiler: spoiler,
        scene: scene,
        timecode: timecode,
        pollOptions: pollOptions ?? this.pollOptions,
        myPollOptionId: clearMyPollOptionId
            ? null
            : (myPollOptionId ?? this.myPollOptionId),
        authorReactions: authorReactions,
        authorFrame: authorFrame,
        skin: skin,
        edited: edited,
        title: title,
        isSaved: isSaved ?? this.isSaved,
      );

  @override
  List<Object?> get props => [
        title,
        topicVotes,
        myTopicVotes,
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
        createdAt,
        authorAvatarUrl,
        tag,
        imageUrl,
        spoiler,
        scene,
        timecode,
        pollOptions,
        myPollOptionId,
        authorReactions,
        authorFrame,
        skin,
        edited,
        isSaved,
      ];
}

class FriendFilmActivity extends Equatable {
  const FriendFilmActivity({
    required this.userId,
    required this.username,
    required this.reaction,
    required this.updatedAt,
    this.takeId,
    this.takeBody,
    this.avatarUrl,
    this.frame,
  });

  final int userId;
  final String username;

  /// The friend's equipped avatar frame key, if sent.
  final String? frame;

  /// Profile picture path or URL, when the friend has one.
  final String? avatarUrl;
  final FilmReaction reaction;
  final DateTime updatedAt;
  final int? takeId;
  final String? takeBody;

  @override
  List<Object?> get props => [
        userId,
        username,
        reaction,
        updatedAt,
        takeId,
        takeBody,
        avatarUrl,
        frame
      ];
}

class TakeComment extends Equatable {
  const TakeComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.body,
    required this.isWriter,
    this.parentId,
    this.createdAt,
    this.isMine = false,
    this.likes = 0,
    this.dislikes = 0,
    this.myVote,
    this.stance,
    this.imageUrl,
    this.authorAvatarUrl,
    this.authorFrame,
  });

  /// The commenter's photo and equipped frame key.
  final String? authorAvatarUrl;
  final String? authorFrame;

  final int id;
  final int authorId;
  final String authorName;
  final String body;

  /// The photo sent with the comment, if any.
  final String? imageUrl;
  final bool isWriter;
  final int? parentId;
  final DateTime? createdAt;
  final bool isMine;
  final int likes;
  final int dislikes;

  /// The viewer's like or dislike on this comment, if any.
  final TopicVote? myVote;
  final ReviewStance? stance;

  int votesOf(TopicVote kind) => kind == TopicVote.like ? likes : dislikes;

  /// This comment with the viewer's vote moved to [vote] (null clears it).
  /// Counts move with it, so the UI can update before the server answers.
  TakeComment withMyVote(TopicVote? vote) {
    var likeCount = likes;
    var dislikeCount = dislikes;
    if (myVote == TopicVote.like) likeCount--;
    if (myVote == TopicVote.dislike) dislikeCount--;
    if (vote == TopicVote.like) likeCount++;
    if (vote == TopicVote.dislike) dislikeCount++;
    return TakeComment(
      id: id,
      authorId: authorId,
      authorName: authorName,
      body: body,
      isWriter: isWriter,
      parentId: parentId,
      createdAt: createdAt,
      isMine: isMine,
      likes: likeCount,
      dislikes: dislikeCount,
      myVote: vote,
      stance: stance,
      imageUrl: imageUrl,
      authorAvatarUrl: authorAvatarUrl,
      authorFrame: authorFrame,
    );
  }

  @override
  List<Object?> get props => [
        id,
        authorId,
        authorName,
        body,
        isWriter,
        parentId,
        createdAt,
        isMine,
        likes,
        dislikes,
        myVote,
        stance,
        imageUrl,
        authorAvatarUrl,
        authorFrame,
      ];
}
