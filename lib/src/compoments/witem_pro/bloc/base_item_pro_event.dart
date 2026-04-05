/// BaseItemPro Events
/// Part of BLoC Pro VIP Architecture
library;

import 'package:equatable/equatable.dart';

/// Base event for item operations
sealed class BaseItemProEvent extends Equatable {
  const BaseItemProEvent();
}

/// Load item
class ItemLoad<F> extends BaseItemProEvent {
  final F? filter;

  /// Force reload, ignore stale check
  final bool forceRefresh;

  const ItemLoad({
    this.filter,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [filter, forceRefresh];
}

/// Refresh item
class ItemRefresh<F> extends BaseItemProEvent {
  final F? filter;

  /// Force refresh even if data is fresh
  final bool force;

  const ItemRefresh({
    this.filter,
    this.force = false,
  });

  @override
  List<Object?> get props => [filter, force];
}

/// Retry after error
class ItemRetry extends BaseItemProEvent {
  const ItemRetry();

  @override
  List<Object?> get props => [];
}

/// Update item (replace current item)
class ItemUpdate<T> extends BaseItemProEvent {
  final T item;

  const ItemUpdate({required this.item});

  @override
  List<Object?> get props => [item];
}

/// Optimistic update with rollback on failure
class ItemOptimisticUpdate<T> extends BaseItemProEvent {
  final T updatedItem;

  /// API call to persist update
  final bool persistToServer;

  const ItemOptimisticUpdate({
    required this.updatedItem,
    this.persistToServer = true,
  });

  @override
  List<Object?> get props => [updatedItem, persistToServer];
}

/// Partial update (patch)
class ItemPatch<T> extends BaseItemProEvent {
  final Map<String, dynamic> changes;

  /// Function to apply changes to current item
  final T Function(T current, Map<String, dynamic> changes) applyChanges;

  const ItemPatch({
    required this.changes,
    required this.applyChanges,
  });

  @override
  List<Object?> get props => [changes];
}

/// Delete item
class ItemDelete extends BaseItemProEvent {
  const ItemDelete();

  @override
  List<Object?> get props => [];
}

/// Reset to initial state
class ItemReset extends BaseItemProEvent {
  const ItemReset();

  @override
  List<Object?> get props => [];
}

/// Set item directly (for local updates)
class ItemSet<T> extends BaseItemProEvent {
  final T item;

  const ItemSet({required this.item});

  @override
  List<Object?> get props => [item];
}
