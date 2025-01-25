import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../services/auth_service.dart';
import '../tools/formatters.dart';

class IncomesScreen extends StatefulWidget {
  @override
  _IncomesScreenState createState() => _IncomesScreenState();
}

class _IncomesScreenState extends State<IncomesScreen> {
  final _authService = AuthService();
  late Future<Map<String, dynamic>> _data;

  @override
  void initState() {
    super.initState();
    _data = _authService.get("get-incomes");
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
          final incomes = data['incomes'] as List<dynamic>;

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Incomes",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              shadowColor: Theme.of(context).colorScheme.shadow,
              centerTitle: true,
              ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                // TODO
              },
              label: const Text('Add'),
              icon: const Icon(Icons.add),
            ),
            body: ListView.builder(
              itemCount: incomes.length,
              itemBuilder: (context, index) {
                final income = incomes[index];

                return Slidable(
                  key: Key(income['id'].toString()),
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${Formatters.currencyFormatter.format(income['value'])}",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                        Text(
                          income['date'],
                          style: TextStyle(color: Colors.grey, fontSize: 16.0),
                        ),
                      ],
                    ),
                    subtitle:  Container(
                      margin: EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            income['comment'],
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                          if (income['is_salary'] == true)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 4.0),
                                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Text(
                                    "Salary",
                                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
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
          return Center(child: Text("Error: no data!"));
        }
      },
    );
  }
}