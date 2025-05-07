import 'package:community_charts_flutter/community_charts_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SimpleBurndownChart extends StatelessWidget {
  final List<dynamic> incomes;
  final List<dynamic> expenses;
  final DateTime startDate;
  final DateTime endDate;
  final bool animate = true;

  const SimpleBurndownChart({super.key, required this.incomes, required this.expenses, required this.startDate, required this.endDate});

  @override
  Widget build(BuildContext context) {
    var seriesList = _createSeries(context, incomes, expenses, startDate, endDate);
    var primaryMeasureAxis = NumericAxisSpec(
      tickProviderSpec: const BasicNumericTickProviderSpec(
        desiredMinTickCount: 6,
        desiredMaxTickCount: 7
      ),
      tickFormatterSpec: BasicNumericTickFormatterSpec(
        (num? number) {
          return number != 0
            ? "${(number! / 1000.0).toStringAsFixed(0)}k"
            : "0";
        }),
        renderSpec: GridlineRendererSpec(
          labelStyle: TextStyleSpec(
            color: Theme.of(context).brightness == Brightness.light
              ? MaterialPalette.gray.shade900
              : MaterialPalette.gray.shade300,
          ),
          lineStyle: LineStyleSpec(
            color: Theme.of(context).brightness == Brightness.light
                ? MaterialPalette.gray.shade200
                : MaterialPalette.gray.shade900,
          )
        )
    );
    var domainAxis = const OrdinalAxisSpec(
          showAxisLine: false,
          renderSpec: NoneRenderSpec(),
        );

    var widgetWidth = MediaQuery.of(context).orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.width * 3 / 5;
    var daysNumber = endDate.difference(startDate).inDays + 2;
    var segmentWidth = widgetWidth / daysNumber;

    return OrdinalComboChart(
      seriesList,
      primaryMeasureAxis: primaryMeasureAxis,
      domainAxis: domainAxis,
      animate: animate,
      defaultRenderer: LineRendererConfig(),
      customSeriesRenderers: [
        BarRendererConfig(
          stackedBarPaddingPx: 0,
          customRendererId: 'customStackedBar',
          groupingType: BarGroupingType.stacked,
        )
      ],
      behaviors: [
        RangeAnnotation(_getSegments(context, startDate, endDate, segmentWidth)),
      ]);
  }


  static List<Series<BudgetBurndown, String>> _createSeries(BuildContext context, List<dynamic> incomes, List<dynamic> expenses, DateTime startDate, DateTime endDate) {
    Map<DateTime, double> dailyExpensesSums = {};
    Map<DateTime, double> monthlyExpensesSums = {};
    double monthlyExpensesSum = 0.0;
    double incomesSum = 0.0;

    for (var expense in expenses) {
      var value = expense['value'];
      var date = DateTime.parse(expense['date']);
      if (expense['is_monthly'] == true) {
        if (monthlyExpensesSums.containsKey(date)) {
          monthlyExpensesSums[date] = monthlyExpensesSums[date]! + value;
        } else {
          monthlyExpensesSums[date] = value;
        }
        monthlyExpensesSum += value;
      } else {
        if (dailyExpensesSums.containsKey(date)) {
          dailyExpensesSums[date] = dailyExpensesSums[date]! + value;
        } else {
          dailyExpensesSums[date] = value;
        }
      }
    }

    for (var income in incomes) {
      var value = income['value'];
      incomesSum += value;
    }

    var burndownData = [
      BudgetBurndown("start", incomesSum - monthlyExpensesSum),
    ];
    var idealBurndownData = [
      BudgetBurndown("start", incomesSum - monthlyExpensesSum),
    ];
    final idealDailyExpensesSum = (incomesSum - monthlyExpensesSum) / (endDate.difference(startDate).inDays + 1);
    var dailyExpensesData = [
      BudgetBurndown("start", 0),
    ];
    var monthlyExpensesData = [
      BudgetBurndown("start", 0),
    ];

    var endDateIncreased = endDate.add(const Duration(days: 1));
    final DateFormat formatter = DateFormat('d.MM');
    for (var date = startDate;
         date.isBefore(endDateIncreased);
         date = date.add(const Duration(days: 1))) {
      date = DateTime(date.year, date.month, date.day);  // remove hours etc. to compare dates (on summertime change)
      var yesterdaySum = burndownData[burndownData.length - 1].sum;
      var dateExpenses = dailyExpensesSums[date] ?? 0.0;
      var dateMonthlyExpenses = monthlyExpensesSums[date] ?? 0.0;
      var burndown = yesterdaySum - dateExpenses;
      var previousIdealBurndown = idealBurndownData[burndownData.length - 1].sum;
      var idealBurndownValue = previousIdealBurndown - idealDailyExpensesSum;
      if (idealBurndownValue < 0) {
        idealBurndownValue = 0;
      }
      final dateStr = formatter.format(date);
      burndownData.add(BudgetBurndown(dateStr, burndown));
      idealBurndownData.add(BudgetBurndown(dateStr, idealBurndownValue));
      dailyExpensesData.add(BudgetBurndown(dateStr, dateExpenses));
      monthlyExpensesData.add(BudgetBurndown(dateStr, dateMonthlyExpenses));
    }

    return [
      Series<BudgetBurndown, String>(
        id: 'Monthly',
        colorFn: (_, __) => Theme.of(context).brightness == Brightness.light
            ? MaterialPalette.indigo.makeShades(5)[4]
            : MaterialPalette.indigo.makeShades(5)[4].darker.darker.darker.darker,
        domainFn: (BudgetBurndown burndown, _) => burndown.day,
        measureFn: (BudgetBurndown burndown, _) => burndown.sum,
        data: monthlyExpensesData
      )
        ..setAttribute(rendererIdKey, 'customStackedBar'),
      Series<BudgetBurndown, String>(
        id: 'Daily',
        colorFn: (_, __) => Theme.of(context).brightness == Brightness.light
          ? MaterialPalette.indigo.makeShades(5)[3]
          : MaterialPalette.indigo.makeShades(5)[3].darker.darker,
        domainFn: (BudgetBurndown burndown, _) => burndown.day,
        measureFn: (BudgetBurndown burndown, _) => burndown.sum,
        data: dailyExpensesData,
      )
        ..setAttribute(rendererIdKey, 'customStackedBar'),
      Series<BudgetBurndown, String>(
        id: 'Ideal burndown',
        colorFn: (_, __) => MaterialPalette.indigo.makeShades(5)[2],
        strokeWidthPxFn: (_, __) => 0.5,
        dashPatternFn: (_, __) => [2, 2],
        domainFn: (BudgetBurndown burndown, _) => burndown.day,
        measureFn: (BudgetBurndown burndown, _) => burndown.sum,
        data: idealBurndownData,
      ),
      Series<BudgetBurndown, String>(
        id: 'Burndown',
        colorFn: (_, __) => MaterialPalette.indigo.shadeDefault,
        domainFn: (BudgetBurndown burndown, _) => burndown.day,
        measureFn: (BudgetBurndown burndown, _) => burndown.sum,
        data: burndownData,
      ),
    ];
  }

  static List<LineAnnotationSegment<Object>> _getSegments(BuildContext context, DateTime startDate, DateTime endDate, double segmentWidth)
  {
    var list = <LineAnnotationSegment<Object>>[];

    var date = startDate;
    while (date.difference(endDate).inDays <= 0) {
      if (date.weekday == 6 || date.weekday == 7) {
        var dayText = DateFormat("d.MM").format(date);
        var weekendSegment = LineAnnotationSegment(
            dayText,
            RangeAnnotationAxisType.domain,
            strokeWidthPx: segmentWidth,
            color: Theme.of(context).brightness == Brightness.light
                ? MaterialPalette.gray.shade100
                : MaterialPalette.gray.shade900.darker
        );
        list.add(weekendSegment);
      }
      date = date.add(const Duration(days: 1));
    }

    if (DateTime.now().isBefore(endDate.add(const Duration(days: 1))) && DateTime.now().isAfter(startDate)) {
      var todayText = DateFormat("d.MM").format(DateTime.now());
      var todaySegment = LineAnnotationSegment(
          todayText,
          RangeAnnotationAxisType.domain,
          strokeWidthPx: segmentWidth,
          color: Theme
              .of(context)
              .brightness == Brightness.light
              ? MaterialPalette.indigo.makeShades(10)[9]
              : MaterialPalette.indigo.shadeDefault.darker.darker.darker.darker
              .darker
      );
      list.add(todaySegment);
    }

    return list;
  }

}

class BudgetBurndown {
  final String day;
  final double sum;

  BudgetBurndown(this.day, this.sum);
}
