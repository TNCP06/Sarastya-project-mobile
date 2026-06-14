import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';

/// High-level authentication state of the app.
enum AuthStatus {
  /// Still deciding (reading the stored token / calling `/auth/me`).
  unknown,

  /// A valid session exists.
  authenticated,

  /// No session — the user must log in.
  unauthenticated,
}

/// Single source of truth for who is logged in.
///
/// Drives the router redirect (via [ChangeNotifier]) and exposes the
/// login/register/logout actions used by the auth screens.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService, this._tokenStorage, ApiClient apiClient) {
    // React to 401s coming from any request: force a clean logout.
    apiClient.onUnauthorized = _onUnauthorized;
  }

  final AuthService _authService;
  final TokenStorage _tokenStorage;

  /// Invoked when a session is dropped because the server returned 401 (an
  /// expired/invalid token) — not on an explicit user logout. The app wires
  /// this to show a "session expired" message.
  VoidCallback? onSessionExpired;

  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;

  User? _user;
  User? get user => _user;

  /// Called once at startup: validate any stored token against `/auth/me`.
  Future<void> bootstrap() async {
    try {
      final token = await _tokenStorage.readToken();
      if (token == null || token.isEmpty) {
        _setUnauthenticated();
        return;
      }
      _user = await _authService.me();
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (_) {
      // Invalid/expired token, unreachable backend, or storage failure:
      // treat as logged out.
      try {
        await _tokenStorage.deleteToken();
      } catch (_) {/* ignore */}
      _setUnauthenticated();
    }
  }

  /// Logs in and persists the token. Throws on failure (handled by the UI).
  Future<void> login({required String email, required String password}) async {
    final result = await _authService.login(email: email, password: password);
    await _applyAuthResult(result);
  }

  /// Registers, persists the token, and signs the new user straight in.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
    );
    await _applyAuthResult(result);
  }

  /// Clears the session and token, returning to the unauthenticated state.
  Future<void> logout() async {
    await _tokenStorage.deleteToken();
    _user = null;
    _setUnauthenticated();
  }

  Future<void> _applyAuthResult(AuthResult result) async {
    await _tokenStorage.saveToken(result.token);
    _user = result.user;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  void _onUnauthorized() {
    // The interceptor already deleted the token; just sync our state.
    _user = null;
    if (_status != AuthStatus.unauthenticated) {
      _setUnauthenticated();
      onSessionExpired?.call();
    }
  }

  void _setUnauthenticated() {
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
