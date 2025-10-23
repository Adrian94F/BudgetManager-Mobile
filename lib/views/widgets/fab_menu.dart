import 'package:flutter/material.dart';

import 'package:budget_manager/l10n/app_localizations.dart';
import '../month_details.dart';
import '../expense_details.dart';
import '../income_details.dart';

enum FabType { full, expense, income }

class FabMenu extends StatelessWidget {
  final Map<String, dynamic> loadedData;
  final VoidCallback onRefresh;
  FabType fabType;

  FabMenu({
    super.key,
    required this.loadedData,
    required this.onRefresh,
    this.fabType = FabType.full,
  });


  @override
  Widget build(BuildContext context) {
    switch (fabType) {
      case FabType.expense:
        return buildAddExpenseFAB(context, inModal: false);
      case FabType.income:
        return buildAddIncomeFAB(context, inModal: false);
      case FabType.full:
        return FloatingActionButton(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (BuildContext context) {
                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 70),
                      child: buildAddExpenseFAB(context),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 140.0),
                      child: buildAddIncomeFAB(context),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 210.0),
                      child: FloatingActionButton.extended(
                        heroTag: 'month_details_fab',
                        onPressed: () {
                          monthDetailsFabAction(context);
                        },
                        label: Text(AppLocalizations.of(context)!.monthDetails),
                        icon: const Icon(Icons.edit_calendar),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 280.0),
                      child: FloatingActionButton.extended(
                        heroTag: 'add_month_fab',
                        onPressed: () {
                          newMonthFabAction(context);
                        },
                        label: Text(AppLocalizations.of(context)!.newMonth),
                        icon: const Icon(Icons.calendar_month_rounded),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          child: const Icon(Icons.menu_rounded),
        );
    }
  }

  void addExpenseFabAction(BuildContext context, {bool inModal = true}) {
    if (inModal) {
      Navigator.pop(context);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetails(
          categories: loadedData['categories'],
          monthId: loadedData['month']['id'],
          topCategories: getTopNCategories(loadedData['expenses'], 5),
        ),
      ),
    ).then((_) => onRefresh());
  }

  Widget buildAddExpenseFAB(BuildContext context, {bool inModal = true}) {
    if (inModal) {
      return FloatingActionButton.extended(
        heroTag: 'add_expense_fab',
        onPressed: () {
          addExpenseFabAction(context, inModal: inModal);
        },
        label: Text(AppLocalizations.of(context)!.addExpense),
        icon: const Icon(Icons.arrow_upward_rounded),
      );
    } else {
      return FloatingActionButton(
        heroTag: 'add_expense_fab',
        onPressed: () {
          addExpenseFabAction(context, inModal: inModal);
        },
        child: const Icon(Icons.add),
      );
    }
  }

  void addIncomeFabAction(BuildContext context, {bool inModal = true}) {
    if (inModal) {
      Navigator.pop(context);
    }
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => IncomeDetails(
          income: null,
          monthId: loadedData['month']['id'],
          preferredDate: DateTime.now(),
        ))
    ).then((_) => onRefresh());
  }

  Widget buildAddIncomeFAB(BuildContext context, {bool inModal = true}) {
    if (inModal) {
      return FloatingActionButton.extended(
        heroTag: 'add_income_fab',
        onPressed: () {
          addIncomeFabAction(context, inModal: inModal);
        },
        label: Text(AppLocalizations.of(context)!.addIncome),
        icon: const Icon(Icons.arrow_downward_rounded),
      );
    } else {
      return FloatingActionButton(
        heroTag: 'add_income_fab',
        onPressed: () {
          addIncomeFabAction(context, inModal: inModal);
        },
        child: const Icon(Icons.add),
      );
    }
  }

  void monthDetailsFabAction(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MonthDetailsScreen(
          month: loadedData['month'],
        ),
      ),
    ).then((_) => onRefresh());
  }

  void newMonthFabAction(BuildContext context) {
    Navigator.pop(context);
    var newStartDate =
    DateTime.parse(loadedData['month']['end_date'])
        .add(const Duration(days: 1));
    var newEndDate = newStartDate.add(const Duration(days: 30));
    var newMonth = {
      'id': null,
      'start_date': newStartDate.toString(),
      'end_date': newEndDate.toString(),
    };
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MonthDetailsScreen(
          month: newMonth,
        ),
      ),
    ).then((_) => onRefresh());
  }

  static List<int> getTopNCategories(List<dynamic> expenses, int nOfCategories) {
    Map<int, int> categoryCounts = {};
    for (var expense in expenses) {
      int categoryId = expense['category'];
      categoryCounts[categoryId] = (categoryCounts[categoryId] ?? 0) + 1;
    }
    List<MapEntry<int, int>> categoryCountsList = categoryCounts.entries.toList();
    categoryCountsList.sort((a, b) => b.value.compareTo(a.value));
    return categoryCountsList.take(nOfCategories).map((entry) => entry.key).toList();
  }
}
