import 'api_client.dart';

class StreamService {
  static Future<Map<String, dynamic>> fetchStreamInfo(int itemId) async {
    final response = await ApiClient.dio.get('/items/$itemId/stream-info');
    return response.data;
  }
}
