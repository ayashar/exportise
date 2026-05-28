import 'package:flutter_test/flutter_test.dart';

import 'package:exportise/main.dart';

void main() {
  testWidgets('Onboarding flow appears before auth', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Exportise'), findsOneWidget);

    await _finishSplash(tester);

    expect(
      find.text('Produkmu bisa laku di\nAmerika, Eropa, Jepang'),
      findsOneWidget,
    );
    expect(find.text('Selanjutnya'), findsOneWidget);

    await tester.ensureVisible(find.text('Selanjutnya'));
    await tester.tap(find.text('Selanjutnya'));
    await tester.pumpAndSettle();

    expect(find.text('Cerita dulu tentang\nprodukmu'), findsOneWidget);
    expect(find.text('Belum Pernah'), findsOneWidget);
  });

  testWidgets('Login and register screens render auth flow', (
    WidgetTester tester,
  ) async {
    await _openLogin(tester);

    expect(find.text('Selamat Datang!'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);

    await tester.ensureVisible(find.text('Daftar di sini'));
    await tester.tap(find.text('Daftar di sini'));
    await tester.pumpAndSettle();

    expect(find.text('Mulai Ekspor Sekarang'), findsOneWidget);
    expect(find.text('Nama Lengkap'), findsOneWidget);

    await tester.ensureVisible(find.text('Selanjutnya'));
    await tester.tap(find.text('Selanjutnya'));
    await tester.pumpAndSettle();

    expect(find.text('Nama UMKM'), findsOneWidget);
    expect(find.text('Daftar'), findsOneWidget);
  });
}

Future<void> _openLogin(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await _finishSplash(tester);
  await tester.ensureVisible(find.text('Lewati'));
  await tester.tap(find.text('Lewati'));
  await tester.pumpAndSettle();
}

Future<void> _finishSplash(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 3200));
  await tester.pumpAndSettle();
}
