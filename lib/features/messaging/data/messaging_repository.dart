import 'dart:convert';

import 'package:image_picker/image_picker.dart';

import '../../find/data/api_client.dart';
import 'messaging_models.dart';

/// Chats with friends: direct ones, groups and private topics.
abstract interface class MessagingRepository {
  /// The user's chats, most recently active first.
  Future<List<Conversation>> conversations();

  /// The one-to-one chat with friend [userId], created on first use.
  Future<Conversation> openDirect(int userId);

  /// A new group or private topic with the given friends.
  Future<Conversation> create({
    required ConversationKind kind,
    required String title,
    required List<int> memberIds,
    String description = '',
  });

  /// Sets the picture of group or topic [conversationId].
  Future<Conversation> setPhoto(int conversationId, XFile photo);

  /// Messages oldest first: the latest page, or only those after [afterId].
  /// Reading them marks the chat as read.
  Future<List<ChatMessage>> messages(int conversationId, {int? afterId});

  Future<ChatMessage> send(int conversationId, String body, {int? replyTo});

  /// A GIF, sticker, photo, video, movie card or poll.
  Future<ChatMessage> sendPost(int conversationId, OutgoingPost post);

  /// One chat, fresh (members, owner, running vote).
  Future<Conversation> conversation(int conversationId);

  /// Adds reaction [emoji] to a message, or takes yours back.
  Future<ChatMessage> react(int messageId, String emoji);

  /// Pins or unpins a message (the group's owner only).
  Future<ChatMessage> togglePin(int messageId);

  /// Votes for [option] of a poll; voting for your current choice clears it.
  Future<ChatMessage> votePoll(int messageId, int option);

  Future<Conversation> removeMember(int conversationId, int userId);

  /// Hands the group to [userId], who becomes Heritage creator.
  Future<Conversation> makeHeritage(int conversationId, int userId);

  /// Leaves a group; its owner must pass it on ([passTo]) or start a vote.
  Future<void> leave(int conversationId, {int? passTo});

  /// The owner's leave vote: start it, cancel it, or vote in it.
  Future<Conversation> startVote(int conversationId);
  Future<Conversation> cancelVote(int conversationId);
  Future<Conversation> castBallot(int conversationId, String choice);

  /// My own settings for a chat: mute it, pin it to the top of the inbox,
  /// or mark it as unread (false marks it read).
  Future<Conversation> updateSettings(
    int conversationId, {
    bool? muted,
    bool? pinned,
    bool? unread,
  });

  /// Hides every message so far, for me only.
  Future<Conversation> clearHistory(int conversationId);

  /// Removes a direct chat from my inbox (it comes back on a new message).
  Future<void> deleteChat(int conversationId);

  /// The group owner adds friends.
  Future<Conversation> addMembers(int conversationId, List<int> userIds);

  /// Reports a chat, or one of its messages, to the moderators.
  Future<void> report(
    int conversationId, {
    required String reason,
    int? messageId,
    String details = '',
  });

  /// Changes the text of my own message.
  Future<ChatMessage> editMessage(int messageId, String body);

  /// Deletes a message for everyone (mine, or any in a group I own).
  Future<ChatMessage> deleteMessage(int messageId);

  /// People I blocked; blocking stops both sides of our direct chat.
  Future<List<ChatUser>> blockedUsers();
  Future<void> block(int userId);
  Future<void> unblock(int userId);
}

class ApiMessagingRepository implements MessagingRepository {
  ApiMessagingRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  static const _base = '/api/messaging/conversations/';

  @override
  Future<List<Conversation>> conversations() async => [
        for (final row in await _client.getList(_base))
          Conversation.fromJson(row),
      ];

  @override
  Future<Conversation> openDirect(int userId) async => Conversation.fromJson(
        await _client
            .postJson(_base, body: {'kind': 'direct', 'user_id': userId}),
      );

  @override
  Future<Conversation> create({
    required ConversationKind kind,
    required String title,
    required List<int> memberIds,
    String description = '',
  }) async =>
      Conversation.fromJson(await _client.postJson(_base, body: {
        'kind': kind.apiValue,
        'title': title,
        'member_ids': memberIds,
        if (description.isNotEmpty) 'description': description,
      }));

