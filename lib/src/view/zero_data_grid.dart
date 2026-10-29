import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zero_grid/src/common/zero_grid_dict.dart';
import 'package:zero_grid/src/controller/zero_grid_controller.dart';
import 'package:zero_grid/src/engine/virtual_viewport_2d.dart';
import 'package:zero_grid/src/model/grid_column.dart';
import 'package:zero_grid/src/view/grid_cell_tile.dart';
import 'package:zero_grid/src/view/grid_header_footer.dart';

/// 120Hz 2D-virtualized DataGrid & Spreadsheet widget supporting 1,000,000+
/// rows, left/right column freezing, marquee range selection, and TSV clipboard
/// copy (`Ctrl+C` / `Cmd+C`).
class ZeroDataGrid<T> extends StatefulWidget {
  /// Creates a [ZeroDataGrid].
  const ZeroDataGrid({
    required this.controller,
    this.rowHeight = 38.0,
    this.headerHeight = 42.0,
    this.footerHeight = 38.0,
    this.showFooter = true,
    this.theme = const ZeroGridTheme(),
    this.emptyPlaceholder,
    this.onCellsCopied,
    super.key,
  });

  /// Reactive controller supplying rows, columns, sorting, and selection.
  final ZeroGridController<T> controller;
  /// Fixed height of each data row in logical pixels.
  final double rowHeight;
  /// Height of the sticky column header row.
  final double headerHeight;
  /// Height of the sticky summary footer row.
  final double footerHeight;
  /// Whether to render the pinned bottom aggregation footer row.
  final bool showFooter;
  /// Visual theme configuration.
  final ZeroGridTheme theme;
  /// Optional custom widget shown when `visibleRows` is empty.
  final Widget? emptyPlaceholder;
  /// Optional callback invoked when `Ctrl+C` / `Cmd+C` copies TSV data.
  final ValueChanged<String>? onCellsCopied;

  @override
  State<ZeroDataGrid<T>> createState() => _ZeroDataGridState<T>();
}

class _ZeroDataGridState<T> extends State<ZeroDataGrid<T>> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  double _scrollX = 0.0;
  double _scrollY = 0.0;

  @override
  void initState() {
    super.initState();
    _verticalController.addListener(_onScrollChanged);
    _horizontalController.addListener(_onScrollChanged);
  }

  void _onScrollChanged() {
    final nx = _horizontalController.hasClients ? _horizontalController.offset : 0.0;
    final ny = _verticalController.hasClients ? _verticalController.offset : 0.0;
    if (nx != _scrollX || ny != _scrollY) {
      setState(() {
        _scrollX = nx;
        _scrollY = ny;
      });
    }
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final isCopyKey = event.logicalKey == LogicalKeyboardKey.keyC &&
        (HardwareKeyboard.instance.isControlPressed ||
            HardwareKeyboard.instance.isMetaPressed);
    if (isCopyKey) {
      widget.controller.copySelectionToClipboard().then((tsv) {
        if (tsv.isNotEmpty) widget.onCellsCopied?.call(tsv);
      });
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final allCols = widget.controller.columns;
          final leftCols = <int>[];
          final centerCols = <int>[];
          final rightCols = <int>[];
          for (var i = 0; i < allCols.length; i++) {
            switch (allCols[i].freeze) {
              case FreezePosition.left:
                leftCols.add(i);
              case FreezePosition.none:
                centerCols.add(i);
              case FreezePosition.right:
                rightCols.add(i);
            }
          }
          final leftWidth = leftCols.fold<double>(0.0, (s, i) => s + widget.controller.widthOf(allCols[i]));
          final rightWidth = rightCols.fold<double>(0.0, (s, i) => s + widget.controller.widthOf(allCols[i]));

          return LayoutBuilder(
            builder: (context, constraints) {
              final centerViewportW = (constraints.maxWidth - leftWidth - rightWidth).clamp(1.0, 100000.0);
              final bodyViewportH = (constraints.maxHeight - widget.headerHeight - (widget.showFooter ? widget.footerHeight : 0.0)).clamp(1.0, 100000.0);
              final span = VirtualViewport2D.compute(
                totalRows: widget.controller.visibleRows.length,
                rowHeight: widget.rowHeight,
                columnWidths: centerCols.map((i) => widget.controller.widthOf(allCols[i])).toList(growable: false),
                scrollOffsetX: _scrollX,
                scrollOffsetY: _scrollY,
                viewportWidth: centerViewportW,
                viewportHeight: bodyViewportH,
              );

              return ColoredBox(
                color: widget.theme.backgroundColor,
                child: Column(
                  children: [
                    GridBandRow<T>(
                      controller: widget.controller, theme: widget.theme,
                      leftCols: leftCols, centerCols: centerCols, rightCols: rightCols,
                      centerViewportW: centerViewportW, totalCenterW: span.totalContentWidth,
                      scrollX: _scrollX, height: widget.headerHeight, isHeader: true,
                    ),
                    Expanded(
                      child: widget.controller.visibleRows.isEmpty
                          ? Center(child: widget.emptyPlaceholder ?? Text(ZeroGridDict.emptyGridLabel, style: widget.theme.cellTextStyle))
                          : _buildVirtualizedBody(leftCols, centerCols, rightCols, leftWidth, rightWidth, centerViewportW, span),
                    ),
                    if (widget.showFooter)
                      GridBandRow<T>(
                        controller: widget.controller, theme: widget.theme,
                        leftCols: leftCols, centerCols: centerCols, rightCols: rightCols,
                        centerViewportW: centerViewportW, totalCenterW: span.totalContentWidth,
                        scrollX: _scrollX, height: widget.footerHeight, isHeader: false,
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildVirtualizedBody(
    List<int> leftCols, List<int> centerCols, List<int> rightCols,
    double leftWidth, double rightWidth, double centerViewportW, VisibleSpan2D span,
  ) {
    final allCols = widget.controller.columns;
    final rows = widget.controller.visibleRows;
    final cells = <Widget>[];
    if (!span.isEmpty) {
      for (var r = span.firstRow; r <= span.lastRow; r++) {
        final top = r * widget.rowHeight - _scrollY;
        var lx = 0.0;
        for (final colIdx in leftCols) {
          final w = widget.controller.widthOf(allCols[colIdx]);
          cells.add(_cell(r, colIdx, lx, top, w, rows[r]));
          lx += w;
        }
        for (var c = span.firstColumn; c <= span.lastColumn; c++) {
          final colIdx = centerCols[c];
          final w = widget.controller.widthOf(allCols[colIdx]);
          final cx = leftWidth + span.columnOffsets[c] - _scrollX;
          if (cx + w >= leftWidth && cx <= leftWidth + centerViewportW) {
            cells.add(_cell(r, colIdx, cx, top, w, rows[r]));
          }
        }
        var rx = leftWidth + centerViewportW;
        for (final colIdx in rightCols) {
          final w = widget.controller.widthOf(allCols[colIdx]);
          cells.add(_cell(r, colIdx, rx, top, w, rows[r]));
          rx += w;
        }
      }
    }
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _verticalController,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: leftWidth + span.totalContentWidth + rightWidth, height: span.totalContentHeight),
          ),
        ),
        ...cells,
      ],
    );
  }

  Widget _cell(int r, int c, double x, double y, double w, T item) => GridCellTile<T>(
    controller: widget.controller, theme: widget.theme, rowIdx: r, colIdx: c,
    left: x, top: y, width: w, height: widget.rowHeight, item: item,
    onFocusRequested: _focusNode.requestFocus,
  );
}
