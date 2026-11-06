import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../articles/data/article.dart';
import '../../../articles/data/article_repository.dart';
import 'section_header.dart';
import 'section_status.dart';

/// Latest published articles. Each card opens the article on the web.
class LatestArticlesSection extends StatefulWidget {
  const LatestArticlesSection({super.key, required this.title, this.repository});

  final String title;
  final ArticleRepository? repository;

  @override
  State<LatestArticlesSection> createState() => _LatestArticlesSectionState();
}

class _LatestArticlesSectionState extends State<LatestArticlesSection> {
  late Future<List<LatestArticle>> _articles = _load();

  Future<List<LatestArticle>> _load() =>
      (widget.repository ?? ApiArticleRepository()).fetchLatest();

  void _retry() => setState(() => _articles = _load());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;

    return FutureBuilder<List<LatestArticle>>(
      future: _articles,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: widget.title),
              SectionStatusCard(
                message: l10n.homeSectionErrorTitle,
                actionIcon: Icons.refresh,
                actionLabel: l10n.homeSectionErrorRetry,
                onAction: _retry,
              ),
            ],
          );
        }
        final articles = snapshot.data;
        if (articles == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: widget.title),
              const LinearProgressIndicator(
                color: AppColors.accentGlow,
                backgroundColor: AppColors.surfaceRaised,
              ),
            ],
          );
        }
        if (articles.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: widget.title),
            SizedBox(height: tokens.spaceSm),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: articles.length,
                separatorBuilder: (_, __) => SizedBox(width: tokens.spaceSm),
                itemBuilder: (context, index) =>
                    _ArticleCard(article: articles[index]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article});

  final LatestArticle article;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return SizedBox(
      width: 260,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => launchUrl(
            Uri.parse(article.url),
            mode: LaunchMode.externalApplication,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: article.coverUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      const ColoredBox(color: AppColors.surfaceRaised),
                  errorWidget: (_, __, ___) =>
                      const ColoredBox(color: AppColors.surfaceRaised),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(tokens.spaceSm),
                child: Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
