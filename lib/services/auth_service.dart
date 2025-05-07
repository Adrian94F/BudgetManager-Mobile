import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final storage = const FlutterSecureStorage();

  Future<String> getBaseUrl() async {
    return "${await storage.read(key: "server_url") ?? "http://10.0.2.2:8000"}/api";
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final baseUrl = await getBaseUrl();
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
    final baseUrl = await getBaseUrl();
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

  Future<void> reLogin() async {
    final savedUsername = await storage.read(key: "username");
    final savedPassword = await storage.read(key: "password");
    if (savedPassword != null && savedUsername != null) {
      await login(savedUsername, savedPassword);
    }
  }

  Future<bool> isAuthenticated() async {
    final accessToken = await storage.read(key: "access_token");
    return accessToken != null;
  }

  Future<Map<String, dynamic>> get(String url) async {
    final accessToken = await storage.read(key: "access_token");
    final baseUrl = await getBaseUrl();
    final response = await http.get(
      Uri.parse("$baseUrl/$url"),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else if (response.statusCode == 401) {
      final responseBody = json.decode(utf8.decode(response.bodyBytes));
      if (responseBody["code"] == 'token_not_valid') {
        final messages = responseBody["messages"];
        for (final message in messages) {
          switch (message["token_class"]) {
            case "AccessToken":
              await refreshToken();
              return get(url);
            case "RefreshToken":
              await reLogin();
              return get(url);
            default:
              throw Exception("Unknown token class: ${message["token_class"]}");
          }
        }
      }
    }
    throw Exception("Failed to fetch data");
  }

  Future<Map<String, dynamic>> post(String url, Map<String, dynamic> body) async {
    final accessToken = await storage.read(key: "access_token");
    final baseUrl = await getBaseUrl();

    final response = await http.post(
      Uri.parse("$baseUrl/$url"),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isNotEmpty) {
        //return json.decode(response.body);
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        return {};
      }
    } else if (response.statusCode == 401) {
      await refreshToken();
      return post(url, body);
    } else {
      print("Error ${response.statusCode}: ${response.body}");
      throw Exception("Failed to post data. Error ${response.statusCode}: ${response.body}");
    }
  }

  Future<void> logout() async {
    await storage.delete(key: "access_token");
    await storage.delete(key: "refresh_token");
  }
}