import 'package:flutter_test/flutter_test.dart';
import 'package:framee/features/notifications/data/dtos/notification_dto.dart';
import 'package:framee/features/notifications/domain/entities/notification.dart';

void main() {
  group('NotificationDto.fromJson', () {
    test('reads actor fields from the nested relation', () {
      final dto = NotificationDto.fromJson({
        'id': 'notif-1',
        'type': 'like',
        'is_read': false,
        'created_at': '2026-01-01T00:00:00.000Z',
        'actor_id': 'user-1',
        'post_id': 'post-1',
        'actor': {
          'username': 'jane',
          'display_name': 'Jane Doe',
          'avatar_url': 'https://x/a.jpg',
        },
        'post': {'image_url': 'https://x/img.jpg'},
      });

      expect(dto.actorUsername, 'jane');
      expect(dto.postImageUrl, 'https://x/img.jpg');
    });

    test('tolerates missing actor/post relations', () {
      final dto = NotificationDto.fromJson({
        'id': 'notif-1',
        'type': 'follow',
        'is_read': true,
        'created_at': '2026-01-01T00:00:00.000Z',
        'actor_id': 'user-1',
      });

      expect(dto.actorUsername, '');
      expect(dto.postId, isNull);
      expect(dto.postImageUrl, isNull);
    });
  });

  group('type string -> NotificationType mapping', () {
    const cases = {
      'like': NotificationType.like,
      'comment': NotificationType.comment,
      'follow': NotificationType.follow,
      'follow_request': NotificationType.followRequest,
      'mention': NotificationType.mention,
    };

    for (final entry in cases.entries) {
      test('"${entry.key}" maps to ${entry.value}', () {
        final dto = NotificationDto.fromJson({
          'id': 'notif-1',
          'type': entry.key,
          'is_read': false,
          'created_at': '2026-01-01T00:00:00.000Z',
          'actor_id': 'user-1',
        });

        expect(dto.toEntity().type, entry.value);
      });
    }
  });
}
