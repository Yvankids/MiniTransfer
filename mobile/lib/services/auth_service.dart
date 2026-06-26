import 'dart:convert';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/auth_response.dart';
import '../storage/token_storage.dart';
import 'api_service.dart';

class AuthService {
  static Future<AuthResponse> register(RegisterRequest request) async {
    final response = await ApiService.post(
      '/auth/register',
      request.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final auth = AuthResponse.fromJson(jsonDecode(response.body));
      await TokenStorage.saveToken(auth.token);
      await TokenStorage.saveEmail(auth.email);
      await TokenStorage.saveUserId(auth.userId);
      return auth;
    }

    throw Exception(jsonDecode(response.body)['message'] ?? 'Registration failed');
  }

  static Future<AuthResponse> login(LoginRequest request) async {
    final response = await ApiService.post(
      '/auth/login',
      request.toJson(),
    );

    if (response.statusCode == 200) {
      final auth = AuthResponse.fromJson(jsonDecode(response.body));
      await TokenStorage.saveToken(auth.token);
      await TokenStorage.saveEmail(auth.email);
      await TokenStorage.saveUserId(auth.userId);
      return auth;
    }

    throw Exception(jsonDecode(response.body)['message'] ?? 'Login failed');
  }

  static Future<void> logout() async {
    await TokenStorage.clear();
  }
}