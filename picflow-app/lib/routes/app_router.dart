import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/home_screen.dart';
import '../providers/auth_provider.dart';
import '../screens/editor_screen.dart';
import '../screens/template_square_screen.dart';
import '../screens/artwork_detail_screen.dart';
import '../screens/publish_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/design_preferences_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter 监听登录状态变更（定义在 auth_provider.dart）

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  refreshListenable: authRouteNotifier,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/notifications',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const NotificationsScreen(),
      ),
    ),
    GoRoute(
      path: '/auth',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const AuthScreen(),
      ),
    ),
    GoRoute(
      path: '/design-preferences',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const DesignPreferencesScreen(),
      ),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const HomeShell(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 150),
          ),
        ),
        GoRoute(
          path: '/templates',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const TemplateSquareScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 150),
          ),
        ),
        GoRoute(
          path: '/profile',
          redirect: (context, state) => _authGuard(context, state),
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ProfileScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 150),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/editor',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const EditorScreen(),
      ),
    ),
    GoRoute(
      path: '/artwork/:id',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: ArtworkDetailScreen(artworkId: int.parse(state.pathParameters['id']!)),
      ),
    ),
    GoRoute(
      path: '/publish',
      parentNavigatorKey: _rootNavigatorKey,
      redirect: (context, state) => _authGuard(context, state),
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return CustomTransitionPage(
          key: state.pageKey,
          child: PublishScreen(
            imagePath: extra?['imagePath'] as String?,
            frameType: extra?['frameType'] as String?,
            aspectRatio: extra?['aspectRatio'] as String?,
            bgColor: extra?['bgColor'] as String?,
            watermarkText: extra?['watermarkText'] as String?,
            filter: extra?['filter'] as String?,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    ),
  ],
);

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  activeIcon: Icons.home_rounded,
                  label: '首页',
                  isActive: location == '/',
                  onTap: () => context.go('/'),
                ),
                _NavItem(
                  icon: Icons.dashboard_customize_outlined,
                  activeIcon: Icons.dashboard_customize_rounded,
                  label: '模板',
                  isActive: location.startsWith('/templates'),
                  onTap: () => context.go('/templates'),
                ),
                _NavItem(
                  icon: Icons.add_circle_outline,
                  activeIcon: Icons.add_circle_rounded,
                  label: '发布',
                  isActive: false,
                  onTap: () => context.push('/publish'),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: '我的',
                  isActive: location.startsWith('/profile'),
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 24,
              color: isActive ? AppColors.inversePrimary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isActive ? AppColors.inversePrimary : AppColors.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 如果未登录且访问需认证页面，重定向到 /auth
String? _authGuard(BuildContext context, GoRouterState state) {
  final needsAuth = ['/publish', '/profile'].any((p) => state.matchedLocation.startsWith(p));
  if (needsAuth && !isLoggedIn) {
    return '/auth';
  }
  return null;
}

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}