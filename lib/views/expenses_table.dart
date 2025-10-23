import 'package:budget_manager/views/widgets/custom_data_table.dart';
import 'package:flutter/material.dart';
import 'package:budget_manager/l10n/app_localizations.dart';
import 'package:material_table_view/material_table_view.dart';

import 'expenses_list.dart';
import 'filtered_expenses_list.dart';
import 'widgets/expenses_table_item_button.dart';

class ExpensesTableView extends StatefulWidget {
  final List<dynamic> expenses;
  final List<dynamic> categories;
  final Map<String, dynamic> month;
  final Future<void> Function() refreshParent;
  final void Function(ExpensesFilter filter) openFilteredListCallback;
  final void Function(ScrollCoords coords) saveTableCoords;
  final ScrollCoords? scrollCoords;

  ExpensesTableView({
    Key? key,
    required this.expenses,
    required this.categories,
    required this.month,
    required this.refreshParent,
    required this.openFilteredListCallback,
    required this.saveTableCoords,
    required this.scrollCoords,
  }) : super(key: key) {
    beginDate = DateTime.parse(month['start_date']);
    endDate = endDate = DateTime.parse(month['end_date']).add(const Duration(days: 1));
  }

  late Map<DateTime, double> dateSums = {};
  late Map<int, double> categorySums = {};
  late Map<int, Map<DateTime, double>> categoryDateSums = {};
  late DateTime beginDate;
  late DateTime endDate;

  @override
  _ExpensesTableViewState createState() => _ExpensesTableViewState();
}

class _ExpensesTableViewState extends State<ExpensesTableView> {
  final TableViewController _tableViewController = TableViewController();
  // final _columnWidth = 45.0;

