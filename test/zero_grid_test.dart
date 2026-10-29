import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zero_grid/zero_grid.dart';

class _TradeRecord {
  const _TradeRecord({
    required this.id,
    required this.symbol,
    required this.price,
    required this.volume,
  });

  final int id;
  final String symbol;
  final double price;
  final int volume;
}

void main() {
  group('VirtualViewport2D 1,000,000-row tests', () {
    test('computes O(1) visible row & column window for 1M x 100 grid', () {
      final widths = List<double>.filled(100, 120.0);
      final span = VirtualViewport2D.compute(
        totalRows: 1000000,
        rowHeight: 40.0,
        columnWidths: widths,
        scrollOffsetX: 2400.0,
        scrollOffsetY: 500000 * 40.0,
        viewportWidth: 600.0,
        viewportHeight: 400.0,
        overscanRows: 2,
        overscanColumns: 1,
      );

      expect(span.totalContentHeight, 40000000.0);
      expect(span.totalContentWidth, 12000.0);
      expect(span.firstRow, 499998);
      expect(span.lastRow, 500012);
      expect(span.visibleRowCount, lessThanOrEqualTo(16));
      expect(span.visibleColumnCount, lessThanOrEqualTo(9));
    });
  });

  group('IsolateGridEngine & TSV Clipboard tests', () {
    test('sorts and filters large datasets via background Isolate', () async {
      final keys = List<int>.generate(2500, (i) => 2500 - i);
      final ascOrder = await IsolateGridEngine.sortIndices(
        extractedKeys: keys,
        direction: SortDirection.ascending,
        isolateThreshold: 500,
      );
      expect(keys[ascOrder.first], 1);
      expect(keys[ascOrder.last], 2500);

      final rows = List<List<String>>.generate(
        2500,
        (i) => ['ID-$i', i.isEven ? 'BTC-USD' : 'ETH-USD'],
      );
      final filtered = await IsolateGridEngine.filterIndicesByQuery(
        rowStrings: rows,
        query: 'btc-usd',
        isolateThreshold: 500,
      );
      expect(filtered.length, 1250);
    });

    test('encodes and decodes Excel-compatible TSV ranges', () {
      const items = [
        _TradeRecord(id: 1, symbol: 'BTC', price: 68500.5, volume: 10),
        _TradeRecord(id: 2, symbol: 'ETH', price: 3450.25, volume: 40),
      ];
      final cols = <ZeroGridColumn<_TradeRecord>>[
        ZeroGridColumn(id: 'id', title: 'ID', valueGetter: (r) => r.id),
        ZeroGridColumn(id: 'sym', title: 'Symbol', valueGetter: (r) => r.symbol),
        ZeroGridColumn(id: 'px', title: 'Price', valueGetter: (r) => r.price),
      ];

      const range = CellRange(
        anchor: CellCoordinate(rowIndex: 0, columnIndex: 0),
        focus: CellCoordinate(rowIndex: 1, columnIndex: 2),
      );
      final tsv = IsolateGridEngine.encodeRangeToTsv(
        visibleItems: items,
        columns: cols,
        range: range,
        includeHeaders: true,
      );
      final matrix = IsolateGridEngine.decodeTsv(tsv);
      expect(matrix.length, 3);
      expect(matrix[0], ['ID', 'Symbol', 'Price']);
      expect(matrix[1], ['1', 'BTC', '68500.5']);
      expect(matrix[2], ['2', 'ETH', '3450.25']);
    });
  });

  group('ZeroDataGrid widget & freeze pane tests', () {
    testWidgets('renders frozen left/right columns, sorts, and selects cells',
        (tester) async {
      final rows = List<_TradeRecord>.generate(
        100,
        (i) => _TradeRecord(
          id: i + 1,
          symbol: i.isEven ? 'SOL' : 'AVAX',
          price: (i + 1) * 10.0,
          volume: (i + 1) * 5,
        ),
      );
      final controller = ZeroGridController<_TradeRecord>(
        rows: rows,
        columns: [
          ZeroGridColumn(
            id: 'id',
            title: 'ID',
            width: 80,
            freeze: FreezePosition.left,
            valueGetter: (r) => r.id,
          ),
          ZeroGridColumn(
            id: 'symbol',
            title: 'Symbol',
            width: 120,
            valueGetter: (r) => r.symbol,
          ),
          ZeroGridColumn(
            id: 'volume',
            title: 'Volume',
            width: 120,
            freeze: FreezePosition.right,
            aggregation: GridAggregation.sum,
            valueGetter: (r) => r.volume,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 400,
              child: ZeroDataGrid<_TradeRecord>(controller: controller),
            ),
          ),
        ),
      );

      expect(find.text('Symbol'), findsOneWidget);
      expect(find.text('SOL'), findsWidgets);

      await tester.tap(find.text('SOL').first);
      await tester.pump();
      expect(controller.selection, isNotNull);

      await controller.toggleSort('id');
      await controller.toggleSort('id');
      await tester.pumpAndSettle();
      expect(controller.visibleRows.first.id, 100);
    });
  });
}
