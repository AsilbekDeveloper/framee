import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/providers/auth_data_providers.dart';

/// Exposes the current authenticated user's ID.
///
/// Depends on [authUserStreamProvider] and updates automatically whenever
/// the auth state changes. Prefer this over accessing
/// `authRepositoryProvider.currentUser?.id` directly in the presentation layer.
///
/// Returns `null` when no user is signed in.
final currentUserIdProvider = Provider<String?>((ref) {
  final authAsync = ref.watch(authUserStreamProvider);
  return authAsync.valueOrNull?.id;
});
