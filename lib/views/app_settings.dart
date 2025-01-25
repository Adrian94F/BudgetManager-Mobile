import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSettingsScreen extends StatelessWidget {
  final Future<void> Function(String) setThemeMode;
  final TextEditingController _serverController = TextEditingController();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  AppSettingsScreen({Key? key, required this.setThemeMode}) : super(key: key);

  ThemeMode _getThemeMode(String mode) {
    switch (mode) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> _loadServerUrl() async {
    final serverUrl = await _storage.read(key: 'server_url');
    _serverController.text = serverUrl ?? '';
  }

  Future<void> _saveServerUrl(BuildContext context) async {
    final newUrl = _serverController.text.trim();
    if (newUrl.isNotEmpty) {
      await _storage.write(key: 'server_url', value: newUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server URL updated. Please log in again.")),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server URL cannot be empty.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadServerUrl();

    return Scaffold(
      appBar: AppBar(
        title: const Text("App Settings"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Appearance",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text("Theme"),
              trailing: DropdownButton<String>(
                value: "system",
                items: const [
                  DropdownMenuItem(
                    value: "light",
                    child: Text("Light"),
                  ),
                  DropdownMenuItem(
                    value: "dark",
                    child: Text("Dark"),
                  ),
                  DropdownMenuItem(
                    value: "system",
                    child: Text("System"),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setThemeMode(value);
                  }
                },
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Connection",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _serverController,
              decoration: const InputDecoration(
                labelText: "Server URL",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _saveServerUrl(context),
              child: const Text("Save Server URL"),
            ),
          ],
        ),
      ),
    );
  }
}