  @override
  Future<Conversation> setPhoto(int conversationId, XFile photo) async =>
      Conversation.fromJson(await _client.patchMultipart(
        '$_base$conversationId/',
        fileField: 'photo',
        file: photo,
      ));

  @override
  Future<List<ChatMessage>> messages(int conversationId,
          {int? afterId}) async =>
      [
        for (final row in await _client.getList(
          '$_base$conversationId/messages/',
          query: afterId == null ? null : {'after': '$afterId'},
        ))
          ChatMessage.fromJson(row),
      ];

  static const _messages = '/api/messaging/messages/';

  @override
  Future<ChatMessage> send(int conversationId, String body,
          {int? replyTo}) async =>
      ChatMessage.fromJson(await _client.postJson(
        '$_base$conversationId/messages/',
        body: {'body': body, if (replyTo != null) 'reply_to': replyTo},
      ));

  @override
  Future<ChatMessage> sendPost(int conversationId, OutgoingPost post) async {
    final path = '$_base$conversationId/messages/';
    final file = post.file;
    if (file != null) {
      return ChatMessage.fromJson(await _client.postMultipart(
        path,
        fields: {
          'kind': post.kind.apiValue,
          'body': post.body,
          if (post.replyTo != null) 'reply_to': '${post.replyTo}',
          'allowed_reactions': jsonEncode(post.allowedReactions),
        },
        file: file,
        fileField: 'attachment',
      ));
    }
    return ChatMessage.fromJson(await _client.postJson(path, body: {
      'kind': post.kind.apiValue,
      'body': post.body,
      if (post.replyTo != null) 'reply_to': post.replyTo,
      'payload': post.payload,
      'allowed_reactions': post.allowedReactions,
    }));
  }

  @override
  Future<Conversation> conversation(int conversationId) async =>
      Conversation.fromJson(await _client.getJson('$_base$conversationId/'));

  @override
  Future<ChatMessage> react(int messageId, String emoji) async =>
      ChatMessage.fromJson(await _client
          .postJson('$_messages$messageId/react/', body: {'emoji': emoji}));

  @override
  Future<ChatMessage> togglePin(int messageId) async =>
      ChatMessage.fromJson(await _client.postJson('$_messages$messageId/pin/'));

  @override
  Future<ChatMessage> votePoll(int messageId, int option) async =>
      ChatMessage.fromJson(await _client
          .postJson('$_messages$messageId/vote/', body: {'option': option}));

  @override
  Future<Conversation> removeMember(int conversationId, int userId) async =>
      Conversation.fromJson(await _client
          .postJson('$_base$conversationId/members/$userId/remove/'));

  @override
  Future<Conversation> makeHeritage(int conversationId, int userId) async =>
      Conversation.fromJson(await _client
          .postJson('$_base$conversationId/owner/', body: {'user_id': userId}));

  @override
  Future<void> leave(int conversationId, {int? passTo}) =>
      _client.postJsonNoContent('$_base$conversationId/leave/',
          body: {if (passTo != null) 'pass_to': passTo});

  @override
  Future<Conversation> startVote(int conversationId) async =>
      Conversation.fromJson(
          await _client.postJson('$_base$conversationId/vote/'));

  @override
  Future<Conversation> cancelVote(int conversationId) async {
    await _client.delete('$_base$conversationId/vote/');
    return conversation(conversationId);
  }

  @override
  Future<Conversation> castBallot(int conversationId, String choice) async =>
      Conversation.fromJson(await _client.postJson(
          '$_base$conversationId/vote/ballot/',
          body: {'choice': choice}));

  @override
  Future<Conversation> updateSettings(
    int conversationId, {
    bool? muted,
    bool? pinned,
    bool? unread,
  }) async =>
      Conversation.fromJson(await _client.patchJson(
        '$_base$conversationId/settings/',
        body: {
          if (muted != null) 'muted': muted,
          if (pinned != null) 'pinned': pinned,
          if (unread != null) 'unread': unread,
        },
      ));

  @override
  Future<Conversation> clearHistory(int conversationId) async =>
      Conversation.fromJson(
          await _client.postJson('$_base$conversationId/clear/'));

  @override
  Future<void> deleteChat(int conversationId) =>
      _client.postJsonNoContent('$_base$conversationId/delete/');

