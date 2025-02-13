import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/auth_service.dart';
import 'expenses.dart';
import 'incomes.dart';
import 'settings.dart';
import 'summary.dart';

class HomeScreen extends StatefulWidget {
  final Future<void> Function(String) setThemeMode;

  const HomeScreen({Key? key, required this.setThemeMode}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  var _currentIndex = 0;
  var _monthRelated = true;
  final _monthRelatedViews = 3;
  late List<Widget> _screens;
  late List<String> _screen_titles;
  late Future<Map<String, dynamic>> _data;
  int? _currentMonthId;
  String? _userName;
  Widget? _customAction;

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
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  Future<void> _logout(BuildContext context) async {
    await _authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _setCustomAction(Widget? action) {
    setState(() {
      _customAction = action;
    });
  }

  Future<void> _loadUserName() async {
    String? login = await _storage.read(key: "login");
    if (login != null) {
      setState(() {
        _userName = login;
        _screen_titles[0] = "Hello, $_userName!";
      });
    }
  }

  void _setScreens() async {
    _screens = [
      SummaryScreen(currentMonth: _currentMonthId),
      ExpensesScreen(currentMonth: _currentMonthId, setCustomAction: _setCustomAction),
      IncomesScreen(currentMonth: _currentMonthId),
      SettingsScreen(setThemeMode: widget.setThemeMode),
    ];
    _screen_titles = [
      "Hello, $_userName!",
      "Expenses",
      "Incomes",
      "Settings",
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _data = _authService.get("get-data");
    _setScreens();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(
                    child: CircularProgressIndicator()
                )
            );
          } else if (snapshot.hasError) {
            _logout(context);
            return const Scaffold(
                body: Center(
                    child: CircularProgressIndicator()
                )
            );
          } else {
            var months = snapshot.data!['months'] as List<dynamic>;

            return Scaffold(
              body: _screens[_currentIndex],
              appBar: AppBar(
                title: Text(
                  _screen_titles[_currentIndex],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                shadowColor: Theme.of(context).colorScheme.shadow,
                actions: _customActionsMenu() + _monthMenu(_monthRelated, months),
              ),
              bottomNavigationBar: _bottomNavigation()
            );
          }
        }
    );
  }

  BottomNavigationBar _bottomNavigation() {
    return BottomNavigationBar(
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
    );
  }

  List<Widget> _customActionsMenu() {
    return _customAction == null
        ? []
        : [
            _customAction!,
            const SizedBox(width: 10)
          ];
  }

  void _selectMonth(int monthId) {
    setState(() {
      _currentMonthId = monthId;
      _setScreens();
    });
  }

  List<Widget> _monthMenu(bool isMonthRelated, List<dynamic> months) {
    var currentMonthIdx = months.indexWhere((month) => month['id'] == _currentMonthId);
    if (currentMonthIdx < 0) {
      currentMonthIdx = 0;
    }
    var previousEnabled = false;
    var nextEnabled = false;
    if (months.isNotEmpty) {
      if (_currentMonthId != null && _currentMonthId != months[0]['id']) {
        nextEnabled = true;
      }
      if (_currentMonthId != months[months.length - 1]['id']) {
        previousEnabled = true;
      }
    }

    return !isMonthRelated ? [] : [
      IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: previousEnabled
            ? () {
          if (currentMonthIdx < months.length - 1) {
            _selectMonth(months[currentMonthIdx + 1]['id']);
          }
        }
            : null,
      ),
      IconButton(
        icon: const Icon(Icons.arrow_forward_ios_rounded),
        onPressed: nextEnabled
            ? () {
          if (currentMonthIdx > 0) {
            _selectMonth(months[currentMonthIdx - 1]['id']);
          }
        }
            : null,
      ),
      MenuAnchor(
        builder: (context, controller, child) {
          return IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
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
              child: const Text("Details"),
              onPressed: () {
                // TODO
              }
          ),
          MenuItemButton(
              child: const Text("Select"),
              onPressed: () {
                // TODO
              }
          ),
          MenuItemButton(
              child: const Text("New month"),
              onPressed: () {
                // TODO
              }
          ),
        ],
      ),
    ];
  }
}
