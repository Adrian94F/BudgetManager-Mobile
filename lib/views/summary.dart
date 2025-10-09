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

    // Lista, która będzie przechowywać wszystkie elementy widoku (nagłówki i pola)
    List<Widget> listItems = [];

    // --- OBLICZENIA ---
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

    // --- BUDOWANIE WIDOKU ---
    // Nagłówek miesiąca i wykres
    listItems.add(_buildMonthHeader(monthDates));
    listItems.add(_buildChartPlaceholder(widget.data));

    // Sekcja PRZYCHODY
    if (salarySum > 0 && otherIncomesSum == 0) {
      // Tylko pensja
      listItems.add(_buildGroupTitle(AppLocalizations.of(context)!.salary, context, amount: salarySum));
    } else if (salarySum == 0 && otherIncomesSum > 0) {
      // Tylko inne przychody
      listItems.add(_buildGroupTitle(AppLocalizations.of(context)!.otherIncome, context, amount: otherIncomesSum));
    } else {
      // Oba rodzaje przychodów lub żadne
      listItems.add(_buildGroupTitle(AppLocalizations.of(context)!.incomes, context, amount: incomesSum));
      if (salarySum > 0 && otherIncomesSum > 0) {
        listItems.add(_buildFieldRow(AppLocalizations.of(context)!.salary, salarySum, type: 'currency'));
        listItems.add(_buildFieldRow(AppLocalizations.of(context)!.otherIncome, otherIncomesSum, type: 'currency'));
      }
    }


    // Sekcja WYDATKI
    if (regularExpensesSum > 0 && monthlyExpensesSum == 0) {
      // Tylko wydatki codzienne
      listItems.add(_buildGroupTitle(AppLocalizations.of(context)!.dailyExpenses, context, amount: regularExpensesSum));
    } else if (regularExpensesSum == 0 && monthlyExpensesSum > 0) {
      // Tylko wydatki comiesięczne
      listItems.add(_buildGroupTitle(AppLocalizations.of(context)!.recurrentExpenses, context, amount: monthlyExpensesSum));
    } else {
      // Oba rodzaje wydatków lub żadne
      listItems.add(_buildGroupTitle(AppLocalizations.of(context)!.expenses, context, amount: expensesSum));
      if (regularExpensesSum > 0 && monthlyExpensesSum > 0) {
        listItems.add(_buildFieldRow(AppLocalizations.of(context)!.dailyExpenses, regularExpensesSum, type: 'currency'));
        listItems.add(_buildFieldRow(AppLocalizations.of(context)!.recurrentExpenses, monthlyExpensesSum, type: 'currency'));
      }
    }

    // Sekcja BILANS
    listItems.add(_buildGroupTitle(AppLocalizations.of(context)!.balance, context, amount: incomesSum - expensesSum));


    // Sekcja AKTUALNY MIESIĄC (jeśli dotyczy)
    if (DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate.add(const Duration(days: 1)))) {
      listItems.add(_buildGroupTitle(AppLocalizations.of(context)!.currentMonth, context));

      var daysLeft = endDate.difference(DateTime.now()).inDays + 1;
      var balanceBeforeToday = incomesSum - monthlyExpensesSum - dailyExpensesBeforeTodaySum;

      var maxDailyExpenses = (daysLeft > 0) ? balanceBeforeToday / daysLeft : 0.0;
      var todayExpensesPercent = (maxDailyExpenses > 0) ? (todayExpensesSum / maxDailyExpenses * 100) : 0.0;

      listItems.add(_buildFieldRow(AppLocalizations.of(context)!.daysLeft, daysLeft));

      if (balanceBeforeToday > 0) {
        listItems.add(_buildFieldRow(AppLocalizations.of(context)!.maxDailyExpense, maxDailyExpenses, type: 'currency'));
      }

      String spentTodayValue = Formatters.currencyFormatter.format(todayExpensesSum);
      if (balanceBeforeToday > 0 && maxDailyExpenses > 0) {
        spentTodayValue += " (${todayExpensesPercent.round()}%)";
      }
      listItems.add(_buildFieldRow(AppLocalizations.of(context)!.spentToday, spentTodayValue, type: 'text'));
    }

    return _buildNewSummary(listItems);
  }

  // Nowa metoda budująca cały widok
  Widget _buildNewSummary(List<Widget> items) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return items[index];
      },
    );
  }

  // Pomocnicza metoda do tworzenia wiersza z polem
  Widget _buildFieldRow(String name, dynamic value, {String type = 'integer', bool isTotal = false}) {
    Widget valueWidget;
    switch (type) {
      case 'currency':
        valueWidget = Text(
          Formatters.currencyFormatter.format(value),
          style: TextStyle(fontSize: 16.0, fontWeight: isTotal ? FontWeight.bold : FontWeight.w500),
        );
        break;
      case 'text':
        valueWidget = Text(
          value.toString(),
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
        );
        break;
      default:
        valueWidget = Text(
          Formatters.integerFormatter.format(value),
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
        );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(fontSize: 16.0, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal),
          ),
          valueWidget,
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
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

  Widget _buildGroupTitle(String name, BuildContext context, {double? amount}) {
    final titleStyle = TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
      letterSpacing: 0.5,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 22.0, 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name.toUpperCase(), style: titleStyle),
          if (amount != null)
            Text(Formatters.currencyFormatter.format(amount), style: titleStyle),
        ],
      ),
    );
  }
}
