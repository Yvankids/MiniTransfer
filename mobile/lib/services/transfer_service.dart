import 'dart:convert';
import '../models/transfer_request.dart';
import '../models/transaction.dart';
import '../storage/token_storage.dart';
import 'api_service.dart';

class TransferService {
  static Future<Transaction> transfer(TransferRequest request) async {
    final response = await ApiService.post(
      '/transfers',
      request.toJson(),
      auth: true,
    );

    if (response.statusCode == 200) {
      return Transaction.fromJson(jsonDecode(response.body));
    }

    throw Exception(jsonDecode(response.body)['message'] ?? 'Transfer failed');
  }

  static Future<List<Transaction>> getHistory() async {
    final userId = await TokenStorage.getUserId();
    if (userId == null) throw Exception('Not logged in');

    final response = await ApiService.get(
      '/transactions/$userId',
      auth: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Transaction.fromJson(e)).toList();
    }

    throw Exception('Failed to load history');
  }
}