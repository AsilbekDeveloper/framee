import 'package:flutter_test/flutter_test.dart';
import 'package:framee/features/profile/data/dtos/profile_dto.dart';

void main() {
  group('ProfileDto.fromJson', () {
    test('maps a full row', () {
      final dto = ProfileDto.fromJson({
        'id': 'user-1',
        'username': 'jane',
        'display_name': 'Jane Doe',
        'avatar_url': 'https://x/a.jpg',
        'bio': 'Hello world',
        'website': 'https://jane.dev',
        'posts_count': 10,
        'followers_count': 20,
        'following_count': 5,
        'is_private': true,
        'is_verified': true,
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-02-01T00:00:00.000Z',
      });

      expect(dto.username, 'jane');
      expect(dto.postsCount, 10);
      expect(dto.followersCount, 20);
      expect(dto.isPrivate, isTrue);
      expect(dto.isVerified, isTrue);
      expect(dto.updatedAt, DateTime.parse('2026-02-01T00:00:00.000Z'));
    });

    test('defaults counts to zero and booleans to false when absent', () {
      final dto = ProfileDto.fromJson({
        'id': 'user-1',
        'created_at': '2026-01-01T00:00:00.000Z',
      });

      expect(dto.username, '');
      expect(dto.displayName, '');
      expect(dto.postsCount, 0);
      expect(dto.followersCount, 0);
      expect(dto.followingCount, 0);
      expect(dto.isPrivate, isFalse);
      expect(dto.isVerified, isFalse);
      expect(dto.updatedAt, isNull);
    });

    test('follow-relationship flags come from the constructor, not the '
        'JSON — the profiles table has no such columns', () {
      final dto = ProfileDto.fromJson(
        {'id': 'user-1', 'created_at': '2026-01-01T00:00:00.000Z'},
        isFollowing: true,
        isRequested: false,
        isFollowingMe: true,
      );

      expect(dto.isFollowing, isTrue);
      expect(dto.isRequested, isFalse);
      expect(dto.isFollowingMe, isTrue);
    });
  });

  test('toJson omits null optional fields', () {
    final dto = ProfileDto.fromJson({
      'id': 'user-1',
      'username': 'jane',
      'display_name': 'Jane Doe',
      'created_at': '2026-01-01T00:00:00.000Z',
    });

    final json = dto.toJson();

    expect(json.containsKey('avatar_url'), isFalse);
    expect(json.containsKey('bio'), isFalse);
    expect(json.containsKey('website'), isFalse);
    expect(json['is_private'], isFalse);
  });

  test('toEntity carries follow flags through', () {
    final dto = ProfileDto.fromJson(
      {'id': 'user-1', 'created_at': '2026-01-01T00:00:00.000Z'},
      isFollowing: true,
    );

    final entity = dto.toEntity();

    expect(entity.isFollowing, isTrue);
  });
}
