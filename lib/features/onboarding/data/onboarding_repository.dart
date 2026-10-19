import '../../find/data/api_client.dart';

class OnboardingCounts {
  const OnboardingCounts({
    required this.top5,
    required this.watched,
    required this.watchlist,
  });

  final int top5;
  final int watched;
  final int watchlist;
}

class OnboardingRepository {
  OnboardingRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  static const _profilePath = '/api/account/profile';

  Future<OnboardingCounts> fetchCounts() async {
    final json = await _client.getJson(_profilePath);
    int countOf(String key) => (json[key] as List? ?? const []).length;
    return OnboardingCounts(
      top5: countOf('top_movies'),
      watched: countOf('watched_movies'),
      watchlist: countOf('watchlist_movies'),
    );
  }

  Future<void> saveBio(String bio) async {
    await _client.patchJson(_profilePath, body: {'bio': bio});
  }

  Future<void> uploadAvatar(String filePath) async {
    await _client.patchMultipart(
      _profilePath,
      fileField: 'avatar',
      filePath: filePath,
    );
  }

  Future<void> uploadCover(String filePath) async {
    await _client.patchMultipart(
      _profilePath,
      fileField: 'cover',
      filePath: filePath,
    );
  }
}
