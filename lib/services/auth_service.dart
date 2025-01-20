import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl = "http://10.0.2.2:8000/api";
  final storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/token/"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    print("Status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await storage.write(key: "access_token", value: data['access']);
      await storage.write(key: "refresh_token", value: data['refresh']);
      return data;
    } else {
      throw Exception("Failed to login");
    }
  }

  Future<void> refreshToken() async {
    final refreshToken = await storage.read(key: "refresh_token");
    final response = await http.post(
      Uri.parse("$baseUrl/token/refresh/"),
      body: {'refresh': refreshToken},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await storage.write(key: "access_token", value: data['access']);
    } else {
      throw Exception("Failed to refresh token");
    }
  }

  Future<bool> isAuthenticated() async {
    final accessToken = await storage.read(key: "access_token");
    return accessToken != null;
  }

  Future<Map<String, dynamic>> get([String url = "get-data"]) async {
    final accessToken = await storage.read(key: "access_token");

    final response = await http.get(
      Uri.parse("$baseUrl/$url/"),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      await refreshToken();
      return get(url);
    } else {
      throw Exception("Failed to fetch data");
    }
  }

  Future<void> logout() async {
    await storage.deleteAll();
  }
}