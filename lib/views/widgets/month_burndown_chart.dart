import 'package:community_charts_flutter/community_charts_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SimpleBurndownChart extends StatelessWidget {
  final List<dynamic> incomes;
  final List<dynamic> expenses;
  final DateTime startDate;
  final DateTime endDate;
  final bool animate = true;
  final simple = false;

  SimpleBurndownChart({required this.incomes, required this.expenses, required this.startDate, required this.endDate});

  @override
  Widget build(BuildContext context) {
    var seriesList = _createSeries(incomes, expenses, startDate, endDate);
    var primaryMeasureAxis = simple
      ? const NumericAxisSpec(
          showAxisLine: false,
          renderSpec: NoneRenderSpec(),
        )
      : NumericAxisSpec(
          tickProviderSpec: const BasicNumericTickProviderSpec(desiredTickCount: 5),
          tickFormatterSpec: BasicNumericTickFormatterSpec(
            (num? number) {
              return "${(number! / 1000.0).toStringAsFixed(0)}k";
            })
        );
    var domainAxis = const OrdinalAxisSpec(
          showAxisLine: true,
          renderSpec: NoneRenderSpec(),
        );

    return OrdinalComboChart(
      seriesList,
      primaryMeasureAxis: primaryMeasureAxis,
      domainAxis: domainAxis,
      animate: animate,
      defaultRenderer: new LineRendererConfig(),
      customSeriesRenderers: [
        new BarRendererConfig(
            customRendererId: 'customBar')
      ]);
  }


  static List<Series<BudgetBurndown, String>> _createSeries(List<dynamic> incomes, List<dynamic> expenses, DateTime startDate, DateTime endDate) {
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
    final idealDailyExpensesSum = (incomesSum - monthlyExpensesSum) / (endDate.difference(startDate).inDays + 2);
    var dailyExpensesData = [
      BudgetBurndown("start", 0),
    ];
    var monthlyExpensesData = [
      BudgetBurndown("start", 0),
    ];

    var startDateDecreased = startDate.subtract(const Duration(days: 1));
    var endDateIncreased = endDate.add(const Duration(days: 1));
    final DateFormat formatter = DateFormat('d.MM');
    var counter = 0;
    for (var date = startDateDecreased;
         date.isBefore(endDateIncreased);
         date = date.add(const Duration(days: 1)), counter++) {
      var yesterdaySum = burndownData[burndownData.length - 1].sum;
      var dateExpenses = dailyExpensesSums[date] ?? 0.0;
      var dateMonthlyExpenses = monthlyExpensesSums[date] ?? 0.0;
      var burndown = yesterdaySum - dateExpenses;
      var previousIdealBurndown = idealBurndownData[burndownData.length - 1].sum;
      final dateStr = formatter.format(date);
      burndownData.add(BudgetBurndown(dateStr, burndown));
      idealBurndownData.add(BudgetBurndown(dateStr, previousIdealBurndown - idealDailyExpensesSum));
      dailyExpensesData.add(BudgetBurndown(dateStr, dateExpenses));
      monthlyExpensesData.add(BudgetBurndown(dateStr, dateMonthlyExpenses));
    }

    return [
      Series<BudgetBurndown, String>(
        id: 'Daily',
        colorFn: (_, __) => MaterialPalette.indigo.makeShades(5)[3],
        domainFn: (BudgetBurndown burndown, _) => burndown.day,
        measureFn: (BudgetBurndown burndown, _) => burndown.sum,
        data: dailyExpensesData,
      )
        ..setAttribute(rendererIdKey, 'customBar'),
      Series<BudgetBurndown, String>(
          id: 'Monthly',
          colorFn: (_, __) => MaterialPalette.indigo.makeShades(5)[4],
          domainFn: (BudgetBurndown burndown, _) => burndown.day,
          measureFn: (BudgetBurndown burndown, _) => burndown.sum,
          data: monthlyExpensesData
      )
        ..setAttribute(rendererIdKey, 'customBar'),
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
}

class BudgetBurndown {
  final String day;
  final double sum;

  BudgetBurndown(this.day, this.sum);
}
