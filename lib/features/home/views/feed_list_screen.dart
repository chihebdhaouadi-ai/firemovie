import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../film_reviews/data/review_repository.dart';
import '../data/home_models.dart';
import 'widgets/feed_take_card.dart';

class FeedListScreen extends StatelessWidget {
  const FeedListScreen({
    super.key,
    required this.title,
    required this.items,
    this.reviews,
  });

  final String title;
  final List<FeedItem> items;
  final ReviewRepository? reviews;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
          child: ListView.separated(
            padding: EdgeInsets.all(tokens.spaceLg),
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(height: tokens.spaceSm),
            itemBuilder: (context, index) {
              final item = items[index];
              return FeedTakeCard(
                key: ValueKey(item.take.id),
                item: item,
                heroScope: title,
                reviews: reviews,
              );
            },
          ),
        ),
      ),
    );
  }
}
