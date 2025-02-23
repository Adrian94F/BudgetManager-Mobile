import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';

import 'expenses_list.dart';
import 'expenses_table.dart';

class ExpensesScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final void Function(Widget?) setCustomAction;
  final Future<void> Function() refreshParent;

  const ExpensesScreen({Key? key,  required this.data, required this.setCustomAction, required this.refreshParent}) : super(key: key);

  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _list_table_switch = ValueNotifier<bool>(false);

  Future<void> _handleRefresh() async {
    widget.refreshParent();
  }

  @override
  void initState() {
    super.initState();
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
              Icons.table_rows_rounded,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
            ),
            inactiveChild: Icon(
              Icons.grid_view_rounded,
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
    final expenses = widget.data['expenses'] as List<dynamic>;
    final categories = widget.data['categories'] as List<dynamic>;
    final month = widget.data['month'] as Map<String, dynamic>;

    return Scaffold(
      body: _list_table_switch.value
        ? ExpensesListView(expenses: expenses, categories: categories, filter: ExpensesFilter())
        : ExpensesTableView(expenses: expenses, categories: categories, month: month, refreshParent: _handleRefresh),
    );
  }
}
