import '../../../../core/errors/failure.dart';

/// Profile feature'ga xos failure'lar ierarxiyasi.
/// Barcha subclass'lar [Failure] base class'ini [ProfileFailure] orqali meros oladi.
abstract class ProfileFailure extends Failure {
  const ProfileFailure({
    required super.message,
    required super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Profil topilmadi — `profiles` jadvalida yozuv yo'q
final class ProfileNotFoundFailure extends ProfileFailure {
  const ProfileNotFoundFailure({String? userId})
      : super(
          message: 'Profil topilmadi',
          code: 'profile/not-found',
        );
}

/// Username allaqachon band — unikal bo'lishi shart
final class UsernameAlreadyTakenFailure extends ProfileFailure {
  const UsernameAlreadyTakenFailure()
      : super(
          message: 'Bu username allaqachon band',
          code: 'profile/username-taken',
        );
}

/// Username noto'g'ri format — faqat harf, raqam, _ va . bo'lishi kerak
final class InvalidUsernameFailure extends ProfileFailure {
  const InvalidUsernameFailure()
      : super(
          message: "Username faqat harf, raqam, '_' va '.' dan iborat bo'lishi kerak",
          code: 'profile/invalid-username',
        );
}

/// Avatar yuklashda xato — Storage muammo
final class AvatarUploadFailure extends ProfileFailure {
  const AvatarUploadFailure({super.originalError, super.stackTrace})
      : super(
          message: 'Rasm yuklanmadi, qayta urinib ko\'ring',
          code: 'profile/avatar-upload-failed',
        );
}

/// Profil yangilashda xato — server yoki RLS muammosi
final class ProfileUpdateFailure extends ProfileFailure {
  const ProfileUpdateFailure({super.originalError, super.stackTrace})
      : super(
          message: 'Profil saqlanmadi, qayta urinib ko\'ring',
          code: 'profile/update-failed',
        );
}

/// Ruxsatsiz amal — o'zganing profilini tahrirlashga urinish
final class ProfileUnauthorizedFailure extends ProfileFailure {
  const ProfileUnauthorizedFailure()
      : super(
          message: 'Bu amalni bajarish uchun ruxsat yo\'q',
          code: 'profile/unauthorized',
        );
}
