import 'package:go_router/go_router.dart';
import '../core/constants/app_routes.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/food_check/presentation/screens/food_check_home_screen.dart';
import '../features/food_check/presentation/screens/food_scan_screen.dart';
import '../features/food_check/presentation/screens/food_preview_screen.dart';
import '../features/food_check/presentation/screens/fresh_food_questionnaire_screen.dart';
import '../features/food_check/presentation/screens/food_analyzing_screen.dart';
import '../features/food_check/presentation/screens/food_result_screen.dart';
import '../features/food_check/presentation/screens/food_offline_screen.dart';
import '../features/atur/presentation/screens/atur_intro_screen.dart';
import '../features/atur/presentation/screens/atur_camera_scanner_screen.dart';
import '../features/atur/presentation/screens/atur_analyzing_screen.dart';
import '../features/atur/presentation/screens/atur_empty_ingredients_screen.dart';
import '../features/atur/presentation/screens/atur_ingredient_selection_screen.dart';
import '../features/atur/presentation/screens/recipe_recommendations_screen.dart';
import '../features/atur/presentation/screens/recipe_detail_screen.dart';
import 'shell_scaffold.dart';

/// Router utama aplikasi Kura AI menggunakan go_router.
final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: false,
  routes: [
    // ── ShellRoute dengan Bottom Navigation Bar ────────────────
    ShellRoute(
      builder: (context, state, child) => ShellScaffold(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.foodCheck,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: FoodCheckHomeScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.atur,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AturIntroScreen(),
          ),
        ),
      ],
    ),

    // ── Rute Layar Penuh Modul Food Check ─────────────────────
    GoRoute(
      path: AppRoutes.foodCheckScan,
      builder: (context, state) => const FoodScanScreen(),
    ),
    GoRoute(
      path: AppRoutes.foodCheckPreview,
      builder: (context, state) => const FoodPreviewScreen(),
    ),
    GoRoute(
      path: AppRoutes.foodCheckQuestionnaire,
      builder: (context, state) => const FreshFoodQuestionnaireScreen(),
    ),
    GoRoute(
      path: AppRoutes.foodCheckAnalyzing,
      builder: (context, state) => const FoodAnalyzingScreen(),
    ),
    GoRoute(
      path: AppRoutes.foodCheckResult,
      builder: (context, state) => const FoodResultScreen(),
    ),
    GoRoute(
      path: AppRoutes.foodCheckOffline,
      builder: (context, state) => const FoodOfflineScreen(),
    ),

    // ── Rute Layar Penuh Modul Atur ───────────────────────────
    GoRoute(
      path: AppRoutes.aturCamera,
      builder: (context, state) => const AturCameraScannerScreen(),
    ),
    GoRoute(
      path: AppRoutes.aturAnalyzing,
      builder: (context, state) => const AturAnalyzingScreen(),
    ),
    GoRoute(
      path: AppRoutes.aturEmptyIngredients,
      builder: (context, state) => const AturEmptyIngredientsScreen(),
    ),
    GoRoute(
      path: AppRoutes.aturIngredients,
      builder: (context, state) => const AturIngredientSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.aturRecipes,
      builder: (context, state) => const RecipeRecommendationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.aturRecipeDetail,
      builder: (context, state) => const RecipeDetailScreen(),
    ),
  ],
);
