import '../../find/data/api_client.dart';
import '../domain/person.dart';
import 'person_parser.dart';

/// Loads a cast or crew member's page by their backend person id (a Watchmode
/// numeric id or an IMDb `nm…` id).
abstract class PersonRepository {
  Future<PersonDetail> fetchPerson(String personId);
}

class ApiPersonRepository implements PersonRepository {
  ApiPersonRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<PersonDetail> fetchPerson(String personId) async {
    final json = await _client
        .getJson('/api/films/people/${Uri.encodeComponent(personId)}/');
    return parsePersonDetail(json);
  }
}

class FakePersonRepository implements PersonRepository {
  FakePersonRepository({this.person, this.error});

  final PersonDetail? person;
  final Object? error;
  int calls = 0;

  @override
  Future<PersonDetail> fetchPerson(String personId) async {
    calls++;
    if (error case final error?) throw error;
    return person ?? PersonDetail(id: personId, name: 'Test Person');
  }
}
