import '../models/tour.dart';
import 'service_interfaces.dart';

class TourService implements ITourService {
  Future<String> fetchNearestTourId(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
  }

  Future<TourInfo> fetchTourInfo(String tourId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return TourInfo(
      scheduleId: "00000002-0000-0000-0000-000000000001",
      name: 'Волжское путешествие',
      shipName: 'Александр Невский',
      startDate: DateTime(2026, 7, 1),
      endDate: DateTime(2026, 7, 5),
      imageUrl: "https://volgadream.ru/wp-content/uploads/2024/10/znakomstvo-s-volgoj-gl-2026-scaled.webp"
    );
  }

  @override
  Future<TourInfo?> fetchNearestTour(DateTime date) async {
    final tourId = await fetchNearestTourId(date);
    return fetchTourInfo(tourId);
  }

  @override
  void dispose() {}
}
