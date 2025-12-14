/// BaseItemPro State - Simplified state using sealed classes
/// Part of BLoC Pro VIP Architecture
library;

import 'package:equatable/equatable.dart';
import '../../../core/failure/failure.dart';

/// Simplified item state với 4 trạng thái chính
sealed class BaseItemProState<T> extends Equatable {
  const BaseItemProState();

  /// Check if state has item
  bool get hasItem => switch (this) {
        ItemLoading(:final previousItem) => previousItem != null,
        ItemLoaded(:final item) => item != null,
        ItemError(:final previousItem) => previousItem != null,
        _ => false,
      };

  /// Get item from any state
  T? get item => switch (this) {
        ItemLoading(:final previousItem) => previousItem,
        ItemLoaded(:final item) => item,
        ItemError(:final previousItem) => previousItem,
        _ => null,
      };
}

/// Initial state - chưa có data
class ItemInitial<T> extends BaseItemProState<T> {
  const ItemInitial();

  @override
  List<Object?> get props => [];
}

/// Loading state
class ItemLoading<T> extends BaseItemProState<T> {
  /// Item cũ (nếu có) để hiển thị trong khi loading
  final T? previousItem;

  /// true nếu đang refresh
  final bool isRefresh;

  const ItemLoading({
    this.previousItem,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [previousItem, isRefresh];
}

/// Loaded state - success
class ItemLoaded<T> extends BaseItemProState<T> {
  @override
  final T item;

  /// Thời điểm load data
  final DateTime loadedAt;

  /// true nếu đang update
  final bool isUpdating;

  const ItemLoaded({
    required this.item,
    required this.loadedAt,
    this.isUpdating = false,
  });

  /// Check if data is stale (> 5 minutes)
  bool get isStale => DateTime.now().difference(loadedAt).inMinutes > 5;

  ItemLoaded<T> copyWith({
    T? item,
    DateTime? loadedAt,
    bool? isUpdating,
  }) {
    return ItemLoaded<T>(
      item: item ?? this.item,
      loadedAt: loadedAt ?? this.loadedAt,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [item, loadedAt, isUpdating];
}

/// Error state
class ItemError<T> extends BaseItemProState<T> {
  final Failure failure;

  /// Item cũ nếu có
  final T? previousItem;

  /// Số lần đã retry
  final int retryCount;

  const ItemError({
    required this.failure,
    this.previousItem,
    this.retryCount = 0,
  });

  /// Check if can retry
  bool get canRetry => failure.isRetryable && retryCount < 3;

  /// Get error message
  String get message => failure.message;

  ItemError<T> copyWith({
    Failure? failure,
    T? previousItem,
    int? retryCount,
  }) {
    return ItemError<T>(
      failure: failure ?? this.failure,
      previousItem: previousItem ?? this.previousItem,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  List<Object?> get props => [failure, previousItem, retryCount];
}

/// Extension for convenient state checking
extension BaseItemProStateX<T> on BaseItemProState<T> {
  /// Check if is initial state
  bool get isInitial => this is ItemInitial<T>;

  /// Check if is loading
  bool get isLoading => this is ItemLoading<T>;

  /// Check if is loaded
  bool get isLoaded => this is ItemLoaded<T>;

  /// Check if is error
  bool get isError => this is ItemError<T>;

  /// Check if is refreshing
  bool get isRefreshing => switch (this) {
        ItemLoading(:final isRefresh) => isRefresh,
        _ => false,
      };

  /// Check if is updating
  bool get isUpdating => switch (this) {
        ItemLoaded(:final isUpdating) => isUpdating,
        _ => false,
      };

  /// Get failure if in error state
  Failure? get failure => switch (this) {
        ItemError(:final failure) => failure,
        _ => null,
      };

  /// Cast to ItemLoaded (throws if not loaded)
  ItemLoaded<T> get asLoaded {
    if (this is ItemLoaded<T>) return this as ItemLoaded<T>;
    throw StateError('State is not ItemLoaded: $runtimeType');
  }

  /// Cast to ItemLoaded or null
  ItemLoaded<T>? get asLoadedOrNull {
    return this is ItemLoaded<T> ? this as ItemLoaded<T> : null;
  }

  /// Cast to ItemError or null
  ItemError<T>? get asErrorOrNull {
    return this is ItemError<T> ? this as ItemError<T> : null;
  }
}
