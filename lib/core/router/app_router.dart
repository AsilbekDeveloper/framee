import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/profile_setup_screen.dart';
import '../../features/post/presentation/screens/create_post_screen.dart';
import '../../features/post/presentation/screens/post_detail_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/followers_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../components/scaffold_with_nav_bar.dart';

abstract final class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String profileSetup = '/profile-setup';
  static const String home = '/home';
  static const String search = '/search';
  static const String profile = '/profile';
  static const String createPost = '/create-post';
  static const String notifications = '/notifications';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';

  static String postDetailPath(String postId) => '/post/$postId';
  static String followersPath(String userId) => '/followers/$userId';
  static String userProfilePath(String userId) => '/user/$userId';
}

final _shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorSearchKey =
    GlobalKey<NavigatorState>(debugLabel: 'search');
final _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (_, __) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (_, __) => const ProfileSetupScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSearchKey,
            routes: [
              GoRoute(
                path: AppRoutes.search,
                builder: (_, __) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.createPost,
        pageBuilder: (_, __) => const MaterialPage(
          fullscreenDialog: true,
          child: CreatePostScreen(),
        ),
      ),
      GoRoute(
        path: '/post/:postId',
        builder: (_, state) => PostDetailScreen(
          postId: state.pathParameters['postId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/followers/:userId',
        builder: (_, state) => FollowersScreen(
          userId: state.pathParameters['userId']!,
          initialTab: state.uri.queryParameters['tab'] ?? 'followers',
        ),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        pageBuilder: (_, __) => const MaterialPage(
          fullscreenDialog: true,
          child: EditProfileScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/user/:userId',
        builder: (_, state) => ProfileScreen(
          userId: state.pathParameters['userId'],
        ),
      ),
    ],
  );
});
