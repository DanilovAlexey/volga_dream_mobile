class TourInfo {
  final String id;
  final String name;
  final String shipName;
  final DateTime startDate;
  final DateTime endDate;

  const TourInfo({
    required this.id,
    required this.name,
    required this.shipName,
    required this.startDate,
    required this.endDate,
  });

  int get daysUntilStart => startDate.difference(DateTime.now()).inDays;

  bool get hasStarted => DateTime.now().isAfter(startDate);

  bool get hasEnded => DateTime.now().isAfter(endDate);

  factory TourInfo.fromJson(Map<String, dynamic> json) => TourInfo(
        id: json['id'] as String,
        name: json['name'] as String,
        shipName: json['shipName'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'shipName': shipName,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };
}
