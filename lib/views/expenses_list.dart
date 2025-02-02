import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../tools/formatters.dart';

class ExpensesListView extends StatelessWidget {
  final List<dynamic> expenses;
  final List<dynamic> categories;

  const ExpensesListView({Key? key, required this.expenses, required this.categories}) : super(key: key);

  String getCategoryName(int categoryId) {
    final category = categories.firstWhere((element) => element['id'] == categoryId);
    return category['name'];
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];

        return Slidable(
          key: Key(expense['id'].toString()),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {
                  // TODO
                },
                foregroundColor: Colors.indigo,
                icon: Icons.edit,
                label: 'Edit',
              ),
              SlidableAction(
                onPressed: (context) {
                  // TODO
                },
                foregroundColor: Colors.red,
                icon: Icons.delete,
                label: 'Remove',
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Formatters.currencyFormatter.format(expense['value']),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4.0),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey.shade100
                        : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    getCategoryName(expense['category']),
                  ),
                ),
              ],
            ),
            subtitle:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  expense['comment'],
                  //style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                if (expense['is_monthly_expense'] == true)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4.0),
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.grey.shade100
                              : Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: const Text(
                          "Monthly",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}
