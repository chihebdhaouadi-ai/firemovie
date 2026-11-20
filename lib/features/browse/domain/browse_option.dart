import 'package:equatable/equatable.dart';

/// A film genre from `GET /api/films/genres/`.
class BrowseGenre extends Equatable {
  const BrowseGenre({required this.id, required this.name});

  factory BrowseGenre.fromJson(Map<String, dynamic> json) => BrowseGenre(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] is String ? json['name'] as String : '',
      );

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

/// A country films can be browsed by (films streaming there), from
/// `GET /api/films/countries/`.
class BrowseCountry extends Equatable {
  const BrowseCountry({required this.code, required this.name, this.flagUrl});

  factory BrowseCountry.fromJson(Map<String, dynamic> json) {
    final flag = json['flag_url'];
    return BrowseCountry(
      code: json['code'] is String ? json['code'] as String : '',
      name: json['name'] is String ? json['name'] as String : '',
      flagUrl: flag is String && flag.startsWith('https://') ? flag : null,
    );
  }

  final String code;
  final String name;
  final String? flagUrl;

  @override
  List<Object?> get props => [code, name, flagUrl];
}

/// Original languages offered in Browse by language (ISO 639-1 codes). Names
/// are localized in the app.
const browseLanguageCodes = [
  'en', 'fr', 'es', 'it', 'de', 'pt', 'ru', 'ar', //
  'tr', 'hi', 'ko', 'ja', 'zh', 'sv',
];
