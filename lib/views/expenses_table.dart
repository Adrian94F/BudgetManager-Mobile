import 'package:flutter/material.dart';

class ExpensesTableView extends StatelessWidget {
  final List<dynamic> expenses;

  const ExpensesTableView({Key? key, required this.expenses}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Date")),
          DataColumn(label: Text("Value")),
          DataColumn(label: Text("Comment")),
        ],
        rows: expenses.map((expense) {
          return DataRow(cells: [
            DataCell(Text(expense['date'])),
            DataCell(Text(expense['value'].toString())),
            DataCell(Text(expense['comment'])),
          ]);
        }).toList(),
      ),
    );
  }
}
