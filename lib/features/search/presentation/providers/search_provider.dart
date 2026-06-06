import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/ui_models.dart';
import '../../../../core/utils/mock_data.dart';

class SearchState {
  const SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
  });

  final String query;
  final List<UserModel> results;
  final bool isLoading;

  SearchState copyWith({
    String? query,
    List<UserModel>? results,
    bool? isLoading,
  }) =>
      SearchState(
        query: query ?? this.query,
        results: results ?? this.results,
        isLoading: isLoading ?? this.isLoading,
      );
}

class SearchNotifier extends Notifier<SearchState> {
  @override
  SearchState build() => const SearchState();

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }
    state = state.copyWith(query: query, isLoading: true);
    // Replace with Supabase full-text search
    await Future.delayed(const Duration(milliseconds: 400));
    final results = MockData.users
        .where(
          (u) =>
              u.username.toLowerCase().contains(query.toLowerCase()) ||
              u.displayName.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    state = state.copyWith(results: results, isLoading: false);
  }

  void clearSearch() => state = const SearchState();

  void toggleFollow(String userId) {
    state = state.copyWith(
      results: state.results.map((u) {
        if (u.id != userId) return u;
        return u.copyWith(isFollowing: !u.isFollowing);
      }).toList(),
    );
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);
