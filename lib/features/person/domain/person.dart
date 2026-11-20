import 'package:equatable/equatable.dart';

/// A cast or crew member's page: photo, height, biography and the films they
/// are best known for.
class PersonDetail extends Equatable {
  const PersonDetail({
    required this.id,
    required this.name,
    this.photoUrl,
    this.heightDisplay,
    this.biography,
    this.birthDate,
    this.birthPlace,
    this.deathDate,
    this.knownFor = const [],
  });

  final String id;
  final String name;
  final String? photoUrl;
  final String? heightDisplay;
  final String? biography;
  final DateTime? birthDate;
  final String? birthPlace;
  final DateTime? deathDate;
  final List<PersonCredit> knownFor;

  @override
  List<Object?> get props => [
        id,
        name,
        photoUrl,
        heightDisplay,
        biography,
        birthDate,
        birthPlace,
        deathDate,
        knownFor,
      ];
}

/// One film in a person's history, with the part they played or their job.
class PersonCredit extends Equatable {
  const PersonCredit({
    required this.filmId,
    required this.title,
    this.year,
    this.posterUrl,
    this.isCast = true,
    this.job,
    this.characters = const [],
  });

  final String filmId;
  final String title;
  final int? year;
  final String? posterUrl;
  final bool isCast;
  final String? job;
  final List<String> characters;

  @override
  List<Object?> get props =>
      [filmId, title, year, posterUrl, isCast, job, characters];
}
