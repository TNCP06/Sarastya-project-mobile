import 'package:dio/dio.dart';

/// Converts a [DioException] into a short, human-readable message.
///
/// The backend (ASP.NET Core) returns two different error shapes:
///  1. Validation errors (400) — `ValidationProblemDetails`:
///     `{ "title": "...", "errors": { "Field": ["msg", ...] } }`
///  2. Everything else (401/404/409/500): `{ "message": "..." }`
///
/// This helper handles both, plus transport-level failures (no network,
/// timeout) so the UI always has something sensible to show.
String describeApiError(Object error) {
  if (error is! DioException) return error.toString();

  // Transport-level problems never carry a response body.
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Connection timed out. Please try again.';
    case DioExceptionType.connectionError:
      return 'Cannot reach the server. Check your connection.';
    default:
      break;
  }

  final data = error.response?.data;
  if (data is Map) {
    // 1) Validation problem details: surface the first field error.
    final errors = data['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
      if (first is String) return first;
    }
    // 2) Generic error envelope.
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;
    final title = data['title'];
    if (title is String && title.isNotEmpty) return title;
  }

  return error.message ?? 'Something went wrong. Please try again.';
}
