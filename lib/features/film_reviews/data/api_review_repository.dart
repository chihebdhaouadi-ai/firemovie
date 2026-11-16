import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../../find/data/api_client.dart';
import '../domain/film_reaction.dart';
import '../domain/movie_review_summary.dart';
import '../../home/data/home_models.dart';
import '../domain/review_stance.dart';
import '../domain/take.dart';
import '../domain/take_tag.dart';
import '../domain/topic_vote.dart';
import '../domain/vote_kind.dart';
import 'review_parser.dart';
import 'review_repository.dart';

/// The photo type the backend accepts, taken from the picked file's name.
MediaType topicImageType(XFile file) {
  final name = file.name.toLowerCase();
  if (name.endsWith('.png')) return MediaType('image', 'png');
  if (name.endsWith('.webp')) return MediaType('image', 'webp');
  return MediaType('image', 'jpeg');
}

class ApiReviewRepository implements ReviewRepository {
  ApiReviewRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<MovieReviewSummary> fetchSummary(String filmId) async {
    return ReviewParser.summary(
      await _client.getJson('/api/takes/films/$filmId/summary/'),
    );
  }

  @override
  Future<MovieReviewSummary> setReaction(
    String filmId,
    FilmReaction? reaction,
  ) async {
    return ReviewParser.summary(
      await _client.putJson(
        '/api/takes/films/$filmId/reaction/',
        body: {'reaction': reaction?.apiValue},
      ),
    );
  }

  @override
  Future<List<Take>> fetchTakes(String filmId) async {
    return ReviewParser.takes(
      await _client.getList('/api/takes/films/$filmId/takes/'),
    );
  }

  @override
  Future<Take> postTake(
    String filmId, {
    required String body,
    TakeTag tag = TakeTag.review,
  }) async {
    return ReviewParser.take(
      await _client.postJson(
        '/api/takes/films/$filmId/takes/',
        body: {'body': body, 'tag': tag.apiValue},
      ),
    );
  }

  @override
  Future<Take> postTopic({
    String? filmId,
    required String body,
    required TakeTag tag,
    XFile? image,
    List<String> options = const [],
    String? scene,
    String? timecode,
    bool spoiler = false,
  }) async {
    return ReviewParser.take(
      await _client.postMultipart(
        '/api/takes/topics/',
        fields: {
          'body': body,
          'tag': tag.apiValue,
          if (filmId != null) 'film_id': filmId,
          if (scene != null && scene.isNotEmpty) 'scene': scene,
          if (timecode != null && timecode.isNotEmpty) 'timecode': timecode,
          // Sent only when set, so ordinary topics keep the same request.
          if (spoiler) 'spoiler': 'true',
        },
        fieldLists: {
          if (options.isNotEmpty) 'options': options,
        },
        file: image,
        fileType: image == null ? null : topicImageType(image),
      ),
    );
  }

  @override
  Future<List<FeedItem>> fetchExploreFeed() async {
    return ReviewParser.exploreItems(
      await _client.getList('/api/takes/explore/'),
    );
  }

  @override
  Future<List<FeedItem>> fetchFriendTakes() async {
    return ReviewParser.exploreItems(
      await _client.getList('/api/takes/friends/takes/'),
    );
  }

  @override
  Future<List<FeedItem>> fetchMyTakes() async {
    return ReviewParser.exploreItems(
      await _client.getList('/api/takes/me/takes/'),
    );
  }

  @override
  Future<List<FeedItem>> fetchTrendingTopics() async {
    return ReviewParser.exploreItems(
      await _client.getList('/api/takes/topics/trending/'),
    );
  }

  @override
  Future<Take> setVote(int takeId, VoteKind kind,
      {required bool active}) async {
    return ReviewParser.take(
      await _client.putJson(
        '/api/takes/takes/$takeId/votes/${kind.apiValue}/',
        body: {'active': active},
      ),
    );
  }

  @override
  Future<Take> setTopicVote(int takeId, TopicVote kind,
      {required bool active}) async {
    return ReviewParser.take(
      await _client.putJson(
        '/api/takes/takes/$takeId/votes/${kind.apiValue}/',
        body: {'active': active},
      ),
    );
  }

  @override
  Future<Take> setPollVote(int takeId, int optionId) async {
    return ReviewParser.take(
      await _client.postJson(
        '/api/takes/takes/$takeId/poll/',
        body: {'option_id': optionId},
      ),
    );
  }

  @override
  Future<List<TakeComment>> fetchComments(int takeId) async {
    return ReviewParser.comments(
      await _client.getList('/api/takes/takes/$takeId/comments/'),
    );
  }

  @override
  Future<TakeComment> setCommentVote(
    int commentId,
    TopicVote kind, {
    required bool active,
  }) async {
    return ReviewParser.comment(
      await _client.putJson(
        '/api/takes/comments/$commentId/votes/${kind.apiValue}/',
        body: {'active': active},
      ),
    );
  }

  @override
  Future<TakeComment> postComment(
    int takeId, {
    required String body,
    int? parentId,
    ReviewStance? stance,
  }) async {
    return ReviewParser.comment(
      await _client.postJson(
        '/api/takes/takes/$takeId/comments/',
        body: {
          'body': body,
          if (parentId != null) 'parent_id': parentId,
          if (stance != null) 'stance': stance.apiValue,
        },
      ),
    );
  }

  @override
  Future<List<FriendFilmActivity>> fetchFriendActivity(String filmId) async {
    return ReviewParser.friendActivity(
      await _client.getList('/api/takes/films/$filmId/friends/'),
    );
  }
}
