import 'package:budget_manager/views/widgets/custom_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_table_view/material_table_view.dart';

import 'expenses_list.dart';
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
    final coordX = _tableViewController.horizontalScrollController.offset;
    final coordY = _tableViewController.verticalScrollController.offset;
    widget.saveTableCoords(ScrollCoords(x: coordX, y: coordY));
    widget.openFilteredListCallback(filter);
  }

  Color getBackgroundColor(BuildContext context, DateTime date) {
    var now = DateTime.now();
    var isToday = date.isAtSameMomentAs(DateTime(now.year, now.month, now.day));
    var isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    var bgColor = isToday
      ? (Theme.of(context).brightness == Brightness.light
        ? Colors.indigo[100]!
        : Colors.grey[800]!)
      : (isWeekend
        ? Theme.of(context).brightness == Brightness.light
          ? Colors.indigo[50]!
          : Colors.grey[900]!
        : Colors.transparent);
    return bgColor;
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

    final _rowsCells = widget.categories.map((category) {
      final categoryId = category['id'];
      return List.generate(endDate.difference(beginDate).inDays, (dayIndex) {
        final date = beginDate.add(Duration(days: dayIndex));
        final sum = categoryDateSums[categoryId]?[date] ?? 0.0;
        return sum != 0.0 ? sum.round() : 0;
      });
    }).toList();
    final _fixedColCells = widget.categories.map((c) => c['name'].toString()).toList();
    final _fixedRowCells = List.generate(
        endDate.difference(beginDate).inDays,
            (i) => DateFormat('d.MM').format(beginDate.add(Duration(days: i))));
    return CustomDataTable(
      rowsCells: _rowsCells,
      fixedColCells: _fixedColCells,
      fixedRowCells: _fixedRowCells,
      fixedColWidth: 100,
      cellWidth: 50,
      cellHeight: 30,
      cellBuilder: (data) {
        return Text('$data');
      },
      fixedCornerCell: null,
    );

    List<TableColumn> columns = [
      const TableColumn(width: 150.0, freezePriority: 100),
    ];
    for (var date = beginDate; date.isBefore(endDate); date = date.add(const Duration(days: 1))) {
      columns.add(TableColumn(width: _columnWidth));
    }

    return Column(
      children: [
        Expanded(
          child: TableView.builder(
            controller: _tableViewController,
            columns: columns,
            rowCount: widget.categories.length,
            rowHeight: 30,
            style: const TableViewStyle(
              dividers: TableViewDividersStyle(
                vertical: TableViewVerticalDividersStyle(
                  leading: TableViewVerticalDividerStyle(wiggleCount: 0),
                  trailing: TableViewVerticalDividerStyle(wiggleCount: 0),
                ),
              ),
            ),
            headerBuilder: (context, contentBuilder) {
              return contentBuilder(
                context,
                (context, column) {
                  if (column == 0) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: Text(
                          AppLocalizations.of(context)!.categories,
                        style: TextStyle(fontStyle: FontStyle.italic)
                      ),
                    );
                  } else {
                    DateTime date = beginDate.add(Duration(days: column - 1));
                    DateFormat format = DateFormat('d.MM');
                    return ExpensesTableItemButton(
                      onPressed: () => _showFilteredExpenses(date: date),
                      child: Text(format.format(date)),
                    );
                  }
                },
              );
            },
            rowBuilder: (context, row, contentBuilder) {
              var category = widget.categories[row];
              return contentBuilder(
                context,
                (context, column) {
                  if (column == 0) {
                    return ExpensesTableItemButton(
                      onPressed: () => _showFilteredExpenses(categoryId: category['id']),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        child: Text(
                          category['name'],
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal
                          ),
                        ),
                      ),
                    );
                  } else {
                    DateTime date = beginDate.add(Duration(days: column - 1));
                    double sum = categoryDateSums[category['id']]?[date] ?? 0.0;
                    return Container(
                      color: getBackgroundColor(context, date),
                      alignment: Alignment.center,
                      child: ExpensesTableItemButton(
                        onPressed: () => _showFilteredExpenses(categoryId: category['id'], date: date),
                        child: Text(sum != 0.0 ? sum.toStringAsFixed(0) : ""),
                      )
                    );
                  }
                },
              );
            },
            footerBuilder: (context, contentBuilder) {
              return contentBuilder(
                context,
                (context, column) {
                  if (column == 0) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: Text(
                        AppLocalizations.of(context)!.sums,
                        style: const TextStyle(fontStyle: FontStyle.italic)
                      ),
                    );
                  } else {
                    DateTime date = beginDate.add(Duration(days: column - 1));
                    double sum = dateSums[date] ?? 0.0;
                    return ExpensesTableItemButton(
                      onPressed: () => _showFilteredExpenses(date: date),
                      child: Text(
                        sum.toStringAsFixed(0),
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.normal
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class ScrollCoords {
  late double? x;
  late double? y;
  ScrollCoords({this.x, this.y});
}
