import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

/// A person in a chat.
class ChatUser extends Equatable {
  const ChatUser({required this.id, required this.username, this.avatarUrl});

  final int id;
  final String username;
  final String? avatarUrl;

  String get initial => username.isEmpty ? '?' : username[0].toUpperCase();

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
        id: json['id'] as int,
        username: json['username'] as String? ?? '',
        avatarUrl: json['avatar'] as String?,
      );

  @override
  List<Object?> get props => [id, username, avatarUrl];
}

/// What a message holds.
enum MessageKind {
  text('text'),
  system('system'),
  gif('gif'),
  sticker('sticker'),
  photo('photo'),
  video('video'),
  movie('movie'),
  poll('poll'),

  /// A take or topic a friend sent you, or a comment that tagged you.
  take('take'),

  /// A movie list a friend sent you.
  list('list');

  const MessageKind(this.apiValue);

  final String apiValue;

  static MessageKind fromApi(String? value) =>
      values.firstWhere((kind) => kind.apiValue == value, orElse: () => text);
}

/// The message a reply quotes.
class ReplyPreview extends Equatable {
  const ReplyPreview({
    required this.id,
    required this.sender,
    required this.snippet,
    this.kind = MessageKind.text,
  });

  final int id;
  final String sender;
  final String snippet;
  final MessageKind kind;

  factory ReplyPreview.fromJson(Map<String, dynamic> json) => ReplyPreview(
        id: json['id'] as int,
        sender: json['sender'] as String? ?? '',
        snippet: json['snippet'] as String? ?? '',
        kind: MessageKind.fromApi(json['kind'] as String?),
      );

  @override
  List<Object?> get props => [id, sender, snippet, kind];
}

/// How many people reacted with [emoji], and whether I am one of them.
class ReactionCount extends Equatable {
  const ReactionCount({
    required this.emoji,
    required this.count,
    this.me = false,
  });

  final String emoji;
  final int count;
  final bool me;

