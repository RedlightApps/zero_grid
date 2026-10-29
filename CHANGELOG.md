## 1.0.0

- **Initial Stable Release of `zero_grid` by RedLight Apps (`https://redlightapps.com`).**
- **2D Virtualized Viewport (`VirtualViewport2D`):** $O(1)$ visible row and column span calculation supporting 1,000,000+ rows and 100+ columns at 120Hz with zero off-screen widget allocation.
- **Left & Right Column Freezing (`FreezePosition`):** Pin key columns to the left or right edge while scrolling middle columns smoothly with synchronized vertical scrolling.
- **Background Isolate Sorting & Filtering (`IsolateGridEngine`):** Non-blocking multi-column sorting and full-text predicate filtering powered by `Isolate.run`.
- **Excel-Style Marquee Range Selection & TSV Clipboard (`CellRange`, `ClipboardTsvCodec`):** Drag or Shift-click to select rectangular cell regions and copy/paste directly to Excel or Google Sheets (`Ctrl+C` / `Cmd+C`).
- **Interactive Column Resizing & Pinned Summary Footer (`ZeroDataGrid`, `ZeroGridController`):** Live drag handles for column widths and sticky summary aggregation rows (`SUM`, `AVG`, `MIN`, `MAX`, custom builders).
