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
}

class DayItinerary {
  final int dayIndex;
  final String dateLabel;
  final String title;
  final String? locationName;
  final List<Activity> activities;

  const DayItinerary({
    required this.dayIndex,
    required this.dateLabel,
    required this.title,
    this.locationName,
    required this.activities,
  });
}

class Cruise {
  final String name;
  final String shipName;
  final List<DayItinerary> days;

  const Cruise({
    required this.name,
    required this.shipName,
    required this.days,
  });
}
