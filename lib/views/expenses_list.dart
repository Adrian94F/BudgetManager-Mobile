import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../tools/formatters.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExpensesListView extends StatefulWidget {
  final List<dynamic> expenses;
  final List<dynamic> categories;
  ExpensesFilter filter = ExpensesFilter();

  ExpensesListView({Key? key, required this.expenses, required this.categories, required ExpensesFilter filter}) : super(key: key);
  ExpensesListView.filtered({Key? key, required this.expenses, required this.categories, required this.filter}) : super(key: key);

  @override
  State<ExpensesListView> createState() => _ExpensesListViewState();
}

class _ExpensesListViewState extends State<ExpensesListView> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();

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

  String _getCategoryName(int categoryId) {
    final category = widget.categories.firstWhere(
          (element) => element['id'] == categoryId,
      orElse: () => {'name': '–'},
    );
    return category['name'];
  }

  Widget _dateHeader(DateTime date) {
    final dateFormat = DateFormat('d.MM');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 8.0, 8.0),
          child: Text(
            dateFormat.format(date),
            style: const TextStyle(
              fontSize: 18.0,
              //fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Divider(
          height: 0,
        )
      ]
    );
  }

  Widget _expenseListItemTitle(dynamic expense) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width * 0.25,
            maxWidth: MediaQuery.of(context).size.width * 0.25,
          ),
          child: Text(
            Formatters.currencyFormatter.format(expense['value']),
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.indigo.shade50
                  : Colors.grey.shade900,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              _getCategoryName(expense['category']),
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
    );
  }

  Container _monthlyExpenseTag() {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(8, 4, 0, 4),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
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
    );
  }

  Widget? _expenseListItemSubtitle(dynamic expense) {
    if ((expense['comment'] == null || expense['comment'].isEmpty) && !expense['is_monthly']) {
      return null;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          expense['comment'],
          textAlign: TextAlign.right,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),

        if (expense['is_monthly'])
          _monthlyExpenseTag()
      ],
    );
  }

  Widget _expenseListItem(dynamic expense) {
    return Slidable(
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
            label: AppLocalizations.of(context)!.edit,
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
            label: AppLocalizations.of(context)!.remove,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0.0),
        title: _expenseListItemTitle(expense),
        subtitle: _expenseListItemSubtitle(expense)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO
        },
        label: Text(AppLocalizations.of(context)!.add),
        icon: const Icon(Icons.add),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: widget.expenses.length,
        padding: const EdgeInsets.only(bottom: 80),
        itemBuilder: (context, index) {
          final expense = widget.expenses[index];
          bool showDateHeader = (index == 0 || widget.expenses[index - 1]['date'] != expense['date']) && widget.filter.date == null;

          return Column(
            key: _itemKeys[index],
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDateHeader)
                _dateHeader(DateTime.parse(expense['date'])),
              _expenseListItem(expense)
            ],
          );
        },
      ),
    );
  }


  /*Future<List<int>> getTopNCategories(List<dynamic> expenses, int nOfCategories) async {
    Map<int, int> categoryCounts = {};
    for (var expense in expenses) {
      int categoryId = expense['category'];
      categoryCounts[categoryId] = (categoryCounts[categoryId] ?? 0) + 1;
    }
    List<MapEntry<int, int>> categoryCountsList = categoryCounts.entries.toList();
    categoryCountsList.sort((a, b) => b.value.compareTo(a.value));
    return categoryCountsList.take(nOfCategories).map((entry) => entry.key).toList();
  }

  void _showExpenseDetailsDialog(Map<String, dynamic>? expense, List<dynamic> categories, List<int> topCategories) {
    final title = expense != null
      ? AppLocalizations.of(context)!.expenseDetails
      : AppLocalizations.of(context)!.addExpense;


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              actionsPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.startDate),
                  TextButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null && pickedDate != startDate) {
                        setState(() {
                          startDate = pickedDate;
                        });
                      }
                    },
                    child: Text("${startDate.toLocal()}".split(' ')[0]),
                  ),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context)!.endDate),
                  TextButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null && pickedDate != endDate) {
                        setState(() {
                          endDate = pickedDate;
                        });
                      }
                    },
                    child: Text("${endDate.toLocal()}".split(' ')[0]),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: save data
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            );
          },
        );
      },
    );
  }*/
}

class ExpensesFilter {
  DateTime? date;
  int? category;

  ExpensesFilter({this.date, this.category});
}
