import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/landing_screen.dart';
import '../screens/auth/customer_auth_screen.dart';
import '../screens/auth/admin_login_screen.dart';
import '../screens/main_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/landing',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/auth/customer',
        builder: (context, state) => const CustomerAuthScreen(),
      ),
      GoRoute(
        path: '/admin/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isAuthenticated = authProvider.isAuthenticated;
      final isAdmin = authProvider.isAdmin;
      final isInitialized = authProvider.isInitialized;

      // Allow splash and onboarding regardless of auth state
      final isSplash = state.uri.path == '/splash';
      final isOnboarding = state.uri.path == '/onboarding';
      
      // Wait for initialization before redirecting based on auth
      if (!isInitialized) return null;

      final isAuthRoute = state.uri.path == '/auth/customer' || 
                          state.uri.path == '/admin/login' || 
                          state.uri.path == '/landing';

      // If not authenticated, let them go to auth routes
      if (!isAuthenticated) {
        if (!isAuthRoute && !isSplash && !isOnboarding) {
          return '/landing';
        }
        return null;
      }

      // If authenticated, prevent access to auth routes
      if (isAuthRoute) {
        if (isAdmin) {
          return '/admin/dashboard';
        } else {
          return '/home';
        }
      }

      // Enforce admin vs customer routes
      final isAdminRoute = state.uri.path.startsWith('/admin');
      if (isAdminRoute && !isAdmin) {
        return '/home';
      }

      if (!isAdminRoute && isAdmin && !isSplash) {
        return '/admin/dashboard';
      }

      return null;
    },
  );
}
