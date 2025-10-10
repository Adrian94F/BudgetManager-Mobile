import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../month_details.dart';
import '../expense_details.dart';
import '../income_details.dart';

class FabMenu extends StatelessWidget {
  final Map<String, dynamic> loadedData;
  final VoidCallback onRefresh;

  const FabMenu({
    super.key,
    required this.loadedData,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            final topCategories = getTopNCategories(loadedData['expenses'], 5);
            return Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 70),
                  child: FloatingActionButton.extended(
                    heroTag: 'add_expense_fab',
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExpenseDetails(
                            categories: loadedData['categories'],
                            monthId: loadedData['month']['id'],
                            topCategories: topCategories,
                          ),
                        ),
                      ).then((_) => onRefresh());
                    },
                    label: Text(AppLocalizations.of(context)!.addExpense),
                    icon: const Icon(Icons.arrow_upward_rounded),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 140.0),
                  child: FloatingActionButton.extended(
                    heroTag: 'add_income_fab',
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => IncomeDetails(
                            income: null,
                            monthId: loadedData['month']['id'],
                            preferredDate: DateTime.now(),
                          ))
                      ).then((_) => onRefresh());
                    },
                    label: Text(AppLocalizations.of(context)!.addIncome),
                    icon: const Icon(Icons.arrow_downward_rounded),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 210.0),
                  child: FloatingActionButton.extended(
                    heroTag: 'month_details_fab',
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MonthDetailsScreen(
                            month: loadedData['month'],
                          ),
                        ),
                      ).then((_) => onRefresh());
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
                      Navigator.pop(context);
                      var newStartDate = DateTime.parse(loadedData['month']['end_date']).add(const Duration(days: 1));
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
