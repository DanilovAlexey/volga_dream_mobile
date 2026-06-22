import 'dart:convert';

class Reminder {
  final String id;
  final String activityId;
  final String activityTitle;
  final DateTime activityStart;
  final int minutesBefore;
  final int dayIndex;

  const Reminder({
    required this.id,
    required this.activityId,
    required this.activityTitle,
    required this.activityStart,
    required this.minutesBefore,
    required this.dayIndex,
  });

  DateTime get notifyAt => activityStart.subtract(Duration(minutes: minutesBefore));

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as String,
        activityId: json['activityId'] as String,
        activityTitle: json['activityTitle'] as String,
        activityStart: DateTime.parse(json['activityStart'] as String),
        minutesBefore: json['minutesBefore'] as int,
        dayIndex: json['dayIndex'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'activityId': activityId,
        'activityTitle': activityTitle,
        'activityStart': activityStart.toIso8601String(),
        'minutesBefore': minutesBefore,
        'dayIndex': dayIndex,
      };

  String toRawJson() => jsonEncode(toJson());

  static Reminder fromRawJson(String source) =>
      Reminder.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
