import '../../../../core/errors/result.dart';
import '../entities/auth_user.dart';

/// Auth domain shartnomasi — data layer bundan xabardor emas.
/// Barcha metodlar [Result] qaytaradi: exception throw qilinmaydi.
abstract interface class AuthRepository {
  /// Joriy foydalanuvchini sinxron ravishda qaytaradi (cache'dan)
  AuthUser? get currentUser;

  /// Auth holati o'zgarganda stream'dan xabar beradi
  Stream<AuthUser?> get authStateChanges;

  Future<Result<AuthUser>> signIn({
    required String email,
    required String password,
  });

  /// Muvaffaqiyatli ro'yxatdan o'tish: [AuthUser] qaytaradi.
  /// Email tasdiq kerak bo'lsa — `null` qaytaradi (Ok(null)).
  Future<Result<AuthUser?>> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  /// OAuth — natija [authStateChanges] stream'i orqali keladi
  Future<Result<void>> signInWithGoogle();

  Future<Result<void>> signOut();

  Future<Result<void>> sendPasswordResetEmail(String email);

  /// Parolni yangilaydi (foydalanuvchi tizimga kirgan bo'lishi kerak)
  Future<Result<void>> updatePassword(String newPassword);

  /// Foydalanuvchi hisobini butunlay o'chiradi
  Future<Result<void>> deleteAccount();
}
