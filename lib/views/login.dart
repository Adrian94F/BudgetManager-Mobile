import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:budget_manager/services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _serverController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  // Function to load server URL on init
  Future<void> _loadSavedData() async {
    final serverUrl = await _storage.read(key: "server_url");
    if (serverUrl != null) {
      _serverController.text = serverUrl; // Set the server URL in the text field
    }
    final login = await _storage.read(key: "login");
    if (login != null) {
      _usernameController.text = login;
      _rememberMe = true;
    }
    final password = await _storage.read(key: "password");
    if (password != null) {
      _passwordController.text = password;
    }
  }

  // Function to save the server URL
  Future<void> _setServerUrl(String value) async {
    await _storage.write(key: "server_url", value: value);
  }

  Future<void> _login() async {
    if (_rememberMe) {
      await _storage.write(key: "login", value: _usernameController.text);
      await _storage.write(key: "password", value: _passwordController.text);
    }
    try {
      await _authService.login(
        _usernameController.text,
        _passwordController.text,
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.login)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.username),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.password),
              obscureText: true,
            ),
            TextField(
              controller: _serverController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.serverUrl),
              onChanged: _setServerUrl,
            ),
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value!;
                    });
                  },
                ),
                Text(AppLocalizations.of(context)!.rememberMe)
              ],
            ),
            ElevatedButton(
              onPressed: _login,
              child: Text(AppLocalizations.of(context)!.login),
            ),
          ],
        ),
      ),
    );
  }
}
