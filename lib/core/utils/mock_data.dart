import '../models/ui_models.dart';

/// Sample data for UI development and testing.
/// Replace with real Supabase data in production.
abstract final class MockData {
  static UserModel currentUser = UserModel(
    id: 'user_001',
    username: 'asilbek_dev',
    displayName: 'Asilbek Ilhomov',
    email: 'ilhomovasilbek7@gmail.com',
    bio: 'Flutter Developer 📱 | Building beautiful apps with clean architecture. PDP University student.',
    website: 'github.com/AsilbekDeveloper',
    postsCount: 24,
    followersCount: 200,
    followingCount: 150,
    isFollowing: false,
  );

  static final List<UserModel> users = [
    UserModel(
      id: 'user_002',
      username: 'john_dev',
      displayName: 'John Dev',
      postsCount: 48,
      followersCount: 1200,
      followingCount: 340,
      isFollowing: false,
    ),
    UserModel(
      id: 'user_003',
      username: 'sara_creates',
      displayName: 'Sara Creates',
      bio: 'Designer & Creator ✨',
      postsCount: 31,
      followersCount: 460,
      followingCount: 120,
      isFollowing: true,
    ),
    UserModel(
      id: 'user_004',
      username: 'nina_art',
      displayName: 'Nina Art',
      bio: 'Visual artist 🎨',
      postsCount: 112,
      followersCount: 8400,
      followingCount: 230,
      isFollowing: false,
    ),
    UserModel(
      id: 'user_005',
      username: 'mike_codes',
      displayName: 'Mike Codes',
      postsCount: 17,
      followersCount: 320,
      followingCount: 98,
      isFollowing: false,
    ),
    UserModel(
      id: 'user_006',
      username: 'luna_ux',
      displayName: 'Luna UX',
      bio: 'Product Designer 🌙',
      postsCount: 55,
      followersCount: 2100,
      followingCount: 180,
      isFollowing: true,
    ),
  ];

  static List<PostModel> get posts => [
    PostModel(
      id: 'post_001',
      author: users[0],
      caption:
          'Just shipped a new Flutter app to production 🚀 Clean architecture FTW. #flutter #mobile #dev',
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      likesCount: 248,
      commentsCount: 34,
      isLiked: true,
      type: PostType.imageOnly,
    ),
    PostModel(
      id: 'post_002',
      author: users[1],
      caption:
          '"Design is not just what it looks like and feels like. Design is how it works." — Steve Jobs',
      createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
      likesCount: 92,
      commentsCount: 17,
      type: PostType.textOnly,
    ),
    PostModel(
      id: 'post_003',
      author: users[2],
      caption:
          'Late night colors 🎨 Playing with gradients and shapes. What do you see?',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      likesCount: 531,
      commentsCount: 63,
      type: PostType.imageOnly,
    ),
    PostModel(
      id: 'post_004',
      author: users[3],
      caption:
          'Working on something new 🔮 Flutter + Clean Architecture is just beautiful.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      likesCount: 124,
      commentsCount: 18,
      isLiked: true,
      type: PostType.imageOnly,
    ),
  ];

  static List<CommentModel> get comments => [
    CommentModel(
      id: 'c_001',
      author: users[0],
      text: '🔥 Amazing work! What state management are you using?',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likesCount: 5,
      replies: [
        CommentModel(
          id: 'c_001_r1',
          author: currentUser,
          text: 'BLoC all the way! Clean architecture makes it so much easier 💜',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          likesCount: 3,
        ),
      ],
    ),
    CommentModel(
      id: 'c_002',
      author: users[2],
      text: 'Love the design! So clean 💜',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      likesCount: 2,
    ),
    CommentModel(
      id: 'c_003',
      author: users[1],
      text: 'Congrats! Keep shipping 🚀',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      likesCount: 1,
    ),
  ];

  static List<NotificationModel> get notifications => [
    NotificationModel(
      id: 'n_001',
      type: NotificationType.like,
      actor: users[0],
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      isRead: false,
    ),
    NotificationModel(
      id: 'n_002',
      type: NotificationType.follow,
      actor: users[2],
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: false,
    ),
    NotificationModel(
      id: 'n_003',
      type: NotificationType.comment,
      actor: users[1],
      commentText: 'Congrats! Keep shipping 🚀',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    NotificationModel(
      id: 'n_004',
      type: NotificationType.like,
      actor: users[3],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationModel(
      id: 'n_005',
      type: NotificationType.follow,
      actor: users[4],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];
}
