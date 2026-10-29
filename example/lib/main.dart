import 'package:flutter/material.dart';
import 'package:zero_grid/zero_grid.dart';

void main() => runApp(const ZeroGridShowcaseApp());

/// Financial market row model demonstrated inside the `zero_grid` showcase.
class MarketOrderRow {
  /// Creates a [MarketOrderRow].
  const MarketOrderRow({
    required this.orderId,
    required this.ticker,
    required this.side,
    required this.price,
    required this.quantity,
    required this.notionalUsd,
  });

  /// Order sequence ID.
  final int orderId;
  /// Instrument symbol.
  final String ticker;
  /// Order side (`BUY` or `SELL`).
  final String side;
  /// Execution price.
  final double price;
  /// Filled quantity.
  final int quantity;
  /// Total notional USD value.
  final double notionalUsd;
}

/// Showcase application demonstrating 100,000 rows with frozen left/right panes,
/// marquee selection, and pinned aggregations.
class ZeroGridShowcaseApp extends StatefulWidget {
  /// Creates a [ZeroGridShowcaseApp].
  const ZeroGridShowcaseApp({super.key});

  @override
  State<ZeroGridShowcaseApp> createState() => _ZeroGridShowcaseAppState();
}

class _ZeroGridShowcaseAppState extends State<ZeroGridShowcaseApp> {
  late final ZeroGridController<MarketOrderRow> _controller;
  static const _tickers = ['BTC-PERP', 'ETH-PERP', 'SOL-PERP', 'NVDA', 'AAPL'];

  @override
  void initState() {
    super.initState();
    final rows = List<MarketOrderRow>.generate(100000, (i) {
      final px = 142.50 + (i % 40) * 8.75;
      final qty = 10 + (i % 25) * 4;
      return MarketOrderRow(
        orderId: 1000 + i,
        ticker: _tickers[i % _tickers.length],
        side: i.isEven ? 'BUY' : 'SELL',
        price: px,
        quantity: qty,
        notionalUsd: px * qty,
      );
    });

    _controller = ZeroGridController<MarketOrderRow>(
      rows: rows,
      columns: [
        ZeroGridColumn(
          id: 'id',
          title: 'ORDER #',
          width: 92,
          freeze: FreezePosition.left,
          valueGetter: (r) => '#${r.orderId}',
        ),
        ZeroGridColumn(
          id: 'ticker',
          title: 'SYMBOL',
          width: 105,
          valueGetter: (r) => r.ticker,
        ),
        ZeroGridColumn(
          id: 'side',
          title: 'SIDE',
          width: 78,
          alignment: Alignment.center,
          valueGetter: (r) => r.side,
          cellBuilder: (ctx, rowIdx, item, val, isSelected) {
            final isBuy = item.side == 'BUY';
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isBuy ? const Color(0x2400E676) : const Color(0x24FF1744),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.side,
                style: TextStyle(
                  color: isBuy ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            );
          },
        ),
        ZeroGridColumn(
          id: 'price',
          title: 'PRICE (\$)',
          width: 104,
          alignment: Alignment.centerRight,
          aggregation: GridAggregation.average,
          valueGetter: (r) => r.price,
          formatter: (v) => (v as double).toStringAsFixed(2),
        ),
        ZeroGridColumn(
          id: 'notional',
          title: 'TOTAL (\$)',
          width: 112,
          freeze: FreezePosition.right,
          alignment: Alignment.centerRight,
          aggregation: GridAggregation.sum,
          valueGetter: (r) => r.notionalUsd,
          formatter: (v) {
            final d = (v as num).toDouble();
            if (d >= 1e9) return '\$${(d / 1e9).toStringAsFixed(2)}B';
            if (d >= 1e6) return '\$${(d / 1e6).toStringAsFixed(2)}M';
            return '\$${(d / 1e3).toStringAsFixed(1)}k';
          },
        ),
      ],
    )..setSelectionRange(
        const CellRange(
          anchor: CellCoordinate(rowIndex: 1, columnIndex: 1),
          focus: CellCoordinate(rowIndex: 4, columnIndex: 3),
        ),
      );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        backgroundColor: const Color(0xFF07090F),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F1422),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('zero_grid — 100,000 Rows @ 120Hz', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              Text('2D Virtualized • Frozen L/R Panes • Isolate Sort • TSV Copy', style: TextStyle(fontSize: 11, color: Color(0xFF38BDF8))),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: TextField(
                onChanged: _controller.setFilterQuery,
                decoration: InputDecoration(
                  hintText: ZeroGridDict.searchPlaceholder,
                  prefixIcon: const Icon(Icons.search, size: 18),
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFF161E31),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
        ),
        body: ZeroDataGrid<MarketOrderRow>(controller: _controller),
      ),
    );
  }
}
