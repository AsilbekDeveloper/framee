import '../../../../core/errors/failure.dart';

/// Post domeniga tegishli barcha xatolar uchun asosiy class.
abstract class PostFailure extends Failure {
  const PostFailure({
    required super.message,
    required super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Post topilmadi (o'chirilgan yoki mavjud emas)
final class PostNotFoundFailure extends PostFailure {
  const PostNotFoundFailure()
      : super(
          message: 'Post topilmadi yoki o\'chirilgan.',
          code: 'post/not-found',
        );
}

/// Post yaratishda rasm yuklanmadi (profil saqlash analogiyasi bo'yicha — soft fail ham qo'llanilishi mumkin)
final class PostImageUploadFailure extends PostFailure {
  const PostImageUploadFailure({super.originalError, super.stackTrace})
      : super(
          message: 'Rasm yuklanmadi. Iltimos qayta urinib ko\'ring.',
          code: 'post/image-upload-failed',
        );
}

/// Post yaratishda DB xatosi
final class PostCreateFailure extends PostFailure {
  const PostCreateFailure({super.originalError, super.stackTrace})
      : super(
          message: 'Post saqlanmadi. Keyinroq urinib ko\'ring.',
          code: 'post/create-failed',
        );
}

/// Post o'chirishda xato
final class PostDeleteFailure extends PostFailure {
  const PostDeleteFailure({super.originalError, super.stackTrace})
      : super(
          message: 'Postni o\'chirib bo\'lmadi.',
          code: 'post/delete-failed',
        );
}

/// Izoh qo'shishda xato
final class CommentFailure extends PostFailure {
  const CommentFailure({super.originalError, super.stackTrace})
      : super(
          message: 'Izoh saqlanmadi. Keyinroq urinib ko\'ring.',
          code: 'post/comment-failed',
        );
}

/// Validatsiya xatosi (bo'sh matn va h.k.)
final class PostValidationFailure extends PostFailure {
  const PostValidationFailure({required super.message})
      : super(code: 'post/validation');
}

/// Like/save operatsiyasida xato
final class PostInteractionFailure extends PostFailure {
  const PostInteractionFailure({super.originalError})
      : super(
          message: 'Amal bajarilmadi. Qayta urinib ko\'ring.',
          code: 'post/interaction-failed',
        );
}

/// Ruxsat yo'q (boshqa birovning postini o'chirishga urinish)
final class PostUnauthorizedFailure extends PostFailure {
  const PostUnauthorizedFailure()
      : super(
          message: 'Bu amalni bajarishga ruxsatingiz yo\'q.',
          code: 'post/unauthorized',
        );
}
