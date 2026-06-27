import 'dart:convert';
import 'api_service.dart';
import '../models/user.dart';

class UserService {
  static Future<List<User>> searchUsers(String query) async {
    // Assuming the backend has an endpoint /users/search?q=query
    final response = await ApiService.get(
      '/users/search?query=$query',
      auth: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    }
    
    // If the endpoint doesn't exist yet, we might get a 404 or 500
    // For now, let's return an empty list or throw if it's a real error
    return [];
  }
}
