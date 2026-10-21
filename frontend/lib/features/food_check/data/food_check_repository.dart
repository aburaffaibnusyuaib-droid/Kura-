import '../domain/food_check_models.dart';

/// Kontrak repository untuk Food Check.
abstract interface class FoodCheckRepository {
  Future<FoodCheckResult> assessFood({
    required String imagePath,
    required FoodType foodType,
    FreshFoodQuestionnaireAnswers? questionnaireAnswers,
    String? forcedScenario,
  });
}
