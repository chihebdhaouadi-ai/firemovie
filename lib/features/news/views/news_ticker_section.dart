import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../articles/data/article.dart';
import '../../articles/data/article_repository.dart';
import 'news_ticker_bar.dart';

/// Latest articles scrolling in the news ticker. Each headline opens the
/// article on the web. Renders nothing while loading, on error, or when empty
/// so the ticker never shows a broken or empty bar.
class NewsTickerSection extends StatefulWidget {
  const NewsTickerSection({super.key, this.repository});

  final ArticleRepository? repository;

  @override
  State<NewsTickerSection> createState() => _NewsTickerSectionState();
}

class _NewsTickerSectionState extends State<NewsTickerSection> {
  late final Future<List<LatestArticle>> _articles =
      (widget.repository ?? ApiArticleRepository()).fetchLatest();

  static Future<void> _open(LatestArticle article) {
    return launchUrl(
      Uri.parse(article.url),
      mode: LaunchMode.externalApplication,
    );
  }

  void _showAll(BuildContext context, List<LatestArticle> articles) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (sheetContext) => SafeArea(
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          itemCount: articles.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, index) {
            final article = articles[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: CachedNetworkImage(
                    imageUrl: article.coverUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        ColoredBox(color: AppColors.surfaceRaised),
                  ),
                ),
              ),
              title: Text(
                article.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _open(article);
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LatestArticle>>(
      future: _articles,
      builder: (context, snapshot) {
        final articles = snapshot.data;
        if (articles == null || articles.isEmpty) {
          return const SizedBox.shrink();
        }
        return NewsTickerBar(
          items: [
            for (final article in articles)
              NewsTickerItem(
                id: '${article.id}',
                headline: article.title,
                posterUrl: article.coverUrl,
              ),
          ],
          onItemTap: (id) => _open(
            articles.firstWhere((article) => '${article.id}' == id),
          ),
          onSeeAllTap: () => _showAll(context, articles),
        );
      },
    );
  }
}
