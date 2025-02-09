import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'expenses.dart';
import 'incomes.dart';
import 'settings.dart';
import 'statistics.dart';
import 'summary.dart';

class HomeScreen extends StatefulWidget {
  final Future<void> Function(String) setThemeMode;

  const HomeScreen({Key? key, required this.setThemeMode}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  int _currentIndex = 0;
  bool _monthRelated = true;
  final _monthRelatedViews = 3;
  late List<Widget> _screens;
  late List<String> _screen_titles;
  late dynamic _data;
  static const List<BottomNavigationBarItem> _items = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_filled),
      label: 'Summary',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart),
      label: 'Expenses',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.attach_money),
      label: 'Incomes',
    ),
    // BottomNavigationBarItem(
    //   icon: Icon(Icons.bar_chart),
    //   label: 'Statistics',
    // ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];
  Widget? _customAction;

  Future<void> _logout(BuildContext context) async {
    await _authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _setCustomAction(Widget? action) {
    setState(() {
      _customAction = action;
    });
  }

  @override
  void initState() {
    super.initState();
    _data = _authService.get();
    _screens = [
      SummaryScreen(),
      ExpensesScreen(setCustomAction: _setCustomAction),
      IncomesScreen(),
      //StatisticsScreen(),
      SettingsScreen(setThemeMode: widget.setThemeMode),
    ];
    _screen_titles = [
      "Summary",
      "Expenses",
      "Incomes",
      //"Statistics",
      "Settings",
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            _logout(context);
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            _screen_titles[0] = "Hello, ${snapshot.data!['username']}!";

            return Scaffold(
              body: _screens[_currentIndex],
              appBar: AppBar(
                title: Text(
                  _screen_titles[_currentIndex],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                shadowColor: Theme.of(context).colorScheme.shadow,
                // centerTitle: true,
                actions: [
                  if (_customAction != null) _customAction!,
                  SizedBox(width: _customAction != null ? 10 : 0),
                  if (_monthRelated) IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      onPressed: () {
                        // TODO
                      }
                  ),
                  if (_monthRelated) IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded),
                      onPressed: () {
                        // TODO
                      }
                  ),
                  if (_monthRelated) MenuAnchor(
                    builder: (context, controller, child) {
                      return IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                      );
                    },
                    menuChildren: [
                      MenuItemButton(
                        onPressed: () => print("Select selected"),
                        child: const Text("Select month"),
                      ),
                      MenuItemButton(
                        onPressed: () => print("Details selected"),
                        child: const Text("Details"),
                      ),
                      MenuItemButton(
                        onPressed: () => print("New selected"),
                        child: const Text("New month"),
                      ),
                    ],
                  ),
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _monthRelated = index < _monthRelatedViews;
                    _customAction = null;
                    _currentIndex = index;
                  });
                },
                items: _items,
              ),
            );
          }
        }
    );
  }
}