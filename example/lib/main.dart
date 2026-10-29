import 'package:flutter/material.dart';
import 'package:zero_grid/zero_grid.dart';

void main() => runApp(const ZeroGridShowcaseApp());

/// Financial market row model demonstrated inside the `zero_grid` showcase.
class MarketOrderRow {
  /// Creates a [MarketOrderRow].
  const MarketOrderRow({
    required this.orderId,
    required this.ticker,
    required this.venue,
    required this.price,
    required this.quantity,
    required this.notionalUsd,
  });

  /// Order sequence ID.
  final int orderId;

  /// Instrument symbol.
  final String ticker;

  /// Execution exchange venue.
  final String venue;

  /// Execution price.
  final double price;

  /// Filled quantity.
  final int quantity;

  /// Total notional USD value.
  final double notionalUsd;
}

/// Showcase application demonstrating 100,000 rows with frozen left/right panes.
class ZeroGridShowcaseApp extends StatefulWidget {
  /// Creates a [ZeroGridShowcaseApp].
  const ZeroGridShowcaseApp({super.key});

  @override
  State<ZeroGridShowcaseApp> createState() => _ZeroGridShowcaseAppState();
}

class _ZeroGridShowcaseAppState extends State<ZeroGridShowcaseApp> {
  late final ZeroGridController<MarketOrderRow> _controller;

  static const _tickers = ['BTC-PERP', 'ETH-PERP', 'SOL-PERP', 'NVDA', 'AAPL'];
  static const _venues = ['BINANCE', 'COINBASE', 'NASDAQ', 'KRAKEN'];

  @override
  void initState() {
    super.initState();
    final rows = List<MarketOrderRow>.generate(100000, (i) {
      final px = 100.0 + (i % 900) * 1.25;
      final qty = 1 + (i % 50);
      return MarketOrderRow(
        orderId: i + 1,
        ticker: _tickers[i % _tickers.length],
        venue: _venues[i % _venues.length],
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
          width: 110,
          freeze: FreezePosition.left,
          valueGetter: (r) => r.orderId,
        ),
        ZeroGridColumn(
          id: 'ticker',
          title: 'SYMBOL',
          width: 130,
          valueGetter: (r) => r.ticker,
        ),
        ZeroGridColumn(
          id: 'venue',
          title: 'VENUE',
          width: 140,
          valueGetter: (r) => r.venue,
        ),
        ZeroGridColumn(
          id: 'price',
          title: 'PRICE (\$)',
          width: 130,
          alignment: Alignment.centerRight,
          aggregation: GridAggregation.average,
          valueGetter: (r) => r.price,
          formatter: (v) => (v as double).toStringAsFixed(2),
        ),
        ZeroGridColumn(
          id: 'qty',
          title: 'QTY',
          width: 110,
          alignment: Alignment.centerRight,
          aggregation: GridAggregation.sum,
          valueGetter: (r) => r.quantity,
        ),
        ZeroGridColumn(
          id: 'notional',
          title: 'NOTIONAL (\$)',
          width: 150,
          freeze: FreezePosition.right,
          alignment: Alignment.centerRight,
          aggregation: GridAggregation.sum,
          valueGetter: (r) => r.notionalUsd,
          formatter: (v) => (v as double).toStringAsFixed(2),
        ),
      ],
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
          title: const Text('zero_grid — 100,000 Rows @ 120Hz'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: TextField(
                onChanged: _controller.setFilterQuery,
                decoration: const InputDecoration(
                  hintText: ZeroGridDict.searchPlaceholder,
                  prefixIcon: Icon(Icons.search, size: 18),
                  isDense: true,
                  filled: true,
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
