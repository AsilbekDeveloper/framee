import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/features/post/domain/entities/post.dart';
import 'package:framee/features/profile/presentation/widgets/profile_image_grid.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Post post(String id) => Post(
        id: id,
        author: const PostAuthor(id: 'author-1', username: 'a', displayName: 'A'),
        imageUrl: 'https://example.com/$id.jpg',
        createdAt: DateTime(2026, 1, 1),
      );

  Widget wrapInScrollView(Widget sliver) =>
      CustomScrollView(slivers: [sliver]);

  testWidgets('renders nothing for an empty post list', (tester) async {
    await pumpApp(
      tester,
      wrapInScrollView(
        ProfileImageGrid(posts: const [], onPostTap: (_) {}),
      ),
    );

    expect(find.byType(GestureDetector), findsNothing);
  });

  testWidgets('tapping a cell calls onPostTap with the post id',
      (tester) async {
    String? tappedId;
    await pumpApp(
      tester,
      wrapInScrollView(
        ProfileImageGrid(
          posts: [post('p1'), post('p2')],
          onPostTap: (id) => tappedId = id,
        ),
      ),
    );

    await tester.tap(find.byType(GestureDetector).first);
    expect(tappedId, isNotNull);
  });
}
