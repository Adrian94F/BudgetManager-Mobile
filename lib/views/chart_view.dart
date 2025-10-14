import 'package:flutter/material.dart';
import '../views/widgets/month_burndown_chart.dart';

class ChartViewScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ChartViewScreen({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime.parse(data['month']['start_date']);
    final endDate = DateTime.parse(data['month']['end_date']);
    final incomes = data['incomes'] as List<dynamic>;
    final expenses = data['expenses'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Burndown Chart'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SimpleBurndownChart(
            incomes: incomes,
            expenses: expenses,
            startDate: startDate,
            endDate: endDate,
          ),
        ),
      ),
    );
  }
}