  factory ReactionCount.fromJson(Map<String, dynamic> json) => ReactionCount(
        emoji: json['emoji'] as String? ?? '',
        count: json['count'] as int? ?? 0,
        me: json['me'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [emoji, count, me];
}

/// A film shared as a card.
class SharedMovie extends Equatable {
  const SharedMovie({
    required this.title,
    this.id,
    this.year = '',
    this.posterUrl,
  });

  final String? id;
  final String title;
  final String year;
  final String? posterUrl;

  factory SharedMovie.fromJson(Map<String, dynamic> json) => SharedMovie(
        id: json['id']?.toString(),
        title: json['title'] as String? ?? '',
        year: json['year']?.toString() ?? '',
        posterUrl: json['poster'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'year': year,
        'poster': posterUrl,
      };

  @override
  List<Object?> get props => [id, title, year, posterUrl];
}

/// A movie list posted in the chat as a card: a snapshot taken when it was
/// sent. Tapping it opens the list.
class SharedList extends Equatable {
  const SharedList({
    required this.listId,
    this.name = '',
    this.owner = '',
    this.filmCount = 0,
    this.posters = const [],
  });

  factory SharedList.fromPayload(Map<String, dynamic> payload) {
    final list = payload['list'] as Map<String, dynamic>? ?? const {};
    return SharedList(
      listId: list['id'] as int? ?? 0,
      name: list['name'] as String? ?? '',
      owner: list['owner'] as String? ?? '',
      filmCount: list['film_count'] as int? ?? 0,
      posters: [
        for (final poster in list['posters'] as List? ?? const [])
          if (poster is String && poster.isNotEmpty) poster,
      ],
    );
  }

  final int listId;
  final String name;
  final String owner;
  final int filmCount;
  final List<String> posters;

  @override
  List<Object?> get props => [listId, name, owner, filmCount, posters];
}

/// A take or topic posted in the chat as a card: a snapshot taken when it
/// was sent and, for a mention, the comment that tagged you.
class SharedTake extends Equatable {
  const SharedTake({
    required this.takeId,
    this.tag = '',
    this.title = '',
    this.body = '',
    this.author = '',
    this.authorAvatarUrl,
    this.filmTitle,
    this.posterUrl,
    this.commentId,
    this.commentBody,
    this.mention = false,
  });

  final int takeId;

  /// "review", "question", "discussion", ...
  final String tag;
  final String title;
  final String body;
  final String author;
  final String? authorAvatarUrl;
  final String? filmTitle;
  final String? posterUrl;

  /// The comment that tagged you (mentions only).
  final int? commentId;
  final String? commentBody;

  /// Whether you were tagged in a comment (otherwise it was shared with you).
  final bool mention;

  bool get isTopic => tag != 'review';

  factory SharedTake.fromPayload(Map<String, dynamic> payload) {
    final take = payload['take'] as Map<String, dynamic>? ?? const {};
    final comment = payload['comment'] as Map<String, dynamic>?;
    return SharedTake(
      takeId: take['id'] as int? ?? 0,
      tag: take['tag'] as String? ?? '',
      title: take['title'] as String? ?? '',
      body: take['body'] as String? ?? '',
      author: take['author'] as String? ?? '',
      authorAvatarUrl: take['author_avatar'] as String?,
      filmTitle: take['film_title'] as String?,
      posterUrl: take['poster'] as String?,
      commentId: comment?['id'] as int?,
      commentBody: comment?['body'] as String?,
      mention: payload['event'] == 'mention',
    );
  }

  @override
  List<Object?> get props => [
        takeId,
        tag,
        title,
        body,
        author,
        authorAvatarUrl,
        filmTitle,
        posterUrl,
        commentId,
        commentBody,
        mention,
      ];
}

/// A question with two to four options; one vote per member.
class ChatPoll extends Equatable {
  const ChatPoll({
    required this.question,
    required this.options,
    this.votes = const [],
    this.myVote,
  });

  final String question;
  final List<String> options;

  /// Votes per option, in [options] order.
  final List<int> votes;
  final int? myVote;

  int get total => votes.fold(0, (sum, n) => sum + n);

  int votesFor(int option) => option < votes.length ? votes[option] : 0;

  factory ChatPoll.fromJson(Map<String, dynamic> json) => ChatPoll(
        question: json['question'] as String? ?? '',
        options: [
          for (final o in json['options'] as List<dynamic>? ?? const [])
            o.toString(),
        ],
        votes: [
          for (final n in json['votes'] as List<dynamic>? ?? const [])
            (n as num).toInt(),
        ],
        myVote: json['my_vote'] as int?,
      );

  @override
  List<Object?> get props => [question, options, votes, myVote];
}

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.body,
    required this.sender,
    required this.createdAt,
    this.kind = MessageKind.text,
    this.replyTo,
    this.attachmentUrl,
    this.gif,
    this.sticker,
    this.movie,
    this.sharedTake,
    this.sharedList,
    this.poll,
    this.event,
    this.eventTarget,
    this.allowedReactions = const [],
    this.pinned = false,
    this.reactions = const [],
    this.edited = false,
    this.deleted = false,
  });

  final int id;
  final MessageKind kind;

  /// The text, or a post's caption (may be empty).
  final String body;

  /// Who wrote it; for a system line, who caused it.
  final ChatUser sender;
  final DateTime createdAt;
  final ReplyPreview? replyTo;

  /// The photo or video file.
  final String? attachmentUrl;

  /// The GIF's name (GIFs are drawn as animated tiles).
  final String? gif;
  final String? sticker;
  final SharedMovie? movie;

  /// The take or topic card (take messages only).
  final SharedTake? sharedTake;

  /// The list card (list messages only).
  final SharedList? sharedList;
  final ChatPoll? poll;

  /// System lines: what happened ("pinned", "removed", "left", ...) and to
  /// whom.
  final String? event;
  final String? eventTarget;

