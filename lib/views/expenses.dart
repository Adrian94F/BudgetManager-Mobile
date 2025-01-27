import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class ExpensesScreen extends StatefulWidget {
  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _authService = AuthService();
  late Future<Map<String, dynamic>> _data;

  @override
  void initState() {
    super.initState();
    _data = _authService.get("get-expenses");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          final expenses = data['expenses'] as List<dynamic>;
          final categories = data['categories'] as List<dynamic>;

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Expenses",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              shadowColor: Theme.of(context).colorScheme.shadow,
              centerTitle: true,
            )
          );
        } else {
          return const Center(child: Text("Error: no data!"));
        }
      },
    );
  }
}