  @override
  Future<Conversation> addMembers(
          int conversationId, List<int> userIds) async =>
      Conversation.fromJson(await _client.postJson(
          '$_base$conversationId/members/',
          body: {'user_ids': userIds}));

  @override
  Future<void> report(
    int conversationId, {
    required String reason,
    int? messageId,
    String details = '',
  }) =>
      _client.postJsonNoContent('$_base$conversationId/report/', body: {
        'reason': reason,
        if (messageId != null) 'message_id': messageId,
        if (details.isNotEmpty) 'details': details,
      });

  @override
  Future<ChatMessage> editMessage(int messageId, String body) async =>
      ChatMessage.fromJson(await _client
          .patchJson('$_messages$messageId/', body: {'body': body}));

  @override
  Future<ChatMessage> deleteMessage(int messageId) async =>
      ChatMessage.fromJson(await _client.deleteJson('$_messages$messageId/'));

  @override
  Future<List<ChatUser>> blockedUsers() async => [
        for (final row in await _client.getList(_blocks))
          ChatUser.fromJson(row),
      ];

  @override
  Future<void> block(int userId) =>
      _client.postJsonNoContent('$_blocks$userId/');

  @override
  Future<void> unblock(int userId) => _client.delete('$_blocks$userId/');

  static const _blocks = '/api/messaging/blocks/';
}

/// Chats kept in memory, for tests and previews.
class FakeMessagingRepository implements MessagingRepository {
  FakeMessagingRepository({
    required this.me,
    List<Conversation>? conversations,
    Map<int, List<ChatMessage>>? messages,
  })  : _conversations = [...?conversations],
        _messages = {
          for (final entry in (messages ?? const {}).entries)
            entry.key: [...entry.value],
        };

  final ChatUser me;
  final List<Conversation> _conversations;
  final Map<int, List<ChatMessage>> _messages;
  int _nextId = 1000;

  @override
  Future<List<Conversation>> conversations() async =>
      [..._conversations]..sort((a, b) {
          // Pinned chats first, then the newest.
          if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });

  @override
  Future<Conversation> openDirect(int userId) async {
    final existing = _conversations.where(
        (c) => c.isDirect && c.members.any((member) => member.id == userId));
    if (existing.isNotEmpty) return existing.first;
    final convo = Conversation(
      id: _nextId++,
      kind: ConversationKind.direct,
      title: 'friend $userId',
      members: [me, ChatUser(id: userId, username: 'friend $userId')],
      updatedAt: DateTime.now(),
    );
    _conversations.add(convo);
    return convo;
  }

  @override
  Future<Conversation> create({
    required ConversationKind kind,
    required String title,
    required List<int> memberIds,
    String description = '',
  }) async {
    final convo = Conversation(
      id: _nextId++,
      kind: kind,
      title: title,
      members: [
        me,
        for (final id in memberIds) ChatUser(id: id, username: '$id')
      ],
      updatedAt: DateTime.now(),
      description: description,
      createdById: me.id,
    );
    _conversations.add(convo);
    return convo;
  }

  @override
  Future<Conversation> setPhoto(int conversationId, XFile photo) async {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    final old = _conversations[index];
    final updated = Conversation(
      id: old.id,
      kind: old.kind,
      title: old.title,
      members: old.members,
      updatedAt: old.updatedAt,
      lastMessage: old.lastMessage,
      unread: old.unread,
      description: old.description,
      photoUrl: 'fake://${photo.name}',
      createdById: old.createdById,
    );
    _conversations[index] = updated;
    return updated;
  }

