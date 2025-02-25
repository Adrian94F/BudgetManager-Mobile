import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExpenseDetails extends StatefulWidget {
  final Map<String, dynamic>? expense;
  final List<dynamic> categories;
  final List<int>? topCategories;
  final int monthId;
  final int? preferredCategoryId;
  final DateTime? preferredDate;

  const ExpenseDetails({
    super.key,
    this.expense,
    required this.categories,
    required this.monthId,
    this.preferredCategoryId,
    this.preferredDate,
    this.topCategories,
  });

  @override
  State<StatefulWidget> createState() => _ExpenseDetailsState();
}

class _ExpenseDetailsState extends State<ExpenseDetails> {
  late TextEditingController _valueController;
  late TextEditingController _dateController;
  late TextEditingController _commentController;
  late int _categoryId;
  bool _isRecurrent = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(text: widget.expense?['value']?.toString() ?? '');
    _dateController = TextEditingController(
      text: widget.expense?['date'] ?? DateFormat("yyyy-MM-dd").format(widget.preferredDate ?? DateTime.now()),
    );
    _commentController = TextEditingController(text: widget.expense?['comment'] ?? '');
    _categoryId = widget.expense?['category'] ?? widget.preferredCategoryId ?? (widget.topCategories != null ? widget.topCategories![0] : widget.categories.first['id']);
    _isRecurrent = widget.expense?['is_monthly'] ?? false;
  }

  @override
  void dispose() {
    _valueController.dispose();
    _dateController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _saveExpense() async {
    if (_valueController.text.isEmpty || _dateController.text.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.pleaseFillAllFields;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      final requestData = {
        'value': double.tryParse(_valueController.text) ?? 0.0,
        'date': _dateController.text,
        'is_monthly': _isRecurrent,
        'comment': _commentController.text,
        'category': _categoryId,
        'month': widget.monthId
      };

      if (widget.expense != null) {
        requestData['id'] = widget.expense!['id'];
      }

      await authService.post("expense/", requestData);
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context)!.errorSavingData;
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.expense != null
          ? DateTime.parse(widget.expense!['date'])
          : widget.preferredDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> topCategoriesList = widget.categories
        .where((c) => widget.topCategories?.contains(c['id']) ?? false)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense != null
            ? AppLocalizations.of(context)!.expenseDetails
            : AppLocalizations.of(context)!.addExpense),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TextField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.amount,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TextField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.date,
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                ),
                onTap: _selectDate,
              )
            ),

            if (topCategoriesList.isNotEmpty && widget.preferredCategoryId == null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(AppLocalizations.of(context)!.quickSelectCategory)
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                child: Wrap(
                  spacing: 8.0,
                  children: topCategoriesList.map((category) {
                    bool isSelected = _categoryId == category['id'];
                    return ChoiceChip(
                      label: Text(category['name']),
                      selected: isSelected,
                      selectedColor: Colors.blue.shade200,
                      onSelected: (_) {
                        setState(() {
                          _categoryId = category['id'];
                        });
                      },
                    );
                  }).toList(),
                )
              ),
              const SizedBox(height: 16),
            ],

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: DropdownButtonFormField<int>(
                value: _categoryId,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.category,
                  border: const OutlineInputBorder(),
                ),
                items: widget.categories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category['id'],
                    child: Text(category['name']),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _categoryId = newValue ?? 0;
                  });
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.comment,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(AppLocalizations.of(context)!.recurrentExpense),
              value: _isRecurrent,
              onChanged: (bool? value) {
                if (value != null) {
                  setState(() {
                    _isRecurrent = value;
                  });
                }
              },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveExpense,
                  child: Text(
                    widget.expense != null
                      ? AppLocalizations.of(context)!.save
                      : AppLocalizations.of(context)!.add,
                    style: const TextStyle(
                      fontSize: 20
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
