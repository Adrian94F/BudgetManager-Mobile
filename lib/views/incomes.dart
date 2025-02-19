import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../tools/formatters.dart';

class IncomesScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const IncomesScreen({Key? key, required this.data}) : super(key: key);

  @override
  _IncomesScreenState createState() => _IncomesScreenState();
}

class _IncomesScreenState extends State<IncomesScreen> {

  Widget _incomeListItemTitle(dynamic income) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width * 0.25,
            maxWidth: MediaQuery.of(context).size.width * 0.25,
          ),
          child: Text(
            Formatters.currencyFormatter.format(income['value']),
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
        ),

        Text(
          income['date'] ?? "",
          style: const TextStyle(color: Colors.grey, fontSize: 16.0),
        ),
      ],
    );
  }

  Widget? _incomeListItemSubtitle(dynamic income) {
    if ((income['comment'] == null || income['comment'].isEmpty) && income['is_salary'] == false) {
      return null;
    }
    return Container(
        margin: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                income['comment'],
                style: const TextStyle(fontStyle: FontStyle.italic),
                textAlign: TextAlign.end,
              ),
            ),
            if (income['is_salary'] == true)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4.0, left: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey.shade100
                          : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: const Text(
                      "Salary",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final incomes = widget.data['incomes'] as List<dynamic>;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO
        },
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: incomes.length,
        padding: const EdgeInsets.only(bottom: 80),
        itemBuilder: (context, index) {
          final income = incomes[index];

          return Slidable(
            key: Key(income['id'].toString()),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
              title: _incomeListItemTitle(income),
              subtitle: _incomeListItemSubtitle(income)
            ),
          );
        },
      ));
  }
}