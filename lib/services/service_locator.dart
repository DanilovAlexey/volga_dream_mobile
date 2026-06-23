import 'service_interfaces.dart';
import 'tour_service.dart';
import 'tour_api_service.dart';
import 'cruise_service.dart';
import 'cruise_api_service.dart';
import 'about_cruise_service.dart';
import 'about_cruise_api_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static const bool _useMocks =
      bool.fromEnvironment('USE_MOCKS', defaultValue: false);

  static ITourService createTourService() {
    if (_useMocks) return TourService();
    return TourApiService();
  }

  static ICruiseService createCruiseService() {
    if (_useMocks) return CruiseService();
    return CruiseApiService();
  }

  static IAboutCruiseService createAboutCruiseService() {
    if (_useMocks) return AboutCruiseService();
    return AboutCruiseApiService();
  }
}
