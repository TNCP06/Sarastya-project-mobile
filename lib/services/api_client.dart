import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'token_storage.dart';

/// Owns the single [Dio] instance used for every authenticated API call.
///
/// An interceptor automatically attaches `Authorization: Bearer <token>` to
/// each request, and intercepts 401 responses: it clears the stored token and
/// notifies the app (via [onUnauthorized]) so it can drop the user back to the
/// login screen.
class ApiClient {
  ApiClient(this._tokenStorage) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        // Treat only 2xx as success; everything else throws so the UI can
        // surface the error consistently.
        contentType: Headers.jsonContentType,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token is missing/expired/invalid: wipe it and let the app react.
            await _tokenStorage.deleteToken();
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  final TokenStorage _tokenStorage;

  /// The configured Dio instance shared across all services.
  late final Dio dio;

  /// Called whenever a 401 is seen. Wired by [AuthProvider] to force a logout.
  void Function()? onUnauthorized;
}
