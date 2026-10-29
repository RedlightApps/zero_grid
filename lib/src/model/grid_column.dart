import 'package:flutter/widgets.dart';

/// Horizontal pinning behavior for a [ZeroGridColumn].
enum FreezePosition {
  /// Column scrolls horizontally inside the center viewport.
  none,

  /// Column is pinned to the leading (left) edge of the grid.
  left,

  /// Column is pinned to the trailing (right) edge of the grid.
  right,
}

/// Sort order applied to a [ZeroGridColumn].
enum SortDirection {
  /// No active sort.
  none,

  /// Ascending order (`A -> Z`, `0 -> 9`).
  ascending,

  /// Descending order (`Z -> A`, `9 -> 0`).
  descending,
}

/// Built-in footer summary aggregation strategies for numeric columns.
enum GridAggregation {
  /// Do not compute an automatic summary.
  none,

  /// Sum of all visible numeric values in the column.
  sum,

  /// Arithmetic mean of all visible numeric values in the column.
  average,

  /// Minimum numeric value in the column.
  min,

  /// Maximum numeric value in the column.
  max,

  /// Total count of visible rows.
  count,
}

/// Signature for building a custom cell widget at `(rowIndex, item)`.
typedef ZeroCellBuilder<T> = Widget Function(
  BuildContext context,
  int rowIndex,
  T item,
  Object? cellValue,
  bool isSelected,
);

/// Strongly-typed column definition for `ZeroDataGrid<T>`.
class ZeroGridColumn<T> {
  /// Creates a [ZeroGridColumn].
  const ZeroGridColumn({
    required this.id,
    required this.title,
    required this.valueGetter,
    this.width = 140.0,
    this.minWidth = 64.0,
    this.maxWidth = 520.0,
    this.freeze = FreezePosition.none,
    this.sortable = true,
    this.resizable = true,
    this.alignment = Alignment.centerLeft,
    this.aggregation = GridAggregation.none,
    this.formatter,
    this.cellBuilder,
    this.footerBuilder,
  });

  /// Unique identifier for the column.
  final String id;

  /// Display title rendered inside the header bar.
  final String title;

  /// Extracts a comparable and serializable cell value from a row item [T].
  ///
  /// Returning primitives (`num`, `String`, `bool`, `DateTime`) guarantees
  /// background `Isolate` compatibility during sorting and filtering.
  final Object? Function(T item) valueGetter;

  /// Initial width of the column in logical pixels.
  final double width;

  /// Minimum width allowed when resizing the column interactively.
  final double minWidth;

  /// Maximum width allowed when resizing the column interactively.
  final double maxWidth;

  /// Whether this column is pinned to the left, right, or scrolls normally.
  final FreezePosition freeze;

  /// Whether clicking the column header toggles sorting.
  final bool sortable;

  /// Whether dragging the trailing edge resizes the column width.
  final bool resizable;

  /// Alignment of cell content inside the column.
  final Alignment alignment;

  /// Optional automatic numeric aggregation shown in the pinned footer row.
  final GridAggregation aggregation;

  /// Optional string formatter for converting the raw value into display text.
  final String Function(Object? value)? formatter;

  /// Optional custom cell widget builder.
  final ZeroCellBuilder<T>? cellBuilder;

  /// Optional custom footer summary text builder.
  final String Function(List<T> visibleItems)? footerBuilder;

  /// Formats the extracted cell value for display or clipboard export.
  String formatValue(T item) {
    final raw = valueGetter(item);
    if (formatter != null) return formatter!(raw);
    return raw?.toString() ?? '';
  }
}
