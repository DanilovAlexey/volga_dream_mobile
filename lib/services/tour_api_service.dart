import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tour.dart';
import 'cruise_api_service.dart';

class TourApiService {
  final http.Client _client;
  final Uri _baseUrl;
  final String _path = '/cruise/nearest';

  TourApiService({
    http.Client? client,
    Uri? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? Uri.parse('http://localhost:8080');

  Future<TourInfo?> fetchNearestTour(DateTime date) async {
    final uri = _baseUrl.resolve(_path).replace(
          queryParameters: {'date': _formatDate(date)},
        );
    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 204) return null;

    if (response.statusCode == 200) {
      return TourInfo.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw HttpException(
      'Failed to load nearest tour: ${response.statusCode}',
      response.statusCode,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void dispose() {
    _client.close();
  }
}
