import 'dart:convert';

class CruiseInfo {
  final String description;
  final String externalUrl;
  final String duration;
  final String direction;
  final String? priceFrom;
  final String? imageUrl;

  const CruiseInfo({
    required this.description,
    required this.externalUrl,
    required this.duration,
    required this.direction,
    this.priceFrom,
    this.imageUrl,
  });

  factory CruiseInfo.fromJson(Map<String, dynamic> json) => CruiseInfo(
        description: json['description'] as String,
        externalUrl: json['externalUrl'] as String,
        duration: json['duration'] as String,
        direction: json['direction'] as String,
        priceFrom: json['priceFrom'] as String?,
        imageUrl: json['imageUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'description': description,
        'externalUrl': externalUrl,
        'duration': duration,
        'direction': direction,
        'priceFrom': priceFrom,
        'imageUrl': imageUrl,
      };

  String toRawJson() => jsonEncode(toJson());

  static CruiseInfo fromRawJson(String source) =>
      CruiseInfo.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
