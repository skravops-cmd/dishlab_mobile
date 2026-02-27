import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config.dart'; // fixed import
import '../models/receipt.dart';

class ReceiptsApi {
  /// Fetch last 10 receipts for dashboard
  static Future<List<Receipt>> fetchDashboard(String token) async {
    final response = await http.get(
      Uri.parse("${AppConfig.apiBaseUrl}/api/receipts/dashboard"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch dashboard: ${response.body}");
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Receipt.fromJson(e)).toList();
  }

  /// Create new receipt
  static Future<void> createReceipt({
    required String token,
    required String name,
    required String cuisine,
    required String ingredients,
    required String youtubeLink,
  }) async {
    final response = await http.post(
      Uri.parse("${AppConfig.apiBaseUrl}/api/receipts/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "cuisine": cuisine,
        "ingredients": ingredients,
        "youtube_link": youtubeLink,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to create receipt: ${response.body}");
    }
  }

  /// Delete receipt
  static Future<void> deleteReceipt({
    required String token,
    required String receiptId,
  }) async {
    final response = await http.delete(
      Uri.parse("${AppConfig.apiBaseUrl}/api/receipts/$receiptId"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to delete receipt: ${response.body}");
    }
  }

  /// Update receipt
  static Future<void> updateReceipt({
    required String token,
    required String receiptId,
    String? name,
    String? cuisine,
    String? ingredients,
    String? youtubeLink,
  }) async {
    final response = await http.put(
      Uri.parse("${AppConfig.apiBaseUrl}/api/receipts/$receiptId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        if (name != null) "name": name,
        if (cuisine != null) "cuisine": cuisine,
        if (ingredients != null) "ingredients": ingredients,
        if (youtubeLink != null) "youtube_link": youtubeLink,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update receipt: ${response.body}");
    }
  }

  /// Search receipts with optional filters
  static Future<List<Receipt>> searchReceipts({
    required String token,
    String? ingredients,
    String? cuisine,
    bool matchAll = false,
  }) async {
    final queryParams = <String, String>{};

    if (ingredients != null && ingredients.trim().isNotEmpty) {
      queryParams["ingredients"] = ingredients.trim();
    }

    if (cuisine != null && cuisine.trim().isNotEmpty) {
      queryParams["cuisine"] = cuisine.trim().toLowerCase();
    }

    if (matchAll) {
      queryParams["match_all"] = "true";
    }

    final uri = Uri.parse(
      "${AppConfig.apiBaseUrl}/api/receipts/search",
    ).replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("Search failed: ${response.body}");
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Receipt.fromJson(e)).toList();
  }
}
