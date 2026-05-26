import 'package:flutter_test/flutter_test.dart';

import 'package:eksportise_frontend/main.dart';

void main() {
  testWidgets('Home page smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Halo! Arunika Tas'), findsOneWidget);
    expect(find.text('Level Eksportir Pemula'), findsOneWidget);
    expect(find.text('Analisis Terakhir'), findsOneWidget);
  });
}
