import 'package:flutter/material.dart';
import 'package:zero_grid/src/common/zero_grid_dict.dart';
import 'package:zero_grid/src/controller/zero_grid_controller.dart';
import 'package:zero_grid/src/engine/isolate_grid_engine.dart';
import 'package:zero_grid/src/model/grid_column.dart';

/// Visual styling configuration for `ZeroDataGrid<T>`.
class ZeroGridTheme {
  /// Creates a [ZeroGridTheme].
  const ZeroGridTheme({
    this.backgroundColor = const Color(0xFF0B0E17),
    this.headerBackgroundColor = const Color(0xFF121726),
    this.footerBackgroundColor = const Color(0xFF121726),
    this.alternateRowColor = const Color(0xFF0E1320),
    this.borderColor = const Color(0xFF1F273D),
    this.frozenDividerColor = const Color(0xFF38BDF8),
    this.selectionFillColor = const Color(0x2E38BDF8),
    this.selectionBorderColor = const Color(0xFF38BDF8),
    this.headerTextStyle = const TextStyle(
      color: Color(0xFFE2E8F0),
      fontSize: 12.5,
      fontWeight: FontWeight.w700,
    ),
    this.cellTextStyle = const TextStyle(
      color: Color(0xFFCBD5E1),
      fontSize: 13.0,
    ),
    this.footerTextStyle = const TextStyle(
      color: Color(0xFF38BDF8),
      fontSize: 12.5,
      fontWeight: FontWeight.w700,
    ),
  });

  /// Main canvas background color.
  final Color backgroundColor;

  /// Background color for the sticky header bar.
  final Color headerBackgroundColor;

  /// Background color for the sticky summary footer bar.
  final Color footerBackgroundColor;

  /// Zebra-striping background color for odd-numbered rows.
  final Color alternateRowColor;

  /// Grid cell hairline border color.
  final Color borderColor;

  /// Accent divider color separating frozen left/right panes.
  final Color frozenDividerColor;

  /// Fill color for cells inside the active [CellRange] marquee.
  final Color selectionFillColor;

  /// Border color for the anchor cell inside the active selection.
  final Color selectionBorderColor;

  /// Default text style for column headers.
  final TextStyle headerTextStyle;

  /// Default text style for data cells.
  final TextStyle cellTextStyle;

  /// Default text style for footer aggregation cells.
  final TextStyle footerTextStyle;
}

/// Interactive column header cell supporting click-to-sort and drag-to-resize.
class GridHeaderCell<T> extends StatelessWidget {
  /// Creates a [GridHeaderCell].
  const GridHeaderCell({
    required this.column,
    required this.controller,
    required this.theme,
    required this.height,
    super.key,
  });

  /// Column definition rendered by this header cell.
  final ZeroGridColumn<T> column;

  /// Grid controller handling sort toggles and column width updates.
  final ZeroGridController<T> controller;

  /// Visual theme of the grid.
  final ZeroGridTheme theme;

  /// Height of the header bar in logical pixels.
  final double height;

  @override
  Widget build(BuildContext context) {
    final width = controller.widthOf(column);
    final isSorted = controller.sortedColumnId == column.id;
    final sortDir = isSorted ? controller.sortDirection : SortDirection.none;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.headerBackgroundColor,
        border: Border(
          right: BorderSide(color: theme.borderColor),
          bottom: BorderSide(color: theme.borderColor, width: 1.5),
        ),
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: column.sortable
                ? () => controller.toggleSort(column.id)
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Align(
                alignment: column.alignment,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        column.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.headerTextStyle,
                      ),
                    ),
                    if (sortDir != SortDirection.none) ...[
                      const SizedBox(width: 4),
                      Tooltip(
                        message: sortDir == SortDirection.ascending
                            ? ZeroGridDict.sortAscendingHint
                            : ZeroGridDict.sortDescendingHint,
                        child: Icon(
                          sortDir == SortDirection.ascending
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 14,
                          color: theme.selectionBorderColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (column.resizable)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 8,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (details) {
                    controller.resizeColumn(
                      column.id,
                      controller.widthOf(column) + details.delta.dx,
                    );
                  },
                  child: const SizedBox.expand(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Pinned summary footer cell rendering automatic numeric aggregations.
class GridFooterCell<T> extends StatelessWidget {
  /// Creates a [GridFooterCell].
  const GridFooterCell({
    required this.column,
    required this.controller,
    required this.theme,
    required this.height,
    required this.isFirstColumn,
    super.key,
  });

  /// Column definition summarized by this footer cell.
  final ZeroGridColumn<T> column;

  /// Grid controller providing visible rows and column widths.
  final ZeroGridController<T> controller;

  /// Visual theme of the grid.
  final ZeroGridTheme theme;

  /// Height of the footer bar.
  final double height;

  /// Whether this cell is the very first column in the grid.
  final bool isFirstColumn;

  @override
  Widget build(BuildContext context) {
    final width = controller.widthOf(column);
    var summary = IsolateGridEngine.computeAggregation(
      column,
      controller.visibleRows,
    );
    if (summary.isEmpty && isFirstColumn) {
      summary = ZeroGridDict.summaryTotalLabel;
    }

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: column.alignment,
      decoration: BoxDecoration(
        color: theme.footerBackgroundColor,
        border: Border(
          top: BorderSide(color: theme.borderColor, width: 1.5),
          right: BorderSide(color: theme.borderColor),
        ),
      ),
      child: Text(
        summary,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.footerTextStyle,
      ),
    );
  }
}
