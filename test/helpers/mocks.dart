import 'package:framee/features/auth/domain/entities/auth_user.dart';
import 'package:framee/features/auth/domain/repositories/auth_repository.dart';
import 'package:framee/features/follow/domain/repositories/follow_repository.dart';
import 'package:framee/features/notifications/domain/repositories/notification_repository.dart';
import 'package:framee/features/post/domain/entities/post.dart';
import 'package:framee/features/post/domain/repositories/post_repository.dart';
import 'package:framee/features/profile/domain/entities/profile.dart';
import 'package:framee/features/profile/domain/repositories/profile_repository.dart';
import 'package:framee/features/search/domain/repositories/search_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockPostRepository extends Mock implements PostRepository {}

class MockFollowRepository extends Mock implements FollowRepository {}

class MockSearchRepository extends Mock implements SearchRepository {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

/// Registers fallback values mocktail needs for `any()` matchers on
/// non-primitive argument types. Call once in a `setUpAll`.
void registerFallbackValues() {
  registerFallbackValue(_FakeUpdateProfileParams());
  registerFallbackValue(_FakeCreatePostParams());
  registerFallbackValue(_FakeUpdatePostParams());
  registerFallbackValue(_FakeAddCommentParams());
}

class _FakeUpdateProfileParams extends Fake implements UpdateProfileParams {}

class _FakeCreatePostParams extends Fake implements CreatePostParams {}

class _FakeUpdatePostParams extends Fake implements UpdatePostParams {}

class _FakeAddCommentParams extends Fake implements AddCommentParams {}

// ── Shared test fixtures ────────────────────────────────────────────────────

AuthUser makeAuthUser({
  String id = 'user-1',
  String email = 'test@example.com',
  String? fullName,
  String? username,
}) =>
    AuthUser(id: id, email: email, fullName: fullName, username: username);

Profile makeProfile({
  String id = 'user-1',
  String username = 'testuser',
  String displayName = 'Test User',
  bool isPrivate = false,
}) =>
    Profile(
      id: id,
      username: username,
      displayName: displayName,
      isPrivate: isPrivate,
      createdAt: DateTime(2026, 1, 1),
    );
