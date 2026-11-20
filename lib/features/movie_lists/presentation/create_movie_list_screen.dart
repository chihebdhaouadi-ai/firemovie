import 'dart:async';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/widgets/luxe_palette.dart';
import '../../find/data/find_repository.dart';
import '../../find/data/movie.dart';
import '../../home/views/widgets/film_tile.dart';
import '../data/movie_list.dart';
import '../data/movie_list_repository.dart';

/// Name a list, search films to put in it, and post it. Pops with the posted
/// list. Given [editing], it starts from that list and saves the changes
/// instead.
class CreateMovieListScreen extends StatefulWidget {
  const CreateMovieListScreen({
    super.key,
    required this.repository,
    this.find,
    this.editing,
  });

  final MovieListRepository repository;
  final FindRepository? find;

  /// The list being edited, or null for a new one.
  final MovieList? editing;

  @override
  State<CreateMovieListScreen> createState() => _CreateMovieListScreenState();
}

class _CreateMovieListScreenState extends State<CreateMovieListScreen> {
  late final FindRepository _find = widget.find ?? FindRepository();
  final _name = TextEditingController();
  final _query = TextEditingController();
  final List<ListFilm> _picked = [];
  List<Movie> _results = const [];
  bool _searching = false;
  bool _posting = false;
  Timer? _debounce;
  int _searchId = 0;

  @override
  void initState() {
    super.initState();
    if (widget.editing case final list?) {
      _name.text = list.name;
      _picked.addAll(list.films);
    }
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _name.dispose();
    _query.dispose();
    super.dispose();
  }

  void _onQuery(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(text));
  }

  Future<void> _search(String text) async {
    final query = text.trim();
    final id = ++_searchId;
    if (query.length < 2) {
      setState(() {
        _results = const [];
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    try {
      final page = await _find.search(query);
      if (!mounted || id != _searchId) return;
      setState(() {
        _results = page.results;
        _searching = false;
      });
    } catch (_) {
      if (!mounted || id != _searchId) return;
      setState(() {
        _results = const [];
        _searching = false;
      });
    }
  }

  bool _isPicked(String filmId) => _picked.any((f) => f.filmId == filmId);

  void _toggle(Movie movie) {
    setState(() {
      if (_isPicked(movie.id)) {
        _picked.removeWhere((f) => f.filmId == movie.id);
      } else {
        _picked.add(ListFilm(
          filmId: movie.id,
          title: movie.title,
          posterUrl: movie.posterUrl,
        ));
      }
    });
  }

  bool get _canPost =>
      !_posting && _name.text.trim().isNotEmpty && _picked.isNotEmpty;

  Future<void> _post() async {
    if (!_canPost) return;
    setState(() => _posting = true);
    final messenger = ScaffoldMessenger.of(context);
    final failed = context.l10n.listPostFailed;
    try {
      final editing = widget.editing;
      final created = editing == null
          ? await widget.repository.create(_name.text.trim(), _picked)
          : await widget.repository
              .update(editing.id, _name.text.trim(), List.of(_picked));
      if (!mounted) return;
      Navigator.of(context).pop(created);
    } catch (_) {
      if (!mounted) return;
      setState(() => _posting = false);
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    }
  }

  InputDecoration _field(String label, {String? hint, Widget? prefix}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefix,
        filled: true,
        fillColor: LuxeColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: LuxeColors.hair),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: LuxeColors.hair),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: LuxeColors.bg,
      appBar: AppBar(
        backgroundColor: LuxeColors.bg,
        surfaceTintColor: Colors.transparent,
        title: Text(
            widget.editing == null ? l10n.listCreateTitle : l10n.listEditTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                TextField(
                  key: const Key('list-name'),
                  controller: _name,
                  maxLength: 80,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  decoration:
                      _field(l10n.listNameLabel, hint: l10n.listNameHint),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.listPicked(_picked.length),
                  style: TextStyle(
                      color: LuxeColors.muted, fontWeight: FontWeight.w600),
                ),
                if (_picked.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _picked.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) => _PickedPoster(
                        film: _picked[i],
                        onRemove: () => setState(() => _picked.removeAt(i)),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  key: const Key('list-search'),
                  controller: _query,
                  onChanged: _onQuery,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _search,
                  decoration: _field(
                    l10n.listSearchHint,
                    prefix: const Icon(BootstrapIcons.search, size: 18),
                  ),
                ),
                const SizedBox(height: 8),
                if (_searching)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_results.isEmpty && _query.text.trim().length >= 2)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(l10n.listSearchEmpty,
                          style: TextStyle(color: LuxeColors.muted)),
                    ),
                  )
                else
                  for (final movie in _results)
                    _ResultRow(
                      movie: movie,
                      picked: _isPicked(movie.id),
                      onTap: () => _toggle(movie),
                    ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: LuxeColors.bg,
              border: Border(top: BorderSide(color: LuxeColors.hair)),
            ),
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: FilledButton(
                key: const Key('list-post'),
                onPressed: _canPost ? _post : null,
                style: FilledButton.styleFrom(
                  backgroundColor: LuxeColors.text,
                  foregroundColor: LuxeColors.bg,
                  minimumSize: const Size.fromHeight(52),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _posting
                    ? SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: LuxeColors.bg),
                      )
                    : Text(widget.editing == null
                        ? l10n.listPost
                        : l10n.listSaveChanges),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow(
      {required this.movie, required this.picked, required this.onTap});

  final Movie movie;
  final bool picked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final poster = movie.posterUrl;
    final year = movie.year;
    return InkWell(
      key: Key('list-result-${movie.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 40,
                height: 60,
                child: poster == null
                    ? const PosterPlaceholder()
                    : PosterImage(url: poster, width: 40, height: 60),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: LuxeColors.text, fontWeight: FontWeight.w600),
                  ),
                  if (year != null)
                    Text('$year',
                        style:
                            TextStyle(color: LuxeColors.muted, fontSize: 12)),
                ],
              ),
            ),
            Semantics(
              button: true,
              selected: picked,
              label: picked
                  ? l10n.listRemoveFilm(movie.title)
                  : l10n.listAddFilm(movie.title),
              excludeSemantics: true,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: picked ? LuxeColors.text : Colors.transparent,
                  border: Border.all(
                      color: picked ? LuxeColors.text : LuxeColors.hair,
                      width: 1.5),
                ),
                child: Icon(
                  picked ? BootstrapIcons.check_lg : BootstrapIcons.plus_lg,
                  size: 16,
                  color: picked ? LuxeColors.bg : LuxeColors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickedPoster extends StatelessWidget {
  const _PickedPoster({required this.film, required this.onRemove});

  final ListFilm film;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final poster = film.posterUrl;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 64,
            height: 96,
            child: poster == null
                ? const PosterPlaceholder()
                : PosterImage(url: poster, width: 64, height: 96),
          ),
        ),
        Positioned(
          right: -6,
          top: -6,
          child: Semantics(
            button: true,
            label: context.l10n.listRemoveFilm(film.title),
            excludeSemantics: true,
            child: GestureDetector(
              key: Key('list-picked-remove-${film.filmId}'),
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                    color: LuxeColors.text, shape: BoxShape.circle),
                child: Icon(BootstrapIcons.x, size: 14, color: LuxeColors.bg),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
