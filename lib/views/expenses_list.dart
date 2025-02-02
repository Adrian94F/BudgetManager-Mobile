import 'package:flutter/material.dart';

class ExpensesListView extends StatelessWidget {
  final List<dynamic> expenses;

  const ExpensesListView({Key? key, required this.expenses}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return ListTile(
          title: Text(expense['date']),
          subtitle: Text("Amount: ${expense['value']}"),
        );
      },
    );
  }
}
