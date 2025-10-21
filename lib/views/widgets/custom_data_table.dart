import 'package:flutter/material.dart';

class CustomDataTable<T> extends StatefulWidget {
  final T fixedCornerCell;
  final List<T> fixedColCells;
  List<T> fixedRightColCells;
  bool showSums;
  final List<T> fixedRowCells;
  final List<List<T>> rowsCells;
  final Widget Function(T? data) cellBuilder;
  final double fixedColWidth;
  final double cellWidth;
  final double cellHeight;
  final double cellMargin;
  final double cellSpacing;

  CustomDataTable({
    required this.fixedCornerCell,
    required this.fixedColCells,
    required this.fixedRightColCells,
    required this.fixedRowCells,
    required this.rowsCells,
    required this.cellBuilder,
    this.fixedColWidth = 60.0,
    this.cellHeight = 56.0,
    this.cellWidth = 120.0,
    this.cellMargin = 10.0,
    this.cellSpacing = 10.0,
    this.showSums = true,
  });

  @override
  State<StatefulWidget> createState() => CustomDataTableState<T>();
}

class CustomDataTableState<T> extends State<CustomDataTable<T>> {
  final _columnController = ScrollController();
  final _rowController = ScrollController();
  final _subTableYController = ScrollController();
  final _subTableXController = ScrollController();

  final double hiddenCellWidth = 0;

  Widget _buildChild(double width, T? data) => SizedBox(
      width: width, child: widget.cellBuilder.call(data));

  Widget _buildFixedCol() => Material(
    child: DataTable(
        dividerThickness: 0,
        horizontalMargin: widget.cellMargin,
        columnSpacing: widget.cellSpacing,
        headingRowHeight: widget.cellHeight,
        dataRowHeight: widget.cellHeight,
        columns: [
          DataColumn(
              label: _buildChild(
                  widget.fixedColWidth,
                  widget.fixedColCells.first
              )
          )
        ],
        rows: widget.fixedColCells
            .sublist(0)
            .map((c) => DataRow(
            cells: [DataCell(_buildChild(widget.fixedColWidth, c))]))
            .toList()),
  );

  Widget _buildFixedRightCol() => Material(
    child: DataTable(
        dividerThickness: 0,
        horizontalMargin: widget.cellMargin,
        columnSpacing: widget.cellSpacing,
        headingRowHeight: widget.cellHeight,
        dataRowHeight: widget.cellHeight,
        columns: [
          DataColumn(
              label: _buildChild(
                  widget.showSums ? widget.cellWidth : hiddenCellWidth,
                  widget.showSums ? widget.fixedRightColCells.first : null
              )
          )
        ],
        rows: widget.fixedRightColCells
            .sublist(0)
            .map((c) => DataRow(
            cells: [DataCell(_buildChild(widget.showSums
                ? widget.cellWidth
                : hiddenCellWidth,
              c))]))
            .toList()),
  );

  Widget _buildFixedRow() => Material(
    child: DataTable(
        dividerThickness: 0,
        horizontalMargin: widget.cellMargin,
        columnSpacing: widget.cellSpacing,
        headingRowHeight: widget.cellHeight,
        dataRowHeight: widget.cellHeight,
        columns: widget.fixedRowCells
            .map((c) =>
            DataColumn(label: _buildChild(widget.cellWidth, c)))
            .toList(),
        rows: []),
  );

  Widget _buildSubTable() => Material(
      child: DataTable(
          dividerThickness: 0,
          horizontalMargin: widget.cellMargin,
          columnSpacing: widget.cellSpacing,
          headingRowHeight: widget.cellHeight,
          dataRowHeight: widget.cellHeight,
          columns: widget.rowsCells.first
              .map((c) => DataColumn(label: _buildChild(widget.cellWidth, c)))
              .toList(),
          rows: widget.rowsCells
              .sublist(0)
              .map((row) => DataRow(
              cells: row
                  .map((c) => DataCell(_buildChild(widget.cellWidth, c)))
                  .toList()))
              .toList()));

  Widget _buildCornerCell({bool wide = false}) => Material(
        // color: Colors.amberAccent,
        child: DataTable(
            dividerThickness: 0,
            horizontalMargin: widget.cellMargin,
            columnSpacing: widget.cellSpacing,
            headingRowHeight: widget.cellHeight,
            dataRowHeight: widget.cellHeight,
            columns: [
              DataColumn(
                  label: _buildChild(
                      wide
                        ? widget.fixedColWidth
                        : widget.showSums
                          ? widget.cellWidth
                          : hiddenCellWidth,
                      widget.fixedCornerCell))
            ],
            rows: []),
      );

  @override
  void initState() {
    super.initState();
    _subTableXController.addListener(() {
      _rowController.jumpTo(_subTableXController.position.pixels);
    });
    _subTableYController.addListener(() {
      _columnController.jumpTo(_subTableYController.position.pixels);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Row(
          children: <Widget>[
            SingleChildScrollView(
              controller: _columnController,
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
              child: _buildFixedCol(),
            ),
            Flexible(
              child: SingleChildScrollView(
                controller: _subTableXController,
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  controller: _subTableYController,
                  scrollDirection: Axis.vertical,
                  child: _buildSubTable(),
                ),
              ),
            ),
            SingleChildScrollView(
              controller: _columnController,
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
              child: _buildFixedRightCol(),
            )
          ],
        ),
        Row(
          children: <Widget>[
            _buildCornerCell(wide: true),
            Flexible(
              child: SingleChildScrollView(
                controller: _rowController,
                scrollDirection: Axis.horizontal,
                physics: NeverScrollableScrollPhysics(),
                child: _buildFixedRow(),
              ),
            ),
            _buildCornerCell(),
          ],
        ),
      ],
    );
  }
}