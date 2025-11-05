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
        return buildAddExpenseFAB(context);
      case FabType.income:
        return buildAddIncomeFAB(context);
      case FabType.full:
        return FloatingActionButton(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (BuildContext context) {
                final isVertical = MediaQuery.of(context).orientation == Orientation.portrait;
                return GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    color: Colors.transparent,
                    child: DraggableScrollableSheet(
                      initialChildSize: isVertical ? 0.4 : 0.7,
                      minChildSize: 0.3,
                      maxChildSize: isVertical ? 0.5 : 0.7,
                      builder: (_, scrollController) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              topRight: Radius.circular(16.0),
                            ),
                          ),
                          child: ListView(
                            controller: scrollController,
                            children: [
                              Center(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  height: 5.0,
                                  width: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                              buildAddExpenseListItem(context),
                              buildAddIncomeListItem(context),
                              buildMonthDetailsListItem(context),
                              buildNewMonthListItem(context),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
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

  Widget _buildModalListItem({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }

  Widget buildAddExpenseListItem(BuildContext context) {
    return _buildModalListItem(
      context: context,
      label: AppLocalizations.of(context)!.addExpense,
      icon: Icons.arrow_upward_rounded,
      onTap: () => addExpenseFabAction(context),
    );
  }

  Widget buildAddIncomeListItem(BuildContext context) {
    return _buildModalListItem(
      context: context,
      label: AppLocalizations.of(context)!.addIncome,
      icon: Icons.arrow_downward_rounded,
      onTap: () => addIncomeFabAction(context),
    );
  }

  Widget buildMonthDetailsListItem(BuildContext context) {
    return _buildModalListItem(
      context: context,
      label: AppLocalizations.of(context)!.monthDetails,
      icon: Icons.edit_calendar,
      onTap: () => monthDetailsFabAction(context),
    );
  }

  Widget buildNewMonthListItem(BuildContext context) {
    return _buildModalListItem(
      context: context,
      label: AppLocalizations.of(context)!.newMonth,
      icon: Icons.calendar_month_rounded,
      onTap: () => newMonthFabAction(context),
    );
  }

  Widget buildAddExpenseFAB(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'add_expense_fab',
      onPressed: () {
        addExpenseFabAction(context, inModal: false);
      },
      child: const Icon(Icons.add),
    );
  }

  Widget buildAddIncomeFAB(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'add_income_fab',
      onPressed: () {
        addIncomeFabAction(context, inModal: false);
      },
      child: const Icon(Icons.add),
    );
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
