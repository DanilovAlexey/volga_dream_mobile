import '../models/tour.dart';
import '../models/cruise.dart';

abstract class ITourService {
  Future<TourInfo?> fetchNearestTour(DateTime date);
  void dispose();
}

abstract class ICruiseService {
  Future<Cruise> fetchCruise({required String scheduleId});
  void dispose();
}

abstract class INotificationService {
  Future<void> initialize();
  Future<bool> scheduleReminder({
    required String activityId,
    required String title,
    required String body,
    required DateTime startTime,
    int minutesBefore = 15,
  });
  Future<void> cancelReminder(String activityId);
  void dispose();
}
