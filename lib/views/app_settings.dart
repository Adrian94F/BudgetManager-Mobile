import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSettingsScreen extends StatefulWidget {
  final Future<void> Function(String) setThemeMode;

  const AppSettingsScreen({Key? key, required this.setThemeMode})
      : super(key: key);

  @override
  _AppSettingsScreenState createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final TextEditingController _serverController = TextEditingController();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String _currentTheme = "system";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final theme = await _storage.read(key: "theme_mode") ?? "system";
    setState(() {
      _currentTheme = theme;
    });

    final serverUrl = await _storage.read(key: 'server_url');
    _serverController.text = serverUrl ?? '';
  }

  Future<void> _saveTheme(String theme) async {
    await _storage.write(key: "theme_mode", value: theme);
    widget.setThemeMode(theme);
  }

  Future<void> _saveServerUrl(BuildContext context) async {
    final newUrl = _serverController.text.trim();
    if (newUrl.isNotEmpty) {
      await _storage.write(key: 'server_url', value: newUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server URL updated. Please log in again.")),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server URL cannot be empty.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Settings"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
            _appearenceSettings() + _connectionSettings(),
        ),
      ),
    );
  }

  List<Widget> _appearenceSettings() {
    return [
      const Text(
        "Appearance",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      ListTile(
        title: const Text("Theme"),
        trailing: DropdownButton<String>(
          value: _currentTheme,
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
              setState(() {
                _currentTheme = value;
              });
              _saveTheme(value);
            }
          },
        ),
      ),
      const SizedBox(height: 32),
    ];
  }

  List<Widget> _connectionSettings() {
    return [
      const Text(
        "Connection",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      const SizedBox(height: 32),
    ];
  }
}
