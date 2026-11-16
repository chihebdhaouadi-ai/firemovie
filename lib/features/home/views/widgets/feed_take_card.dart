import 'package:flutter/material.dart';

import '../../../film_reviews/data/review_repository.dart';
import '../../../film_reviews/presentation/review_detail_screen.dart';
import '../../../film_reviews/presentation/take_hero.dart';
import '../../data/home_models.dart';
import 'take_summary_card.dart';

class FeedTakeCard extends StatelessWidget {
  const FeedTakeCard({
    super.key,
    required this.item,
    required this.heroScope,
    this.reviews,
  });

  final FeedItem item;
  final String heroScope;
  final ReviewRepository? reviews;

  Object get _heroTag => (heroScope, item.take.id);

  void _openDetail(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ReviewDetailScreen(
          movieId: item.film.imdbId,
          takeId: item.take.id,
          initialItem: item,
          heroTag: _heroTag,
          repository: reviews,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: _heroTag,
      flightShuttleBuilder: takeHeroFlightShuttle,
      child: TakeSummaryCard(
        take: item.take,
        film: item.film,
        onTap: () => _openDetail(context),
      ),
    );
  }
}
