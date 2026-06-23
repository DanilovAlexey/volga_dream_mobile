import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cruise_info.dart';
import 'cruise_api_service.dart';
import 'service_interfaces.dart';

class AboutCruiseApiService implements IAboutCruiseService {
  final http.Client _client;
  final Uri _baseUrl;
  final String _path = '/about-cruise';

  AboutCruiseApiService({
    http.Client? client,
    Uri? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? Uri.parse('http://localhost:8080');

  @override
  Future<CruiseInfo> fetchAboutCruise({required String scheduleId}) async {
    final uri = _baseUrl.resolve(_path).replace(
          queryParameters: {'scheduleId': scheduleId},
        );
    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return CruiseInfo.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw HttpException(
      'Failed to load about cruise: ${response.statusCode}',
      response.statusCode,
    );
  }

  @override
  void dispose() {
    _client.close();
  }
}
