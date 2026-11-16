import '../../find/data/api_client.dart';
import '../../find/data/movie.dart';

class TranslatedText {
  const TranslatedText({required this.text, required this.sourceLanguage});

  final String text;
  final String sourceLanguage;
}

abstract class TranslationRepository {
  Future<TranslatedText> translate(
    String text, {
    required String targetLanguage,
  });
}

class ApiTranslationRepository implements TranslationRepository {
  ApiTranslationRepository({ApiClient? client})
      : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<TranslatedText> translate(
    String text, {
    required String targetLanguage,
  }) async {
    final json = await _client.postJson(
      '/api/takes/translate/',
      body: {'text': text, 'target_language': targetLanguage},
    );
    final translated = json['text'];
    if (translated is! String) {
      throw ServerFailure('bad_response', 'Unexpected response from server.');
    }
    return TranslatedText(
      text: translated,
      sourceLanguage: json['source_language'] as String? ?? '',
    );
  }
}
