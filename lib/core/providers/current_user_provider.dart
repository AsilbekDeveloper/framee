import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/providers/auth_data_providers.dart';

/// Joriy foydalanuvchining ID'sini qaytaradi.
///
/// `authUserStreamProvider` ga bog'liq — auth holati o'zgarganda
/// avtomatik yangilanadi. Presentation qatlamida
/// `ref.read(authRepositoryProvider).currentUser?.id` ni to'g'ridan-to'g'ri
/// ishlatish o'rniga shu provider'dan foydalaning.
///
/// Agar foydalanuvchi tizimga kirmagan bo'lsa `null` qaytaradi.
final currentUserIdProvider = Provider<String?>((ref) {
  final authAsync = ref.watch(authUserStreamProvider);
  return authAsync.valueOrNull?.id;
});
