/// Centralized API configuration.
///
/// The mobile app talks to the EC2 backend directly over HTTP (no proxy —
/// unlike the web client there is no mixed-content rule on mobile).
class ApiConfig {
  ApiConfig._();

  /// Scheme + host + port of the backend. Cleartext HTTP is explicitly
  /// permitted for this host via android/app/src/main/res/xml/network_security_config.xml.
  static const String origin = 'http://18.143.171.142:8080';

  /// Base URL for all REST endpoints. Every service path is appended to this.
  static const String baseUrl = '$origin/api';

  /// Health-check endpoint. Note: it lives at the root (`/health`), NOT under
  /// `/api`, per the live backend & Swagger. Used only to verify connectivity.
  static const String healthUrl = '$origin/health';

  /// Network timeouts.
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
