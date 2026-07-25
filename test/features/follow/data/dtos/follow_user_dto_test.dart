import 'package:flutter_test/flutter_test.dart';
import 'package:framee/features/follow/data/dtos/follow_user_dto.dart';
import 'package:framee/features/follow/domain/entities/follow.dart';

void main() {
  test('fromJson defaults followStatus to none unless given', () {
    final dto = FollowUserDto.fromJson({
      'id': 'user-1',
      'username': 'jane',
      'display_name': 'Jane Doe',
    });

    expect(dto.followStatus, FollowStatus.none);
  });

  test('fromJson accepts an explicit followStatus', () {
    final dto = FollowUserDto.fromJson(
      {'id': 'user-1', 'username': 'jane', 'display_name': 'Jane Doe'},
      followStatus: FollowStatus.following,
    );

    expect(dto.toEntity().followStatus, FollowStatus.following);
  });

  test('defaults verification and privacy flags to false', () {
    final dto = FollowUserDto.fromJson({
      'id': 'user-1',
      'username': 'jane',
      'display_name': 'Jane Doe',
    });

    expect(dto.isVerified, isFalse);
    expect(dto.isPrivate, isFalse);
  });
}
