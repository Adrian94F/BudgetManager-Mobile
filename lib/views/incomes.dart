import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../services/auth_service.dart';
import '../tools/formatters.dart';

class IncomesScreen extends StatefulWidget {
  final int? currentMonth;

  const IncomesScreen({Key? key, required this.currentMonth}) : super(key: key);

  @override
  _IncomesScreenState createState() => _IncomesScreenState();
}

class _IncomesScreenState extends State<IncomesScreen> {
  final _authService = AuthService();
  late Future<Map<String, dynamic>> _data;

  @override
  void didUpdateWidget(covariant IncomesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMonth != widget.currentMonth) {
      _fetchData();
    }
  }

  void _fetchData() {
    setState(() {
      _data = _authService.get("get-incomes${widget.currentMonth == null ? '' : '/?month_id=${widget.currentMonth}'}");
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          final incomes = data['incomes'] as List<dynamic>;

          return Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                // TODO
              },
              label: const Text('Add'),
              icon: const Icon(Icons.add),
            ),
            body: ListView.builder(
              itemCount: incomes.length,
              padding: const EdgeInsets.only(bottom: 80),
              itemBuilder: (context, index) {
                final income = incomes[index];

                return Slidable(
                  key: Key(income['id'].toString()),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          // TODO
                        },
                        foregroundColor: Colors.indigo,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                      SlidableAction(
                        onPressed: (context) {
                          // TODO
                        },
                        foregroundColor: Colors.red,
                        icon: Icons.delete,
                        label: 'Remove',
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Formatters.currencyFormatter.format(income['value']),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                        Text(
                          income['date'] ?? "",
                          style: const TextStyle(color: Colors.grey, fontSize: 16.0),
                        ),
                      ],
                    ),
                    subtitle:  Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              income['comment'],
                              style: const TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                          if (income['is_salary'] == true)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 4.0),
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness == Brightness.light
                                        ? Colors.grey.shade100
                                        : Colors.grey.shade800,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: const Text(
                                    "Salary",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            )
                        ],
                      )
                    ),
                  ),
                );
              },
            ));
        } else {
          return const Center(child: Text("Error: no data!"));
        }
      },
    );
  }
}