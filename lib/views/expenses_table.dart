import 'package:budget_manager/views/widgets/custom_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
      return CellData(
        text: c['name'].toString(),
        categoryId: c['id'],
        date: null,
      );
    }).toList();

    // Create the fixed row headers (Dates) with CellData
    final List<CellData> _fixedRowCells = List.generate(
      endDate.difference(beginDate).inDays,
          (i) {
        final date = beginDate.add(Duration(days: i));
        return CellData(
          text: DateFormat('d.MM').format(date),
          categoryId: null,
          date: date,
        );
      },
    );

    return CustomDataTable<CellData>(
      rowsCells: _rowsCells,
      fixedColCells: _fixedColCells,
      fixedRowCells: _fixedRowCells,
      fixedColWidth: 120,
      cellWidth: 60,
      cellHeight: 30,
      cellMargin: 0,
      cellSpacing: 0,
      cellBuilder: (data) {
        final category = data.categoryId;
        final date = data.date;

        if (category == null && date == null) {
          return Container();
        }

        return ExpensesTableItemButton(
          alignment: date == null ? Alignment.centerLeft : Alignment.center,
          child: Text(
              data.text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.normal
            ),
          ),
          onPressed: () => {
            _showFilteredExpenses(categoryId: category, date: date),
          }
        );
      },
      fixedCornerCell: CellData(text: ''),
    );
  }
}

class CellData {
  late String text;
  late DateTime? date;
  late int? categoryId;

  CellData({required this.text, this.date, this.categoryId});
}

class ScrollCoords {
  late double? x;
  late double? y;
  ScrollCoords({this.x, this.y});
}
