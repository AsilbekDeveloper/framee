import '../../../../core/errors/failure.dart';

/// Auth feature xatolari — [Failure] dan kengaytirilgan.
/// Har bir xato o'ziga xos kodni va matnni o'z ichiga oladi.
abstract class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    required super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Email yoki parol noto'g'ri
final class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure()
      : super(
          message: "Email yoki parol noto'g'ri.",
          code: 'auth/invalid-credentials',
        );
}

/// Email tasdiqlanmagan
final class EmailNotConfirmedFailure extends AuthFailure {
  const EmailNotConfirmedFailure()
      : super(
          message: 'Emailingizni tasdiqlang.',
          code: 'auth/email-not-confirmed',
        );
}

/// Email allaqachon ro'yxatdan o'tgan
final class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure()
      : super(
          message: "Bu email allaqachon ro'yxatdan o'tgan.",
          code: 'auth/email-already-in-use',
        );
}

/// Parol juda zaif
final class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure()
      : super(
          message: "Parol kamida 6 ta belgidan iborat bo'lsin.",
          code: 'auth/weak-password',
        );
}

/// Parollar mos kelmadi (client-side)
final class PasswordMismatchFailure extends AuthFailure {
  const PasswordMismatchFailure()
      : super(
          message: 'Parollar mos kelmadi.',
          code: 'auth/password-mismatch',
        );
}

/// Maydonlar bo'sh qoldirilgan (client-side)
final class EmptyFieldsFailure extends AuthFailure {
  const EmptyFieldsFailure()
      : super(
          message: "Barcha maydonlarni to'ldiring.",
          code: 'auth/empty-fields',
        );
}

/// Foydalanuvchi topilmadi
final class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure()
      : super(
          message: 'Foydalanuvchi topilmadi.',
          code: 'auth/user-not-found',
        );
}

/// Session muddati tugagan
final class SessionExpiredFailure extends AuthFailure {
  const SessionExpiredFailure()
      : super(
          message: 'Sessiya muddati tugadi. Qayta kiring.',
          code: 'auth/session-expired',
        );
}

/// Kategoriyalanmagan auth xatosi — Supabase'dan kelgan noma'lum xabar
final class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure({
    required super.message,
    super.originalError,
    super.stackTrace,
  }) : super(
          code: 'auth/unknown',
        );
}