  @override
  Future<List<ChatMessage>> messages(int conversationId, {int? afterId}) async {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index >= 0) {
      _conversations[index] = _conversations[index].copyWith(unread: 0);
    }
    final all = _messages[conversationId] ?? const [];
    return afterId == null
        ? [...all]
        : all.where((m) => m.id > afterId).toList();
  }

  @override
  Future<ChatMessage> send(int conversationId, String body,
          {int? replyTo}) async =>
      _add(
        conversationId,
        ChatMessage(
          id: _nextId++,
          body: body.trim(),
          sender: me,
          createdAt: DateTime.now(),
          replyTo: _preview(conversationId, replyTo),
        ),
      );

  @override
  Future<ChatMessage> sendPost(int conversationId, OutgoingPost post) async =>
      _add(
        conversationId,
        ChatMessage(
          id: _nextId++,
          kind: post.kind,
          body: post.body.trim(),
          sender: me,
          createdAt: DateTime.now(),
          replyTo: _preview(conversationId, post.replyTo),
          attachmentUrl: post.file == null ? null : 'fake://${post.file!.name}',
          gif: post.gif,
          sticker: post.sticker,
          movie: post.movie,
          poll: post.kind == MessageKind.poll
              ? ChatPoll(
                  question: post.pollQuestion ?? '',
                  options: post.pollOptions,
                  votes: List.filled(post.pollOptions.length, 0),
                )
              : null,
          allowedReactions: post.allowedReactions,
        ),
      );

  ReplyPreview? _preview(int conversationId, int? replyTo) {
    if (replyTo == null) return null;
    final parent = _find(replyTo);
    return parent == null
        ? null
        : ReplyPreview(
            id: parent.id,
            sender: parent.sender.username,
            snippet: parent.body,
            kind: parent.kind,
          );
  }

  ChatMessage _add(int conversationId, ChatMessage message) {
    (_messages[conversationId] ??= []).add(message);
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index >= 0) {
      _conversations[index] =
          _conversations[index].copyWith(lastMessage: message);
    }
    return message;
  }

  ChatMessage? _find(int messageId) {
    for (final list in _messages.values) {
      for (final m in list) {
        if (m.id == messageId) return m;
      }
    }
    return null;
  }

  ChatMessage _replace(ChatMessage updated) {
    for (final list in _messages.values) {
      final i = list.indexWhere((m) => m.id == updated.id);
      if (i >= 0) list[i] = updated;
    }
    return updated;
  }

  Conversation _convo(int conversationId) =>
      _conversations.firstWhere((c) => c.id == conversationId);

  Conversation _save(Conversation convo) {
    final i = _conversations.indexWhere((c) => c.id == convo.id);
    _conversations[i] = convo;
    return convo;
  }

  void _system(int conversationId, String event, {String? target}) {
    _add(
      conversationId,
      ChatMessage(
        id: _nextId++,
        kind: MessageKind.system,
        body: '',
        sender: me,
        createdAt: DateTime.now(),
        event: event,
        eventTarget: target,
      ),
    );
  }

  @override
  Future<Conversation> conversation(int conversationId) async =>
      _convo(conversationId);

  @override
  Future<ChatMessage> react(int messageId, String emoji) async {
    final message = _find(messageId)!;
    final reactions = [...message.reactions];
    final i = reactions.indexWhere((r) => r.emoji == emoji);
    if (i < 0) {
      reactions.add(ReactionCount(emoji: emoji, count: 1, me: true));
    } else if (reactions[i].me) {
      final left = reactions[i].count - 1;
      if (left <= 0) {
        reactions.removeAt(i);
      } else {
        reactions[i] = ReactionCount(emoji: emoji, count: left);
      }
    } else {
      reactions[i] =
          ReactionCount(emoji: emoji, count: reactions[i].count + 1, me: true);
    }
    return _replace(message.copyWith(reactions: reactions));
  }

  @override
  Future<ChatMessage> togglePin(int messageId) async {
    final message = _find(messageId)!;
    return _replace(message.copyWith(pinned: !message.pinned));
  }

  @override
  Future<ChatMessage> votePoll(int messageId, int option) async {
    final message = _find(messageId)!;
    final poll = message.poll!;
    final votes = [...poll.votes];
    final mine = poll.myVote;
    if (mine != null) votes[mine]--;
    final next = mine == option ? null : option;
    if (next != null) votes[next]++;
    return _replace(message.copyWith(
      poll: ChatPoll(
        question: poll.question,
        options: poll.options,
        votes: votes,
        myVote: next,
      ),
    ));
  }

  @override
  Future<Conversation> removeMember(int conversationId, int userId) async {
    final convo = _convo(conversationId);
    final target = convo.members.firstWhere((m) => m.id == userId);
    _system(conversationId, 'removed', target: target.username);
    return _save(convo.copyWith(
      members: convo.members.where((m) => m.id != userId).toList(),
    ));
  }

  @override
  Future<Conversation> makeHeritage(int conversationId, int userId) async {
    final convo = _convo(conversationId);
    final target = convo.members.firstWhere((m) => m.id == userId);
    _system(conversationId, 'heritage', target: target.username);
    return _save(
        convo.copyWith(createdById: userId, heritage: true).withVote(null));
  }

  @override
  Future<void> leave(int conversationId, {int? passTo}) async {
    _conversations.removeWhere((c) => c.id == conversationId);
  }

  @override
  Future<Conversation> startVote(int conversationId) async {
    _system(conversationId, 'vote_started');
    return _save(_convo(conversationId).withVote(GroupVoteState(
      stage: GroupVoteStage.keep,
      startedById: me.id,
      endsAt: DateTime.now().add(const Duration(hours: 24)),
    )));
  }

  @override
  Future<Conversation> cancelVote(int conversationId) async {
    _system(conversationId, 'vote_cancelled');
    return _save(_convo(conversationId).withVote(null));
  }

  @override
  Future<Conversation> castBallot(int conversationId, String choice) async {
    final convo = _convo(conversationId);
    final vote = convo.vote!;
    final tally = {...vote.tally};
    final old = vote.myChoice;
    if (old != null) tally[old] = (tally[old] ?? 1) - 1;
    tally[choice] = (tally[choice] ?? 0) + 1;
    return _save(convo.withVote(GroupVoteState(
      stage: vote.stage,
      startedById: vote.startedById,
      endsAt: vote.endsAt,
      tally: tally,
      myChoice: choice,
    )));
  }

  final Set<int> _blocked = {};

  /// Reports sent, as (conversation id, reason, message id).
  final List<(int, String, int?)> reports = [];

  @override
  Future<Conversation> updateSettings(
    int conversationId, {
    bool? muted,
    bool? pinned,
    bool? unread,
  }) async {
    final convo = _convo(conversationId);
    return _save(convo.copyWith(
      muted: muted,
      pinned: pinned,
      markedUnread: unread,
      unread: unread == false ? 0 : null,
    ));
  }

  @override
  Future<Conversation> clearHistory(int conversationId) async {
    _messages[conversationId] = [];
    return _save(_convo(conversationId).cleared());
  }

  @override
  Future<void> deleteChat(int conversationId) async {
    _messages[conversationId] = [];
    _conversations.removeWhere((c) => c.id == conversationId);
  }

  @override
  Future<Conversation> addMembers(int conversationId, List<int> userIds) async {
    final convo = _convo(conversationId);
    final added = [
      for (final id in userIds)
        if (!convo.members.any((m) => m.id == id))
          ChatUser(id: id, username: 'friend $id'),
    ];
    for (final person in added) {
      _system(conversationId, 'added', target: person.username);
    }
    return _save(
        _convo(conversationId).copyWith(members: [...convo.members, ...added]));
  }

  @override
  Future<void> report(
    int conversationId, {
    required String reason,
    int? messageId,
    String details = '',
  }) async =>
      reports.add((conversationId, reason, messageId));

  @override
  Future<ChatMessage> editMessage(int messageId, String body) async =>
      _replace(_find(messageId)!.copyWith(body: body.trim(), edited: true));

  @override
  Future<ChatMessage> deleteMessage(int messageId) async =>
      _replace(_find(messageId)!.asDeleted());

  @override
  Future<List<ChatUser>> blockedUsers() async => [
        for (final id in _blocked)
          _conversations.expand((c) => c.members).firstWhere((m) => m.id == id,
              orElse: () => ChatUser(id: id, username: 'friend $id')),
      ];

  @override
  Future<void> block(int userId) async {
    _blocked.add(userId);
    _setBlock(userId, ChatBlock.byMe);
  }

  @override
  Future<void> unblock(int userId) async {
    _blocked.remove(userId);
    _setBlock(userId, ChatBlock.none);
  }

  void _setBlock(int userId, ChatBlock block) {
    for (final convo in [..._conversations]) {
      if (convo.isDirect && convo.members.any((m) => m.id == userId)) {
        _save(convo.copyWith(block: block));
      }
    }
  }
}
