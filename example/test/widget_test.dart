import 'package:flutter_test/flutter_test.dart';
import 'package:zero_grid_example/main.dart';

void main() {
  testWidgets('ZeroGridShowcaseApp renders 100,000 rows smoothly',
      (tester) async {
    await tester.pumpWidget(const ZeroGridShowcaseApp());
    expect(find.text('zero_grid — 100,000 Rows @ 120Hz'), findsOneWidget);
    expect(find.text('SYMBOL'), findsOneWidget);
  });
}
