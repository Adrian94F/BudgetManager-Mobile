import 'package:flutter/material.dart';
import 'package:budget_manager/services/auth_service.dart';

import 'app_settings.dart';

class SettingsScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  final Future<void> Function(String) setThemeMode;

  SettingsScreen({Key? key, required this.setThemeMode}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    await _authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("App settings"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppSettingsScreen(setThemeMode: setThemeMode,)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Log out"),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