  /// Emojis members may react with; empty means any.
  final List<String> allowedReactions;
  final bool pinned;
  final List<ReactionCount> reactions;

  /// Whether the sender changed the text after sending it.
  final bool edited;

  /// Deleted for everyone: only a placeholder is shown.
  final bool deleted;

  bool get isSystem => kind == MessageKind.system;

  ChatMessage copyWith({
    bool? pinned,
    List<ReactionCount>? reactions,
    ChatPoll? poll,
    String? body,
    bool? edited,
  }) =>
      ChatMessage(
        id: id,
        body: body ?? this.body,
        edited: edited ?? this.edited,
        deleted: deleted,
        sender: sender,
        createdAt: createdAt,
        kind: kind,
        replyTo: replyTo,
        attachmentUrl: attachmentUrl,
        gif: gif,
        sticker: sticker,
        movie: movie,
        sharedTake: sharedTake,
        sharedList: sharedList,
        poll: poll ?? this.poll,
        event: event,
        eventTarget: eventTarget,
        allowedReactions: allowedReactions,
        pinned: pinned ?? this.pinned,
        reactions: reactions ?? this.reactions,
      );

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'] as Map<String, dynamic>? ?? const {};
    final reply = json['reply_to'] as Map<String, dynamic>?;
    final movie = payload['movie'] as Map<String, dynamic>?;
    final poll = payload['poll'] as Map<String, dynamic>?;
    return ChatMessage(
      id: json['id'] as int,
      kind: MessageKind.fromApi(json['kind'] as String?),
      body: json['body'] as String? ?? '',
      sender: ChatUser.fromJson(json['sender'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      replyTo: reply == null ? null : ReplyPreview.fromJson(reply),
      attachmentUrl: json['attachment'] as String?,
      gif: payload['gif'] as String?,
      sticker: payload['sticker'] as String?,
      movie: movie == null ? null : SharedMovie.fromJson(movie),
      sharedTake:
          json['kind'] == 'take' ? SharedTake.fromPayload(payload) : null,
      sharedList:
          json['kind'] == 'list' ? SharedList.fromPayload(payload) : null,
      poll: poll == null ? null : ChatPoll.fromJson(poll),
      event: payload['event'] as String?,
      eventTarget: payload['target'] as String?,
      allowedReactions: [
        for (final e in json['allowed_reactions'] as List<dynamic>? ?? const [])
          e.toString(),
      ],
      pinned: json['pinned'] as bool? ?? false,
      reactions: [
        for (final r in json['reactions'] as List<dynamic>? ?? const [])
          ReactionCount.fromJson(r as Map<String, dynamic>),
      ],
      edited: json['edited'] as bool? ?? false,
      deleted: json['deleted'] as bool? ?? false,
    );
  }

  /// This message as deleted for everyone: no content, a placeholder.
  ChatMessage asDeleted() => ChatMessage(
        id: id,
        body: '',
        sender: sender,
        createdAt: createdAt,
        kind: kind,
        replyTo: replyTo,
        deleted: true,
      );

  @override
  List<Object?> get props => [
        id,
        kind,
        body,
        sender,
        createdAt,
        replyTo,
        attachmentUrl,
        gif,
        sticker,
        movie,
        sharedTake,
        sharedList,
        poll,
        event,
        eventTarget,
        allowedReactions,
        pinned,
        reactions,
        edited,
        deleted,
      ];
}

/// A post being sent: what kind, its caption, content and allowed reactions.
class OutgoingPost {
  const OutgoingPost({
    required this.kind,
    this.body = '',
    this.replyTo,
    this.file,
    this.gif,
    this.sticker,
    this.movie,
    this.pollQuestion,
    this.pollOptions = const [],
    this.allowedReactions = const [],
  });

  final MessageKind kind;
  final String body;
  final int? replyTo;

