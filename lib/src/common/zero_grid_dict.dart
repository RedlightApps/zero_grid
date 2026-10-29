/// Centralized UI and accessibility string dictionary for `zero_grid`.
///
/// Prevents hard-coded string literals inside widgets and allows host
/// applications to localize every label or tooltip.
abstract final class ZeroGridDict {
  /// Default placeholder when no rows match the active filter.
  static const String emptyGridLabel = 'No matching records found';

  /// Tooltip for ascending sort indicator.
  static const String sortAscendingHint = 'Sorted ascending';

  /// Tooltip for descending sort indicator.
  static const String sortDescendingHint = 'Sorted descending';

  /// Accessibility label for column width resize handle.
  static const String resizeColumnHint = 'Drag to resize column';

  /// Default label for the pinned footer summary row.
  static const String summaryTotalLabel = 'TOTAL';

  /// Status notification text when cells are copied to the clipboard.
  static const String copiedCellsNotification = 'Copied selection to clipboard';

  /// Default search placeholder for grid filter bars.
  static const String searchPlaceholder = 'Filter rows...';
}
