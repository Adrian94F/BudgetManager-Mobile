import 'package:flutter/material.dart';

class ExpensesTableItemButton extends StatelessWidget{
  final VoidCallback onPressed;
  final Widget child;

  const ExpensesTableItemButton({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)))),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        foregroundColor: Theme.of(context).brightness == Brightness.light
            ? WidgetStateProperty.all(Colors.black)
            : WidgetStateProperty.all(Colors.white),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
