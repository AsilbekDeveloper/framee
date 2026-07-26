import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/constants/app_strings.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/core/providers/current_user_provider.dart';
import 'package:framee/features/post/data/providers/post_data_providers.dart';
import 'package:framee/features/post/domain/entities/post.dart';
import 'package:framee/features/profile/presentation/widgets/profile_tabs.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  group('ProfileTab', () {
    testWidgets('renders the icon and calls onTap', (tester) async {
      var tapped = false;
      await pumpApp(
        tester,
        Row(children: [
          ProfileTab(
            icon: Icons.grid_view_rounded,
            isActive: true,
            onTap: () => tapped = true,
          ),
        ]),
      );

      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
      await tester.tap(find.byType(ProfileTab));
      expect(tapped, isTrue);
    });
  });

  group('ProfileTabDelegate', () {
    testWidgets('renders both tab icons and forwards taps', (tester) async {
      int? changedTo;
      await pumpApp(
        tester,
        Builder(
          builder: (context) => ProfileTabDelegate(
            selectedIndex: 0,
            onTabChanged: (i) => changedTo = i,
          ).build(context, 0, false),
        ),
      );

      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
      expect(find.byIcon(Icons.format_list_bulleted_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.format_list_bulleted_rounded));
      expect(changedTo, 1);
    });
  });

  group('ProfileImagePostsTab / ProfileTextPostsTab', () {
    const userId = 'user-1';
    late MockPostRepository postRepository;

    setUpAll(registerFallbackValues);

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      postRepository = MockPostRepository();
    });

    List<Override> overrides() => [
          postRepositoryProvider.overrideWithValue(postRepository),
          currentUserIdProvider.overrideWithValue(userId),
        ];

    Post post(String id, {String? imageUrl}) => Post(
          id: id,
          author:
              const PostAuthor(id: userId, username: 'a', displayName: 'A'),
          imageUrl: imageUrl,
          caption: imageUrl == null ? 'text post' : null,
          createdAt: DateTime(2026, 1, 1),
        );

    void stubUserPosts(List<Post> posts) => when(() => postRepository.getUserPosts(
          userId: userId,
          currentUserId: userId,
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        )).thenAnswer((_) async => Ok(posts));

    testWidgets('image tab shows an empty state when there are no image posts',
        (tester) async {
      stubUserPosts([post('p1')]); // text-only post
      await pumpApp(
        tester,
        CustomScrollView(slivers: [
          ProfileImagePostsTab(userId: userId, onPostTap: (_) {}),
        ]),
        overrides: overrides(),
      );

      expect(find.text(AppStrings.noPostsYet), findsOneWidget);
    });

    testWidgets('image tab renders only the posts that have an image',
        (tester) async {
      stubUserPosts([
        post('p1', imageUrl: 'https://example.com/a.jpg'),
        post('p2'),
      ]);
      await pumpApp(
        tester,
        CustomScrollView(slivers: [
          ProfileImagePostsTab(userId: userId, onPostTap: (_) {}),
        ]),
        overrides: overrides(),
      );

      expect(find.text(AppStrings.noPostsYet), findsNothing);
    });

    testWidgets('text tab shows an empty state when there are no text posts',
        (tester) async {
      stubUserPosts([post('p1', imageUrl: 'https://example.com/a.jpg')]);
      await pumpApp(
        tester,
        CustomScrollView(slivers: [
          ProfileTextPostsTab(
              userId: userId, onPostTap: (_) {}, onUserTap: (_) {}),
        ]),
        overrides: overrides(),
      );

      expect(find.text(AppStrings.noTextPosts), findsOneWidget);
    });

    testWidgets('text tab renders text-only posts', (tester) async {
      stubUserPosts([post('p1')]);
      await pumpApp(
        tester,
        CustomScrollView(slivers: [
          ProfileTextPostsTab(
              userId: userId, onPostTap: (_) {}, onUserTap: (_) {}),
        ]),
        overrides: overrides(),
      );

      expect(find.text(AppStrings.noTextPosts), findsNothing);
      expect(find.textContaining('text post', findRichText: true),
          findsOneWidget);
    });
  });
}
