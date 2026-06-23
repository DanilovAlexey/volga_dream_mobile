import 'dart:convert';

class CruiseInfo {
  final String description;
  final List<String> highlights;
  final String externalUrl;
  final String duration;
  final String direction;
  final String? priceFrom;

  const CruiseInfo({
    required this.description,
    required this.highlights,
    required this.externalUrl,
    required this.duration,
    required this.direction,
    this.priceFrom,
  });

  factory CruiseInfo.fromJson(Map<String, dynamic> json) => CruiseInfo(
        description: json['description'] as String,
        highlights: (json['highlights'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        externalUrl: json['externalUrl'] as String,
        duration: json['duration'] as String,
        direction: json['direction'] as String,
        priceFrom: json['priceFrom'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'description': description,
        'highlights': highlights,
        'externalUrl': externalUrl,
        'duration': duration,
        'direction': direction,
        'priceFrom': priceFrom,
      };

  String toRawJson() => jsonEncode(toJson());

  static CruiseInfo fromRawJson(String source) =>
      CruiseInfo.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
