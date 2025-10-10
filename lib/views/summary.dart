import 'package:flutter/material.dart';import 'package:intl/intl.dart';
import '../tools/formatters.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Summary {
  final Map<String, dynamic> data;

  late DateTime startDate;
  late DateTime endDate;
  late double salarySum;
  late double otherIncomesSum;
  late double incomesSum;
  late double monthlyExpensesSum;
  late double regularExpensesSum;
  late double dailyExpensesBeforeTodaySum;
  late double todayExpensesSum;
  late double expensesSum;
  late double balance;

  Summary({required this.data}) {
    _calculate();
  }

  void _calculate() {
    startDate = DateTime.parse(data['month']['start_date']);
    endDate = DateTime.parse(data['month']['end_date']);

    var incomes = data['incomes'] as List<dynamic>;
    salarySum = 0.0;
    otherIncomesSum = 0.0;
    for (var income in incomes) {
      var value = income['value'];
      if (income['is_salary'] == true) {
        salarySum += value;
      } else {
        otherIncomesSum += value;
      }
    }
    incomesSum = salarySum + otherIncomesSum;

    var expenses = data['expenses'] as List<dynamic>;
    monthlyExpensesSum = 0.0;
    regularExpensesSum = 0.0;
    dailyExpensesBeforeTodaySum = 0.0;
    todayExpensesSum = 0.0;
    var today = DateTime.parse(
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}");
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
    expensesSum = monthlyExpensesSum + regularExpensesSum;
    balance = incomesSum - expensesSum;
  }
}

class SummaryScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const SummaryScreen({Key? key, required this.data}) : super(key: key);

  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  @override
  Widget build(BuildContext context) {
    final summary = Summary(data: widget.data);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      children: [
        _buildIncomeCard(
            context,
            summary.salarySum,
            summary.otherIncomesSum,
            summary.incomesSum),
        const SizedBox(height: 16),
        _buildExpensesCard(
            context,
            summary.regularExpensesSum,
            summary.monthlyExpensesSum,
            summary.expensesSum),
        const SizedBox(height: 16),
        _buildBalanceCard(
            context,
            summary.balance),
        const SizedBox(height: 16),
        if (DateTime.now().isAfter(summary.startDate) &&
            DateTime.now().isBefore(summary.endDate.add(const Duration(days: 1))))
          _buildCurrentMonthCard(
              context,
              summary.startDate,
              summary.endDate,
              summary.incomesSum,
              summary.monthlyExpensesSum,
              summary.dailyExpensesBeforeTodaySum,
              summary.todayExpensesSum),
        const SizedBox(height: 70),
      ],
    );
  }

  Widget _buildIncomeCard(BuildContext context, double salarySum, double otherIncomesSum, double total) {
    String title = AppLocalizations.of(context)!.incomes;
    double amount = total;
    List<Widget> children = [];

    if (salarySum > 0 && otherIncomesSum == 0) {
      title = AppLocalizations.of(context)!.salary;
      amount = salarySum;
    } else if (salarySum == 0 && otherIncomesSum > 0) {
      title = AppLocalizations.of(context)!.otherIncome;
      amount = otherIncomesSum;
    } else if (salarySum > 0 && otherIncomesSum > 0) {
      children.add(_buildDetailRow(AppLocalizations.of(context)!.salary, salarySum));
      children.add(_buildDetailRow(AppLocalizations.of(context)!.otherIncome, otherIncomesSum));
    }

    return _buildInfoCard(
      context: context,
      icon: Icons.arrow_downward_rounded,
      title: title,
      amount: amount,
      isOutlined: true,
      children: children,
    );
  }

  Widget _buildExpensesCard(BuildContext context, double regularSum, double monthlySum, double total) {
    String title = AppLocalizations.of(context)!.expenses;
    double amount = total;
    List<Widget> children = [];

    if (regularSum > 0 && monthlySum == 0) {
      title = AppLocalizations.of(context)!.dailyExpenses;
      amount = regularSum;
    } else if (regularSum == 0 && monthlySum > 0) {
      title = AppLocalizations.of(context)!.recurrentExpenses;
      amount = monthlySum;
    } else if (regularSum > 0 && monthlySum > 0) {
      children.add(_buildDetailRow(AppLocalizations.of(context)!.dailyExpenses, regularSum));
      children.add(_buildDetailRow(AppLocalizations.of(context)!.recurrentExpenses, monthlySum));
    }

    return _buildInfoCard(
      context: context,
      icon: Icons.arrow_upward_rounded,
      title: title,
      amount: amount,
      isOutlined: true,
      children: children,
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: balance >= 0 ? colorScheme.primaryContainer : colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.balance.toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: balance >= 0 ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              Formatters.currencyFormatter.format(balance),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: balance >= 0 ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentMonthCard(BuildContext context, DateTime startDate, DateTime endDate, double incomesSum, double monthlyExpensesSum, double dailyExpensesBeforeTodaySum, double todayExpensesSum) {
    final l10n = AppLocalizations.of(context)!;
    var daysLeft = endDate.difference(DateTime.now()).inDays + 1;
    var balanceBeforeToday = incomesSum - monthlyExpensesSum - dailyExpensesBeforeTodaySum;
    var maxDailyExpenses = (daysLeft > 0) ? balanceBeforeToday / daysLeft : 0.0;
    var todayExpensesPercent = (maxDailyExpenses > 0) ? (todayExpensesSum / maxDailyExpenses * 100) : 0.0;
    String spentTodayValue = Formatters.currencyFormatter.format(todayExpensesSum);
    if (balanceBeforeToday > 0 && maxDailyExpenses > 0) {
      spentTodayValue += " (${todayExpensesPercent.round()}%)";
    }

    return _buildInfoCard(
      context: context,
      title: l10n.daysLeft,
      amount: daysLeft.toDouble(),
      isOutlined: true,
      isCurrency: false,
      isInteger: true,
      children: [
        if (balanceBeforeToday > 0)
          _buildDetailRow(l10n.maxDailyExpense, maxDailyExpenses),
        _buildDetailRow(l10n.spentToday, spentTodayValue, isCurrency: false),
      ],
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    IconData? icon,
    required String title,
    double? amount,
    List<Widget> children = const [],
    bool isOutlined = false,
    bool isCurrency = true,
    bool isInteger = false,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: isOutlined ? 0 : 1,
      shape: isOutlined
          ? RoundedRectangleBorder(
        side: BorderSide(color: colorScheme.outlineVariant),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      )
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  if (icon != null)
                    Icon(icon, color: colorScheme.primary),
                  if (icon != null)
                    const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  if (amount != null)
                    if (isCurrency)
                      Text(
                        Formatters.currencyFormatter.format(amount),
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    if (isInteger)
                      Text(
                        amount!.toInt().toString(),
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                ],
              ),
            ),
            if (children.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(indent: 16, endIndent: 16),
              ...children,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String name, dynamic value, {bool isCurrency = true}) {
    return ListTile(
      dense: true,
      title: Text(name),
      trailing: Text(
          isCurrency ? Formatters.currencyFormatter.format(value) : value.toString(),
          style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14
          ),
      ),
    );
  }
}
