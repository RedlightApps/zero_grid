import 'dart:isolate';
import 'package:zero_grid/src/model/grid_column.dart';
import 'package:zero_grid/src/model/grid_selection.dart';

/// Background `Isolate` execution engine for non-blocking sorting, filtering,
/// numeric aggregation, and Excel TSV/CSV clipboard serialization.
abstract final class IsolateGridEngine {
  /// Minimum row count threshold above which sorting/filtering automatically
  /// spawns a background [Isolate].
  static const int defaultIsolateThreshold = 2000;

  /// Sorts row indices based on extracted column keys without mutating the
  /// original list, offloading to [Isolate.run] for large datasets.
  static Future<List<int>> sortIndices({
    required List<Object?> extractedKeys,
    required SortDirection direction,
    int isolateThreshold = defaultIsolateThreshold,
  }) async {
    final count = extractedKeys.length;
    if (direction == SortDirection.none || count <= 1) {
      return List<int>.generate(count, (i) => i);
    }
    if (count < isolateThreshold) {
      return _sortIndicesSync(extractedKeys, direction);
    }
    return Isolate.run(() => _sortIndicesSync(extractedKeys, direction));
  }

  /// Filters row indices where any column string representation contains
  /// [query] (case-insensitive), running on a background [Isolate] for large
  /// datasets.
  static Future<List<int>> filterIndicesByQuery({
    required List<List<String>> rowStrings,
    required String query,
    int isolateThreshold = defaultIsolateThreshold,
  }) async {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return List<int>.generate(rowStrings.length, (i) => i);
    }
    if (rowStrings.length < isolateThreshold) {
      return _filterSync(rowStrings, trimmed);
    }
    return Isolate.run(() => _filterSync(rowStrings, trimmed));
  }

  /// Serializes a rectangular [CellRange] into Tab-Separated Values (TSV)
  /// compatible with Microsoft Excel, Apple Numbers, and Google Sheets.
  static String encodeRangeToTsv<T>({
    required List<T> visibleItems,
    required List<ZeroGridColumn<T>> columns,
    required CellRange range,
    bool includeHeaders = false,
  }) {
    if (visibleItems.isEmpty || columns.isEmpty) return '';
    final startRow = range.startRow.clamp(0, visibleItems.length - 1);
    final endRow = range.endRow.clamp(0, visibleItems.length - 1);
    final startCol = range.startColumn.clamp(0, columns.length - 1);
    final endCol = range.endColumn.clamp(0, columns.length - 1);

    final buffer = StringBuffer();
    if (includeHeaders) {
      for (var c = startCol; c <= endCol; c++) {
        if (c > startCol) buffer.write('\t');
        buffer.write(_sanitizeTsvCell(columns[c].title));
      }
      buffer.writeln();
    }

    for (var r = startRow; r <= endRow; r++) {
      final item = visibleItems[r];
      for (var c = startCol; c <= endCol; c++) {
        if (c > startCol) buffer.write('\t');
        buffer.write(_sanitizeTsvCell(columns[c].formatValue(item)));
      }
      if (r < endRow) buffer.writeln();
    }
    return buffer.toString();
  }

  /// Parses a TSV string from the system clipboard into a 2D matrix of strings.
  static List<List<String>> decodeTsv(String tsv) {
    if (tsv.trim().isEmpty) return const [];
    final normalized = tsv.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    return normalized
        .split('\n')
        .where((line) => line.isNotEmpty)
        .map((line) => line.split('\t'))
        .toList(growable: false);
  }

  /// Computes a built-in numeric summary aggregation for [column].
  static String computeAggregation<T>(
    ZeroGridColumn<T> column,
    List<T> visibleItems,
  ) {
    if (column.footerBuilder != null) {
      return column.footerBuilder!(visibleItems);
    }
    if (column.aggregation == GridAggregation.none) return '';
    if (column.aggregation == GridAggregation.count) {
      return '${visibleItems.length}';
    }
    var sum = 0.0;
    var minVal = double.infinity;
    var maxVal = double.negativeInfinity;
    var numericCount = 0;
    for (final item in visibleItems) {
      final v = column.valueGetter(item);
      if (v is num) {
        final d = v.toDouble();
        sum += d;
        if (d < minVal) minVal = d;
        if (d > maxVal) maxVal = d;
        numericCount++;
      }
    }
    if (numericCount == 0) return '-';
    return switch (column.aggregation) {
      GridAggregation.sum => _formatNum(sum),
      GridAggregation.average => _formatNum(sum / numericCount),
      GridAggregation.min => _formatNum(minVal),
      GridAggregation.max => _formatNum(maxVal),
      GridAggregation.count || GridAggregation.none => '',
    };
  }

  static String _formatNum(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  static String _sanitizeTsvCell(String value) =>
      value.replaceAll('\t', ' ').replaceAll('\n', ' ');

  static List<int> _sortIndicesSync(
    List<Object?> keys,
    SortDirection direction,
  ) {
    final indices = List<int>.generate(keys.length, (i) => i);
    final sign = direction == SortDirection.ascending ? 1 : -1;
    indices.sort((a, b) => sign * _compareValues(keys[a], keys[b]));
    return indices;
  }

  static int _compareValues(Object? a, Object? b) {
    if (identical(a, b)) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    if (a is num && b is num) return a.compareTo(b);
    if (a is Comparable<Object> && a.runtimeType == b.runtimeType) {
      return a.compareTo(b);
    }
    return a.toString().compareTo(b.toString());
  }

  static List<int> _filterSync(List<List<String>> rows, String lowerQuery) {
    final matched = <int>[];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      for (var c = 0; c < row.length; c++) {
        if (row[c].toLowerCase().contains(lowerQuery)) {
          matched.add(i);
          break;
        }
      }
    }
    return matched;
  }
}
