import 'package:film_wise_mobile/features/person/data/person_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the person endpoint and drops malformed films', () {
    final person = parsePersonDetail({
      'person_id': 'nm0680846',
      'name': 'Todd Phillips',
      'photo_url': 'https://example.com/p.jpg',
      'height': {'cm': 183, 'display': '6′ (1.83 m)'},
      'biography': 'Director.',
      'birth_date': '1970-12-20',
      'birth_place': 'Brooklyn',
      'death_date': null,
      'known_for': [
        {
          'film_id': 'tt7286456',
          'title': 'Joker',
          'year': 2019,
          'poster_url': 'http://insecure.example.com/p.jpg',
          'credit_type': 'crew',
          'job': 'Director',
          'characters': <String>[],
        },
        {'film_id': 'tt1', 'title': ''},
        'junk',
      ],
    });

    expect(person.name, 'Todd Phillips');
    expect(person.heightDisplay, '6′ (1.83 m)');
    expect(person.birthDate, DateTime(1970, 12, 20));
    expect(person.deathDate, isNull);
    expect(person.knownFor, hasLength(1));
    expect(person.knownFor.single.isCast, isFalse);
    expect(person.knownFor.single.job, 'Director');
    expect(person.knownFor.single.posterUrl, isNull);
  });

  test('falls back to centimetres when there is no display height', () {
    final person = parsePersonDetail({
      'name': 'A',
      'height': {'cm': 170, 'display': null},
    });

    expect(person.heightDisplay, '170 cm');
  });
}
