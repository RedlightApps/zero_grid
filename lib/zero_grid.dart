/// 120Hz 2D-Virtualized DataGrid & Spreadsheet Engine for Flutter.
///
/// Built by RedLight Apps (https://redlightapps.com) with zero external
/// dependencies:
/// - **2D Virtualization ([VirtualViewport2D]):** Renders 1,000,000+ rows and
///   100+ columns at 120Hz with $O(1)$ vertical and $O(\log M)$ horizontal
///   windowing.
/// - **Column Freezing ([FreezePosition]):** Pin columns to the left or right
///   edge while scrolling center columns smoothly.
/// - **Background Isolate Engine ([IsolateGridEngine]):** Non-blocking sorting,
///   full-text filtering, numeric footer aggregations, and Excel TSV clipboard
///   codec.
/// - **Interactive DataGrid ([ZeroDataGrid], [ZeroGridController]):** Marquee
///   cell range selection, live column resizing, and keyboard copy (`Ctrl+C`).
library;

export 'src/common/zero_grid_dict.dart';
export 'src/controller/zero_grid_controller.dart';
export 'src/engine/isolate_grid_engine.dart';
export 'src/engine/virtual_viewport_2d.dart';
export 'src/model/grid_column.dart';
export 'src/model/grid_selection.dart';
export 'src/view/grid_cell_tile.dart';
export 'src/view/grid_header_footer.dart';
export 'src/view/zero_data_grid.dart';
