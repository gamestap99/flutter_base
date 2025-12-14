/// BaseListPro State - Simplified state using sealed classes
/// Part of BLoC Pro VIP Architecture
library;

import 'package:equatable/equatable.dart';
import '../../../core/failure/failure.dart';

/// Simplified state với 4 trạng thái chính thay vì 11 enum
/// Sử dụng sealed class để có exhaustive pattern matching
sealed class BaseListProState<T> extends Equatable {
  const BaseListProState();

  /// Check if state has items
  bool get hasItems => switch (this) {
        ListLoading(:final previousItems) => previousItems.isNotEmpty,
        ListLoaded(:final items) => items.isNotEmpty,
        ListError(:final previousItems) => previousItems.isNotEmpty,
        _ => false,
      };

  /// Get items from any state
  List<T> get items => switch (this) {
        ListLoading(:final previousItems) => previousItems,
        ListLoaded(:final items) => items,
        ListError(:final previousItems) => previousItems,
        _ => const [],
      };
}

/// Initial state - chưa có data
class ListInitial<T> extends BaseListProState<T> {
  const ListInitial();

  @override
  List<Object?> get props => [];
}

/// Loading state (initial load hoặc refresh)
/// Giữ previousItems để hiển thị skeleton hoặc data cũ
class ListLoading<T> extends BaseListProState<T> {
  @override
  final List<T> previousItems;

  /// true nếu đang refresh (pull to refresh)
  final bool isRefresh;

  const ListLoading({
    this.previousItems = const [],
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [previousItems, isRefresh];
}

/// Loaded state - success với tất cả thông tin
/// Đây là state chính sau khi load thành công
class ListLoaded<T> extends BaseListProState<T> {
  @override
  final List<T> items;

  /// true nếu còn data để load thêm
  final bool hasMore;

  /// true nếu đang load more
  final bool isLoadingMore;

  /// true nếu đang refresh
  final bool isRefreshing;

  /// Metadata pagination
  final dynamic meta;

  /// Thời điểm load data
  final DateTime loadedAt;

  /// Current page (for pagination)
  final int currentPage;

  const ListLoaded({
    required this.items,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.meta,
    required this.loadedAt,
    this.currentPage = 1,
  });

  /// Check if data is stale (> 5 minutes)
  bool get isStale => DateTime.now().difference(loadedAt).inMinutes > 5;

  /// Total items count
  int get count => items.length;

  /// Check if list is empty
  bool get isEmpty => items.isEmpty;

  /// Check if list is not empty
  bool get isNotEmpty => items.isNotEmpty;

  ListLoaded<T> copyWith({
    List<T>? items,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
    dynamic meta,
    DateTime? loadedAt,
    int? currentPage,
  }) {
    return ListLoaded<T>(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      meta: meta ?? this.meta,
      loadedAt: loadedAt ?? this.loadedAt,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
        items,
        hasMore,
        isLoadingMore,
        isRefreshing,
        meta,
        loadedAt,
        currentPage,
      ];
}

/// Error state - khi có lỗi xảy ra
/// Giữ previousItems để user vẫn thấy data cũ
class ListError<T> extends BaseListProState<T> {
  final Failure failure;

  @override
  final List<T> previousItems;

  /// Số lần đã retry
  final int retryCount;

  /// true nếu error xảy ra khi load more
  final bool isLoadMoreError;

  /// true nếu error xảy ra khi refresh
  final bool isRefreshError;

  const ListError({
    required this.failure,
    this.previousItems = const [],
    this.retryCount = 0,
    this.isLoadMoreError = false,
    this.isRefreshError = false,
  });

  /// Check if can retry
  bool get canRetry => failure.isRetryable && retryCount < 3;

  /// Get error message
  String get message => failure.message;

  ListError<T> copyWith({
    Failure? failure,
    List<T>? previousItems,
    int? retryCount,
    bool? isLoadMoreError,
    bool? isRefreshError,
  }) {
    return ListError<T>(
      failure: failure ?? this.failure,
      previousItems: previousItems ?? this.previousItems,
      retryCount: retryCount ?? this.retryCount,
      isLoadMoreError: isLoadMoreError ?? this.isLoadMoreError,
      isRefreshError: isRefreshError ?? this.isRefreshError,
    );
  }

  @override
  List<Object?> get props => [
        failure,
        previousItems,
        retryCount,
        isLoadMoreError,
        isRefreshError,
      ];
}

/// Extension for convenient state checking
extension BaseListProStateX<T> on BaseListProState<T> {
  /// Check if is initial state
  bool get isInitial => this is ListInitial<T>;

  /// Check if is loading
  bool get isLoading => this is ListLoading<T>;

  /// Check if is loaded
  bool get isLoaded => this is ListLoaded<T>;

  /// Check if is error
  bool get isError => this is ListError<T>;

  /// Check if is refreshing
  bool get isRefreshing => switch (this) {
        ListLoading(:final isRefresh) => isRefresh,
        ListLoaded(:final isRefreshing) => isRefreshing,
        _ => false,
      };

  /// Check if is loading more
  bool get isLoadingMore => switch (this) {
        ListLoaded(:final isLoadingMore) => isLoadingMore,
        _ => false,
      };

  /// Get failure if in error state
  Failure? get failure => switch (this) {
        ListError(:final failure) => failure,
        _ => null,
      };

  /// Check if has more items to load
  bool get hasMore => switch (this) {
        ListLoaded(:final hasMore) => hasMore,
        _ => false,
      };

  /// Cast to ListLoaded (throws if not loaded)
  ListLoaded<T> get asLoaded {
    if (this is ListLoaded<T>) return this as ListLoaded<T>;
    throw StateError('State is not ListLoaded: $runtimeType');
  }

  /// Cast to ListLoaded or null
  ListLoaded<T>? get asLoadedOrNull {
    return this is ListLoaded<T> ? this as ListLoaded<T> : null;
  }

  /// Cast to ListError or null
  ListError<T>? get asErrorOrNull {
    return this is ListError<T> ? this as ListError<T> : null;
  }
}
