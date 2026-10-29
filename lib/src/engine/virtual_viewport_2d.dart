import 'dart:math' as math;

/// Immutable 2D visible index window computed by [VirtualViewport2D].
class VisibleSpan2D {
  /// Creates a [VisibleSpan2D].
  const VisibleSpan2D({
    required this.firstRow,
    required this.lastRow,
    required this.firstColumn,
    required this.lastColumn,
    required this.columnOffsets,
    required this.totalContentWidth,
    required this.totalContentHeight,
  });

  /// Inclusive first visible row index (including overscan buffer).
  final int firstRow;

  /// Inclusive last visible row index (including overscan buffer).
  final int lastRow;

  /// Inclusive first visible scrollable column index.
  final int firstColumn;

  /// Inclusive last visible scrollable column index.
  final int lastColumn;

  /// Cumulative horizontal x-offset for each scrollable column index.
  final List<double> columnOffsets;

  /// Total scrollable width across all center columns.
  final double totalContentWidth;

  /// Total scrollable height across all rows.
  final double totalContentHeight;

  /// Whether there are any visible rows and columns to render.
  bool get isEmpty => lastRow < firstRow || lastColumn < firstColumn;

  /// Number of materialized rows in the current frame.
  int get visibleRowCount => isEmpty ? 0 : (lastRow - firstRow) + 1;

  /// Number of materialized center columns in the current frame.
  int get visibleColumnCount => isEmpty ? 0 : (lastColumn - firstColumn) + 1;
}

/// High-speed 2D virtualization solver that computes the exact visible row and
/// column window in $O(1)$ vertical time and $O(\log M)$ horizontal binary
/// search time.
///
/// Guarantees that a 1,000,000-row x 100-column dataset only builds the ~25x8
/// cells currently inside the viewport.
abstract final class VirtualViewport2D {
  /// Computes the [VisibleSpan2D] for the given scroll offsets and dimensions.
  static VisibleSpan2D compute({
    required int totalRows,
    required double rowHeight,
    required List<double> columnWidths,
    required double scrollOffsetX,
    required double scrollOffsetY,
    required double viewportWidth,
    required double viewportHeight,
    int overscanRows = 3,
    int overscanColumns = 2,
  }) {
    final safeRowHeight = math.max(1.0, rowHeight);
    final totalHeight = totalRows * safeRowHeight;
    final colCount = columnWidths.length;
    final offsets = List<double>.filled(colCount, 0.0);
    var runningWidth = 0.0;
    for (var i = 0; i < colCount; i++) {
      offsets[i] = runningWidth;
      runningWidth += math.max(1.0, columnWidths[i]);
    }

    if (totalRows <= 0 || colCount <= 0) {
      return VisibleSpan2D(
        firstRow: 0,
        lastRow: -1,
        firstColumn: 0,
        lastColumn: -1,
        columnOffsets: offsets,
        totalContentWidth: runningWidth,
        totalContentHeight: totalHeight,
      );
    }

    final clampedY =
        scrollOffsetY.clamp(0.0, math.max(0.0, totalHeight)).toDouble();
    final rawFirstRow = (clampedY / safeRowHeight).floor() - overscanRows;
    final rawLastRow =
        ((clampedY + math.max(1.0, viewportHeight)) / safeRowHeight).ceil() +
            overscanRows;

    final firstRow = rawFirstRow.clamp(0, totalRows - 1);
    final lastRow = rawLastRow.clamp(0, totalRows - 1);

    final clampedX =
        scrollOffsetX.clamp(0.0, math.max(0.0, runningWidth)).toDouble();
    final maxVisibleX = clampedX + math.max(1.0, viewportWidth);

    var firstCol = _binarySearchColumn(offsets, columnWidths, clampedX);
    var lastCol = _binarySearchColumn(offsets, columnWidths, maxVisibleX);

    firstCol = (firstCol - overscanColumns).clamp(0, colCount - 1);
    lastCol = (lastCol + overscanColumns).clamp(0, colCount - 1);

    return VisibleSpan2D(
      firstRow: firstRow,
      lastRow: lastRow,
      firstColumn: firstCol,
      lastColumn: lastCol,
      columnOffsets: offsets,
      totalContentWidth: runningWidth,
      totalContentHeight: totalHeight,
    );
  }

  static int _binarySearchColumn(
    List<double> offsets,
    List<double> widths,
    double targetX,
  ) {
    var low = 0;
    var high = offsets.length - 1;
    while (low <= high) {
      final mid = (low + high) >> 1;
      final start = offsets[mid];
      final end = start + widths[mid];
      if (targetX < start) {
        high = mid - 1;
      } else if (targetX > end) {
        low = mid + 1;
      } else {
        return mid;
      }
    }
    return low.clamp(0, offsets.length - 1);
  }
}
