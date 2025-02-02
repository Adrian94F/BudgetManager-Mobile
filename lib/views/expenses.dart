import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';

import '../services/auth_service.dart';
import 'expenses_list.dart';
import 'expenses_table.dart';

class ExpensesScreen extends StatefulWidget {
  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _authService = AuthService();
  late Future<Map<String, dynamic>> _data;
  final _list_table_switch = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _data = _authService.get("get-expenses");
    _list_table_switch.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          final expenses = data['expenses'] as List<dynamic>;

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Expenses",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              shadowColor: Theme.of(context).colorScheme.shadow,
              centerTitle: true,
              actions: [
                AdvancedSwitch(
                  controller: _list_table_switch,
                  activeColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.indigo.shade50
                      : Colors.indigo.shade900,
                  inactiveColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.indigo.shade50
                      : Colors.indigo.shade900,
                  activeChild: Icon(
                    Icons.grid_view_rounded,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  ),
                  inactiveChild: Icon(
                    Icons.table_rows_rounded,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  ),
                  width: 60.0,
                  height: 28.0,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                const SizedBox(width: 10),
              ],
            ),
            body: _list_table_switch.value
                ? ExpensesTableView(expenses: expenses)
                : ExpensesListView(expenses: expenses),
          );
        } else {
          return const Center(child: Text("Error: no data!"));
        }
      },
    );
  }
}