  /// The photo or video to upload.
  final XFile? file;
  final String? gif;
  final String? sticker;
  final SharedMovie? movie;
  final String? pollQuestion;
  final List<String> pollOptions;
  final List<String> allowedReactions;

  Map<String, dynamic> get payload => switch (kind) {
        MessageKind.gif => {'gif': gif},
        MessageKind.sticker => {'sticker': sticker},
        MessageKind.movie => {'movie': movie?.toJson()},
        MessageKind.poll => {
            'poll': {'question': pollQuestion, 'options': pollOptions},
          },
        _ => const {},
      };
}

/// The creator's leave vote: first keep or delete the group, then who owns
/// it. Each stage lasts 24 hours.
enum GroupVoteStage { keep, owner }

class GroupVoteState extends Equatable {
  const GroupVoteState({
    required this.stage,
    required this.startedById,
    required this.endsAt,
    this.tally = const {},
    this.myChoice,
  });

  final GroupVoteStage stage;
  final int startedById;
  final DateTime endsAt;

  /// Votes per choice: "stay" / "delete", or a member id.
  final Map<String, int> tally;
  final String? myChoice;

  int count(String choice) => tally[choice] ?? 0;

  factory GroupVoteState.fromJson(Map<String, dynamic> json) => GroupVoteState(
        stage: json['stage'] == 'owner'
            ? GroupVoteStage.owner
            : GroupVoteStage.keep,
        startedById: json['started_by'] as int,
        endsAt: DateTime.parse(json['ends_at'] as String),
        tally: {
          for (final entry
              in (json['tally'] as Map<String, dynamic>? ?? const {}).entries)
            entry.key: (entry.value as num).toInt(),
        },
        myChoice: json['my_choice'] as String?,
      );

  @override
  List<Object?> get props => [stage, startedById, endsAt, tally, myChoice];
}

/// One-to-one with a friend, a group, or a private topic.
enum ConversationKind {
  direct('direct'),
  group('group'),
  topic('topic');

  const ConversationKind(this.apiValue);

  final String apiValue;

  static ConversationKind fromApi(String? value) =>
      values.firstWhere((kind) => kind.apiValue == value,
          orElse: () => ConversationKind.direct);
}

/// Who blocked whom in a direct chat.
enum ChatBlock {
  none,

  /// I blocked the other person.
  byMe,

  /// The other person blocked me.
  byThem;

  static ChatBlock fromApi(String? value) => switch (value) {
        'me' => ChatBlock.byMe,
        'them' => ChatBlock.byThem,
        _ => ChatBlock.none,
      };
}

class Conversation extends Equatable {
  const Conversation({
    required this.id,
    required this.kind,
    required this.title,
    required this.members,
    required this.updatedAt,
    this.lastMessage,
    this.unread = 0,
    this.description = '',
    this.photoUrl,
    this.createdById,
    this.heritage = false,
    this.vote,
    this.muted = false,
    this.pinned = false,
    this.markedUnread = false,
    this.block = ChatBlock.none,
    this.seenAt,
  });

  final int id;
  final ConversationKind kind;

  /// The group's name, or the friend's username for a direct chat.
  final String title;
  final List<ChatUser> members;
  final ChatMessage? lastMessage;
  final int unread;
  final DateTime updatedAt;

  /// What a group or topic is about; empty when none was given.
  final String description;

  /// The group's picture, or null to draw the default icon.
  final String? photoUrl;

  /// Who owns the group: its creator, or the Heritage creator once
  /// [heritage] is true.
  final int? createdById;

  /// Whether the group was handed over to [createdById].
  final bool heritage;

  /// The creator's leave vote, while one is running.
  final GroupVoteState? vote;

  /// My own settings: no unread badge, kept at the top, marked as unread.
  final bool muted;
  final bool pinned;
  final bool markedUnread;

  /// Direct chats: whether either of us blocked the other.
  final ChatBlock block;

  /// Direct chats: when the friend last read the chat.
  final DateTime? seenAt;

