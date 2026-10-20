import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kura_ai/main.dart';

void main() {
  testWidgets('App smoke test - renders Kura AI home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KuraAiApp(),
      ),
    );
    await tester.pump();

    // Verify key titles on Home Screen
    expect(find.text('Kura AI'), findsWidgets);
    expect(find.text('Fitur Utama'), findsOneWidget);
    expect(find.text('Food Check'), findsWidgets);
    expect(find.text('Zero Waste Food'), findsOneWidget);
  });
}
