import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_routes.dart';

/// Shell scaffold dengan Bottom Navigation Bar.
/// Menampilkan 4 tab aktif: Home, Food Check, Zero Waste (Atur), dan Kura AI Chat.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.child});

  final Widget child;

  int _locationToIndex(String location) {
    if (location.startsWith(AppRoutes.foodCheck)) return 1;
    if (location.startsWith(AppRoutes.atur)) return 2;
    if (location.startsWith(AppRoutes.kuraChat)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: _KuraBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          HapticFeedback.lightImpact();
          switch (index) {
            case 0:
              context.go(AppRoutes.home);
            case 1:
              context.go(AppRoutes.foodCheck);
            case 2:
              context.go(AppRoutes.atur);
            case 3:
              context.go(AppRoutes.kuraChat);
          }
        },
      ),
    );
  }
}

class _KuraBottomNav extends StatelessWidget {
  const _KuraBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.navSelected,
          unselectedItemColor: AppColors.navUnselected,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_outlined),
              activeIcon: Icon(Icons.camera_alt_rounded),
              label: 'Food Check',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.eco_outlined),
              activeIcon: Icon(Icons.eco_rounded),
              label: 'Zero Waste',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              activeIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Kura AI',
            ),
          ],
        ),
      ),
    );
  }
}
