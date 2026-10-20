import 'package:go_router/go_router.dart';
import '../core/constants/app_routes.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/food_check/presentation/food_check_placeholder_screen.dart';
import '../features/atur/presentation/atur_placeholder_screen.dart';
import 'shell_scaffold.dart';

/// Router utama aplikasi Kura AI menggunakan go_router.
/// Hanya mendaftarkan route yang diperlukan oleh TASK-03 MVP.
/// Route auth dan settings akan ditambahkan di task berikutnya.
final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: false,
  routes: [
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
            child: FoodCheckPlaceholderScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.atur,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AturPlaceholderScreen(),
          ),
        ),
      ],
    ),
  ],
);
