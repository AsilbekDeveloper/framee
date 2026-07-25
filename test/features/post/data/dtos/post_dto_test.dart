import 'package:flutter_test/flutter_test.dart';
import 'package:framee/features/post/data/dtos/post_dto.dart';

void main() {
  group('PostDto.fromRpc', () {
    test('maps the flat RPC row into a DTO', () {
      final dto = PostDto.fromRpc({
        'id': 'post-1',
        'author_id': 'user-1',
        'author_username': 'jane',
        'author_display_name': 'Jane Doe',
        'author_avatar_url': 'https://x/avatar.jpg',
        'author_is_verified': true,
        'image_url': 'https://x/image.jpg',
        'caption': 'Hello',
        'created_at': '2026-01-01T00:00:00.000Z',
        'likes_count': 3,
        'comments_count': 1,
        'is_liked': true,
        'is_saved': false,
      });

      expect(dto.id, 'post-1');
      expect(dto.authorUsername, 'jane');
      expect(dto.authorIsVerified, isTrue);
      expect(dto.likesCount, 3);
      expect(dto.isLiked, isTrue);
      expect(dto.isSaved, isFalse);
    });

    test('defaults optional fields when absent, instead of throwing', () {
      final dto = PostDto.fromRpc({
        'id': 'post-1',
        'author_id': 'user-1',
        'created_at': '2026-01-01T00:00:00.000Z',
      });

      expect(dto.authorUsername, '');
      expect(dto.authorDisplayName, '');
      expect(dto.authorIsVerified, isFalse);
      expect(dto.imageUrl, isNull);
      expect(dto.caption, isNull);
      expect(dto.likesCount, 0);
      expect(dto.commentsCount, 0);
      expect(dto.isLiked, isFalse);
      expect(dto.isSaved, isFalse);
    });
  });

  group('PostDto.fromJoin', () {
    test('reads author fields from the nested profiles relation', () {
      final dto = PostDto.fromJoin({
        'id': 'post-1',
        'user_id': 'user-1',
        'image_url': 'https://x/image.jpg',
        'caption': 'Hi',
        'created_at': '2026-01-01T00:00:00.000Z',
        'likes_count': 2,
        'comments_count': 0,
        'profiles': {
          'id': 'user-1',
          'username': 'jane',
          'display_name': 'Jane Doe',
          'avatar_url': null,
          'is_verified': false,
        },
        'is_liked': false,
        'is_saved': true,
      });

      expect(dto.authorId, 'user-1');
      expect(dto.authorUsername, 'jane');
      expect(dto.isSaved, isTrue);
    });

    test('does not throw when the profiles relation is missing', () {
      final dto = PostDto.fromJoin({
        'id': 'post-1',
        'user_id': 'user-1',
        'created_at': '2026-01-01T00:00:00.000Z',
      });

      expect(dto.authorUsername, '');
      expect(dto.authorDisplayName, '');
    });
  });

  test('toEntity carries every field through unchanged', () {
    final dto = PostDto.fromRpc({
      'id': 'post-1',
      'author_id': 'user-1',
      'author_username': 'jane',
      'author_display_name': 'Jane Doe',
      'created_at': '2026-01-01T00:00:00.000Z',
      'likes_count': 3,
      'is_liked': true,
    });

    final entity = dto.toEntity();

    expect(entity.id, 'post-1');
    expect(entity.author.id, 'user-1');
    expect(entity.author.username, 'jane');
    expect(entity.likesCount, 3);
    expect(entity.isLiked, isTrue);
  });
}
