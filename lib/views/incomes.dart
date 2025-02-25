import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../services/auth_service.dart';
import '../tools/formatters.dart';

class IncomesScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final Future<void> Function() refreshParent;

  const IncomesScreen({Key? key, required this.data, required this.refreshParent}) : super(key: key);

  @override
  _IncomesScreenState createState() => _IncomesScreenState();
}

class _IncomesScreenState extends State<IncomesScreen> {

  Widget _incomeListItemTitle(dynamic income) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width * 0.25,
            maxWidth: MediaQuery.of(context).size.width * 0.25,
          ),
          child: Text(
            Formatters.currencyFormatter.format(income['value']),
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
        ),

        Text(
          income['date'] ?? "",
          style: const TextStyle(color: Colors.grey, fontSize: 16.0),
        ),
      ],
    );
  }

  Widget? _incomeListItemSubtitle(dynamic income) {
    if ((income['comment'] == null || income['comment'].isEmpty) && income['is_salary'] == false) {
      return null;
    }
    return Container(
        margin: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                income['comment'],
                style: const TextStyle(fontStyle: FontStyle.italic),
                textAlign: TextAlign.end,
              ),
            ),
            if (income['is_salary'] == true)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4.0, left: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey.shade100
                          : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.salary,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final incomes = widget.data['incomes'] as List<dynamic>;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showIncomeDetailsDialog(null);
        },
        label: Text(AppLocalizations.of(context)!.add),
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
                    _showIncomeDetailsDialog(income);
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
                    _showIncomeRemovalDialog(income);
                  },
                  foregroundColor: Colors.red,
                  backgroundColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : Colors.grey.shade900,
                  icon: Icons.delete,
                  label: AppLocalizations.of(context)!.remove,
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
              title: _incomeListItemTitle(income),
              subtitle: _incomeListItemSubtitle(income)
            ),
          );
        },
      ));
  }

  void _showIncomeDetailsDialog(Map<String, dynamic>? income) {
    final title = income != null
        ? AppLocalizations.of(context)!.incomeDetails
        : AppLocalizations.of(context)!.addIncome;

    TextEditingController valueController = TextEditingController(text: income?['value']?.toString() ?? '');
    TextEditingController dateController = TextEditingController(text: income?['date'] ?? DateFormat("yyyy-MM-dd").format(DateTime.now()));
    TextEditingController commentController = TextEditingController(text: income?['comment'] ?? '');
    bool isSalary = income?['is_salary'] ?? false;
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                      ),
                    TextField(
                      controller: valueController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.amount,
                      ),
                    ),
                    TextField(
                      controller: dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.date,
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: income != null
                              ? DateTime.parse(income['date'])
                              : DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            dateController.text =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                          });
                        }
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.salary),
                        Checkbox(
                          value: isSalary,
                          onChanged: (bool? value) {
                            setState(() {
                              isSalary = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                    TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.comment,
                      ),
                    ),
                  ],
                ),
              actions: isLoading
                ? []
                : [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (valueController.text.isEmpty || dateController.text.isEmpty) {
                        setState(() {
                          errorMessage = AppLocalizations.of(context)!.pleaseFillAllFields;
                        });
                        return;
                      }

                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });

                      try {
                        final authService = AuthService();
                        final requestData = {
                          'value': double.tryParse(valueController.text) ?? 0.0,
                          'date': dateController.text,
                          'is_salary': isSalary,
                          'comment': commentController.text,
                          'month': widget.data['month']['id'] ?? ''
                        };

                        if (income != null) {
                          requestData['id'] = income['id'];
                        }

                        await authService.post("income/", requestData);
                        Navigator.pop(context);
                        widget.refreshParent();
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                          errorMessage = AppLocalizations.of(context)!.errorSavingData;
                        });
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.save),
                  )
                ],
            );
          },
        );
      },
    );
  }

  void _showIncomeRemovalDialog(Map<String, dynamic> income) {
    final title = AppLocalizations.of(context)!.alert;

    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                    ),
                  Text(AppLocalizations.of(context)!.incomeRemoval)
                ],
              ),
              actions: isLoading
                  ? []
                  : [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });

                    try {
                      final authService = AuthService();
                      final requestData = {
                        'id': income['id'],
                        'remove': 'true'
                      };

                      await authService.post("income/", requestData);
                      Navigator.pop(context);
                      widget.refreshParent();
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                        errorMessage = AppLocalizations.of(context)!.errorSavingData;
                      });
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.remove),
                ),
              ],
            );
          },
        );
      },
    );
  }

}