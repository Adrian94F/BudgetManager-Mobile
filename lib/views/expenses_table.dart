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

  const ExpensesTableView({
    Key? key,
    required this.expenses,
    required this.categories,
    required this.month,
    required this.refreshParent,
    required this.openFilteredListCallback,
    required this.saveTableCoords,
    required this.scrollCoords,
  }) : super(key: key);

  @override
  _ExpensesTableViewState createState() => _ExpensesTableViewState();
}

class _ExpensesTableViewState extends State<ExpensesTableView> {
  final TableViewController _tableViewController = TableViewController();
  final _columnWidth = 45.0;


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
    final scrollOffset = todayColumnIndex * _columnWidth;

    _scrollToXY(ScrollCoords(x: scrollOffset));
  }

  void _scrollToXY(ScrollCoords coords) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    });
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
    const dayAcronyms = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return dayAcronyms[date.weekday - 1];
  }



  @override
  Widget build(BuildContext context) {
    if (widget.expenses.isEmpty || widget.categories.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    final beginDate = DateTime.parse(widget.month['start_date']);
    final endDate = DateTime.parse(widget.month['end_date']).add(const Duration(days: 1));

    final Map<DateTime, double> dateSums = {};
    final Map<int, double> categorySums = {};
    final Map<int, Map<DateTime, double>> categoryDateSums = {};

    for (var expense in widget.expenses) {
      var category = expense['category'];
      DateTime date = DateTime.parse(expense['date']);
      double value = (expense['value'] as num).toDouble();

      dateSums[date] = (dateSums[date] ?? 0.0) + value;
      categorySums[category] = (categorySums[category] ?? 0.0) + value;
      categoryDateSums[category] = categoryDateSums[category] ?? {};
      categoryDateSums[category]![date] = (categoryDateSums[category]![date] ?? 0.0) + value;
    }

    // Create the main data grid with CellData objects
    final List<List<CellData>> _rowsCells = widget.categories.map((category) {
      final int categoryId = category['id'];
      return List.generate(endDate.difference(beginDate).inDays, (dayIndex) {
        final date = beginDate.add(Duration(days: dayIndex));
        final sum = categoryDateSums[categoryId]?[date] ?? 0.0;
        return CellData(
          text: sum != 0.0 ? sum.round().toString() : '',
          categoryId: categoryId,
          date: date,
        );
      });
    }).toList();

    // Create the fixed column headers (Category names) with CellData
    final List<CellData> _fixedColCells = widget.categories.map((c) {
      final categorySum = categorySums[c['id']] ?? 0.0;
      return CellData(
        text: c['name'].toString(),
        secondaryText: categorySum > 0 ? categorySum.round().toString() : '',
        categoryId: c['id'],
        date: null,
      );
    }).toList();

    // Create the fixed row headers (Dates with day acronyms) with CellData
    final List<CellData> _fixedRowCells = List.generate(
      endDate.difference(beginDate).inDays,
          (i) {
        final date = beginDate.add(Duration(days: i));
        final dayAcronym = _getDayAcronym(date);
        final dateNum = date.day.toString();
        return CellData(
          text: dateNum,
          secondaryText: dayAcronym,
          categoryId: null,
          date: date,
        );
      },
    );

    return CustomDataTable<CellData>(
      rowsCells: _rowsCells,
      fixedColCells: _fixedColCells,
      fixedRowCells: _fixedRowCells,
      fixedColWidth: 140,
      cellWidth: 56,
      cellHeight: 56,
      cellMargin: 2,
      cellSpacing: 2,
      cellBuilder: (data) {
        final category = data.categoryId;
        final date = data.date;
        final colorScheme = Theme.of(context).colorScheme;

        if (category == null && date == null) {
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                right: BorderSide(color: colorScheme.outlineVariant, width: 1),
                bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
              ),
            ),
          );
        }

        final isHeader = category == null || date == null;
        final isColumnHeader = date == null;
        final isRowHeader = category == null;

        if (isRowHeader && date != null) {
          final now = DateTime.now();
          final isToday = date.isAtSameMomentAs(DateTime(now.year, now.month, now.day));
          final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

          return Container(
            decoration: BoxDecoration(
              color: isToday
                ? colorScheme.primaryContainer
                : colorScheme.surface,
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.secondaryText ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isWeekend ? FontWeight.w600 : FontWeight.w500,
                    color: isToday
                      ? colorScheme.onPrimaryContainer
                      : (isWeekend ? colorScheme.primary : colorScheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isToday ? colorScheme.primary : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      data.text,
                      style: TextStyle(
                        fontSize: 13,
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
          );
        }

        if (isColumnHeader) {
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                right: BorderSide(color: colorScheme.outlineVariant, width: 1),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.text,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (data.secondaryText != null && data.secondaryText!.isNotEmpty)
                  Text(
                    data.secondaryText!,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          );
        }

        final bgColor = getCellBackgroundColor(context, date!);
        final hasExpense = data.text.isNotEmpty;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showFilteredExpenses(categoryId: category, date: date),
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: hasExpense
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        data.text,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    )
                  : null,
              ),
            ),
          ),
        );
      },
      fixedCornerCell: CellData(text: ''),
    );
  }
}

class CellData {
  late String text;
  late String? secondaryText;
  late DateTime? date;
  late int? categoryId;

  CellData({required this.text, this.secondaryText, this.date, this.categoryId});
}

class ScrollCoords {
  late double? x;
  late double? y;
  ScrollCoords({this.x, this.y});
}
