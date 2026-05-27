import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eksportise_frontend/core/iconography/app_icons.dart';
import 'package:eksportise_frontend/main.dart';

void main() {
  testWidgets('Home page smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Halo! Arunika Tas'), findsOneWidget);
    expect(find.text('Level Eksportir Pemula'), findsOneWidget);
    expect(find.text('Analisis Terakhir'), findsOneWidget);
  });

  testWidgets('Analysis flow smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Analisis sekarang'));
    await tester.pumpAndSettle();

    expect(find.text('Analisis Kesiapan Ekspor'), findsOneWidget);

    await tester.ensureVisible(find.text('Analisis Market'));
    await tester.tap(find.text('Analisis Market'));
    await tester.pumpAndSettle();

    expect(find.text('Hasil Analisis'), findsOneWidget);
    expect(find.text('Tas Anyaman Bali'), findsOneWidget);

    await tester.ensureVisible(find.text('Referensi Desain'));
    await tester.tap(find.text('Referensi Desain'));
    await tester.pumpAndSettle();

    expect(find.text('Tas Anyaman'), findsOneWidget);
    expect(find.text('Variasi A'), findsOneWidget);
  });

  testWidgets('Analysis details accordion toggles content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Analisis sekarang'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Analisis Market'));
    await tester.tap(find.text('Analisis Market'));
    await tester.pumpAndSettle();

    expect(find.text('Analisis Sentimen'), findsOneWidget);

    await tester.ensureVisible(find.text('Rincian Analisis'));
    await tester.tap(find.text('Rincian Analisis'));
    await tester.pumpAndSettle();

    expect(find.text('Analisis Sentimen'), findsNothing);

    await tester.tap(find.text('Rincian Analisis'));
    await tester.pumpAndSettle();

    expect(find.text('Analisis Sentimen'), findsOneWidget);
  });

  testWidgets('History page shows downloadable reference and result tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Laporanku'));
    await tester.pumpAndSettle();

    expect(find.text('Referensi'), findsOneWidget);
    expect(find.text('Variasi A'), findsOneWidget);
    expect(find.text('Unduh'), findsWidgets);

    await tester.tap(find.text('Hasil'));
    await tester.pumpAndSettle();

    expect(find.text('The Manhattan Circle'), findsOneWidget);
    expect(find.text('Unduh JPG'), findsOneWidget);
  });

  testWidgets('Header profile and notification navigation works', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Arunika Tas').first);
    await tester.pumpAndSettle();

    expect(find.text('Informasi Akun'), findsOneWidget);
    expect(find.text('Informasi UMKM'), findsOneWidget);

    await tester.tap(find.text('Ubah Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Konfirmasi Password'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);

    Navigator.of(tester.element(find.text('Informasi Akun'))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(AppIcons.bell()).first);
    await tester.pumpAndSettle();

    expect(find.text('Hari ini'), findsOneWidget);
    expect(find.text('Laporan Tas Anyaman\nAmerika Serikat'), findsWidgets);
    expect(find.text('Unduh PDF'), findsWidgets);
  });

  testWidgets('BrainS bottom nav opens fresh BrainStudio conversation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('BrainS'));
    await tester.pumpAndSettle();

    expect(find.text('BrainStudio'), findsWidgets);
    expect(find.textContaining('Saya ingin mendesain koleksi'), findsOneWidget);
    expect(find.text('Eco-Utility Essential'), findsWidgets);
  });

  testWidgets('Design reference discussion opens contextual chatbot', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Analisis sekarang'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Analisis Market'));
    await tester.tap(find.text('Analisis Market'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Referensi Desain'));
    await tester.tap(find.text('Referensi Desain'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Diskusi').first);
    await tester.tap(find.text('Diskusi').first);
    await tester.pumpAndSettle();

    expect(find.text('BrainStudio'), findsWidgets);
    expect(find.textContaining('Hai Arunika Tas'), findsOneWidget);
    expect(find.text('The Manhattan\nCircle'), findsOneWidget);
  });
}
