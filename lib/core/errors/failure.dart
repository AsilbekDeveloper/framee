/// Ilovadagi barcha xatolar uchun asosiy sealed class.
///
/// Har bir feature o'zining xato sinfini shu classdan kengaytiradi.
/// [message]   — foydalanuvchiga ko'rsatiladigan matn
/// [code]      — mashinaga tushunarli identifikator: 'auth/invalid-credentials'
/// [originalError] — debug uchun asl exception
/// [stackTrace]    — debug uchun stack trace
abstract class Failure implements Exception {
  const Failure({
    required this.message,
    required this.code,
    this.originalError,
    this.stackTrace,
  });

  final String message;
  final String code;
  final Object? originalError;
  final StackTrace? stackTrace;

  @override
  String toString() => 'Failure[$code]: $message';
}

// ── Umumiy xatolar — barcha featurelar ishlatishi mumkin ─────────────────────

/// Internet aloqasi yo'q yoki server bilan bog'lanib bo'lmadi
final class NetworkFailure extends Failure {
  const NetworkFailure({
    String? message,
    super.originalError,
    super.stackTrace,
  }) : super(
          message: message ?? 'Tarmoq xatosi. Internetingizni tekshiring.',
          code: 'network/unavailable',
        );
}

/// Server 5xx xatosi
final class ServerFailure extends Failure {
  const ServerFailure({
    String? message,
    super.originalError,
    super.stackTrace,
  }) : super(
          message: message ?? "Server xatosi. Keyinroq urinib ko'ring.",
          code: 'server/error',
        );
}

/// So'ralgan resurs topilmadi
final class NotFoundFailure extends Failure {
  const NotFoundFailure({
    String? message,
    super.originalError,
  }) : super(
          message: message ?? "Ma'lumot topilmadi.",
          code: 'not-found',
        );
}

/// Foydalanuvchi autentifikatsiya qilinmagan yoki sessiyasi tugagan
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.stackTrace})
      : super(
          message: "Ruxsat yo'q. Iltimos qayta kiring.",
          code: 'unauthorized',
        );
}

/// Kirish ma'lumotlari noto'g'ri (validatsiya)
final class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    String? field,
  }) : super(
          code: 'validation/${field ?? "general"}',
        );
}

/// Fayl saqlash / o'qish xatosi (Storage)
final class StorageFailure extends Failure {
  const StorageFailure({
    String? message,
    super.originalError,
    super.stackTrace,
  }) : super(
          message: message ?? 'Fayl saqlashda xato yuz berdi.',
          code: 'storage/error',
        );
}

/// Kutilmagan, kategoriyalanmagan xato
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    String? message,
    super.originalError,
    super.stackTrace,
  }) : super(
          message: message ?? 'Kutilmagan xato yuz berdi.',
          code: 'unexpected',
        );
}
