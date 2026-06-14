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
