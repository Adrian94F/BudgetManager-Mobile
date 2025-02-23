import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

import '../services/auth_service.dart';
import 'expenses_list.dart';
import 'expenses_table.dart';
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
  final _monthRelatedViews = 4;
  late List<Widget> _screens;
  final List<String> _screenTitles = [
    "Hello!",
    "Expenses list",
    "Expenses table",
    "Incomes",
    "Settings",
  ];
  late Future<Map<String, dynamic>> _data;
  int? _currentMonthId;
  // Widget? _customAction;

  Future<void> _logout(BuildContext context) async {
    await _authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // void _setCustomAction(Widget? action) {
  //   setState(() {
  //     _customAction = action;
  //   });
  // }

  Future<void> _loadUserName() async {
    String? login = await _storage.read(key: "login");
    if (login != null) {
      setState(() {
        _screenTitles[0] = AppLocalizations.of(context)!.summaryTitle(login);
        _screenTitles[1] = AppLocalizations.of(context)!.expensesList;
        _screenTitles[2] = AppLocalizations.of(context)!.expensesTable;
        _screenTitles[3] = AppLocalizations.of(context)!.incomes;
        _screenTitles[4] = AppLocalizations.of(context)!.settings;
      });
    }
  }

  void _setScreens(dynamic data) {
    final expenses = data['expenses'] as List<dynamic>;
    final categories = data['categories'] as List<dynamic>;
    final month = data['month'] as Map<String, dynamic>;

    _screens = [
      SummaryScreen(data: data),
      ExpensesListView(expenses: expenses, categories: categories, filter: ExpensesFilter()),
      ExpensesTableView(expenses: expenses, categories: categories, month: month, refreshParent: _handleRefresh),
      // ExpensesScreen(
      //     data: data,
      //     setCustomAction: _setCustomAction,
      //     refreshParent: _handleRefresh),
      IncomesScreen(data: data, refreshParent: () => _handleRefresh(),),
      SettingsScreen(setThemeMode: widget.setThemeMode),
    ];
  }

  void _fetchData() {
    try {
      _data = _authService.get("month/${_currentMonthId == null
          ? ''
          : '?month_id=$_currentMonthId'}");
      return;
    } catch (e) {
      print("trying to fetch current month");
    }
    _data = _authService.get("month");
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
                body: const Center(
                    child: CircularProgressIndicator()
                ),
                appBar: AppBar(
                  title: Text(
                    _screenTitles[_currentIndex],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  shadowColor: Theme.of(context).colorScheme.shadow,
                  actions: /* _customActionsMenu() + */ _monthMenu(context, _monthRelated, []),
                ),
                bottomNavigationBar: _bottomNavigation()
            );
          } else if (snapshot.hasError) {
            _logout(context);
            return const Scaffold(
                body: Center(
                    child: CircularProgressIndicator()
                )
            );
          } else {
            var data = snapshot.data;
            var months = data!['months'] as List<dynamic>;
            _setScreens(data);

            var message = data['message'];
            var body = message == null
              ? _screens[_currentIndex]
              : Center(
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                )
              );


            return Scaffold(
              body: RefreshIndicator(
                onRefresh: () => _handleRefresh(),
                child: body is Center
                    ? ListView(
                        children: [body],
                      )
                    : body,
              ),
              appBar: AppBar(
                title: Text(
                  _screenTitles[_currentIndex],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                shadowColor: Theme.of(context).colorScheme.shadow,
                actions: /* _customActionsMenu() + */ _monthMenu(context, _monthRelated, months),
              ),
              bottomNavigationBar: _bottomNavigation(),
            );
          }
        }
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _fetchData();
    });
  }

  BottomNavigationBar _bottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _monthRelated = index < _monthRelatedViews;
          // _customAction = null;
          _currentIndex = index;
        });
      },
      // showSelectedLabels: false,
      // showUnselectedLabels: false,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_rounded),
          label: AppLocalizations.of(context)!.summary,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.table_rows_rounded),
          label: AppLocalizations.of(context)!.expensesListShort,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.grid_view_rounded),
          label: AppLocalizations.of(context)!.expensesTableShort,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.download_rounded),
          label: AppLocalizations.of(context)!.incomes,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_rounded),
          label: AppLocalizations.of(context)!.settings,
        ),
      ],
    );
  }

  // List<Widget> _customActionsMenu() {
  //   return _customAction == null
  //       ? []
  //       : [
  //           _customAction!,
  //           const SizedBox(width: 10)
  //         ];
  // }

  void _selectMonth(int monthId) {
    setState(() {
      _currentMonthId = monthId;
      _fetchData();
    });
  }

  void _showMonthDetailsDialog(List<dynamic> months) {
    var currentMonthIdx = _getCurrentMonthIdx(months);
    bool isLoading = false;
    String? errorMessage;
    DateTime startDate = DateTime.parse(months[currentMonthIdx]['start_date']);
    DateTime endDate = DateTime.parse(months[currentMonthIdx]['end_date']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.monthDetails),
              actionsPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.startDate),
                  TextButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null && pickedDate != startDate) {
                        setState(() {
                          startDate = pickedDate;
                        });
                      }
                    },
                    child: Text("${startDate.toLocal()}".split(' ')[0]),
                  ),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context)!.endDate),
                  TextButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null && pickedDate != endDate) {
                        setState(() {
                          endDate = pickedDate;
                        });
                      }
                    },
                    child: Text("${endDate.toLocal()}".split(' ')[0]),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });

                    var monthId = months[currentMonthIdx]['id'];
                    var format = DateFormat("yyyy-MM-dd");
                    var requestData = {
                      'start_date': format.format(startDate),
                      'end_date': format.format(endDate),
                      'id': monthId,
                    };

                    try {
                      await _authService.post("month/", requestData);
                      Navigator.pop(context);
                      _handleRefresh();
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                        errorMessage = AppLocalizations.of(context)!.errorSavingData;
                      });
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMonthSelectorDialog(List<dynamic> months) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectMonth),
          actionsPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 24.0),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: months.length,
              itemBuilder: (context, index) {
                final month = months[index];
                final currentYear = month['start_date'].substring(0, 4);
                final bool showYearHeader = index == 0 ||
                    months[index - 1]['start_date'].substring(0, 4) != currentYear;
                final bool isSelected = (_currentMonthId == null && index == 0) || month['id'] == _currentMonthId;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showYearHeader)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          currentYear,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ListTile(
                      title: Text(
                        "${month['start_date']} – ${month['end_date']}",
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      titleAlignment: ListTileTitleAlignment.center,
                      onTap: () {
                        setState(() {
                          _currentMonthId = month['id'];
                          _fetchData();
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        );
      },
    );
  }

  int _getCurrentMonthIdx(List<dynamic> months) {
    var currentMonthIdx = months.indexWhere((month) => month['id'] == _currentMonthId);
    if (currentMonthIdx < 0) {
      currentMonthIdx = 0;
    }
    return currentMonthIdx;
  }


  List<Widget> _monthMenu(BuildContext context, bool isMonthRelated, List<dynamic> months) {
    var currentMonthIdx = _getCurrentMonthIdx(months);
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
              child: Text(AppLocalizations.of(context)!.monthDetails),
              onPressed: () => _showMonthDetailsDialog(months)
          ),
          MenuItemButton(
              child: Text(AppLocalizations.of(context)!.selectMonth),
              onPressed: () => _showMonthSelectorDialog(months)
          ),
          MenuItemButton(
              child: Text(AppLocalizations.of(context)!.newMonth),
              onPressed: () async {
                var latestMonth = months[0]!;
                var startDate = DateTime.parse(latestMonth['end_date']).add(const Duration(days: 1));
                var endDate = Jiffy.parseFromDateTime(startDate).add(months: 1).subtract(days: 1).dateTime;
                var format = DateFormat("yyyy-MM-dd");
                var requestData = {
                  'start_date': format.format(startDate),
                  'end_date': format.format(endDate),
                };

                try {
                  await _authService.post("month/", requestData);
                  _handleRefresh();
                } catch (e) {
                  setState(() {
                    // isLoading = false;
                    // errorMessage = AppLocalizations.of(context)!.errorSavingData;
                  });
                }
              }
          ),
        ],
      ),
    ];
  }
}
