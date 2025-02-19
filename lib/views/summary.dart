import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../tools/formatters.dart';

class SummaryScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const SummaryScreen({Key? key, required this.data}) : super(key: key);

  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  late Future<Map<String, dynamic>> _data;

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
        otherIncomesSum +=  value;
      }
    }
    var incomesSum = salarySum + otherIncomesSum;
    groups.add({
      "name": "Incomes",
      "fields": [
        {"name": "Salary", "value": salarySum, "type": "currency"},
        {"name": "Other income", "value": otherIncomesSum, "type": "currency"},
        {"name": "Total", "value": incomesSum, "type": "currency"},
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
        if (expDate.year == today.year && expDate.month == today.month && expDate.day == today.day) {
          todayExpensesSum += value;
        }
      }
    }
    var expensesSum = monthlyExpensesSum + regularExpensesSum;
    groups.add({
      "name": "Expenses",
      "fields": [
        {"name": "Daily expenses", "value": regularExpensesSum, "type": "currency"},
        {"name": "Recurring expenses", "value": monthlyExpensesSum, "type": "currency"},
        {"name": "Total", "value": expensesSum, "type": "currency"}
      ]
    });

    groups.add({
      "name": "Balance",
      "fields": [
        {"name": "Incomes", "value": incomesSum, "type": "currency"},
        {"name": "Expenses", "value": expensesSum, "type": "currency"},
        {"name": "Balance", "value": incomesSum - expensesSum, "type": "currency"}
      ]
    });

    if (DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate.add(const Duration(days: 1)))) {  // handle now in the last day of month
      var daysLeft = endDate.difference(DateTime.now()).inDays + 2;  // till the end of day

      var balanceBeforeToday = incomesSum - monthlyExpensesSum - dailyExpensesBeforeTodaySum;
      var maxDailyExpenses = balanceBeforeToday / daysLeft;

      groups.add({
        "name": "Month",
        "fields": [
          {"name": "Days left", "value": daysLeft},
          balanceBeforeToday > 0
            ? {"name": "Max. daily expense", "value": maxDailyExpenses, "type": "currency"}
            : {"name": "Max. daily expense", "value": "—", "type": "text"},
          {"name": "Spent today", "value": todayExpensesSum, "type": "currency"},
          {"name": "Spent today (percent)", "value": (todayExpensesSum / maxDailyExpenses * 100).round(), "type": "percent"}
        ]
      });
    }

    return Column(
      children: [
        _buildMonthHeader(monthDates),
        _buildChartPlaceholder(),
        Expanded(child: _buildSummaryList(groups, context)),
      ],
    );
  }

  Widget _buildChartPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(64.0),
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.grey.shade200
          : Colors.grey.shade900,
      child: Center(
        child: Text(
          "chart",
          style: TextStyle(
              fontSize: 24.0,
              color: Theme.of(context).scaffoldBackgroundColor,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMonthHeader(String dates) {
    return Container(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 16.0, vertical: 4.0),
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

  Widget _buildSummaryList(List<dynamic> groups, BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupTitle(group['name'], context),
            ..._buildGroupFields(group['fields']),
            if (index < groups.length - 1) const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildGroupTitle(String name, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
        padding: const EdgeInsets.symmetric(vertical: 2.0),
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
