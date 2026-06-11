import 'package:share_plus/share_plus.dart';

import '../../features/post/domain/entities/post.dart';

/// Handles all share actions across the app.
///
/// URLs use the framee.app deep link scheme. Once the app is published on
/// Play Store / App Store and App Links are configured, these URLs will open
/// the app directly. Until then they fall back to plain text on devices that
/// don't have the app installed.
abstract final class ShareUtils {
  static const _baseUrl = 'https://framee.app';

  /// Shares a post — caption + deep link.
  static void sharePost(Post post) {
    final url = '$_baseUrl/posts/${post.id}';
    final caption = post.caption?.trim();
    final text = (caption != null && caption.isNotEmpty)
        ? '$caption\n\n$url'
        : 'Check out this post on Framee!\n\n$url';
    Share.share(text);
  }

  /// Shares a user profile — username + deep link using userId route.
  static void shareProfile({required String userId, required String username}) {
    final url = '$_baseUrl/user/$userId';
    Share.share('Follow @$username on Framee!\n\n$url');
  }

  /// Returns the post deep link URL (for clipboard copy).
  static String postUrl(String postId) => '$_baseUrl/posts/$postId';

  /// Returns the profile deep link URL (for clipboard copy).
  static String profileUrl(String userId) => '$_baseUrl/user/$userId';
}
