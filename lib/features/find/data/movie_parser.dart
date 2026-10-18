import 'movie.dart';

/// Parses movie payloads returned by the backend search/detail proxy.
abstract final class MovieParser {
  static const _genresKey = 'genres';
  static const _watchProvidersKey = 'watch_providers';

  static Movie searchResult(Map<String, dynamic> json) {
    return _base(json);
  }

  static Movie detail(Map<String, dynamic> json) {
    final movie = _base(json);
    if (json[_watchProvidersKey] case final Map<String, dynamic> wp) {
      return movie.withWatchProviders(_parseWatchProviders(wp));
    }
    return movie;
  }

  static Movie _base(Map<String, dynamic> json) {
    final id = json['film_id'] is String
        ? json['film_id'] as String
        : '${json['film_id'] ?? json['tmdb_id'] ?? ''}';
    final rawYear = json['year'];
    final year = rawYear is int
        ? rawYear
        : rawYear is num
            ? rawYear.toInt()
            : rawYear is String && rawYear.isNotEmpty
                ? int.tryParse(rawYear)
                : null;
    final rawVote = json['vote_average'];
    final vote = rawVote is num ? rawVote.toDouble() : null;

    final genres = <String>[];
    if (json[_genresKey] case final List genreList) {
      for (final genre in genreList) {
        if (genre is String && genre.isNotEmpty) genres.add(genre);
      }
    }

    final inLists = <String>[];
    if (json['in_lists'] case final List listList) {
      for (final list in listList) {
        if (list is String && list.isNotEmpty) inLists.add(list);
      }
    }

    return Movie(
      id: id,
      title: _string(json['title']) ?? '',
      year: year,
      posterUrl: _string(json['poster_url']),
      backdropUrl: _string(json['backdrop_url']),
      director: _string(json['director']),
      genres: genres,
      overview: _string(json['overview']),
      runtime: json['runtime'] is int ? (json['runtime'] as int) : null,
      voteAverage: vote,
      inLists: inLists,
    );
  }

  static MovieSearchPage searchPage(Map<String, dynamic> json) {
    final results = <Movie>[];
    if (json['results'] case final List resultList) {
      for (final row in resultList) {
        if (row is Map<String, dynamic>) {
          final movie = searchResult(row);
          if (movie.id.isNotEmpty) results.add(movie);
        }
      }
    }
    return MovieSearchPage(
      page: _int(json['page']) ?? 1,
      totalPages: _int(json['total_pages']) ?? 1,
      totalResults: _int(json['total_results']) ?? 0,
      results: results,
    );
  }

  static WatchProviders _parseWatchProviders(Map<String, dynamic> json) {
    return WatchProviders(
      link: _string(json['link']),
      flatrate: _parseProviders(json['flatrate']),
      rent: _parseProviders(json['rent']),
      buy: _parseProviders(json['buy']),
    );
  }

  static List<StreamingProvider> _parseProviders(Object? json) {
    final out = <StreamingProvider>[];
    if (json is List) {
      for (final row in json) {
        if (row is Map<String, dynamic>) {
          final name = _string(row['name']) ?? '';
          if (name.isNotEmpty) {
            out.add(StreamingProvider(
              name: name,
              logoUrl: _string(row['logo_url']),
            ));
          }
        }
      }
    }
    return out;
  }

  static String? _string(Object? value) => value is String
      ? value
      : value == null
          ? null
          : '$value';

  static int? _int(Object? value) => value is num ? value.toInt() : null;
}

/// A copy-with helper for movies that is not part of the immutable model
/// (kept here, separate from the data class).
extension MovieCopy on Movie {
  Movie withWatchProviders(WatchProviders providers) {
    return Movie(
      id: id,
      title: title,
      year: year,
      posterUrl: posterUrl,
      backdropUrl: backdropUrl,
      director: director,
      genres: genres,
      overview: overview,
      runtime: runtime,
      voteAverage: voteAverage,
      watchProviders: providers,
      inLists: inLists,
    );
  }

  Movie withInLists(List<String> value) {
    return Movie(
      id: id,
      title: title,
      year: year,
      posterUrl: posterUrl,
      backdropUrl: backdropUrl,
      director: director,
      genres: genres,
      overview: overview,
      runtime: runtime,
      voteAverage: voteAverage,
      watchProviders: watchProviders,
      inLists: value,
    );
  }
}
