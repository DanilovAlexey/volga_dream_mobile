import 'package:http/http.dart' as http;
import '../models/cruise.dart';
import 'service_interfaces.dart';

class CruiseApiService implements ICruiseService {
  final http.Client _client;
  final Uri _baseUrl;
  final String mockUrl = "/mock/cruise"; 
  final String url = "/cruise"; 

  CruiseApiService({
    http.Client? client,
    Uri? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? Uri.parse('http://localhost:8080');

  @override
  Future<Cruise> fetchCruise({required String scheduleId}) async {
    final uri = _baseUrl.resolve(url).replace(queryParameters: {
      'scheduleId': scheduleId,
    });
    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return Cruise.fromRawJson(response.body);
    }
    throw HttpException(
      'Failed to load cruise: ${response.statusCode}',
      response.statusCode,
    );
  }

  @override
  void dispose() {
    _client.close();
  }
}

class HttpException implements Exception {
  final String message;
  final int statusCode;

  HttpException(this.message, this.statusCode);

  @override
  String toString() => message;
}
