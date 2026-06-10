import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/profile.dart';
import '../failures/profile_failure.dart';
import '../repositories/profile_repository.dart';

/// Foydalanuvchi profilini yangilaydi — validatsiya + repository chaqiruvi.
class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);
  final ProfileRepository _repository;

  // Username regex: 3-30 ta belgi, faqat harf/raqam/._
  static final _usernameRegex = RegExp(r'^[a-zA-Z0-9._]{3,30}$');

  Future<Result<Profile>> call(UpdateProfileParams params) async {
    // ── Client-side validatsiya ───────────────────────────────────────────────
    final username = params.username?.trim() ?? '';
    final displayName = params.displayName?.trim() ?? '';

    if (username.isEmpty || displayName.isEmpty) {
      return const Err(
        ValidationFailure(
          message: "Username va ism bo'sh bo'lmasligi kerak",
          field: 'required-fields',
        ),
      );
    }

    if (!_usernameRegex.hasMatch(username)) {
      return const Err(InvalidUsernameFailure());
    }

    // ── Username mavjudligini tekshiruv ──────────────────────────────────────
    // O'z username'ini o'zgartirmasdan saqlasa — "band" xatosi chiqmasligi kerak
    final availResult = await _repository.isUsernameAvailable(
      username,
      excludeUserId: params.userId,
    );
    switch (availResult) {
      case Ok(:final value) when !value:
        return const Err(UsernameAlreadyTakenFailure());
      case Err():
        // Tarmoq xatosi — tekshiruvni o'tkazib yubormiz, server xatosi qaytaradi
        break;
      case Ok():
        break;
    }

    return _repository.updateProfile(params);
  }
}
