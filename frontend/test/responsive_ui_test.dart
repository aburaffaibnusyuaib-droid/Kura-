import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kura_ai/features/home/presentation/home_screen.dart';
import 'package:kura_ai/features/food_check/presentation/screens/food_check_home_screen.dart';
import 'package:kura_ai/features/atur/presentation/screens/atur_intro_screen.dart';
import 'package:kura_ai/features/kura_chat/presentation/screens/kura_chat_screen.dart';
import 'package:kura_ai/features/food_check/presentation/screens/food_offline_screen.dart';
import 'package:kura_ai/features/auth/presentation/screens/welcome_screen.dart';
import 'package:kura_ai/core/theme/app_theme.dart';

void main() {
  const List<double> viewportWidths = [320, 360, 375, 390, 412, 432];
  const List<double> textScales = [1.0, 1.3, 1.5];

  group('Cross-Device Responsive UI & Viewport Validation', () {
    for (final width in viewportWidths) {
      testWidgets('HomeScreen renders with zero overflow at ${width}px width', (tester) async {
        tester.view.physicalSize = Size(width * 2, 800 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const HomeScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('FoodCheckHomeScreen renders with zero overflow at ${width}px width', (tester) async {
        tester.view.physicalSize = Size(width * 2, 800 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const FoodCheckHomeScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('AturIntroScreen renders with zero overflow at ${width}px width', (tester) async {
        tester.view.physicalSize = Size(width * 2, 800 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const AturIntroScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('KuraChatScreen renders with zero overflow at ${width}px width', (tester) async {
        tester.view.physicalSize = Size(width * 2, 800 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const KuraChatScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('FoodOfflineScreen renders with zero overflow at ${width}px width', (tester) async {
        tester.view.physicalSize = Size(width * 2, 800 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const FoodOfflineScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('WelcomeScreen renders with zero overflow at ${width}px width', (tester) async {
        tester.view.physicalSize = Size(width * 2, 800 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const WelcomeScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });
    }

    for (final scale in textScales) {
      testWidgets('HomeScreen handles large font scale $scale without overflow', (tester) async {
        tester.view.physicalSize = const Size(720, 1612); // Infinix Hot 30i physical
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: const HomeScreen(),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('FoodOfflineScreen handles large font scale $scale without overflow', (tester) async {
        tester.view.physicalSize = const Size(720, 1612);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: const FoodOfflineScreen(),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('WelcomeScreen handles large font scale $scale without overflow', (tester) async {
        tester.view.physicalSize = const Size(720, 1612);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: const WelcomeScreen(),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
