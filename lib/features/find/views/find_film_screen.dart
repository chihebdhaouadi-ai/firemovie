import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/find_film_bloc.dart';
import '../bloc/find_film_event.dart';
import '../bloc/find_film_state.dart';
import '../data/api_lists_repository.dart';
import '../data/find_repository.dart';
import '../data/lists_repository.dart';
import '../data/movie.dart';
import '../data/recent_searches_store.dart';
import 'film_detail_screen.dart';
import 'find_route_args.dart';
import 'widgets/empty_error_views.dart';
import 'widgets/recent_searches.dart';
import 'widgets/result_actions.dart';
import 'widgets/result_tile.dart';
import 'widgets/search_field.dart';
import 'widgets/skeletons.dart';

/// The Find a film screen.
///
/// Opens with a [FindFilmRouteArgs] describing the destination context
/// (`target` plus an optional slot/pick index). Pops with a [FindFilmResult]
/// on a successful add when a fixed target is set.
class FindFilmScreen extends StatefulWidget {
  const FindFilmScreen({
    super.key,
    this.repository,
    this.listsRepository,
    this.recentStore,
  });

  final FindRepository? repository;
  final ListsRepository? listsRepository;
  final RecentSearchesStore? recentStore;

  static PageRoute<FindFilmResult> route(FindFilmRouteArgs args) {
    return MaterialPageRoute<FindFilmResult>(
      builder: (_) => FindFilmScreen(),
      settings: RouteSettings(arguments: args),
    );
  }

  @override
  State<FindFilmScreen> createState() => _FindFilmScreenState();
}

class _FindFilmScreenState extends State<FindFilmScreen> {
  @override
  Widget build(BuildContext context) {
    final raw = ModalRoute.of(context)?.settings.arguments;
    final args = raw is FindFilmRouteArgs ? raw : const FindFilmRouteArgs();

    return BlocProvider(
      create: (_) => FindFilmBloc(
        find: widget.repository ?? FindRepository(),
        lists: widget.listsRepository ?? ApiListsRepository(),
        recentStore: widget.recentStore ?? RecentSearchesStore(),
        target: args.target ?? AddTarget.watchlist,
        circleIndex: args.target == AddTarget.top5 ? args.slot : 0,
        slot: args.target == AddTarget.generatePick ? args.pickIndex : 0,
        onPickFilled: args.target == AddTarget.generatePick
            ? (film) => _onPickFilled(context, film)
            : null,
      ),
      child: _FindFilmView(args: args),
    );
  }

  void _onPickFilled(BuildContext context, Movie film) {
    if (!mounted) return;
    Navigator.of(context).pop(
      FindFilmResult(film: film, target: AddTarget.generatePick),
    );
  }
}

class _FindFilmView extends StatefulWidget {
  const _FindFilmView({required this.args});

  final FindFilmRouteArgs args;

  @override
  State<_FindFilmView> createState() => _FindFilmViewState();
}

class _FindFilmViewState extends State<_FindFilmView> {
  bool _resultPopped = false;

  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;

