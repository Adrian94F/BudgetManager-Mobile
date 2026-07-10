import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final storage = const FlutterSecureStorage();

  // Shared across all AuthService instances so concurrent 401s trigger only a
  // single refresh/re-login attempt (the server rotates & blacklists refresh
  // tokens, so competing refreshes would invalidate each other).
  static Future<bool>? _reauthFuture;

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

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await storage.write(key: "access_token", value: data['access']);
      await storage.write(key: "refresh_token", value: data['refresh']);
      return data;
    } else {
      throw Exception("Failed to login");
    }
  }

  /// Refreshes the access token. Also persists the rotated refresh token that
  /// the server returns (with ROTATE_REFRESH_TOKENS the previous one is
  /// blacklisted, so it must be replaced). Returns whether it succeeded.
  Future<bool> _refreshToken() async {
    final refreshToken = await storage.read(key: "refresh_token");
    if (refreshToken == null) return false;

    final baseUrl = await getBaseUrl();
    final response = await http.post(
      Uri.parse("$baseUrl/token/refresh/"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await storage.write(key: "access_token", value: data['access']);
      if (data['refresh'] != null) {
        await storage.write(key: "refresh_token", value: data['refresh']);
      }
      return true;
    }
    return false;
  }

  /// Silently re-logs-in with the credentials saved at login time. Returns
  /// whether it succeeded.
  Future<bool> _reLogin() async {
    // NOTE: the login screen stores the username under the "login" key.
    final savedUsername = await storage.read(key: "login");
    final savedPassword = await storage.read(key: "password");
    if (savedUsername == null || savedPassword == null) return false;
    try {
      await login(savedUsername, savedPassword);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Serialized, silent re-authentication. Tries to refresh the access token;
  /// if that fails (e.g. the refresh token expired or was blacklisted), falls
  /// back to a re-login with the saved credentials. Only logs out when both
  /// fail. Concurrent callers share a single in-flight attempt.
  Future<bool> _reauthenticate() {
    final existing = _reauthFuture;
    if (existing != null) return existing;

    final future = _performReauthentication();
    _reauthFuture = future;
    future.whenComplete(() => _reauthFuture = null);
    return future;
  }

  Future<bool> _performReauthentication() async {
    var success = await _refreshToken();
    if (!success) {
      success = await _reLogin();
    }
    if (!success) {
      await logout();
    }
    return success;
  }

  Future<bool> isAuthenticated() async {
    final accessToken = await storage.read(key: "access_token");
    return accessToken != null;
  }

  Future<Map<String, dynamic>> get(String url, {bool isRetry = false}) async {
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
    } else if (response.statusCode == 401 && !isRetry) {
      if (await _reauthenticate()) {
        return get(url, isRetry: true);
      }
      throw Exception("Authentication failed");
    }
    throw Exception("Failed to fetch data");
  }

  Future<Map<String, dynamic>> post(String url, Map<String, dynamic> body,
      {bool isRetry = false}) async {
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
    } else if (response.statusCode == 401 && !isRetry) {
      if (await _reauthenticate()) {
        return post(url, body, isRetry: true);
      }
      throw Exception("Authentication failed");
    } else {
      throw Exception("Failed to post data. Error ${response.statusCode}");
    }
  }

  Future<Map<String, dynamic>> delete(String url, Map<String, dynamic> body,
      {bool isRetry = false}) async {
    final accessToken = await storage.read(key: "access_token");
    final baseUrl = await getBaseUrl();

    final response = await http.delete(
      Uri.parse("$baseUrl/$url"),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      if (response.body.isNotEmpty) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        return {};
      }
    } else if (response.statusCode == 401 && !isRetry) {
      if (await _reauthenticate()) {
        return delete(url, body, isRetry: true);
      }
      throw Exception("Authentication failed");
    } else {
      throw Exception("Failed to delete data. Error ${response.statusCode}");
    }
  }

  Future<void> logout() async {
    await storage.delete(key: "access_token");
    await storage.delete(key: "refresh_token");
  }
}
