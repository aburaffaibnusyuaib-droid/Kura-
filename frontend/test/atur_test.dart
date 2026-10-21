// TASK-05: Unit Test — Atur Module
// [DEMO] Menguji business logic controller dan mock repository.

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kura_ai/features/atur/data/atur_mock_repository.dart';
import 'package:kura_ai/features/atur/domain/atur_models.dart';
import 'package:kura_ai/features/atur/presentation/controllers/atur_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall methodCall) async => null,
    );
  });

  // ── Repository Tests ─────────────────────────────────────────

  group('AturMockRepository', () {
    late AturMockRepository repo;

    setUp(() => repo = AturMockRepository());

    test('analyzeIngredients returns non-empty list', () async {
      final result = await repo.analyzeIngredients(null);
      expect(result, isNotEmpty);
      expect(result.length, greaterThanOrEqualTo(1));
    });

    test('analyzeIngredients always returns exactly 6 demo ingredients', () async {
      final result = await repo.analyzeIngredients('any_path');
      expect(result.length, equals(6));
    });

    test('generateRecipes always returns EXACTLY 3 recipes [PRODUCT_SPEC]',
        () async {
      final ingredients = [
        const DetectedIngredient(
          id: 'test1',
          name: 'Test Bahan',
          quantity: '1 buah',
          emoji: '🧪',
        ),
      ];
      final result = await repo.generateRecipes(ingredients);
      expect(result.length, equals(3),
          reason: 'PRODUCT_SPEC.md: harus tepat 3 resep');
    });

    test('all ingredients are selected by default', () async {
      final result = await repo.analyzeIngredients(null);
      for (final ing in result) {
        expect(ing.isSelected, isTrue);
      }
    });

    test('all ingredients have non-empty id, name, quantity', () async {
      final result = await repo.analyzeIngredients(null);
      for (final ing in result) {
        expect(ing.id, isNotEmpty);
        expect(ing.name, isNotEmpty);
        expect(ing.quantity, isNotEmpty);
      }
    });

    test('all recipes have non-empty steps', () async {
      final result = await repo.generateRecipes([]);
      for (final recipe in result) {
        expect(recipe.steps, isNotEmpty);
        expect(recipe.name, isNotEmpty);
      }
    });
  });

  // ── Controller / State Tests ──────────────────────────────────

  group('AturNotifier', () {
    late ProviderContainer container;
    late AturNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(aturControllerProvider.notifier);
    });

    tearDown(() => container.dispose());

    test('initial state is idle with empty data', () {
      final state = container.read(aturControllerProvider);
      expect(state.status, AturAnalysisStatus.idle);
      expect(state.detectedIngredients, isEmpty);
      expect(state.recipes, isEmpty);
      expect(state.selectedRecipe, isNull);
    });

    test('setHasPermission updates hasPermission flag', () {
      notifier.setHasPermission(granted: true);
      expect(container.read(aturControllerProvider).hasPermission, isTrue);

      notifier.setHasPermission(granted: false);
      expect(container.read(aturControllerProvider).hasPermission, isFalse);
    });

    test('capturePhoto stores imagePath and stays idle', () {
      notifier.capturePhoto('/test/image.jpg');
      final state = container.read(aturControllerProvider);
      expect(state.capturedImagePath, equals('/test/image.jpg'));
      expect(state.status, AturAnalysisStatus.idle);
    });

    test('analyzeIngredients sets status to detected with results', () async {
      await notifier.analyzeIngredients();
      final state = container.read(aturControllerProvider);
      expect(state.status, AturAnalysisStatus.detected);
      expect(state.detectedIngredients, isNotEmpty);
    });

    test('toggleIngredient flips selection', () async {
      await notifier.analyzeIngredients();
      final state = container.read(aturControllerProvider);
      final firstId = state.detectedIngredients.first.id;
      final wasSelected = state.detectedIngredients.first.isSelected;

      notifier.toggleIngredient(firstId);
      final newSelected = container
          .read(aturControllerProvider)
          .detectedIngredients
          .first
          .isSelected;
      expect(newSelected, isNot(wasSelected));
    });

    test('addIngredient appends to list', () async {
      await notifier.analyzeIngredients();
      final countBefore =
          container.read(aturControllerProvider).detectedIngredients.length;
      notifier.addIngredient('Bayam');
      final countAfter =
          container.read(aturControllerProvider).detectedIngredients.length;
      expect(countAfter, equals(countBefore + 1));
    });

    test('addIngredient ignores empty/whitespace string', () async {
      await notifier.analyzeIngredients();
      final countBefore =
          container.read(aturControllerProvider).detectedIngredients.length;
      notifier.addIngredient('   ');
      expect(
        container.read(aturControllerProvider).detectedIngredients.length,
        equals(countBefore),
      );
    });

    test('removeIngredient deletes ingredient by id', () async {
      await notifier.analyzeIngredients();
      final state = container.read(aturControllerProvider);
      final idToRemove = state.detectedIngredients.first.id;
      final countBefore = state.detectedIngredients.length;
      notifier.removeIngredient(idToRemove);
      final newState = container.read(aturControllerProvider);
      expect(newState.detectedIngredients.length, equals(countBefore - 1));
      expect(
        newState.detectedIngredients.any((i) => i.id == idToRemove),
        isFalse,
      );
    });

    test('generateRecipes returns exactly 3 recipes [PRODUCT_SPEC]', () async {
      await notifier.analyzeIngredients();
      await notifier.generateRecipes();
      final state = container.read(aturControllerProvider);
      expect(state.recipes.length, equals(3),
          reason: 'PRODUCT_SPEC.md: harus tepat 3 resep');
    });

    test('selectRecipe updates selectedRecipe in state', () async {
      await notifier.analyzeIngredients();
      await notifier.generateRecipes();
      final recipe = container.read(aturControllerProvider).recipes.first;
      notifier.selectRecipe(recipe);
      expect(
        container.read(aturControllerProvider).selectedRecipe?.id,
        equals(recipe.id),
      );
    });

    test('reset clears all state', () async {
      await notifier.analyzeIngredients();
      await notifier.generateRecipes();
      notifier.reset();
      final state = container.read(aturControllerProvider);
      expect(state.status, AturAnalysisStatus.idle);
      expect(state.detectedIngredients, isEmpty);
      expect(state.recipes, isEmpty);
      expect(state.selectedRecipe, isNull);
    });
  });
}
