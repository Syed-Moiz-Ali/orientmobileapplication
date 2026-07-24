import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListState<T> {
  final bool isLoading;
  final String searchQuery;
  final List<T> items;

  const ListState({
    this.isLoading = true,
    this.searchQuery = '',
    this.items = const [],
  });

  ListState<T> copyWith({
    bool? isLoading,
    String? searchQuery,
    List<T>? items,
  }) =>
      ListState<T>(
        isLoading: isLoading ?? this.isLoading,
        searchQuery: searchQuery ?? this.searchQuery,
        items: items ?? this.items,
      );

  List<T> filter(bool Function(T item) predicate) {
    if (searchQuery.isEmpty) return items;
    return items.where(predicate).toList();
  }
}

mixin ListNotifierMixin<T, S extends ListState<T>> on Notifier<S> {
  Future<void> load({required Future<List<T>> Function() fetcher}) async {
    state = (state.copyWith(isLoading: true) as S);
    state = (state.copyWith(isLoading: false, items: await fetcher()) as S);
  }

  void onSearch(String q) {
    state = (state.copyWith(searchQuery: q) as S);
  }
}
