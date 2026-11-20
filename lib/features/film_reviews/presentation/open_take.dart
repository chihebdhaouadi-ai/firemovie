import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../find/data/movie.dart' show ServerFailure;
import '../../home/data/home_models.dart';
import '../data/api_review_repository.dart';
import '../data/review_repository.dart';
import '../domain/take.dart';
import '../data/take_actions_repository.dart';
import 'topic_detail_screen.dart';

/// Opens take [takeId] on its own page (takes and topics share the topic
/// page), as when tapping a share or mention notification.
/// Shows a message instead when the take is gone or cannot be loaded.
Future<void> openTakeById(
  BuildContext context,
  int takeId, {
  int? replyToCommentId,
  TakeActionsRepository? actions,
  ReviewRepository? reviews,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final navigator = Navigator.of(context);
  final l10n = context.l10n;
  final FeedItem item;
  try {
    item = await (actions ?? ApiTakeActionsRepository()).fetchTake(takeId);
  } on ServerFailure {
    messenger?.showSnackBar(SnackBar(content: Text(l10n.notificationTakeGone)));
    return;
  } catch (_) {
    messenger?.showSnackBar(SnackBar(content: Text(l10n.reviewTakesFailed)));
    return;
  }
  // Takes and topics share one page: the post, then its comments.
  await navigator.push<void>(
    MaterialPageRoute<void>(
      builder: (_) => TopicDetailScreen(
        item: item,
        repository: reviews,
        replyToCommentId: replyToCommentId,
        actions: actions,
      ),
    ),
  );
}

/// Opens take [takeId] of film [filmId] on the topic page, finding it among
/// the film's takes (as from the film page's friend activity).
Future<void> openFilmTake(
  BuildContext context,
  String filmId,
  int takeId, {
  ReviewRepository? reviews,
  Film? film,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final navigator = Navigator.of(context);
  final l10n = context.l10n;
  final repository = reviews ?? ApiReviewRepository();
  final Take take;
  try {
    final takes = await repository.fetchTakes(filmId);
    final found = takes.where((t) => t.id == takeId);
    if (found.isEmpty) {
      messenger
          ?.showSnackBar(SnackBar(content: Text(l10n.notificationTakeGone)));
      return;
    }
    take = found.first;
  } catch (_) {
    messenger?.showSnackBar(SnackBar(content: Text(l10n.reviewTakesFailed)));
    return;
  }
  await navigator.push<void>(
    MaterialPageRoute<void>(
      builder: (_) => TopicDetailScreen(
        item: FeedItem(film: film ?? Film(imdbId: filmId), take: take),
        repository: reviews,
      ),
    ),
  );
}
