import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class ApiClient {
  static Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return http.post(
      Uri.parse("${AppConfig.apiBaseUrl}$path"),
      headers: {"Content-Type": "application/json", ...?headers},
      body: body != null ? jsonEncode(body) : null,
    );
  }
}
