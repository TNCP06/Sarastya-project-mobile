
import 'package:flutter/material.dart';
import 'api_client.dart';
import 'token_storage.dart';
import '../models/user.dart';
import 'package:dio/dio.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = true;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<void> checkAuth() async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      final response = await ApiClient.dio.get('/auth/me');
      _currentUser = User.fromJson(response.data);
    } catch (e) {
      await TokenStorage.deleteToken();
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await ApiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final token = response.data['token'];
      await TokenStorage.saveToken(token);
      _currentUser = User.fromJson(response.data['user']);
      notifyListeners();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      final response = await ApiClient.dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      final token = response.data['token'];
      await TokenStorage.saveToken(token);
      _currentUser = User.fromJson(response.data['user']);
      notifyListeners();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Register failed');
    }
  }

  Future<void> logout() async {
    await TokenStorage.deleteToken();
    _currentUser = null;
    notifyListeners();
  }
}
