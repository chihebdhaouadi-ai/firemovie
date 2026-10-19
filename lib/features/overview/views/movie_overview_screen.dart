import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../find/data/find_repository.dart';
import '../../find/data/movie.dart';
import '../../home/data/home_models.dart';
import 'widgets/friend_activity.dart';
import 'widgets/overview_header.dart';
import 'widgets/overview_panel.dart';
import 'widgets/reviews_section.dart';
import 'widgets/status_row.dart';
import 'widgets/where_to_watch_card.dart';

class MovieOverviewScreen extends StatefulWidget {
  const MovieOverviewScreen({super.key, required this.film, this.repository});

  final Film film;
  final FindRepository? repository;

  @override
  State<MovieOverviewScreen> createState() => _MovieOverviewScreenState();
}

class _MovieOverviewScreenState extends State<MovieOverviewScreen> {
  late final FindRepository _repository;
  Movie? _detail;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? FindRepository();
    _load();
  }

  Future<void> _load() async {
    try {
      final detail = await _repository.fetchDetail(widget.film.imdbId);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  void _retry() {
    setState(() {
      _loading = true;
      _failed = false;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final detail = _detail;
    final summary = Movie(
      id: widget.film.imdbId,
      title: widget.film.displayTitle,
      posterUrl: widget.film.posterUrl,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: l10n.overviewBack,
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
            child: ListView(
              padding: EdgeInsetsDirectional.fromSTEB(
                tokens.spaceLg,
                0,
                tokens.spaceLg,
                tokens.spaceXl,
              ),
              children: [
                OverviewHeader(
                  movie: detail ?? summary,
                  loaded: detail != null,
                ),
                SizedBox(height: tokens.spaceLg),
                if (_loading)
                  const LinearProgressIndicator(
                    color: AppColors.accentGlow,
                    backgroundColor: AppColors.surfaceRaised,
                  ),
                if (detail != null) ..._loadedSections(detail),
                if (_failed) _ErrorCard(onRetry: _retry),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _loadedSections(Movie detail) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return [
      StatusRow(movie: detail),
      SizedBox(height: tokens.spaceLg),
      const UserStarsRow(),
      SizedBox(height: tokens.spaceLg),
      WhereToWatchCard(providers: detail.watchProviders),
      SizedBox(height: tokens.spaceMd),
      const FriendActivity(),
      SizedBox(height: tokens.spaceMd),
      const ReviewsSection(),
      SizedBox(height: tokens.spaceLg),
      Text(
        l10n.findAttribution,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
      ),
    ];
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(top: tokens.spaceLg),
      child: OverviewPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.findDetailsErrorTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            SizedBox(height: tokens.spaceSm),
            FilledButton(
              onPressed: onRetry,
              child: Text(l10n.findDetailsRetry),
            ),
          ],
        ),
      ),
    );
  }
}
