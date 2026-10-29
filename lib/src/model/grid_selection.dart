import 'dart:math' as math;

/// Zero-based 2D cell coordinate `(rowIndex, columnIndex)` in `ZeroDataGrid`.
class CellCoordinate {
  /// Creates a [CellCoordinate].
  const CellCoordinate({required this.rowIndex, required this.columnIndex});

  /// Zero-based visible row index.
  final int rowIndex;

  /// Zero-based global column index.
  final int columnIndex;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellCoordinate &&
          other.rowIndex == rowIndex &&
          other.columnIndex == columnIndex;

  @override
  int get hashCode => Object.hash(rowIndex, columnIndex);

  @override
  String toString() => 'CellCoordinate(row: $rowIndex, col: $columnIndex)';
}

/// Rectangular selection range between an [anchor] and a [focus] cell.
///
/// Supports Excel-style marquee drag selection and Shift+Click expansion.
class CellRange {
  /// Creates a [CellRange] from [anchor] to [focus].
  const CellRange({
    required this.anchor,
    required this.focus,
  });

  /// Creates a single-cell selection range at [coordinate].
  const CellRange.single(CellCoordinate coordinate)
      : anchor = coordinate,
        focus = coordinate;

  /// Starting cell where the selection gesture began.
  final CellCoordinate anchor;

  /// Current end cell of the selection gesture.
  final CellCoordinate focus;

  /// Inclusive minimum row index in this range.
  int get startRow => math.min(anchor.rowIndex, focus.rowIndex);

  /// Inclusive maximum row index in this range.
  int get endRow => math.max(anchor.rowIndex, focus.rowIndex);

  /// Inclusive minimum column index in this range.
  int get startColumn => math.min(anchor.columnIndex, focus.columnIndex);

  /// Inclusive maximum column index in this range.
  int get endColumn => math.max(anchor.columnIndex, focus.columnIndex);

  /// Total number of rows spanned by the selection.
  int get rowCount => (endRow - startRow) + 1;

  /// Total number of columns spanned by the selection.
  int get columnCount => (endColumn - startColumn) + 1;

  /// Total number of cells contained in this rectangular selection.
  int get cellCount => rowCount * columnCount;

  /// Returns `true` if `(rowIndex, columnIndex)` lies within this range.
  bool contains(int rowIndex, int columnIndex) {
    return rowIndex >= startRow &&
        rowIndex <= endRow &&
        columnIndex >= startColumn &&
        columnIndex <= endColumn;
  }

  /// Returns a new [CellRange] with an updated [focus] coordinate.
  CellRange copyWithFocus(CellCoordinate newFocus) {
    return CellRange(anchor: anchor, focus: newFocus);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellRange && other.anchor == anchor && other.focus == focus;

  @override
  int get hashCode => Object.hash(anchor, focus);
}
