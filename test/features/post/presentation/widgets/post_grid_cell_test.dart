import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framee/features/post/domain/entities/post.dart';
import 'package:framee/features/post/presentation/widgets/post_grid_cell.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Post post({String? imageUrl, String? caption}) => Post(
        id: 'post-1',
        author: const PostAuthor(id: 'author-1', username: 'a', displayName: 'A'),
        imageUrl: imageUrl,
        caption: caption,
        createdAt: DateTime(2026, 1, 1),
      );

  testWidgets('shows the caption text when there is no image', (tester) async {
    await pumpApp(tester, PostGridCell(post: post(caption: 'hello there')));

    expect(find.text('hello there'), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsNothing);
  });

  testWidgets('shows a quote icon when there is neither image nor caption',
      (tester) async {
    await pumpApp(tester, PostGridCell(post: post()));

    expect(find.byIcon(Icons.format_quote_rounded), findsOneWidget);
  });

  testWidgets('renders CachedNetworkImage when the post has an image',
      (tester) async {
    await pumpApp(
      tester,
      PostGridCell(post: post(imageUrl: 'https://example.com/a.jpg')),
    );

    expect(find.byType(CachedNetworkImage), findsOneWidget);
  });
}
