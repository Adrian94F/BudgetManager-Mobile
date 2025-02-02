import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';

import '../services/auth_service.dart';
import '../tools/formatters.dart';
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
          final categories = data['categories'] as List<dynamic>;
          final month = data['month'] as Map<String, dynamic>;

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
                      : Colors.grey.shade800,
                  inactiveColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.indigo.shade50
                      : Colors.grey.shade800,
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
                ? ExpensesTableView(expenses_table: GenerateExpensesTable(expenses, categories, month))
                : ExpensesListView(expenses: expenses, categories: categories),
          );
        } else {
          return const Center(child: Text("Error: no data!"));
        }
      },
    );
  }
}

List<List<dynamic>> GenerateExpensesTable(List<dynamic> expenses, List<dynamic> categories, Map<String, dynamic> month) {
  if (expenses.isEmpty) return [];

  final begin_date = month['start_date'];
  final end_date = month['end_date'];

  final Map<DateTime, double> dateSums = {};
  final Map<int, double> categorySums = {};
  final Map<int, Map<DateTime, double>> categoryDateSums = {};

  for (var expense in expenses) {
    var category = expense['category'];
    DateTime date = DateTime.parse(expense['date']);
    double value = (expense['value'] as num).toDouble();
    dateSums[date] = (dateSums[date] ?? 0.0) + value;
    categorySums[category] = (categorySums[category] ?? 0.0) + value;
    categoryDateSums[category] = categoryDateSums[category] ?? {};
    categoryDateSums[category]![date] = (categoryDateSums[category]![date] ?? 0.0) + value;
  }

  List<dynamic> headerRow = [{}];

  var begin_date_obj = DateTime.parse(begin_date);
  var end_date_obj = DateTime.parse(end_date);

  for (var date = begin_date_obj; date.isBefore(end_date_obj); date = date.add(const Duration(days: 1))) {
    var data = {
      "content" : date.day.toString(),
      "date" : date
    };
    headerRow = headerRow + [data];
  }

  List<List<dynamic>> tableRows = [headerRow];

  for (var category in categories) {
    var data = {
      "content" : category['name'],
      "category" : category["id"]
    };
    List<dynamic> categoryRow = [data];
    for (var date = begin_date_obj; date.isBefore(end_date_obj); date = date.add(const Duration(days: 1))) {
      var sum_number = categoryDateSums[category['id']]?[date] ?? 0.0;
      var sum = sum_number != 0.0 ? Formatters.integerFormatter.format(sum_number) : "";
      var data = {
        "content" : sum,
        "date" : date,
        "category" : category["id"]
      };
      categoryRow = categoryRow + [data];
    }
    tableRows = tableRows + [categoryRow];
  }

  return tableRows;
}

