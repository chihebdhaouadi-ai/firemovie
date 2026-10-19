import '../../find/data/api_client.dart';
import 'profile_models.dart';

class ProfileRepository {
  ProfileRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<UserProfile> fetchMe() async {
    final me = await _client.getJson('/api/account/profile');
    return fetchUser(me['id'] as int);
  }

  Future<UserProfile> fetchUser(int userId) async {
    final json = await _client.getJson('/api/account/users/$userId');
    return UserProfile.fromJson(json);
  }

  Future<void> saveBio(String bio) async {
    await _client.patchJson('/api/account/profile', body: {'bio': bio});
  }

  Future<void> uploadAvatar(String filePath) async {
    await _client.patchMultipart(
      '/api/account/profile',
      fileField: 'avatar',
      filePath: filePath,
    );
  }

  Future<void> uploadCover(String filePath) async {
    await _client.patchMultipart(
      '/api/account/profile',
      fileField: 'cover',
      filePath: filePath,
    );
  }
}
