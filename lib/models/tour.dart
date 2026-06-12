class TourInfo {
  final String id;
  final String name;
  final String shipName;
  final DateTime startDate;
  final DateTime endDate;
  final String? imageUrl;

  const TourInfo({
    required this.id,
    required this.name,
    required this.shipName,
    required this.startDate,
    required this.endDate,
    this.imageUrl,
  });

  int get daysUntilStart => startDate.difference(DateTime.now()).inDays;

  bool get hasStarted => DateTime.now().isAfter(startDate);

  bool get hasEnded => DateTime.now().isAfter(endDate);

      factory TourInfo.fromJson(Map<String, dynamic> json) => TourInfo(
        id: json['scheduleId'] as String,
        name: json['name'] as String,
        shipName: json['shipName'] as String,
        startDate: DateTime.parse(json['dateBegin'] as String),
        endDate: DateTime.parse(json['dateEnd'] as String),
        imageUrl: json['imageUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'scheduleId': id,
        'name': name,
        'shipName': shipName,
        'dateBegin': startDate.toIso8601String(),
        'dateEnd': endDate.toIso8601String(),
        'imageUrl': imageUrl,
      };
}
