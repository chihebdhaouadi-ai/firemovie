import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../film_reviews/data/review_repository.dart';
import '../../film_reviews/domain/take_tag.dart';
import '../../find/views/widgets/empty_error_views.dart';
import '../../home/data/home_models.dart';
import '../../home/views/widgets/feed_take_card.dart';
import '../data/browse_repository.dart';

/// The top 100 takes of all time, or only those of one [tag]
/// (polls, conversations, scenes, questions, hot takes).
class BrowseTakesScreen extends StatefulWidget {
  const BrowseTakesScreen({
    super.key,
    required this.title,
    this.tag,
    this.repository,
    this.reviews,
  });

  final String title;
  final TakeTag? tag;
  final BrowseRepository? repository;
  final ReviewRepository? reviews;

  @override
  State<BrowseTakesScreen> createState() => _BrowseTakesScreenState();
}

class _BrowseTakesScreenState extends State<BrowseTakesScreen> {
  late final BrowseRepository _repository =
      widget.repository ?? ApiBrowseRepository();
  late Future<List<FeedItem>> _takes = _load();

  Future<List<FeedItem>> _load() => _repository.fetchTopTakes(tag: widget.tag);

  void _retry() => setState(() => _takes = _load());

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(widget.title),
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<FeedItem>>(
          future: _takes,
          builder: (context, snapshot) {
            if (snapshot.hasError) return SearchError(onRetry: _retry);
            final items = snapshot.data;
            if (items == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (items.isEmpty) {
              return FindMessageView(
                icon: BootstrapIcons.chat_square_text,
                title: context.l10n.browseTakesEmpty,
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
                child: ListView.separated(
                  padding: EdgeInsets.all(tokens.spaceLg),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => SizedBox(height: tokens.spaceSm),
                  itemBuilder: (context, index) => FeedTakeCard(
                    key: ValueKey(items[index].take.id),
                    item: items[index],
                    heroScope: 'browse-${widget.title}',
                    reviews: widget.reviews,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
