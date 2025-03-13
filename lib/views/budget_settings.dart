import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BudgetSettings extends StatefulWidget {
  const BudgetSettings({super.key});


  @override
  _BudgetSettingsState createState() => _BudgetSettingsState();

}

class _BudgetSettingsState extends State<BudgetSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.budgetSettings
        ),
        centerTitle: true,
      ),
    );
  }
}