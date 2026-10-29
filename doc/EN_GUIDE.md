# `zero_grid` — English Developer Guide

## 1. Overview
`zero_grid` is a 120Hz 2D-virtualized DataGrid and Spreadsheet engine for Flutter engineered by **RedLight Apps** (`https://redlightapps.com`) with zero external dependencies.

## 2. Key Capabilities
- **1,000,000+ Rows (`VirtualViewport2D`):** $O(1)$ vertical and $O(\log M)$ horizontal virtualization.
- **Frozen Columns (`FreezePosition`):** Pin columns to the left or right viewport boundary.
- **Non-Blocking Isolate Sorting & Filtering (`IsolateGridEngine`):** Offloads heavy dataset operations to `Isolate.run`.
- **Excel TSV Clipboard (`CellRange`):** Press `Ctrl+C` or `Cmd+C` to copy selected cells directly into Excel or Google Sheets.
- **Sticky Aggregation Footer (`GridAggregation`):** Built-in `sum`, `average`, `min`, `max`, and `count` footers.
