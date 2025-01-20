import 'package:flutter/material.dart';
import 'package:budget_manager/services/auth_service.dart';

import 'summary.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  //late Future<Map<String, dynamic>> _data;

  int _currentIndex = 2; // default view
  final List<Widget> _screens = [
    ExpensesScreen(),
    IncomesScreen(),
    SummaryScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    //_data = _authService.get();
  }

  Future<void> _logout() async {
    await _authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Budget Manager"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
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

class ExpensesScreen extends StatefulWidget {
  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _authService = AuthService();
  late Future<Map<String, dynamic>> _data;

  @override
  void initState() {
    super.initState();
    _data = _authService.get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          return Center(child: Text("Data: ${snapshot.data}"));
        }
      },
    );
  }
}

class IncomesScreen extends StatefulWidget {
  @override
  _IncomesScreenState createState() => _IncomesScreenState();
}

class _IncomesScreenState extends State<IncomesScreen> {
  final _authService = AuthService();
  late Future<Map<String, dynamic>> _data;

  @override
  void initState() {
    super.initState();
    _data = _authService.get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          return Center(child: Text("Data: ${snapshot.data}"));
        }
      },
    );
  }
}

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _authService = AuthService();
  late Future<Map<String, dynamic>> _data;

  @override
  void initState() {
    super.initState();
    _data = _authService.get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          return Center(child: Text("Data: ${snapshot.data}"));
        }
      },
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Ekran Ustawień'));
  }
}