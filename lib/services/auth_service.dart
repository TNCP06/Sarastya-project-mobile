import '../models/user.dart';
import 'api_client.dart';

/// Result of a successful login/register: the JWT plus the user it belongs to.
class AuthResult {
  const AuthResult({required this.token, required this.user});

  final String token;
  final User user;
}

/// Wraps the authentication endpoints of the API.
class AuthService {
  AuthService(this._apiClient);

  final ApiClient _apiClient;

  /// POST /api/auth/register → 201 `{ token, user }`.
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _apiClient.dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {'name': name, 'email': email, 'password': password},
    );
    return _parseAuth(res.data!);
  }

  /// POST /api/auth/login → 200 `{ token, user }`.
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final res = await _apiClient.dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return _parseAuth(res.data!);
  }

  /// GET /api/auth/me → 200 `{ id, name, email }`.
  Future<User> me() async {
    final res = await _apiClient.dio.get<Map<String, dynamic>>('/auth/me');
    return User.fromJson(res.data!);
  }

  AuthResult _parseAuth(Map<String, dynamic> data) {
    return AuthResult(
      token: data['token'] as String,
      user: User.fromJson(data['user'] as Map<String, dynamic>),
    );
  }
}
