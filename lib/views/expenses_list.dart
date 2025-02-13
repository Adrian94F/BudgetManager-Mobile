import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../tools/formatters.dart';

class ExpensesListView extends StatefulWidget {
  final List<dynamic> expenses;
  final List<dynamic> categories;

  const ExpensesListView({Key? key, required this.expenses, required this.categories}) : super(key: key);

  @override
  State<ExpensesListView> createState() => _ExpensesListViewState();
}

class _ExpensesListViewState extends State<ExpensesListView> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();

    // Tworzenie GlobalKey dla każdego elementu
    for (int i = 0; i < widget.expenses.length; i++) {
      _itemKeys[i] = GlobalKey();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  void _scrollToToday() {
    DateTime now = DateTime.now();
    int? targetIndex;

    for (int i = 0; i < widget.expenses.length; i++) {
      DateTime expenseDate = DateTime.parse(widget.expenses[i]['date']);

      if (expenseDate.year == now.year &&
          expenseDate.month == now.month &&
          expenseDate.day == now.day) {
        targetIndex = i;
        break;
      } else if (expenseDate.isBefore(now)) {
        targetIndex = i;
        break;
      }
    }

    if (targetIndex != null && _itemKeys.containsKey(targetIndex)) {
      final context = _itemKeys[targetIndex]!.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  String getCategoryName(int categoryId) {
    final category = widget.categories.firstWhere(
          (element) => element['id'] == categoryId,
      orElse: () => {'name': '–'},
    );
    return category['name'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO
        },
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: widget.expenses.length,
        padding: const EdgeInsets.only(bottom: 80),
        itemBuilder: (context, index) {
          final expense = widget.expenses[index];
          final String currentDate = expense['date'];
          bool showDateHeader = index == 0 || widget.expenses[index - 1]['date'] != currentDate;

          return Column(
            key: _itemKeys[index],
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDateHeader)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 24.0, 8.0, 8.0),
                  child: Text(
                    currentDate,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              Slidable(
                key: Key(expense['id'].toString()),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        // TODO
                      },
                      foregroundColor: Colors.indigo,
                      backgroundColor: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : Colors.grey.shade900,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                    SlidableAction(
                      onPressed: (context) {
                        // TODO
                      },
                      foregroundColor: Colors.red.shade900,
                      backgroundColor: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : Colors.grey.shade900,
                      icon: Icons.delete,
                      label: 'Remove',
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2.0),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Formatters.currencyFormatter.format(expense['value']),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.light
                                ? Colors.indigo.shade50
                                : Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            getCategoryName(expense['category']),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                                color: Theme.of(context).brightness == Brightness.light
                                    ? Colors.grey.shade900
                                    : Colors.grey.shade100),
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          expense['comment'],
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      if (expense['is_monthly'] == true)
                        Container(
                          margin: const EdgeInsetsDirectional.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.light
                                ? Colors.indigo.shade50
                                : Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Icon(
                            Icons.repeat,
                            size: 16,
                            color: Theme.of(context).brightness == Brightness.light
                                ? Colors.grey.shade900
                                : Colors.grey.shade100,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