  @override
  void initState() {
    super.initState();
    if (widget.scrollCoords != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToXY(widget.scrollCoords!)
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToToday());
    }
  }

  void _scrollToToday() {
    DateTime today = DateTime.now();
    DateTime beginDate = DateTime.parse(widget.month['start_date']);
    DateTime endDate = DateTime.parse(widget.month['end_date']).add(const Duration(days: 1));

    if (today.isBefore(beginDate) || today.isAfter(endDate)) {
      return;
    }

    final screenWidth = MediaQuery.of(context).size.width.toInt();
    final columnsOffset = ((screenWidth - 150) / 45 * 0.6).floor();
    final todayColumnIndex = today.difference(beginDate).inDays - columnsOffset;
    // final scrollOffset = todayColumnIndex * _columnWidth;
    // _scrollToXY(ScrollCoords(x: scrollOffset));
  }

  void _scrollToXY(ScrollCoords coords) {
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      if (coords.x != null) {
        _tableViewController.horizontalScrollController.animateTo(
          coords.x!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      if (coords.y != null) {
      _tableViewController.verticalScrollController.animateTo(
        coords.y!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      }
    });*/
  }

  void _showFilteredExpenses({int? categoryId, DateTime? date}) {
    final filter = ExpensesFilter(
      date: date,
      category: categoryId,
    );
    print("Showing filtered expenses");
    // final coordX = _tableViewController.horizontalScrollController.offset;
    // final coordY = _tableViewController.verticalScrollController.offset;
    // widget.saveTableCoords(ScrollCoords(x: coordX, y: coordY));

    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilteredExpensesList(
          expenses: widget.expenses,
          categories: widget.categories,
          filter: filter,
          monthId: widget.month['id'],
          refreshParent: widget.refreshParent,
        ),
      ),
    );*/

    widget.openFilteredListCallback(filter);
  }

  Color getCellBackgroundColor(BuildContext context, DateTime date) {
    var now = DateTime.now();
    var isToday = date.isAtSameMomentAs(DateTime(now.year, now.month, now.day));
    var isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    final colorScheme = Theme.of(context).colorScheme;

    if (isToday) {
      return colorScheme.primaryContainer.withOpacity(0.3);
    } else if (isWeekend) {
      return colorScheme.surfaceVariant.withOpacity(0.3);
    }
    return Colors.transparent;
  }

  String _getDayAcronym(DateTime date) {
    final dayAcronyms = [
      AppLocalizations.of(context)!.shortMonday,
      AppLocalizations.of(context)!.shortTuesday,
      AppLocalizations.of(context)!.shortWednesday,
      AppLocalizations.of(context)!.shortThursday,
      AppLocalizations.of(context)!.shortFriday,
      AppLocalizations.of(context)!.shortSaturday,
      AppLocalizations.of(context)!.shortSunday
    ];
    return dayAcronyms[date.weekday - 1];
  }

  Widget _cellBuilder(CellData? data) {
    if (data == null) {
      return Container();
    }

    final category = data.categoryId;
    final date = data.date;
    final colorScheme = Theme.of(context).colorScheme;

    final isColumnHeader = date == null;
    final isRowHeader = category == null;

    // Header row with dates
    if (isRowHeader && date != null && data.isSum != true) {
      final now = DateTime.now();
      final isToday = date.isAtSameMomentAs(DateTime(now.year, now.month, now.day));
      final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showFilteredExpenses(date: date),
          child: Container(
            decoration: BoxDecoration(
              color: isToday
                  ? colorScheme.primaryContainer
                  : colorScheme.surface,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.secondaryText ?? '',
                  overflow: TextOverflow.clip,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isWeekend ? FontWeight.w600 : FontWeight.w500,
                    color: isToday
                        ? colorScheme.onPrimaryContainer
                        : (isWeekend ? colorScheme.primary : colorScheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isToday ? colorScheme.primary : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      data.text,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                        color: isToday
                            ? colorScheme.onPrimary
                            : (isWeekend ? colorScheme.primary : colorScheme.onSurface),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Categories column
    if (isColumnHeader && data.isSum != true) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showFilteredExpenses(categoryId: category),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.text,
                  overflow: TextOverflow.clip,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Category or date sum cell
    if (data.isSum == true) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:() {
            if (category != null) {
              _showFilteredExpenses(categoryId: category);
            } else if (date != null) {
              _showFilteredExpenses(date: date);
            }
          },
          child: Container(
            // decoration: BoxDecoration(
            //   color: colorScheme.surfaceVariant.withOpacity(0.3),
            // ),
            child: Center(
              child: data.text.isNotEmpty
                  ? Text(
                    data.text,
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                  : null,
            ),
          ),
        ),
      );
    }

    final bgColor = getCellBackgroundColor(context, date!);
    final hasExpense = data.text.isNotEmpty;

    // category + date sum cell
    return Material(
      color: bgColor,
      child: InkWell(
        onTap: () => _showFilteredExpenses(categoryId: category, date: date),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Center(
            child: hasExpense
                ? Text(
                    data.text,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  String formatNumber(double number) {
    return number != 0.0
        ? number < 1000
          ? number.round().toString()
          : "${(number.round() / 1000.0).toStringAsFixed(0)}k"
        : '';
  }

  void calculateSums() {
    for (var expense in widget.expenses) {
      var category = expense['category'];
      DateTime date = DateTime.parse(expense['date']);
      double value = (expense['value'] as num).toDouble();

      widget.dateSums[date] = (widget.dateSums[date] ?? 0.0) + value;
      widget.categorySums[category] = (widget.categorySums[category] ?? 0.0) + value;
      widget.categoryDateSums[category] = widget.categoryDateSums[category] ?? {};
      widget.categoryDateSums[category]![date] = (widget.categoryDateSums[category]![date] ?? 0.0) + value;
    }
  }

  List<List<CellData>> createRowsCells() {
    // Create the main data grid with CellData objects
    return widget.categories.map((category) {
      final int categoryId = category['id'];
      return List.generate(widget.endDate.difference(widget.beginDate).inDays, (dayIndex) {
        var date = DateUtils.dateOnly(widget.beginDate.add(Duration(days: dayIndex, hours: 1))); // Add 1 hour for daytime change
        final sum = widget.categoryDateSums[categoryId]?[date] ?? 0.0;
        return CellData(
          text: formatNumber(sum),
          categoryId: categoryId,
          date: date,
        );
      });
    }).toList();
  }

  List<CellData> createFixedColCells() {
    // Create the fixed column headers (Category names) with CellData
    return widget.categories.map((c) {
      return CellData(
        text: c['name'].toString(),
        secondaryText: null,
        categoryId: c['id'],
        date: null,
      );
    }).toList();
  }

  List<CellData> createFixedColCellsSums() {
    // Create sum column for categories
    return widget.categories.map((c) {
      final categorySum = widget.categorySums[c['id']] ?? 0.0;
      return CellData(
        text: formatNumber(categorySum),
        categoryId: c['id'],
        date: null,
        isSum: true,
        sum: categorySum,
      );
    }).toList();
  }

  List<CellData> createFixedRowCells() {
    // Create the fixed row headers (Dates with day acronyms) with CellData
    return List.generate(
      widget.endDate.difference(widget.beginDate).inDays,
          (i) {
        final date = widget.beginDate.add(Duration(days: i));
        final dayAcronym = _getDayAcronym(date);
        final dateNum = date.day.toString();
        final dateSum = widget.dateSums[date] ?? 0.0;
        return CellData(
          text: dateNum,
          secondaryText: dayAcronym,
          categoryId: null,
          date: date,
        );
      },
    );
  }

  List<CellData> createFixedRowCellsSums() {
    // Create fixed bottom row with date sums
    return List.generate(widget.endDate.difference(widget.beginDate).inDays, (dayIndex) {
      final date = widget.beginDate.add(Duration(days: dayIndex));
      final sum = widget.dateSums[date] ?? 0.0;
      return CellData(
        text: formatNumber(sum),
        date: date,
        isSum: true,
        sum: sum,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.expenses.isEmpty || widget.categories.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    calculateSums();
    return CustomDataTable<CellData>(
      rowsCells: createRowsCells(),
      fixedColCells: createFixedColCells(),
      fixedRightColCells: createFixedColCellsSums(),
      fixedRowCells: createFixedColCells(),
      fixedBottomRowCells: createFixedRowCellsSums(),
      cellBuilder: _cellBuilder,
    );
  }
}

class CellData {
  late String text;
  late String? secondaryText;
  late DateTime? date;
  late int? categoryId;
  late bool? isSum;
  late double? sum;

  CellData({
    required this.text,
    this.secondaryText,
    this.date,
    this.categoryId,
    this.isSum,
    this.sum,
  });
}

class ScrollCoords {
  late double? x;
  late double? y;
  ScrollCoords({this.x, this.y});
}
