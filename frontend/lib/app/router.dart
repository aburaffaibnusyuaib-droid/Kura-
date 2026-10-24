import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_routes.dart';
import '../core/services/local_storage_service.dart';
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
import '../features/kura_chat/presentation/screens/kura_chat_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/otp_verification_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import 'shell_scaffold.dart';

/// Router utama aplikasi Kura AI menggunakan go_router.
final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: false,
  redirect: (context, state) {
    final location = state.uri.path;

    // Biarkan SplashScreen menyelesaikan animasi pembuka dan handshake sesi
    if (location == AppRoutes.splash) {
      return null;
    }

    final isAuthRoute = location == AppRoutes.welcome ||
        location == AppRoutes.login ||
        location == AppRoutes.register ||
        location == AppRoutes.forgotPassword ||
        location == AppRoutes.otp;

    final isGuest = LocalStorageService.instance.isGuestMode();
    bool isAuthenticated = false;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && !user.isAnonymous) {
        isAuthenticated = true;
      }
    } catch (_) {}

    // Jika user sudah terautentikasi resmi dan mencoba membuka auth routes, kembalikan ke home
    if (isAuthenticated && isAuthRoute) {
      return AppRoutes.home;
    }

    // Jika bukan user resmi dan bukan tamu (eksplisit keluar/tanpa sesi), arahkan ke welcome
    if (!isAuthenticated && !isGuest && !isAuthRoute) {
      return AppRoutes.welcome;
    }

    return null;
  },
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
        GoRoute(
          path: AppRoutes.kuraChat,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: KuraChatScreen(),
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

    // ── Rute Onboarding ───────────────────────────────────────
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),

    // ── Rute Autentikasi Kura AI (Auth Suite) ──────────────────
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) => OtpVerificationScreen(
        email: state.uri.queryParameters['email'],
      ),
    ),
  ],
);
