import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/providers/auth_data_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/profile_setup_screen.dart';
import '../../features/post/presentation/screens/create_post_screen.dart';
import '../../features/post/domain/entities/post.dart';
import '../../features/post/presentation/screens/edit_post_screen.dart';
import '../../features/profile/presentation/screens/profile_posts_feed_screen.dart';
import '../../features/post/presentation/screens/post_detail_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/followers_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/post/presentation/screens/saved_posts_screen.dart';
import '../components/avatar_crop_screen.dart';
import '../../features/settings/presentation/screens/help_support_screen.dart';
import '../../features/settings/presentation/screens/privacy_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/terms_screen.dart';
import '../components/scaffold_with_nav_bar.dart';

/// Named route path constants used throughout the app.
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

  static const String savedPosts = '/saved-posts';
  static const String avatarCrop = '/avatar-crop';
  static const String privacy = '/privacy';
  static const String helpSupport = '/help-support';
  static const String termsOfService = '/terms-of-service';

  static String postDetailPath(String postId) => '/post/$postId';
  static String editPostPath(String postId) => '/post/$postId/edit';
  static String followersPath(String userId) => '/followers/$userId';
  static String userProfilePath(String userId) => '/user/$userId';
  static String profilePostsFeedPath(String userId, String postId) =>
      '/user/$userId/posts?postId=$postId';
}

// Navigator keys for each shell branch
final _shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorSearchKey =
    GlobalKey<NavigatorState>(debugLabel: 'search');
final _shellNavigatorNotificationsKey =
    GlobalKey<NavigatorState>(debugLabel: 'notifications');
final _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile');

/// Routes accessible without authentication.
/// profileSetup is intentionally excluded — only authenticated users may set up a profile.
const _unauthenticatedRoutes = {
  AppRoutes.onboarding,
  AppRoutes.login,
  AppRoutes.signUp,
};

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthRouterNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: (context, routerState) {
      final authAsync = ref.read(authUserStreamProvider);
      final location = routerState.matchedLocation;

      // Auth state is still loading — do not redirect yet.
      // This prevents a "flash of wrong route" on startup.
      if (authAsync.isLoading) return null;

      final isAuthenticated = authAsync.valueOrNull != null;
      final isUnauthRoute = _unauthenticatedRoutes.contains(location);

      // Unauthenticated user trying to access a protected route.
      if (!isAuthenticated && !isUnauthRoute) return AppRoutes.onboarding;

      // Authenticated user should not land on onboarding/login/signup.
      if (isAuthenticated && isUnauthRoute) return AppRoutes.home;

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (_, _) => const SignUpScreen(),
      ),
      // profileSetup is outside the unauthenticated routes set — only reachable after sign-up.
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (_, _) => const ProfileSetupScreen(),
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
                builder: (_, _) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSearchKey,
            routes: [
              GoRoute(
                path: AppRoutes.search,
                builder: (_, _) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorNotificationsKey,
            routes: [
              GoRoute(
                path: AppRoutes.notifications,
                builder: (_, _) => const NotificationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.createPost,
        pageBuilder: (_, _) => const MaterialPage(
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
        path: '/post/:postId/edit',
        pageBuilder: (_, state) => MaterialPage(
          fullscreenDialog: true,
          child: EditPostScreen(post: state.extra as Post),
        ),
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
        pageBuilder: (_, _) => const MaterialPage(
          fullscreenDialog: true,
          child: EditProfileScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/user/:userId',
        builder: (_, state) => ProfileScreen(
          userId: state.pathParameters['userId'],
        ),
      ),
      GoRoute(
        path: '/user/:userId/posts',
        builder: (_, state) => ProfilePostsFeedScreen(
          userId: state.pathParameters['userId']!,
          initialPostId: state.uri.queryParameters['postId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.savedPosts,
        builder: (_, _) => const SavedPostsScreen(),
      ),
      GoRoute(
        path: AppRoutes.avatarCrop,
        pageBuilder: (_, state) => MaterialPage(
          fullscreenDialog: true,
          child: AvatarCropScreen(imagePath: state.extra as String),
        ),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        builder: (_, _) => const PrivacyScreen(),
      ),
      GoRoute(
        path: AppRoutes.helpSupport,
        builder: (_, _) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.termsOfService,
        builder: (_, _) => const TermsScreen(),
      ),
    ],
  );
});

/// Notifies GoRouter whenever the Supabase auth state changes.
/// Uses a microtask to avoid calling [notifyListeners] synchronously
/// during a widget build, which would cause a setState-during-build error.
class _AuthRouterNotifier extends ChangeNotifier {
  _AuthRouterNotifier(this._ref) {
    _ref.listen(authUserStreamProvider, (_, _) {
      Future.microtask(notifyListeners);
    });
  }

  final Ref _ref;
}
