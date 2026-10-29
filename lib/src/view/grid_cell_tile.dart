import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zero_grid/src/controller/zero_grid_controller.dart';
import 'package:zero_grid/src/model/grid_selection.dart';
import 'package:zero_grid/src/view/grid_header_footer.dart';

/// Synchronized horizontal header or footer band supporting frozen left and
/// right columns alongside a horizontally scrolled center pane.
class GridBandRow<T> extends StatelessWidget {
  /// Creates a [GridBandRow].
  const GridBandRow({
    required this.controller,
    required this.theme,
    required this.leftCols,
    required this.centerCols,
    required this.rightCols,
    required this.centerViewportW,
    required this.totalCenterW,
    required this.scrollX,
    required this.height,
    required this.isHeader,
    super.key,
  });

  /// Grid controller.
  final ZeroGridController<T> controller;

  /// Active visual theme.
  final ZeroGridTheme theme;

  /// Left-frozen column indices.
  final List<int> leftCols;

  /// Scrollable center column indices.
  final List<int> centerCols;

  /// Right-frozen column indices.
  final List<int> rightCols;

  /// Available width for the center scrollable viewport.
  final double centerViewportW;

  /// Total sum of widths of all center columns.
  final double totalCenterW;

  /// Current horizontal scroll offset.
  final double scrollX;

  /// Height of the band row.
  final double height;

  /// `true` for header band, `false` for footer summary band.
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    final allCols = controller.columns;
    Widget buildCell(int globalIdx) => isHeader
        ? GridHeaderCell<T>(
            column: allCols[globalIdx],
            controller: controller,
            theme: theme,
            height: height,
          )
        : GridFooterCell<T>(
            column: allCols[globalIdx],
            controller: controller,
            theme: theme,
            height: height,
            isFirstColumn: globalIdx == 0,
          );

    return SizedBox(
      height: height,
      child: Row(
        children: [
          ...leftCols.map(buildCell),
          SizedBox(
            width: centerViewportW,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.topLeft,
                minWidth: totalCenterW,
                maxWidth:
                    totalCenterW < centerViewportW ? centerViewportW : totalCenterW,
                child: Transform.translate(
                  offset: Offset(-scrollX, 0),
                  child: Row(children: centerCols.map(buildCell).toList()),
                ),
              ),
            ),
          ),
          ...rightCols.map(buildCell),
        ],
      ),
    );
  }
}

/// Positioned data cell tile inside the 2D virtualized canvas.
class GridCellTile<T> extends StatelessWidget {
  /// Creates a [GridCellTile].
  const GridCellTile({
    required this.controller,
    required this.theme,
    required this.rowIdx,
    required this.colIdx,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.item,
    required this.onFocusRequested,
    super.key,
  });

  /// Grid controller.
  final ZeroGridController<T> controller;

  /// Active visual theme.
  final ZeroGridTheme theme;

  /// Zero-based visible row index.
  final int rowIdx;

  /// Zero-based global column index.
  final int colIdx;

  /// Horizontal position in the viewport Stack.
  final double left;

  /// Vertical position in the viewport Stack.
  final double top;

  /// Cell width.
  final double width;

  /// Cell height.
  final double height;

  /// Row item model.
  final T item;

  /// Callback invoked to focus the grid for keyboard shortcuts.
  final VoidCallback onFocusRequested;

  @override
  Widget build(BuildContext context) {
    final col = controller.columns[colIdx];
    final sel = controller.selection;
    final isSelected = sel?.contains(rowIdx, colIdx) ?? false;
    final isAnchor =
        sel?.anchor.rowIndex == rowIdx && sel?.anchor.columnIndex == colIdx;
    final coord = CellCoordinate(rowIndex: rowIdx, columnIndex: colIdx);

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: () {
          onFocusRequested();
          controller.selectCell(
            coord,
            extendSelection: HardwareKeyboard.instance.isShiftPressed,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: col.alignment,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.selectionFillColor
                : (rowIdx.isOdd ? theme.alternateRowColor : theme.backgroundColor),
            border: isAnchor
                ? Border.all(color: theme.selectionBorderColor, width: 1.5)
                : Border(
                    right: BorderSide(color: theme.borderColor),
                    bottom: BorderSide(color: theme.borderColor),
                  ),
          ),
          child: col.cellBuilder != null
              ? col.cellBuilder!(
                  context,
                  rowIdx,
                  item,
                  col.valueGetter(item),
                  isSelected,
                )
              : Text(
                  col.formatValue(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.cellTextStyle,
                ),
        ),
      ),
    );
  }
}
