import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kura_ai/features/home/presentation/home_screen.dart';
import 'package:kura_ai/main.dart';

void main() {
  testWidgets('App smoke test - renders Kura splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KuraAiApp(),
      ),
    );
    await tester.pump();

    // Verify key titles on Splash Screen
    expect(find.text('Kura'), findsWidgets);
    expect(find.text('Asisten Makanan Cerdas & Berkelanjutan'), findsOneWidget);
    expect(find.text('v1.0.0'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('HomeScreen renders correctly with KuraGlobalAppBar and main sections', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pump();

    // Verify key titles on Home Screen
    expect(find.text('Kura'), findsWidgets);
    expect(find.text('Fitur Utama'), findsOneWidget);
    expect(find.text('Food Check'), findsWidgets);
    expect(find.text('Zero Waste Food'), findsOneWidget);
  });
}
