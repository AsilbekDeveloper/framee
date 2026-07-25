import 'package:flutter_test/flutter_test.dart';
import 'package:framee/features/post/data/dtos/comment_dto.dart';

void main() {
  test('CommentDto.fromJson reads nested profile fields', () {
    final dto = CommentDto.fromJson({
      'id': 'comment-1',
      'post_id': 'post-1',
      'user_id': 'user-1',
      'text': 'Nice!',
      'created_at': '2026-01-01T00:00:00.000Z',
      'likes_count': 2,
      'is_liked': true,
      'parent_id': null,
      'profiles': {
        'username': 'jane',
        'display_name': 'Jane Doe',
        'avatar_url': 'https://x/a.jpg',
      },
    });

    expect(dto.authorUsername, 'jane');
    expect(dto.authorDisplayName, 'Jane Doe');
    expect(dto.likesCount, 2);
    expect(dto.isLiked, isTrue);
    expect(dto.parentId, isNull);
  });

  test('defaults author fields when the profiles relation is missing', () {
    final dto = CommentDto.fromJson({
      'id': 'comment-1',
      'post_id': 'post-1',
      'user_id': 'user-1',
      'text': 'Nice!',
      'created_at': '2026-01-01T00:00:00.000Z',
    });

    expect(dto.authorUsername, '');
    expect(dto.authorDisplayName, '');
    expect(dto.likesCount, 0);
    expect(dto.isLiked, isFalse);
  });

  test('a non-null parent_id marks the comment as a reply', () {
    final dto = CommentDto.fromJson({
      'id': 'comment-2',
      'post_id': 'post-1',
      'user_id': 'user-1',
      'text': 'A reply',
      'created_at': '2026-01-01T00:00:00.000Z',
      'parent_id': 'comment-1',
    });

    expect(dto.parentId, 'comment-1');
  });

  test('toEntity attaches the given replies', () {
    final parent = CommentDto.fromJson({
      'id': 'comment-1',
      'post_id': 'post-1',
      'user_id': 'user-1',
      'text': 'Top level',
      'created_at': '2026-01-01T00:00:00.000Z',
    });
    final reply = CommentDto.fromJson({
      'id': 'comment-2',
      'post_id': 'post-1',
      'user_id': 'user-2',
      'text': 'A reply',
      'created_at': '2026-01-01T00:00:00.000Z',
      'parent_id': 'comment-1',
    }).toEntity();

    final entity = parent.toEntity(replies: [reply]);

    expect(entity.replies, [reply]);
  });
}
