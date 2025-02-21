import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../tools/formatters.dart';
import 'widgets/month_burndown_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SummaryScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const SummaryScreen({Key? key, required this.data}) : super(key: key);

  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {

  @override
  Widget build(BuildContext context) {
    var startDate = DateTime.parse(widget.data['month']['start_date']);
    var endDate = DateTime.parse(widget.data['month']['end_date']);
    var monthDates = startDate.year == endDate.year
        ? "${DateFormat("d.MM").format(startDate)}-${DateFormat("d.MM.yyyy").format(endDate)}"
        : "${DateFormat("d.MM.yyyy").format(startDate)}-${DateFormat("d.MM.yyyy").format(endDate)}";
    var groups = [];

    var incomes = widget.data['incomes'] as List<dynamic>;
    var salarySum = 0.0;
    var otherIncomesSum = 0.0;
    for (var income in incomes) {
      var value = income['value'];
      if (income['is_salary'] == true) {
        salarySum += value;
      } else {
        otherIncomesSum += value;
      }
    }
    var incomesSum = salarySum + otherIncomesSum;
    groups.add({
      "name": AppLocalizations.of(context)!.incomes,
      "fields": [
        {"name": AppLocalizations.of(context)!.salary, "value": salarySum, "type": "currency"},
        {"name": AppLocalizations.of(context)!.otherIncome, "value": otherIncomesSum, "type": "currency"},
        {"name": AppLocalizations.of(context)!.total, "value": incomesSum, "type": "currency"},
      ],
    });

    var expenses = widget.data['expenses'] as List<dynamic>;
    var monthlyExpensesSum = 0.0;
    var regularExpensesSum = 0.0;
    var dailyExpensesBeforeTodaySum = 0.0;
    var todayExpensesSum = 0.0;
    var today = DateTime.parse("${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}");
    for (var expense in expenses) {
      var value = expense['value'];
      if (expense['is_monthly'] == true) {
        monthlyExpensesSum += value;
      } else {
        regularExpensesSum += value;
        var expDate = DateTime.parse(expense['date']);
        if (expDate.isBefore(today)) {
          dailyExpensesBeforeTodaySum += value;
        }
        if (expDate.year == today.year &&
            expDate.month == today.month &&
            expDate.day == today.day) {
          todayExpensesSum += value;
        }
      }
    }
    var expensesSum = monthlyExpensesSum + regularExpensesSum;
    groups.add({
      "name": AppLocalizations.of(context)!.expenses,
      "fields": [
        {"name": AppLocalizations.of(context)!.dailyExpenses, "value": regularExpensesSum, "type": "currency"},
        {"name": AppLocalizations.of(context)!.recurrentExpenses, "value": monthlyExpensesSum, "type": "currency"},
        {"name": AppLocalizations.of(context)!.total, "value": expensesSum, "type": "currency"}
      ]
    });

    groups.add({
      "name": AppLocalizations.of(context)!.balance,
      "fields": [
        {"name": AppLocalizations.of(context)!.incomes, "value": incomesSum, "type": "currency"},
        {"name": AppLocalizations.of(context)!.expenses, "value": expensesSum, "type": "currency"},
        {"name": AppLocalizations.of(context)!.balance, "value": incomesSum - expensesSum, "type": "currency"}
      ]
    });

    if (DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate.add(const Duration(days: 1)))) {  // handle now in the last day of month
      var daysLeft = endDate.difference(DateTime.now()).inDays + 2;  // till the end of day

      var balanceBeforeToday = incomesSum - monthlyExpensesSum - dailyExpensesBeforeTodaySum;
      var maxDailyExpenses = balanceBeforeToday / daysLeft;

      groups.add({
        "name": AppLocalizations.of(context)!.currentMonth,
        "fields": [
          {"name": AppLocalizations.of(context)!.daysLeft, "value": daysLeft},
          balanceBeforeToday > 0
            ? {"name": AppLocalizations.of(context)!.maxDailyExpense, "value": maxDailyExpenses, "type": "currency"}
            : {"name": AppLocalizations.of(context)!.maxDailyExpense, "value": "—", "type": "text"},
          {"name": AppLocalizations.of(context)!.spentToday, "value": todayExpensesSum, "type": "currency"},
          {"name": AppLocalizations.of(context)!.spentTodayPercent, "value": (todayExpensesSum / maxDailyExpenses * 100).round(), "type": "percent"}
        ]
      });
    }

    return _buildSummary(groups, context, monthDates);
  }

  Widget _buildChartPlaceholder(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
      child: AspectRatio(
        aspectRatio: 2,
        child: SimpleBurndownChart(
          incomes: data['incomes'],
          expenses: data['expenses'],
          startDate: DateTime.parse(data['month']['start_date']),
          endDate: DateTime.parse(data['month']['end_date'])
        )
      ),
    );
  }

  Widget _buildMonthHeader(String dates) {
    return Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 16.0, vertical: 4.0),
        alignment: Alignment.centerLeft,
        child: Text(
          dates,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).primaryColorLight
                : Theme.of(context).primaryColor,
          ),
        )
    );
  }

  Widget _buildSummary(List<dynamic> groups, BuildContext context, String header) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index == 0) _buildMonthHeader(header),
            if (index == 0) _buildChartPlaceholder(widget.data),
            _buildGroupTitle(group['name'], context),
            ..._buildGroupFields(group['fields'])
          ],
        );
      },
    );
  }

  Widget _buildGroupTitle(String name, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 2.0),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).primaryColorLight
              : Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  List<Widget> _buildGroupFields(List<dynamic> fields) {
    return fields.map((field) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              field['name'],
              style: const TextStyle(fontSize: 16.0),
            ),
            _buildFieldValue(field),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildFieldValue(Map<String, dynamic> field) {
    if (!field.containsKey('type')) {
      return Text(
        Formatters.integerFormatter.format(field['value']),
        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
      );
    }

    switch (field['type']) {
      case 'currency':
        return Text(
          Formatters.currencyFormatter.format(field['value']),
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
        );
      case 'percent':
        return Text(
          "${Formatters.integerFormatter.format(field['value'])}%",
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
        );
      case 'text':
        return Text(
          field['value'],
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
        );
      default:
        return const SizedBox();
    }
  }
}
