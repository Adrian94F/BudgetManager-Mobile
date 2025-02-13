import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../tools/formatters.dart';

class ExpensesListView extends StatelessWidget {
  final List<dynamic> expenses;
  final List<dynamic> categories;

  const ExpensesListView({Key? key, required this.expenses, required this.categories}) : super(key: key);

  String getCategoryName(int categoryId) {
    final category = categories.firstWhere(
        (element) => element['id'] == categoryId,
        orElse: () => {'name': '–'}
    );
    return category['name'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO
        },
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: expenses.length,
        padding: const EdgeInsets.only(bottom: 80),
        itemBuilder: (context, index) {
          final expense = expenses[index];
          final String currentDate = expense['date'];
          bool showDateHeader = index == 0 || expenses[index - 1]['date'] != currentDate;
          bool isToday = DateTime.now().day == DateTime.parse(currentDate).day &&
                         DateTime.now().month == DateTime.parse(currentDate).month &&
                         DateTime.now().year == DateTime.parse(currentDate).year;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDateHeader)
                Container(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 24.0, 8.0, 8.0),
                    //child: Center(
                      child: Text(
                        currentDate,
                        style: const TextStyle(
                          //fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          fontStyle: FontStyle.italic
                        ),
                      ),
                    //),
                  ),
                ),
              Slidable(
                key: Key(expense['id'].toString()),
                endActionPane: ActionPane(
                  motion: ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        // TODO
                      },
                      foregroundColor: Colors.indigo,
                      backgroundColor: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Colors.grey.shade900,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                    SlidableAction(
                      onPressed: (context) {
                        // TODO
                      },
                      foregroundColor: Colors.red.shade900,
                      backgroundColor: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : Colors.grey.shade900,
                      icon: Icons.delete,
                      label: 'Remove',
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2.0),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Formatters.currencyFormatter.format(expense['value']),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                      ),
                      Text(
                        expense['date'],
                        style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          expense['comment'],
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      if (expense['is_monthly'] == true)
                        Container(
                          margin: const EdgeInsetsDirectional.symmetric(horizontal: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.light
                                ? Colors.indigo.shade50
                                : Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Icon(
                            Icons.repeat,
                            size: 20,
                            color: Theme.of(context).brightness == Brightness.light
                                ? Colors.grey.shade900
                                : Colors.grey.shade100,
                          ),
                        ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.light
                                ? Colors.indigo.shade50
                                : Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            getCategoryName(expense['category']),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.light
                                    ? Colors.grey.shade900
                                    : Colors.grey.shade100),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
