import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:zero_grid/src/engine/isolate_grid_engine.dart';
import 'package:zero_grid/src/model/grid_column.dart';
import 'package:zero_grid/src/model/grid_selection.dart';

/// Reactive controller managing rows, columns, sorting, filtering, column
/// widths, and marquee cell selection for `ZeroDataGrid<T>`.
class ZeroGridController<T> extends ChangeNotifier {
  /// Creates a [ZeroGridController] with initial [rows] and [columns].
  ZeroGridController({
    required List<T> rows,
    required List<ZeroGridColumn<T>> columns,
    this.isolateThreshold = IsolateGridEngine.defaultIsolateThreshold,
  })  : _rawRows = List<T>.unmodifiable(rows),
        _columns = List<ZeroGridColumn<T>>.unmodifiable(columns) {
    _visibleRows = _rawRows;
    for (final col in _columns) {
      _columnWidths[col.id] = col.width;
    }
  }

  List<T> _rawRows;
  List<T> _visibleRows = const [];
  final List<ZeroGridColumn<T>> _columns;
  final Map<String, double> _columnWidths = <String, double>{};

  String? _sortedColumnId;
  SortDirection _sortDirection = SortDirection.none;
  String _searchQuery = '';
  bool _isProcessing = false;
  CellRange? _selection;

  /// Row count above which sorting and filtering run inside a background
  /// `Isolate`.
  final int isolateThreshold;

  /// Unfiltered original rows.
  List<T> get rawRows => _rawRows;

  /// Currently visible rows after filtering and sorting.
  List<T> get visibleRows => _visibleRows;

  /// Active column definitions.
  List<ZeroGridColumn<T>> get columns => _columns;

  /// ID of the currently sorted column, if any.
  String? get sortedColumnId => _sortedColumnId;

  /// Active sort direction.
  SortDirection get sortDirection => _sortDirection;

  /// Active search/filter query.
  String get searchQuery => _searchQuery;

  /// Whether a background `Isolate` sort or filter operation is running.
  bool get isProcessing => _isProcessing;

  /// Current rectangular cell selection range, if any.
  CellRange? get selection => _selection;

  /// Returns the current width in logical pixels for [column].
  double widthOf(ZeroGridColumn<T> column) =>
      _columnWidths[column.id] ?? column.width;

  /// Updates the width of the column identified by [columnId], clamping to its
  /// configured `minWidth` and `maxWidth`.
  void resizeColumn(String columnId, double newWidth) {
    final idx = _columns.indexWhere((c) => c.id == columnId);
    if (idx < 0) return;
    final col = _columns[idx];
    if (!col.resizable) return;
    final clamped = newWidth.clamp(col.minWidth, col.maxWidth);
    if (_columnWidths[columnId] == clamped) return;
    _columnWidths[columnId] = clamped;
    notifyListeners();
  }

  /// Replaces the dataset with [newRows] and reapplies active filter/sort.
  Future<void> setRows(List<T> newRows) async {
    _rawRows = List<T>.unmodifiable(newRows);
    await _recomputeVisibleRows();
  }

  /// Cycles sort order (`none -> ascending -> descending -> none`) for
  /// [columnId].
  Future<void> toggleSort(String columnId) async {
    final idx = _columns.indexWhere((c) => c.id == columnId);
    if (idx < 0 || !_columns[idx].sortable) return;

    if (_sortedColumnId != columnId) {
      _sortedColumnId = columnId;
      _sortDirection = SortDirection.ascending;
    } else {
      _sortDirection = switch (_sortDirection) {
        SortDirection.none => SortDirection.ascending,
        SortDirection.ascending => SortDirection.descending,
        SortDirection.descending => SortDirection.none,
      };
      if (_sortDirection == SortDirection.none) {
        _sortedColumnId = null;
      }
    }
    await _recomputeVisibleRows();
  }

  /// Filters rows across all columns using a case-insensitive [query].
  Future<void> setFilterQuery(String query) async {
    if (_searchQuery == query) return;
    _searchQuery = query;
    await _recomputeVisibleRows();
  }

  /// Starts or updates the rectangular cell selection.
  void selectCell(CellCoordinate coordinate, {bool extendSelection = false}) {
    if (extendSelection && _selection != null) {
      _selection = _selection!.copyWithFocus(coordinate);
    } else {
      _selection = CellRange.single(coordinate);
    }
    notifyListeners();
  }

  /// Explicitly sets the active [CellRange] selection.
  void setSelectionRange(CellRange? range) {
    if (_selection == range) return;
    _selection = range;
    notifyListeners();
  }

  /// Copies the currently selected [CellRange] to the system clipboard in
  /// Excel-compatible TSV format and returns the serialized string.
  Future<String> copySelectionToClipboard({bool includeHeaders = false}) async {
    final activeRange = _selection;
    if (activeRange == null || _visibleRows.isEmpty) return '';
    final tsv = IsolateGridEngine.encodeRangeToTsv(
      visibleItems: _visibleRows,
      columns: _columns,
      range: activeRange,
      includeHeaders: includeHeaders,
    );
    if (tsv.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: tsv));
    }
    return tsv;
  }

  Future<void> _recomputeVisibleRows() async {
    _isProcessing = true;
    notifyListeners();

    var working = _rawRows;
    if (_searchQuery.trim().isNotEmpty) {
      final matrix = working
          .map((item) => _columns.map((c) => c.formatValue(item)).toList())
          .toList(growable: false);
      final matched = await IsolateGridEngine.filterIndicesByQuery(
        rowStrings: matrix,
        query: _searchQuery,
        isolateThreshold: isolateThreshold,
      );
      working = matched.map((i) => working[i]).toList(growable: false);
    }

    if (_sortedColumnId != null && _sortDirection != SortDirection.none) {
      final colIdx = _columns.indexWhere((c) => c.id == _sortedColumnId);
      if (colIdx >= 0) {
        final col = _columns[colIdx];
        final keys =
            working.map((item) => col.valueGetter(item)).toList(growable: false);
        final order = await IsolateGridEngine.sortIndices(
          extractedKeys: keys,
          direction: _sortDirection,
          isolateThreshold: isolateThreshold,
        );
        working = order.map((i) => working[i]).toList(growable: false);
      }
    }

    _visibleRows = working;
    _isProcessing = false;
    notifyListeners();
  }
}