  bool get isDirect => kind == ConversationKind.direct;
  bool get isTopic => kind == ConversationKind.topic;

  /// Shows as unread in the inbox: new messages, or marked by hand.
  bool get looksUnread => unread > 0 || markedUnread;

  /// Everyone but [meId].
  List<ChatUser> others(int? meId) =>
      members.where((member) => member.id != meId).toList();

  /// Whether [userId] owns (and so manages) this group.
  bool isOwner(int? userId) =>
      !isDirect && userId != null && createdById == userId;

  Conversation copyWith({
    int? unread,
    ChatMessage? lastMessage,
    List<ChatUser>? members,
    int? createdById,
    bool? heritage,
    String? photoUrl,
    bool? muted,
    bool? pinned,
    bool? markedUnread,
    ChatBlock? block,
  }) =>
      Conversation(
        id: id,
        kind: kind,
        title: title,
        members: members ?? this.members,
        updatedAt: lastMessage?.createdAt ?? updatedAt,
        lastMessage: lastMessage ?? this.lastMessage,
        unread: unread ?? this.unread,
        description: description,
        photoUrl: photoUrl ?? this.photoUrl,
        createdById: createdById ?? this.createdById,
        heritage: heritage ?? this.heritage,
        vote: vote,
        muted: muted ?? this.muted,
        pinned: pinned ?? this.pinned,
        markedUnread: markedUnread ?? this.markedUnread,
        block: block ?? this.block,
        seenAt: seenAt,
      );

  /// This chat with [vote] running (or none).
  Conversation withVote(GroupVoteState? vote) => Conversation(
        id: id,
        kind: kind,
        title: title,
        members: members,
        updatedAt: updatedAt,
        lastMessage: lastMessage,
        unread: unread,
        description: description,
        photoUrl: photoUrl,
        createdById: createdById,
        heritage: heritage,
        vote: vote,
        muted: muted,
        pinned: pinned,
        markedUnread: markedUnread,
        block: block,
        seenAt: seenAt,
      );

  /// This chat with its history cleared: no last message, nothing unread.
  Conversation cleared() => Conversation(
        id: id,
        kind: kind,
        title: title,
        members: members,
        updatedAt: updatedAt,
        description: description,
        photoUrl: photoUrl,
        createdById: createdById,
        heritage: heritage,
        vote: vote,
        muted: muted,
        pinned: pinned,
        block: block,
        seenAt: seenAt,
      );

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final last = json['last_message'] as Map<String, dynamic>?;
    final seen = json['seen_at'] as String?;
    return Conversation(
      id: json['id'] as int,
      kind: ConversationKind.fromApi(json['kind'] as String?),
      title: json['title'] as String? ?? '',
      members: [
        for (final member in json['members'] as List<dynamic>? ?? const [])
          ChatUser.fromJson(member as Map<String, dynamic>),
      ],
      lastMessage: last == null ? null : ChatMessage.fromJson(last),
      unread: json['unread'] as int? ?? 0,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      description: json['description'] as String? ?? '',
      photoUrl: json['photo'] as String?,
      createdById: json['created_by'] as int?,
      heritage: json['heritage'] as bool? ?? false,
      vote: json['vote'] == null
          ? null
          : GroupVoteState.fromJson(json['vote'] as Map<String, dynamic>),
      muted: json['muted'] as bool? ?? false,
      pinned: json['pinned'] as bool? ?? false,
      markedUnread: json['marked_unread'] as bool? ?? false,
      block: ChatBlock.fromApi(json['block'] as String?),
      seenAt: seen == null ? null : DateTime.parse(seen),
    );
  }

  @override
  List<Object?> get props => [
        id,
        kind,
        title,
        members,
        lastMessage,
        unread,
        description,
        photoUrl,
        createdById,
        heritage,
        vote,
        muted,
        pinned,
        markedUnread,
        block,
        seenAt,
      ];
}
