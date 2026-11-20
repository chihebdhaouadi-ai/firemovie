import 'package:equatable/equatable.dart';

/// Who made a list or wrote a comment.
class ListPerson extends Equatable {
  const ListPerson({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.frame,
  });

  factory ListPerson.fromJson(Map<String, dynamic> json) => ListPerson(
        id: json['id'] as int? ?? 0,
        username: json['username'] as String? ?? '',
        avatarUrl: json['avatar'] as String?,
        frame: json['equipped_frame'] as String?,
      );

  final int id;
  final String username;
  final String? avatarUrl;
  final String? frame;

  @override
  List<Object?> get props => [id, username, avatarUrl, frame];
}

/// One film in a list.
class ListFilm extends Equatable {
  const ListFilm({required this.filmId, required this.title, this.posterUrl});

  factory ListFilm.fromJson(Map<String, dynamic> json) => ListFilm(
        filmId: json['film_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        posterUrl: json['poster_url'] as String?,
      );

  final String filmId;
  final String title;
  final String? posterUrl;

  Map<String, dynamic> toJson() => {
        'film_id': filmId,
        'title': title,
        if (posterUrl != null) 'poster_url': posterUrl,
      };

  @override
  List<Object?> get props => [filmId, title, posterUrl];
}

/// A list someone made and posted: its name, owner, a few posters for the
/// stacked cover, hearts and comments. [films] is only filled on the list's
/// own page.
class MovieList extends Equatable {
  const MovieList({
    required this.id,
    required this.name,
    required this.owner,
    required this.isMine,
    required this.filmCount,
    this.posters = const [],
    this.likes = 0,
    this.liked = false,
    this.comments = 0,
    this.saved = false,
    this.films = const [],
  });

  factory MovieList.fromJson(Map<String, dynamic> json) => MovieList(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        owner: ListPerson.fromJson(
          (json['owner'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
        isMine: json['is_mine'] as bool? ?? false,
        filmCount: json['film_count'] as int? ?? 0,
        posters: [
          for (final poster in json['posters'] as List? ?? const [])
            if (poster is String && poster.isNotEmpty) poster,
        ],
        likes: json['likes'] as int? ?? 0,
        liked: json['liked'] as bool? ?? false,
        comments: json['comments'] as int? ?? 0,
        saved: json['saved'] as bool? ?? false,
        films: [
          for (final film in json['films'] as List? ?? const [])
            if (film is Map) ListFilm.fromJson(film.cast<String, dynamic>()),
        ],
      );

  final int id;
  final String name;
  final ListPerson owner;
  final bool isMine;
  final int filmCount;
  final List<String> posters;
  final int likes;
  final bool liked;
  final int comments;

  /// Whether you saved this list to your profile (only someone else's).
  final bool saved;
  final List<ListFilm> films;

  MovieList copyWith({
    String? name,
    int? likes,
    bool? liked,
    int? comments,
    bool? saved,
    List<ListFilm>? films,
  }) =>
      MovieList(
        id: id,
        name: name ?? this.name,
        owner: owner,
        isMine: isMine,
        filmCount: films?.length ?? filmCount,
        posters: films == null
            ? posters
            : [
                for (final film in films)
                  if (film.posterUrl case final poster?) poster,
              ].take(4).toList(),
        likes: likes ?? this.likes,
        liked: liked ?? this.liked,
        comments: comments ?? this.comments,
        saved: saved ?? this.saved,
        films: films ?? this.films,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        owner,
        isMine,
        filmCount,
        posters,
        likes,
        liked,
        comments,
        saved,
        films
      ];
}

class ListComment extends Equatable {
  const ListComment({
    required this.id,
    required this.author,
    required this.body,
    this.createdAt,
    this.parentId,
    this.imageUrl,
    this.isWriter = false,
    this.isMine = false,
  });

  factory ListComment.fromJson(Map<String, dynamic> json) => ListComment(
        id: json['id'] as int? ?? 0,
        author: ListPerson.fromJson(
          (json['author'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
        body: json['body'] as String? ?? '',
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
        parentId: json['parent_id'] as int?,
        imageUrl: json['image_url'] as String?,
        isWriter: json['is_writer'] as bool? ?? false,
        isMine: json['is_mine'] as bool? ?? false,
      );

  final int id;
  final ListPerson author;
  final String body;
  final DateTime? createdAt;

  /// The comment this one answers; null for a top-level comment.
  final int? parentId;

  /// The photo sent with the comment, if any.
  final String? imageUrl;

  /// Whether the list's owner wrote it.
  final bool isWriter;

  /// Whether the viewer wrote it.
  final bool isMine;

  @override
  List<Object?> get props =>
      [id, author, body, createdAt, parentId, imageUrl, isWriter, isMine];
}
