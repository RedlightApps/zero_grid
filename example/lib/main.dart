import 'dart:async';
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
  final ScrollController _vScroll = ScrollController();
  final ScrollController _hScroll = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _tourTimer;
  int _step = 0;

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
          width: 90,
          freeze: FreezePosition.left,
          valueGetter: (r) => '#${r.orderId}',
        ),
        ZeroGridColumn(
          id: 'ticker',
          title: 'SYMBOL',
          width: 102,
          valueGetter: (r) => r.ticker,
        ),
        ZeroGridColumn(
          id: 'side',
          title: 'SIDE',
          width: 76,
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
          width: 102,
          alignment: Alignment.centerRight,
          aggregation: GridAggregation.average,
          valueGetter: (r) => r.price,
          formatter: (v) => (v as double).toStringAsFixed(2),
        ),
        ZeroGridColumn(
          id: 'qty',
          title: 'QTY',
          width: 82,
          alignment: Alignment.centerRight,
          aggregation: GridAggregation.sum,
          valueGetter: (r) => r.quantity,
        ),
        ZeroGridColumn(
          id: 'notional',
          title: 'TOTAL (\$)',
          width: 110,
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tourTimer = Timer.periodic(const Duration(milliseconds: 1050), (_) {
        if (mounted) _advanceTour();
      });
    });
  }

  void _advanceTour() {
    _step = (_step + 1) % 5;
    switch (_step) {
      case 0:
        _searchCtrl.text = '';
        _controller.setFilterQuery('');
        if (_vScroll.hasClients) {
          _vScroll.animateTo(0, duration: const Duration(milliseconds: 650), curve: Curves.easeOutCubic);
        }
        _controller.setSelectionRange(const CellRange(anchor: CellCoordinate(rowIndex: 1, columnIndex: 1), focus: CellCoordinate(rowIndex: 4, columnIndex: 3)));
      case 1:
        if (_vScroll.hasClients) {
          _vScroll.animateTo(920, duration: const Duration(milliseconds: 800), curve: Curves.easeInOutCubic);
        }
        _controller.setSelectionRange(const CellRange(anchor: CellCoordinate(rowIndex: 25, columnIndex: 1), focus: CellCoordinate(rowIndex: 30, columnIndex: 3)));
      case 2:
        if (_hScroll.hasClients) {
          _hScroll.animateTo(110, duration: const Duration(milliseconds: 700), curve: Curves.easeInOut);
        }
      case 3:
        if (_hScroll.hasClients) {
          _hScroll.animateTo(0, duration: const Duration(milliseconds: 600), curve: Curves.easeOut);
        }
        if (_vScroll.hasClients) {
          _vScroll.animateTo(0, duration: const Duration(milliseconds: 600), curve: Curves.easeOut);
        }
        _controller.toggleSort('price');
        _controller.setSelectionRange(const CellRange(anchor: CellCoordinate(rowIndex: 2, columnIndex: 2), focus: CellCoordinate(rowIndex: 7, columnIndex: 4)));
      case 4:
        _searchCtrl.text = 'BTC-PERP';
        _controller.setFilterQuery('BTC-PERP');
        _controller.setSelectionRange(const CellRange(anchor: CellCoordinate(rowIndex: 0, columnIndex: 1), focus: CellCoordinate(rowIndex: 3, columnIndex: 3)));
    }
  }

  @override
  void dispose() {
    _tourTimer?.cancel();
    _vScroll.dispose();
    _hScroll.dispose();
    _searchCtrl.dispose();
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
                controller: _searchCtrl,
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
        body: ZeroDataGrid<MarketOrderRow>(
          controller: _controller,
          verticalScrollController: _vScroll,
          horizontalScrollController: _hScroll,
        ),
      ),
    );
  }
}
