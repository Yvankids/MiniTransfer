import 'dart:convert';
import 'api_service.dart';
import '../storage/token_storage.dart';

class WalletService {
  static Future<int> getBalance() async {
    final email = await TokenStorage.getEmail();
    if (email == null) throw Exception('Not logged in');

    final response = await ApiService.get(
      '/wallet/balance?email=$email',
      auth: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['balance'];
    }

    throw Exception('Failed to load balance');
  }
}