import 'package:flutter/material.dart';

class CustomDataTable<T> extends StatefulWidget {
  // final T fixedCornerCell;
  final List<T> fixedColCells;
  List<T> fixedRightColCells;
  bool showSums;
  final List<T> fixedRowCells;
  final List<List<T>> rowsCells;
  final Widget Function(T? data) cellBuilder;

  CustomDataTable({
    // required this.fixedCornerCell,
    required this.fixedColCells,
    required this.fixedRightColCells,
    required this.fixedRowCells,
    required this.rowsCells,
    required this.cellBuilder,
    this.showSums = true,
  });

  double cellHeight = 30.0;
  double cellWidth = 40.0;
  double fixedRowHeight = 60.0;
  double fixedColWidth = 150.0;
  double cellMargin = 0.0;
  double cellSpacing = 0.0;

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
      width: width,
      height: widget.cellHeight,
      child: widget.cellBuilder.call(data)
  );

  Widget _buildFixedCol() => Material(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widget.fixedColCells.map((cell) {
        return Container(
          width: widget.fixedColWidth + (widget.cellMargin * 2),
          height: widget.cellHeight,
          padding: EdgeInsets.symmetric(horizontal: widget.cellMargin),
          child: _buildChild(widget.fixedColWidth, cell),
        );
      }).toList(),
    ),
  );

  Widget _buildFixedRightCol() => Material(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widget.fixedRightColCells.map((cell) {
        final cellWidth = widget.showSums ? widget.cellWidth : hiddenCellWidth;
        return Container(
          width: cellWidth + (widget.cellMargin * 2),
          height: widget.cellHeight,
          padding: EdgeInsets.symmetric(horizontal: widget.cellMargin),
          child: _buildChild(cellWidth, cell),
        );
      }).toList(),
    ),
  );

  Widget _buildFixedRow() => Material(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widget.fixedRowCells.map((cell) {
        return Container(
          width: widget.cellWidth + (widget.cellMargin * 2),
          height: widget.fixedRowHeight,
          padding: EdgeInsets.symmetric(horizontal: widget.cellMargin),
          child: _buildChild(widget.cellWidth, cell),
        );
      }).toList(),
    ),
  );

  Widget _buildSubTable() => Material(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widget.rowsCells.map((row) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: row.map((cell) {
            return Container(
              width: widget.cellWidth + (widget.cellMargin * 2),
              height: widget.cellHeight,
              padding: EdgeInsets.symmetric(horizontal: widget.cellMargin),
              child: _buildChild(widget.cellWidth, cell),
            );
          }).toList(),
        );
      }).toList(),
    ),
  );

  Widget _buildCornerSumCell({bool wide = false, showButton = false, required BuildContext context}) => Material(
    child: Container(
      width: (wide ? widget.fixedColWidth : (widget.showSums ? widget.cellWidth : hiddenCellWidth)) + (widget.cellMargin * 2),
      height: widget.fixedRowHeight,
      padding: EdgeInsets.symmetric(horizontal: widget.cellMargin),
      child: SizedBox(
        width: wide
            ? widget.fixedColWidth
            : widget.showSums
            ? widget.cellWidth
            : hiddenCellWidth,
        height: widget.cellHeight,
        child: Container(
          decoration: BoxDecoration(
          // color: colorScheme.surface,
          ),
          child: Center(
            child: showButton
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 6,
                    children: [
                      Text(
                        "Σ",
                        style: TextStyle(
                          fontSize: 28,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                          thumbIcon: WidgetStateProperty<Icon>.fromMap(
                            <WidgetStatesConstraint, Icon>{
                              WidgetState.selected: Icon(Icons.visibility),
                              WidgetState.any: Icon(Icons.close),
                            },
                          ),
                          onChanged: (value) {
                            setState(() {
                              widget.showSums = value;
                            });
                          },
                          value: widget.showSums
                      )
                    ]
                  )
                : const Text(
                    "Σ",
                    style: TextStyle(
                      fontSize: 26,
                    ),
                  ),
          ),
        ),
      )
    ),
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

  void setColumnsWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    widget.fixedColWidth = screenWidth / 3.0;
    widget.cellWidth = (screenWidth - widget.fixedColWidth) / 7.0;
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      widget.fixedColWidth /= 2.0;
      widget.cellWidth /= 2.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    setColumnsWidth(context);
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
            _buildCornerSumCell(context: context, wide: true, showButton: true),
            Flexible(
              child: SingleChildScrollView(
                controller: _rowController,
                scrollDirection: Axis.horizontal,
                physics: NeverScrollableScrollPhysics(),
                child: _buildFixedRow(),
              ),
            ),
            _buildCornerSumCell(context: context),
          ],
        ),
      ],
    );
  }
}