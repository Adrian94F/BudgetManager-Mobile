import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'expenses_list.dart';

class FilteredExpensesList extends StatelessWidget {
  final List<dynamic> expenses;
  final List<dynamic> categories;
  final ExpensesFilter filter;
  final int monthId;
  final Future<void> Function() refreshParent;

  const FilteredExpensesList({super.key, required this.expenses, required this.categories, required this.filter, required this.monthId, required this.refreshParent});

  @override
  Widget build(BuildContext context) {
    var titleParts = [];
    if (filter.date != null) {
      titleParts += [DateFormat('d.MM.yyyy').format(filter.date!)];
    }
    if (filter.category != null) {
      titleParts += [
        categories.firstWhere((category) => category['id'] == filter.category)['name']
      ];
    }
    var title = AppLocalizations.of(context)!.filteredExpenses;
    var subtitle = titleParts.join(' — ');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          title,
          maxLines: 3,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        shadowColor: Theme.of(context).colorScheme.shadow,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
            child: Text(
              subtitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          )),
      ),
      body: Column(
        children: [
          Expanded(
            child: ExpensesListView(
              expenses: expenses,
              categories: categories,
              filter: filter,
              monthId: monthId,
              refreshParent: refreshParent
            )
          )
        ]
      ),
    );
  }
}
