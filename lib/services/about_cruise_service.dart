import '../models/cruise_info.dart';
import 'service_interfaces.dart';

class AboutCruiseService implements IAboutCruiseService {
  @override
  Future<CruiseInfo> fetchAboutCruise({required String scheduleId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return getMockAboutCruise();
  }

  CruiseInfo getMockAboutCruise() {
    return const CruiseInfo(
      direction: 'Москва — Тверь — Углич — Москва',
      duration: '2 или 3 ночи',
      priceFrom: 'от 65 000 ₽',
      description:
          'Идеальный выбор для тех, кто хочет на несколько дней сменить обстановку, '
          'восстановить силы и почувствовать атмосферу речных путешествий с Volga Dream. '
          'Всё продумано до мелочей: маршруты, экскурсии, отдых на борту и безупречный сервис. '
          'Круиз проходит по верховьям Волги с остановками в двух городах с богатой историей — '
          'Твери и Угличе. Именно здесь, среди живописных берегов, берёт начало великая Волга.',
      imageUrl:
          'https://volgadream.ru/wp-content/uploads/2024/10/znakomstvo-s-volgoj-gl-2026-scaled.webp',
      externalUrl: 'https://volgadream.ru/cruise/znakomstvo-s-volgoj/',
    );
  }

  @override
  void dispose() {}
}
