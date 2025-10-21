import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../tools/formatters.dart';
import 'package:budget_manager/l10n/app_localizations.dart';
import '../views/widgets/month_burndown_chart.dart';
import '../views/chart_view.dart';

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
        _buildBurndownChartCard(context),
        const SizedBox(height: 16),
        _buildBalanceCard(context, summary),
        const SizedBox(height: 16),
        _buildExpensesCard(
            context,
            summary.regularExpensesSum,
            summary.monthlyExpensesSum,
            summary.expensesSum),
        const SizedBox(height: 16),
        _buildIncomeCard(
            context,
            summary.salarySum,
            summary.otherIncomesSum,
            summary.incomesSum),
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

  Widget _buildBurndownChartCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final startDate = DateTime.parse(widget.data['month']['start_date']);
    final endDate = DateTime.parse(widget.data['month']['end_date']);
    final incomes = widget.data['incomes'] as List<dynamic>;
    final expenses = widget.data['expenses'] as List<dynamic>;

    return Container(
      height: 150,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChartViewScreen(data: widget.data),
            ),
          );
        },
        child: AbsorbPointer(
          child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: MonthBurndownChart(
                incomes: incomes,
                expenses: expenses,
                startDate: startDate,
                endDate: endDate,
                isSimplified: true
              ),
            ),
          ),
      )
    );
  }

  Widget _buildBalanceCard(BuildContext context, Summary summary) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final balance = summary.balance;
    final daysLeft = summary.endDate.difference(DateTime.now()).inDays + 1;
    final balanceBeforeToday = summary.incomesSum - summary.monthlyExpensesSum - summary.dailyExpensesBeforeTodaySum;
    final maxDailyExpenses = (daysLeft > 0) ? balanceBeforeToday / daysLeft : 0.0;
    final todayExpensesPercent = (maxDailyExpenses > 0) ? (summary.todayExpensesSum / maxDailyExpenses * 100) : 0.0;
    String spentTodayValue = Formatters.currencyFormatter.format(summary.todayExpensesSum);
    if (balanceBeforeToday > 0 && maxDailyExpenses > 0) {
      spentTodayValue += " (${todayExpensesPercent.round()}%)";
    }

    final children = <Widget>[];
    final isCurrent = DateTime.now().isAfter(summary.startDate) &&
        DateTime.now().isBefore(summary.endDate.add(const Duration(days: 1)));
    if (isCurrent) {
      if (balanceBeforeToday > 0) {
        children.add(_buildDetailRow(l10n.maxDailyExpense, maxDailyExpenses,
            valueColor: colorScheme.onPrimaryContainer));
      }
      children.add(_buildDetailRow(l10n.spentToday, spentTodayValue,
          isCurrency: false, valueColor: colorScheme.onPrimaryContainer));
      children.add(_buildDetailRow(l10n.daysLeft, daysLeft.toString(),
          isCurrency: false, valueColor: colorScheme.onPrimaryContainer));
    }

    return Card(
      elevation: 0,
      color: balance >= 0
          ? isCurrent
            ? colorScheme.primaryContainer
            : Theme.of(context).brightness == Brightness.light
              ? Colors.green.shade100
              : Colors.green.shade900
          : colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.balance.toUpperCase(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: balance >= 0
                        ? isCurrent
                          ? colorScheme.onPrimaryContainer
                          : Theme.of(context).brightness == Brightness.light
                            ? Colors.green.shade800
                            : Colors.green.shade100
                        : colorScheme.onErrorContainer,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    Formatters.currencyFormatter.format(balance),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: balance >= 0
                          ? isCurrent
                            ? colorScheme.onPrimaryContainer
                            : Theme.of(context).brightness == Brightness.light
                              ? Colors.green.shade800
                              : Colors.green.shade100
                          : colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            ),
            if (children.isNotEmpty)
              const Divider(indent: 16, endIndent: 16),
            ...children
          ],
        ),
      ),
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

  Widget _buildDetailRow(String name, dynamic value, {bool isCurrency = true, Color? valueColor}) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
      title: Text(name),
      trailing: Text(
        isCurrency ? Formatters.currencyFormatter.format(value) : value.toString(),
        style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          color: valueColor
        ),
      ),
    );
  }
}
