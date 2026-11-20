import '../../find/data/api_client.dart';
import '../../home/data/home_models.dart';
import '../domain/report_reason.dart';
import '../domain/take.dart';
import '../domain/take_skin.dart';
import 'review_parser.dart';

/// What a viewer can do to a take beyond voting and commenting: open it on
/// its own, edit or delete their own, report someone else's, or send it to
/// friends.
abstract interface class TakeActionsRepository {
  /// One take with its film, for opening it from a notification.
  Future<FeedItem> fetchTake(int takeId);

  /// Rewrites the author's take. [skin] and [spoiler] are kept when null.
  Future<Take> editTake(
    int takeId, {
    required String body,
    TakeSkin? skin,
    bool? spoiler,
  });

  Future<void> deleteTake(int takeId);

  Future<void> reportTake(
    int takeId, {
    required ReportReason reason,
    String details = '',
  });

  /// Sends the take to friends; returns how many received it.
  Future<int> shareTake(
    int takeId, {
    required List<int> recipientIds,
    String message = '',
  });
}

class ApiTakeActionsRepository implements TakeActionsRepository {
  ApiTakeActionsRepository({ApiClient? client})
      : _client = client ?? ApiClient();

  final ApiClient _client;

  String _path(int takeId) => '/api/takes/takes/$takeId/';

  @override
  Future<FeedItem> fetchTake(int takeId) async {
    final json = await _client.getJson(_path(takeId));
    return ReviewParser.exploreItems([json]).single;
  }

  @override
  Future<Take> editTake(
    int takeId, {
    required String body,
    TakeSkin? skin,
    bool? spoiler,
  }) async {
    return ReviewParser.take(
      await _client.patchJson(
        _path(takeId),
        body: {
          'body': body,
          if (skin != null) 'skin': skin.apiValue,
          if (spoiler != null) 'spoiler': spoiler,
        },
      ),
    );
  }

  @override
  Future<void> deleteTake(int takeId) => _client.delete(_path(takeId));

  @override
  Future<void> reportTake(
    int takeId, {
    required ReportReason reason,
    String details = '',
  }) async {
    await _client.postJson(
      '${_path(takeId)}report/',
      body: {
        'reason': reason.apiValue,
        if (details.isNotEmpty) 'details': details,
      },
    );
  }

  @override
  Future<int> shareTake(
    int takeId, {
    required List<int> recipientIds,
    String message = '',
  }) async {
    final json = await _client.postJson(
      '${_path(takeId)}share/',
      body: {
        'recipient_ids': recipientIds,
        if (message.isNotEmpty) 'message': message,
      },
    );
    return (json['sent'] as num?)?.toInt() ?? recipientIds.length;
  }
}
