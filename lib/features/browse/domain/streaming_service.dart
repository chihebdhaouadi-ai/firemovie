import 'package:equatable/equatable.dart';

/// A streaming service the user can browse films by, from
/// `GET /api/films/providers/`.
class StreamingService extends Equatable {
  const StreamingService({required this.id, required this.name, this.logoUrl});

  factory StreamingService.fromJson(Map<String, dynamic> json) {
    final logo = json['logo_url'];
    return StreamingService(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] is String ? json['name'] as String : '',
      logoUrl: logo is String && logo.startsWith('https://') ? logo : null,
    );
  }

  final int id;
  final String name;
  final String? logoUrl;

  @override
  List<Object?> get props => [id, name, logoUrl];
}
