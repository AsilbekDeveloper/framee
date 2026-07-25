import 'package:flutter_test/flutter_test.dart';
import 'package:framee/features/follow/domain/entities/follow.dart';
import 'package:framee/features/search/data/dtos/search_user_dto.dart';

void main() {
  test('toEntity resolves "following" when is_following is true', () {
    final dto = SearchUserDto.fromJson({
      'id': 'user-1',
      'username': 'jane',
      'display_name': 'Jane Doe',
      'is_following': true,
      'is_requested': false,
    });

    expect(dto.toEntity().followStatus, FollowStatus.following);
  });

  test('toEntity resolves "requested" when is_requested is true', () {
    final dto = SearchUserDto.fromJson({
      'id': 'user-1',
      'username': 'jane',
      'display_name': 'Jane Doe',
      'is_following': false,
      'is_requested': true,
    });

    expect(dto.toEntity().followStatus, FollowStatus.requested);
  });

  test('toEntity resolves "none" when neither flag is set', () {
    final dto = SearchUserDto.fromJson({
      'id': 'user-1',
      'username': 'jane',
      'display_name': 'Jane Doe',
    });

    expect(dto.toEntity().followStatus, FollowStatus.none);
  });

  test('is_following takes precedence if both flags were somehow true',
      () {
    final dto = SearchUserDto.fromJson({
      'id': 'user-1',
      'username': 'jane',
      'display_name': 'Jane Doe',
      'is_following': true,
      'is_requested': true,
    });

    expect(dto.toEntity().followStatus, FollowStatus.following);
  });
}
