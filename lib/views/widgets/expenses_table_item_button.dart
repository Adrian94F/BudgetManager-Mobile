import 'package:flutter/material.dart';

class ExpensesTableItemButton extends StatelessWidget{
  final VoidCallback onPressed;
  final Widget child;
  AlignmentGeometry alignment = Alignment.center;

  ExpensesTableItemButton({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        alignment: alignment,
        shape: WidgetStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)))),
        padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 0, horizontal: 8)),
        foregroundColor: Theme.of(context).brightness == Brightness.light
            ? WidgetStateProperty.all(Colors.black)
            : WidgetStateProperty.all(Colors.white),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
