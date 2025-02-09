import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

class ExpensesTableView extends StatelessWidget {
  final List<dynamic> expenses;
  final List<dynamic> categories;
  final Map<String, dynamic> month;

  const ExpensesTableView(
      {Key? key, required this.expenses, required this.categories, required this.month})
      : super(key: key);

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
    if (expenses.isEmpty || categories.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    final begin_date = month['start_date'];
    final end_date = month['end_date'];

    final Map<DateTime, double> dateSums = {};
    final Map<int, double> categorySums = {};
    final Map<int, Map<DateTime, double>> categoryDateSums = {};

    for (var expense in expenses) {
      var category = expense['category'];
      DateTime date = DateTime.parse(expense['date']);
      double value = (expense['value'] as num).toDouble();

      dateSums[date] = (dateSums[date] ?? 0.0) + value;
      categorySums[category] = (categorySums[category] ?? 0.0) + value;
      categoryDateSums[category] = categoryDateSums[category] ?? {};
      categoryDateSums[category]![date] =
          (categoryDateSums[category]![date] ?? 0.0) + value;
    }

    var begin_date_obj = DateTime.parse(begin_date);
    var end_date_obj = DateTime.parse(end_date).add(Duration(days: 1));

    var columns = [
      DataColumn2(
        label: Text(''),
        size: ColumnSize.L,
      )
    ];
    for (var date = begin_date_obj; date.isBefore(end_date_obj); date = date.add(const Duration(days: 1))) {
      final date_string = date.day.toString() + "." + date.month.toString().padLeft(2, '0');
      columns = columns + [
        DataColumn2(
          size: ColumnSize.S,
          numeric: true,
          label: Container(
            color: getBackgroundColor(context, date),
            child: Center(
              child: Text(date_string)
            ),
          ),
        )
      ];
    }

    List<DataRow> rows = [];
    for (var category in categories) {
      var cells = [
        DataCell(
          Text(
            category['name'],
            overflow: TextOverflow.ellipsis,
          ),
        )
      ];

      for (var date = begin_date_obj; date.isBefore(end_date_obj); date = date.add(const Duration(days: 1))) {
        var sumNumber = categoryDateSums[category['id']]?[date] ?? 0.0;
        cells = cells + [
          DataCell(
            Container(
              color: getBackgroundColor(context, date),
              child: Center(
                child: Text(
                  sumNumber != 0.0 ? sumNumber.toStringAsFixed(0) : "",
                  textAlign: TextAlign.center,
                )
              )
            ),
            onTap: () {
              // TODO
            },
          )
        ];
      }
      var row = DataRow(cells: cells);
      rows = rows + [row];
    }

    var minWidth = (end_date_obj.difference(begin_date_obj).inDays + 1) * 40 + 1000.0;

    return Padding(
      padding: const EdgeInsets.all(0),
      child: DataTable2(
        border: TableBorder(
          verticalInside: BorderSide(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey[100]!
                  : Colors.grey[800]!
          ),
          horizontalInside: BorderSide(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey[100]!
                  : Colors.grey[800]!
          ),
        ),

        columnSpacing: 0,
        horizontalMargin: 8,
        fixedLeftColumns: 1,
        fixedTopRows: 1,
        columns: columns,
        rows: rows,
        minWidth: minWidth,
      )
    );
  }
}