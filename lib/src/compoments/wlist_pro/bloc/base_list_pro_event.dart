/// BaseListPro Events
/// Part of BLoC Pro VIP Architecture
library;

import 'package:equatable/equatable.dart';

/// Base event for list operations
sealed class BaseListProEvent extends Equatable {
  const BaseListProEvent();
}

/// Load initial data or reload
class ListLoad<F> extends BaseListProEvent {
  final F? filter;

  /// Force reload, ignore cache
  final bool forceRefresh;

  const ListLoad({
    this.filter,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [filter, forceRefresh];
}

/// Refresh data (pull to refresh)
class ListRefresh<F> extends BaseListProEvent {
  final F? filter;

  const ListRefresh({this.filter});

  @override
  List<Object?> get props => [filter];
}

/// Load more data (pagination)
class ListLoadMore<F> extends BaseListProEvent {
  final F? filter;

  const ListLoadMore({this.filter});

  @override
  List<Object?> get props => [filter];
}

/// Search with keyword
class ListSearch<F> extends BaseListProEvent {
  final String keyword;
  final F? filter;

  /// Debounce duration in milliseconds
  final int debounceMs;

  const ListSearch({
    required this.keyword,
    this.filter,
    this.debounceMs = 300,
  });

  @override
  List<Object?> get props => [keyword, filter, debounceMs];
}

/// Retry after error
class ListRetry extends BaseListProEvent {
  const ListRetry();

  @override
  List<Object?> get props => [];
}

/// Update single item in list
class ListUpdateItem<T> extends BaseListProEvent {
  final T item;

  /// Predicate to find item to update
  final bool Function(T) predicate;

  const ListUpdateItem({
    required this.item,
    required this.predicate,
  });

  @override
  List<Object?> get props => [item];
}

/// Delete single item from list
class ListDeleteItem<T> extends BaseListProEvent {
  final T item;

  /// Predicate to find item to delete
  final bool Function(T) predicate;

  /// Use optimistic update (update UI immediately, rollback on error)
  final bool optimistic;

  const ListDeleteItem({
    required this.item,
    required this.predicate,
    this.optimistic = true,
  });

  @override
  List<Object?> get props => [item, optimistic];
}

/// Add item to list
class ListAddItem<T> extends BaseListProEvent {
  final T item;

  /// Position to add item (0 = beginning, -1 = end)
  final int position;

  /// Use optimistic update
  final bool optimistic;

  const ListAddItem({
    required this.item,
    this.position = 0,
    this.optimistic = true,
  });

  @override
  List<Object?> get props => [item, position, optimistic];
}

/// Update multiple items in list
class ListUpdateItems<T> extends BaseListProEvent {
  final List<T> items;

  const ListUpdateItems({required this.items});

  @override
  List<Object?> get props => [items];
}

/// Clear cache
class ListClearCache extends BaseListProEvent {
  /// Clear specific cache key
  final String? cacheKey;

  const ListClearCache({this.cacheKey});

  @override
  List<Object?> get props => [cacheKey];
}

/// Manual set items (for local manipulation)
class ListSetItems<T> extends BaseListProEvent {
  final List<T> items;
  final bool hasMore;
  final dynamic meta;

  const ListSetItems({
    required this.items,
    this.hasMore = false,
    this.meta,
  });

  @override
  List<Object?> get props => [items, hasMore, meta];
}

/// Reset to initial state
class ListReset extends BaseListProEvent {
  const ListReset();

  @override
  List<Object?> get props => [];
}

/// Internal event for optimistic rollback
class _ListRollback<T> extends BaseListProEvent {
  final List<T> previousItems;
  final bool hasMore;
  final dynamic meta;

  const _ListRollback({
    required this.previousItems,
    required this.hasMore,
    this.meta,
  });

  @override
  List<Object?> get props => [previousItems, hasMore, meta];
}
