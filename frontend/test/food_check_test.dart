import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kura_ai/features/food_check/domain/food_check_models.dart';
import 'package:kura_ai/features/food_check/data/food_check_mock_repository.dart';
import 'package:kura_ai/features/food_check/presentation/controllers/food_check_controller.dart';

void main() {
  group('FoodCheckMockRepository Tests', () {
    const repository = FoodCheckMockRepository();

    test('returns packaged safe scenario matching Mockup 06', () async {
      final res = await repository.assessFood(
        imagePath: 'assets/images/il_food_check_banner.png',
        foodType: FoodType.packaged,
        forcedScenario: 'packaged_safe',
      );

      expect(res.status, FoodCheckStatus.looksOk);
      expect(res.productName, 'Sarden dalam Saus Tomat');
      expect(res.categoryName, 'ABC');
      expect(res.packagingCondition, 'Baik');
    });

    test('returns packaged warning scenario matching Mockup 07', () async {
      final res = await repository.assessFood(
        imagePath: 'assets/images/il_food_check_banner.png',
        foodType: FoodType.packaged,
        forcedScenario: 'packaged_warning',
      );

      expect(res.status, FoodCheckStatus.checkFurther);
      expect(res.productName, 'Keripik Kentang');
      expect(res.packagingCondition, 'Sedikit penyok');
    });

    test('returns packaged danger scenario matching Mockup 08', () async {
      final res = await repository.assessFood(
        imagePath: 'assets/images/il_food_check_banner.png',
        foodType: FoodType.packaged,
        forcedScenario: 'packaged_danger',
      );

      expect(res.status, FoodCheckStatus.avoidEating);
      expect(res.productName, 'Susu UHT');
      expect(res.packagingCondition, 'Rusak');
    });

    test('returns fresh safe scenario matching Mockup 09', () async {
      final res = await repository.assessFood(
        imagePath: 'assets/images/il_food_check_banner.png',
        foodType: FoodType.fresh,
        forcedScenario: 'fresh_safe',
      );

      expect(res.status, FoodCheckStatus.looksOk);
      expect(res.productName, 'Bayam');
      expect(res.texture, 'Renyah');
    });

    test('returns fresh uncertain scenario matching Mockup 11', () async {
      final res = await repository.assessFood(
        imagePath: 'assets/images/il_food_check_banner.png',
        foodType: FoodType.fresh,
        forcedScenario: 'fresh_uncertain',
      );

      expect(res.status, FoodCheckStatus.unableToAssess);
      expect(res.productName, 'Buah Berry');
    });
  });

  group('FoodCheckController Tests', () {
    test('updates selected food type and scenarios correctly', () {
      final container = ProviderContainer();
      final controller = container.read(foodCheckControllerProvider.notifier);

      expect(container.read(foodCheckControllerProvider).selectedFoodType, FoodType.packaged);

      controller.selectFoodType(FoodType.fresh);
      expect(container.read(foodCheckControllerProvider).selectedFoodType, FoodType.fresh);
      expect(container.read(foodCheckControllerProvider).selectedScenario, 'fresh_safe');

      controller.selectFoodType(FoodType.packaged);
      expect(container.read(foodCheckControllerProvider).selectedFoodType, FoodType.packaged);
      expect(container.read(foodCheckControllerProvider).selectedScenario, 'packaged_safe');
    });

    test('sets and clears captured image', () {
      final container = ProviderContainer();
      final controller = container.read(foodCheckControllerProvider.notifier);

      controller.setCapturedImage('/path/to/test.jpg');
      expect(container.read(foodCheckControllerProvider).capturedImagePath, '/path/to/test.jpg');

      controller.clearCapturedImage();
      expect(container.read(foodCheckControllerProvider).capturedImagePath, isNull);
    });
  });
}
