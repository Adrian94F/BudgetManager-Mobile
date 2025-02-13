import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';

import '../services/auth_service.dart';
import 'expenses_list.dart';
import 'expenses_table.dart';

class ExpensesScreen extends StatefulWidget {
  final int? currentMonth;
  final void Function(Widget?) setCustomAction;

  const ExpensesScreen({Key? key,  required this.currentMonth, required this.setCustomAction}) : super(key: key);

  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _authService = AuthService();
  late Future<Map<String, dynamic>> _data;
  final _list_table_switch = ValueNotifier<bool>(false);

  @override
  void didUpdateWidget(covariant ExpensesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMonth != widget.currentMonth) {
      _fetchData();
    }
  }

  void _fetchData() {
    setState(() {
      _data = _authService.get("get-expenses${widget.currentMonth == null ? '' : '/?month_id=${widget.currentMonth}'}");
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    _list_table_switch.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.setCustomAction(
          AdvancedSwitch(
            controller: _list_table_switch,
            width: 60.0,
            height: 28.0,
            borderRadius: BorderRadius.circular(16.0),
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
          )
      );
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
            // appBar: AppBar(
            //   shadowColor: Theme.of(context).colorScheme.shadow,
            //   centerTitle: true,
            //   // actions: [
            //   //   const SizedBox(width: 10),
            //   // ],
            // ),
            body: _list_table_switch.value
                ? ExpensesTableView(expenses: expenses, categories: categories, month: month)
                : ExpensesListView(expenses: expenses, categories: categories),
          );
        } else {
          return const Center(child: Text("Error: no data!"));
        }
      },
    );
  }
}
