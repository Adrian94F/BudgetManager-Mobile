import 'package:flutter/material.dart';

class ExpensesTableView extends StatelessWidget {
  final List<List<dynamic>> expenses_table;

  const ExpensesTableView({Key? key, required this.expenses_table}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (expenses_table.isEmpty || expenses_table.any((row) => row.isEmpty)) {
      return const Center(child: Text("No data available"));
    }

    return LayoutBuilder(
        builder: (context, constraints) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 2.0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(
                  border: TableBorder.all(color: Colors.grey.shade500),
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: List.generate(expenses_table.length, (rowIndex) {
                    return TableRow(
                      children: List.generate(
                          expenses_table[rowIndex].length, (colIndex) {
                        bool isFrozenRow = rowIndex ==
                            0; // || rowIndex == expenses_table.length - 1;
                        bool isFrozenCol = colIndex ==
                            0; // || colIndex == expenses_table[rowIndex].length - 1;

                        return Container(
                          width: colIndex == 0 ? 160 : 50,
                          //color: (isFrozenRow || isFrozenCol) ? Colors.grey.shade300 : null,
                          alignment: isFrozenCol
                              ? Alignment.centerLeft
                              : Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 1.0, horizontal: 8.0),
                            child: Text(
                              expenses_table[rowIndex][colIndex]!["content"] ?? "",
                              overflow: isFrozenCol
                                  ? TextOverflow.ellipsis
                                  : TextOverflow.clip,
                              style: TextStyle(
                                fontWeight: (isFrozenRow || isFrozenCol)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ),
            ),
          );
        }
    );
  }
}
