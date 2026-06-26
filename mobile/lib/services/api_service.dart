import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../storage/token_storage.dart';

class ApiService {
  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await TokenStorage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<http.Response> post(String path, Map<String, dynamic> body,
      {bool auth = false}) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}$path'),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return response;
  }

  static Future<http.Response> get(String path, {bool auth = false}) async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}$path'),
      headers: await _headers(auth: auth),
    );
    return response;
  }
}