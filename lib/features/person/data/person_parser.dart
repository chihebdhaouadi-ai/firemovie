import '../domain/person.dart';

/// Parses `GET /api/films/people/<id>/`. Unknown or malformed fields are
/// dropped rather than failing the whole page.
PersonDetail parsePersonDetail(Map<String, dynamic> json) {
  final height = json['height'];
  return PersonDetail(
    id: _string(json['person_id']) ?? '',
    name: _string(json['name']) ?? '',
    photoUrl: _https(json['photo_url']),
    heightDisplay: height is Map<String, dynamic>
        ? _string(height['display']) ??
            (height['cm'] is int ? '${height['cm']} cm' : null)
        : null,
    biography: _string(json['biography']),
    birthDate: _date(json['birth_date']),
    birthPlace: _string(json['birth_place']),
    deathDate: _date(json['death_date']),
    knownFor: [
      if (json['known_for'] case final List rows)
        for (final row in rows)
          if (row is Map<String, dynamic> &&
              _string(row['film_id']) != null &&
              _string(row['title']) != null)
            PersonCredit(
              filmId: _string(row['film_id'])!,
              title: _string(row['title'])!,
              year: row['year'] is int ? row['year'] as int : null,
              posterUrl: _https(row['poster_url']),
              isCast: row['credit_type'] != 'crew',
              job: _string(row['job']),
              characters: [
                if (row['characters'] case final List names)
                  for (final name in names)
                    if (_string(name) case final value?) value,
              ],
            ),
    ],
  );
}

String? _string(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String? _https(Object? value) {
  final text = _string(value);
  return text != null && text.startsWith('https://') ? text : null;
}

DateTime? _date(Object? value) {
  final text = _string(value);
  return text == null ? null : DateTime.tryParse(text);
}
