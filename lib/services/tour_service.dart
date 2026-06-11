import '../models/tour.dart';

class TourService {
  Future<String> fetchNearestTourId(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
  }

  Future<TourInfo> fetchTourInfo(String tourId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return TourInfo(
      id: tourId,
      name: 'Волжское путешествие',
      shipName: 'Александр Невский',
      startDate: DateTime(2026, 7, 1),
      endDate: DateTime(2026, 7, 5),
    );
  }

  Future<TourInfo> fetchNearestTour(DateTime date) async {
    final tourId = await fetchNearestTourId(date);
    return fetchTourInfo(tourId);
  }
}
