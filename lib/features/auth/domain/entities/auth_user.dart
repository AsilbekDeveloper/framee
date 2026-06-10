/// Domain entity — hech qanday framework yoki tashqi paket import yo'q.
/// Supabase `User` modeli bu entity'ga `_toEntity()` orqali map qilinadi.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.fullName,
    this.username,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? username;
  final String? avatarUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          other.id == id &&
          other.email == email &&
          other.fullName == fullName &&
          other.username == username &&
          other.avatarUrl == avatarUrl;

  @override
  int get hashCode => Object.hash(id, email, fullName, username, avatarUrl);

  AuthUser copyWith({
    String? fullName,
    String? username,
    String? avatarUrl,
  }) =>
      AuthUser(
        id: id,
        email: email,
        fullName: fullName ?? this.fullName,
        username: username ?? this.username,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );
}
