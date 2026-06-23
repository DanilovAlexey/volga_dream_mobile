import '../models/tour.dart';
import '../models/cruise.dart';
import '../models/cruise_info.dart';

abstract class ITourService {
  Future<TourInfo?> fetchNearestTour(DateTime date);
  void dispose();
}

abstract class ICruiseService {
  Future<Cruise> fetchCruise({required String scheduleId});
  void dispose();
}

abstract class IAboutCruiseService {
  Future<CruiseInfo> fetchAboutCruise({required String scheduleId});
  void dispose();
}