    return BlocListener<FindFilmBloc, FindFilmState>(
      listenWhen: (previous, current) =>
          _noticeId(previous) != _noticeId(current) ||
          _confirmId(previous) != _confirmId(current),
      listener: (context, state) {
        if (state is FindFilmResults && state.confirmReplace != null) {
          _showReplaceDialog(context, state.confirmReplace!);
        } else if (state is FindFilmResults && state.notice != null) {
          _showNotice(context, state.notice!);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.background,
                elevation: 0,
                scrolledUnderElevation: 0,
                title: _titleFor(context, args),
                leading: IconButton(
                  tooltip: context.l10n.homeUndo,
                  onPressed: () => Navigator.of(context).pop(
                    const FindFilmResult(),
                  ),
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
              SliverToBoxAdapter(
                child: _Centered(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      context.tokens.spaceLg,
                      context.tokens.spaceSm,
                      context.tokens.spaceLg,
                      context.tokens.spaceMd,
                    ),
                    child: SearchField(
                      controller: _controller,
                      hint: context.l10n.findSearchHint,
                      onChanged: (query) =>
                          context.read<FindFilmBloc>().add(QueryChanged(query)),
                      onSubmitted: (query) => context
                          .read<FindFilmBloc>()
                          .add(SearchSubmitted(query)),
                      clearLabel: context.l10n.findSearchClear,
                    ),
                  ),
                ),
              ),
              BlocBuilder<FindFilmBloc, FindFilmState>(
                builder: (context, state) => switch (state) {
                  FindFilmInitial(:final recent) =>
                    _recentSliver(context, recent),
                  FindFilmMinChars(:final recent) =>
                    _recentWithPromptSliver(context, recent),
                  FindFilmLoading() => SliverPadding(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: context.tokens.spaceMd,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          SizedBox(
                            height: 500,
                            child: ResultListSkeleton(),
                          ),
                        ]),
                      ),
                    ),
                  FindFilmEmpty(:final query) => SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyResults(query: query),
                    ),
                  FindFilmError(:final isOffline) => SliverFillRemaining(
                      hasScrollBody: false,
                      child: isOffline
                          ? OfflineMessage()
                          : SearchError(
                              onRetry: () => context
                                  .read<FindFilmBloc>()
                                  .add(const RetryRequested()),
                            ),
                    ),
                  FindFilmResults(
                    :final results,
                    :final hasMore,
                    :final loadingMore,
                    :final processingIds,
                  ) =>
                    _resultsSliver(context, args, results, hasMore, loadingMore,
                        processingIds),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titleFor(BuildContext context, FindFilmRouteArgs args) {
    final l10n = context.l10n;
    final target = args.target;
    final label =
        target == null ? l10n.findBodySearch : _chipLabel(l10n, target);
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
    );
  }

  String _chipLabel(AppLocalizations l10n, AddTarget target) =>
      switch (target) {
        AddTarget.top5 => l10n.findTitleTop5,
        AddTarget.watched => l10n.findTitleWatched,
        AddTarget.watchlist => l10n.findTitleWatchlist,
        AddTarget.generatePick => l10n.findTitleGenerate,
      };

  Widget _recentSliver(BuildContext context, List<String> recent) {
    return SliverToBoxAdapter(
      child: _CenterContent(
        padding: EdgeInsetsDirectional.fromSTEB(
          context.tokens.spaceLg,
          context.tokens.spaceMd,
          context.tokens.spaceLg,
          0,
        ),
        child: _recentWidget(context, recent),
      ),
    );
  }

  Widget _recentWidget(BuildContext context, List<String> recent) {
    final bloc = context.read<FindFilmBloc>();
    return RecentSearches(
      terms: recent,
      onSelected: (term) {
        _controller.text = term;
        bloc.add(SearchSubmitted(term));
      },
      onClear: () => bloc.add(const ClearRecent()),
    );
  }

  Widget _recentWithPromptSliver(BuildContext context, List<String> recent) {
    return SliverToBoxAdapter(
      child: _CenterContent(
        padding: EdgeInsetsDirectional.fromSTEB(
          context.tokens.spaceLg,
          context.tokens.spaceMd,
          context.tokens.spaceLg,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _recentWidget(context, recent),
            const SizedBox(height: 40),
            const MinCharsPrompt(),
          ],
        ),
      ),
    );
  }

  Widget _resultsSliver(
    BuildContext context,
    FindFilmRouteArgs args,
    List<Movie> results,
    bool hasMore,
    bool loadingMore,
    Set<String> processingIds,
  ) {
    final bloc = context.read<FindFilmBloc>();
    final target = args.target;

    return SliverPadding(
      padding: EdgeInsetsDirectional.only(bottom: context.tokens.spaceLg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= results.length) {
              return _footer(context, hasMore, loadingMore, bloc);
            }
            final movie = results[index];
            final added = bloc.alreadyAdded(movie);
            void addNow(AddTarget chosen) {
              bloc.add(
                AddRequested(
                  movie,
                  target: chosen,
                  circleIndex: args.target == AddTarget.top5 ? args.slot : 0,
                  slot: args.target == AddTarget.top5 ? args.slot : 0,
                ),
              );
            }

            return _Centered(
              child: ResultTile(
                movie: movie,
                added: added,
                processing: processingIds.contains(movie.id),
                onAdd: target == null
                    ? () => _chooseTargetThenAdd(context, movie, bloc,
                        canPick: false)
                    : () => addNow(target),
                onOpen: () => _openDetails(context, movie),
                onLongPressMenu: () =>
                    _chooseTargetThenAdd(context, movie, bloc, canPick: true),
                heroTag: 'find-poster-${movie.id}',
              ),
            );
          },
          childCount: results.length + 1,
        ),
      ),
    );
  }

  Widget _footer(
    BuildContext context,
    bool hasMore,
    bool loadingMore,
    FindFilmBloc bloc,
  ) {
    final tokens = context.tokens;
    if (!hasMore) {
      return Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: tokens.spaceLg),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: tokens.spaceXs,
          children: [
            const Icon(Icons.done_all, size: 16, color: AppColors.textMuted),
            Text(
              context.l10n.findNoMoreResults,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ],
        ),
      );
    }
    if (loadingMore) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    return Center(
      child: TextButton(
        onPressed: () => bloc.add(const LoadMore()),
        child: Text(context.l10n.findLoadMore),
      ),
    );
  }

  Future<void> _chooseTargetThenAdd(
    BuildContext context,
    Movie movie,
    FindFilmBloc bloc, {
    required bool canPick,
  }) async {
    final chosen = await ResultActions.showChooseTarget(
      context,
      movie: movie,
      canPick: canPick,
    );
    if (!context.mounted || chosen == null) return;
    bloc.add(AddRequested(movie, target: chosen));
  }

  Future<void> _openDetails(BuildContext context, Movie movie) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FilmDetailScreen(
          movie: movie,
          heroTag: 'find-poster-${movie.id}',
        ),
      ),
    );
  }

  Future<void> _showReplaceDialog(
    BuildContext context,
    ReplaceConfirmNotice notice,
  ) async {
    final l10n = context.l10n;
    final bloc = context.read<FindFilmBloc>();
    final current = notice.slotTitle ?? '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.findReplaceSlotTitle(current)),
        content: Text(
          l10n.findReplaceSlotBody(current, notice.film.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.findCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.findReplace),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    bloc.add(const AcknowledgeNotice(-1));
    if (confirmed == true) {
      bloc.add(
        ConfirmReplaceRequested(
          notice.film,
          notice.slot,
          notice.slotFilmId,
        ),
      );
    }
  }

  void _showNotice(BuildContext context, FindFilmNotice notice) {
    final l10n = context.l10n;
    final bloc = context.read<FindFilmBloc>();

    final snackbar = switch (notice) {
      AddedNotice(:final film, :final target, :final movedFromWatchlist) =>
        _addedSnackbar(context, film, target, movedFromWatchlist),
      RemovedNotice(:final film, :final target) =>
        _removedSnackbar(context, film, target),
      AlreadyWatchedNotice() => SnackBar(
          content: Text(l10n.findAlreadyWatchedTitle),
        ),
      Top5FullNotice() => SnackBar(
          content: Text(l10n.findTop5FullTitle),
        ),
      AddFailedNotice() || ActionFailedNotice() => SnackBar(
          content: Text(l10n.findGenericErrorTitle),
        ),
      ReplaceConfirmNotice() => null,
    };

    if (snackbar != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackbar);
    }
    bloc.add(AcknowledgeNotice(notice.id));
  }

  SnackBar _addedSnackbar(
    BuildContext context,
    Movie film,
    AddTarget target,
    bool movedFromWatchlist,
  ) {
    final l10n = context.l10n;
    final bloc = context.read<FindFilmBloc>();
    final message = movedFromWatchlist
        ? l10n.findMovedToWatched
        : l10n.findAddedSnackbar(ResultActions.labelFor(context, target));

    // For a fixed target, after a successful add we pop with the result.
    final raw = ModalRoute.of(context)?.settings.arguments;
    final FindFilmRouteArgs? fixedArgs = raw is FindFilmRouteArgs ? raw : null;

    return SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: l10n.findUndo,
        onPressed: () => bloc.add(const UndoRequested()),
      ),
      duration: const Duration(seconds: 4),
      onVisible: () {
        if (fixedArgs == null || fixedArgs.target == null || _resultPopped) {
          return;
        }
        _resultPopped = true;
        final navigator = Navigator.of(context);
        Future.delayed(const Duration(milliseconds: 450), () {
          if (mounted) {
            navigator.pop(
              FindFilmResult(film: film, target: fixedArgs.target),
            );
          }
        });
      },
    );
  }

  SnackBar _removedSnackbar(
      BuildContext context, Movie film, AddTarget target) {
    final l10n = context.l10n;
    final bloc = context.read<FindFilmBloc>();
    return SnackBar(
      content: Text(
        l10n.findRemovedSnackbar(ResultActions.labelFor(context, target)),
      ),
      action: SnackBarAction(
        label: l10n.findUndo,
        onPressed: () => bloc.add(const UndoRequested()),
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.tokens.maxContentWidth,
        ),
        child: child,
      ),
    );
  }
}

/// A padded, horizontally-centered content block.
class _CenterContent extends StatelessWidget {
  const _CenterContent({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.tokens.maxContentWidth,
        ),
        child: Padding(
          padding: padding ?? EdgeInsetsDirectional.zero,
          child: child,
        ),
      ),
    );
  }
}

int? _noticeId(FindFilmState state) => switch (state) {
      FindFilmResults(:final notice) => notice?.id,
      _ => null,
    };

int? _confirmId(FindFilmState state) => switch (state) {
      FindFilmResults(:final confirmReplace) => confirmReplace?.id,
      _ => null,
    };
