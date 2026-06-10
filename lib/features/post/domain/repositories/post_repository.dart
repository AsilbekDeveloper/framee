import '../../../../core/errors/result.dart';
import '../entities/post.dart';

/// Post domenining repository interfeysi.
///
/// Data qatlami bu interfeysi implement qiladi.
/// Domain qatlami faqat shu abstraksiya bilan ishlaydi — Supabase yoki
/// boshqa backend haqida bilmaydi.
abstract interface class PostRepository {
  // ── Feed ───────────────────────────────────────────────────────────────────

  /// Hozirgi foydalanuvchining feed postlarini qaytaradi
  /// (kelajakda: faqat following bo'lganlarniki; hozircha barcha public postlar)
  Future<Result<List<Post>>> getFeed({
    required String currentUserId,
    int limit = 20,
    int offset = 0,
  });

  // ── Post CRUD ──────────────────────────────────────────────────────────────

  /// ID bo'yicha bitta postni yuklaydi
  Future<Result<Post>> getPost({
    required String postId,
    required String currentUserId,
  });

  /// Yangi post yaratadi (rasm yuklanishi + DB yozuvi)
  Future<Result<Post>> createPost(CreatePostParams params);

  /// Postni o'chiradi (faqat egasi)
  Future<Result<bool>> deletePost({
    required String postId,
    required String currentUserId,
  });

  // ── Like / Save ────────────────────────────────────────────────────────────

  /// Like qo'yish / olib tashlash. Yangilangan [likesCount] + [isLiked] qaytaradi.
  Future<Result<({int likesCount, bool isLiked})>> toggleLike({
    required String postId,
    required String currentUserId,
  });

  /// Saqlab qo'yish / olib tashlash
  Future<Result<bool>> toggleSave({
    required String postId,
    required String currentUserId,
  });

  // ── Comments ───────────────────────────────────────────────────────────────

  /// Post uchun izohlar ro'yxatini yuklaydi
  Future<Result<List<Comment>>> getComments({
    required String postId,
    required String currentUserId,
  });

  /// Yangi izoh qo'shadi
  Future<Result<Comment>> addComment(AddCommentParams params);

  /// Izoh o'chiradi (faqat izoh egasi yoki post egasi)
  Future<Result<bool>> deleteComment({
    required String commentId,
    required String currentUserId,
  });

  // ── User / Saved Posts ─────────────────────────────────────────────────────

  /// Biror foydalanuvchining postlari
  Future<Result<List<Post>>> getUserPosts({
    required String userId,
    required String currentUserId,
    int limit = 30,
    int offset = 0,
  });

  /// Joriy foydalanuvchining saqlangan postlari
  Future<Result<List<Post>>> getSavedPosts({
    required String userId,
    int limit = 30,
    int offset = 0,
  });
}
