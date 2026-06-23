import 'dart:convert';

enum ActivityType { lecture, excursion, meal }

class Activity {
  final String id;
  final String title;
  final String description;
  final ActivityType type;
  final String timeRange;
  final String location;
  final int dayIndex;
  final String? lecturer;

  const Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timeRange,
    required this.location,
    required this.dayIndex,
    this.lecturer,
  });

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        type: ActivityType.values.byName(json['type'] as String),
        timeRange: json['timeRange'] as String,
        location: json['location'] as String,
        dayIndex: json['dayIndex'] as int,
        lecturer: json['lecturer'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'timeRange': timeRange,
        'location': location,
        'dayIndex': dayIndex,
        'lecturer': lecturer,
      };
}

class DayItinerary {
  final int dayIndex;
  final DateTime dayDate;
  final String dateLabel;
  final String title;
  final String? locationName;
  final List<Activity> activities;

  const DayItinerary({
    required this.dayIndex,
    required this.dayDate,
    required this.dateLabel,
    required this.title,
    this.locationName,
    required this.activities,
  });

  factory DayItinerary.fromJson(Map<String, dynamic> json) => DayItinerary(
        dayIndex: json['dayIndex'] as int,
        dayDate: DateTime.parse(json['dayDate'] as String),
        dateLabel: json['dateLabel'] as String,
        title: json['title'] as String,
        locationName: json['locationName'] as String?,
        activities: (json['activities'] as List<dynamic>)
            .map((e) => Activity.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'dayIndex': dayIndex,
        'dateLabel': dateLabel,
        'title': title,
        'locationName': locationName,
        'activities': activities.map((e) => e.toJson()).toList(),
      };
}

class Cruise {
  final String name;
  final String shipName;
  final DateTime startDate;
  final DateTime endDate;
  final List<DayItinerary> days;

  const Cruise({
    required this.name,
    required this.shipName,
    required this.startDate,
    required this.endDate,
    required this.days,
  });

  factory Cruise.fromJson(Map<String, dynamic> json) => Cruise(
        name: json['name'] as String,
        shipName: json['shipName'] as String,
        startDate: DateTime.parse(json['dateBegin'] as String),
        endDate: DateTime.parse(json['dateEnd'] as String),
        days: (json['days'] as List<dynamic>)
            .map((e) => DayItinerary.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'shipName': shipName,
        'days': days.map((e) => e.toJson()).toList(),
      };

  String toRawJson() => jsonEncode(toJson());

  static Cruise fromRawJson(String source) =>
      Cruise.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
