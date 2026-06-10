import '../../../../core/errors/result.dart';
import '../entities/profile.dart';

/// Profile domain repository — faqat interface.
/// Implementatsiya data qatlamida joylashadi.
abstract interface class ProfileRepository {
  /// Berilgan [userId] bo'yicha profilni yuklaydi.
  /// [currentUserId] — kim ko'rmoqda (isFollowing ni aniqlash uchun)
  Future<Result<Profile>> getProfile(String userId, {String? currentUserId});

  /// Profil ma'lumotlarini yangilaydi.
  /// Avatar lokal yo'l bo'lsa Storage'ga yuklanadi.
  Future<Result<Profile>> updateProfile(UpdateProfileParams params);

  /// Username mavjudligini tekshiradi — `true` = band emas.
  /// [excludeUserId] — bu user'ning o'z username'ini e'tiborsiz qoldirish uchun
  Future<Result<bool>> isUsernameAvailable(String username, {String? excludeUserId});

  /// Profil stream'i — real-time yangilanishlar uchun
  Stream<Profile?> watchProfile(String userId);
}
