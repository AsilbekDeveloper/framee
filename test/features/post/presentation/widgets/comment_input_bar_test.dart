import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/core/constants/app_strings.dart';
import 'package:framee/core/errors/result.dart';
import 'package:framee/core/providers/current_user_provider.dart';
import 'package:framee/features/auth/data/providers/auth_data_providers.dart';
import 'package:framee/features/post/presentation/widgets/comment_input_bar.dart';
import 'package:framee/features/profile/data/providers/profile_data_providers.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  const userId = 'user-1';
  late MockAuthRepository authRepository;
  late MockProfileRepository profileRepository;

  setUpAll(registerFallbackValues);

  setUp(() {
    authRepository = MockAuthRepository();
    profileRepository = MockProfileRepository();
    when(() => authRepository.currentUser)
        .thenReturn(makeAuthUser(id: userId));
    when(() => authRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
    when(() => profileRepository.getProfile(userId, currentUserId: userId))
        .thenAnswer((_) async => Ok(makeProfile(id: userId)));
  });

  List<Override> overrides() => [
        authRepositoryProvider.overrideWithValue(authRepository),
        profileRepositoryProvider.overrideWithValue(profileRepository),
        currentUserIdProvider.overrideWithValue(userId),
      ];

  testWidgets('renders the comment hint placeholder', (tester) async {
    await pumpApp(
      tester,
      CommentInputBar(controller: TextEditingController(), onSend: () async {}),
      overrides: overrides(),
    );

    expect(find.text(AppStrings.addCommentPlaceholder), findsOneWidget);
  });

  testWidgets('tapping send with text calls onSend and clears the field',
      (tester) async {
    var sent = false;
    final controller = TextEditingController();
    await pumpApp(
      tester,
      CommentInputBar(
        controller: controller,
        onSend: () async {
          sent = true;
        },
      ),
      overrides: overrides(),
    );

    await tester.enterText(find.byType(TextField), 'nice post');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(sent, isTrue);
    expect(controller.text, isEmpty);
  });

  testWidgets('tapping send with empty text does nothing', (tester) async {
    var sent = false;
    await pumpApp(
      tester,
      CommentInputBar(
        controller: TextEditingController(),
        onSend: () async => sent = true,
      ),
      overrides: overrides(),
    );

    await tester.tap(find.byIcon(Icons.send_rounded));
    expect(sent, isFalse);
  });

  testWidgets('shows a spinner while the send is in flight', (tester) async {
    await pumpApp(
      tester,
      CommentInputBar(
        controller: TextEditingController(text: 'hi'),
        onSend: () async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        },
      ),
      overrides: overrides(),
    );

    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  group('ReplyBanner', () {
    testWidgets('renders the username and calls onClear', (tester) async {
      var cleared = false;
      await pumpApp(
        tester,
        ReplyBanner(username: 'jane', onClear: () => cleared = true),
      );

      expect(find.text('@jane'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(cleared, isTrue);
    });
  });
}
