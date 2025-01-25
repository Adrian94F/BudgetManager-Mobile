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

  int _currentIndex = 2; // default view
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ExpensesScreen(),
      IncomesScreen(),
      SummaryScreen(),
      StatisticsScreen(),
      SettingsScreen(setThemeMode: widget.setThemeMode), // Przekazujemy funkcję tutaj
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Expenses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              label: 'Incomes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Summary',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Statistics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
