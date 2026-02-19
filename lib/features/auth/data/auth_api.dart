import 'dart:convert';
import '../../../core/api/api_client.dart';
import '../models/token_response.dart';

class AuthApi {
  static Future<void> register({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      "/api/auth/register",
      body: {"email": email, "password": password},
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  static Future<TokenResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      "/api/auth/login",
      body: {"email": email, "password": password},
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    return TokenResponse.fromJson(jsonDecode(response.body));
  }
}
