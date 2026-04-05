/// Repository interfaces for BLoC Pro VIP
/// Part of BLoC Pro VIP Architecture
library;

import 'package:flutter_base/flutter_base.dart';

/// Abstract repository for list operations
/// Implement this for testable list data sources
abstract class ListRepository<T, F> {
  /// Fetch paginated items
  Future<Result<ListResponse<T>>> getItems({
    required int page,
    required int limit,
    F? filter,
  });

  /// Create a new item
  Future<Result<T>> createItem(T item);

  /// Update an existing item
  Future<Result<T>> updateItem(T item);

  /// Delete an item
  Future<Result<void>> deleteItem(T item);

  /// Optional: Batch delete
  Future<Result<void>> deleteItems(List<T> items) async {
    for (final item in items) {
      final result = await deleteItem(item);
      if (result.isFailure) return result;
    }
    return const Result.success(null);
  }
}

/// Response wrapper for list operations
class ListResponse<T> {
  final List<T> items;
  final bool hasMore;
  final int? totalCount;
  final int? currentPage;
  final int? totalPages;
  final dynamic meta;

  const ListResponse({
    required this.items,
    this.hasMore = false,
    this.totalCount,
    this.currentPage,
    this.totalPages,
    this.meta,
  });

  /// Create empty response
  factory ListResponse.empty() => const ListResponse(items: []);

  /// Create from existing BaseListState compatible format
  factory ListResponse.fromMeta({
    required List<T> items,
    PaginateMetaEntity? meta,
  }) {
    return ListResponse(
      items: items,
      hasMore: meta?.nextPage != null,
      totalCount: meta?.totalCount,
      currentPage: meta?.currentPage,
      totalPages: meta?.pageCount,
      meta: meta,
    );
  }

  ListResponse<T> copyWith({
    List<T>? items,
    bool? hasMore,
    int? totalCount,
    int? currentPage,
    int? totalPages,
    dynamic meta,
  }) {
    return ListResponse(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      meta: meta ?? this.meta,
    );
  }
}

/// Abstract repository for single item operations
abstract class ItemRepository<T, F> {
  /// Fetch single item
  Future<Result<T>> getItem(F filter);

  /// Update item
  Future<Result<T>> updateItem(T item);

  /// Partial update
  Future<Result<T>> patchItem(T item, Map<String, dynamic> changes);

  /// Delete item
  Future<Result<void>> deleteItem(T item);
}

/// Abstract repository for form submission
abstract class FormRepository<T> {
  /// Submit form data and return result
  Future<Result<T>> submit(Map<String, dynamic> values);

  /// Validate field async (e.g., check email exists)
  Future<Result<bool>> validateField(String field, dynamic value) async {
    return const Result.success(true);
  }

  /// Save draft locally
  Future<Result<void>> saveDraft(Map<String, dynamic> values);

  /// Load draft
  Future<Result<Map<String, dynamic>?>> loadDraft();

  /// Clear draft
  Future<Result<void>> clearDraft();
}

/// Adapter to convert legacy API functions to ListRepository
class LegacyListRepositoryAdapter<T, F> implements ListRepository<T, F> {
  final Future<dynamic> Function(int page, int limit, F? filter) legacyApi;
  final T Function(Map<String, dynamic>) fromJson;
  
  const LegacyListRepositoryAdapter({
    required this.legacyApi,
    required this.fromJson,
  });

  @override
  Future<Result<ListResponse<T>>> getItems({
    required int page,
    required int limit,
    F? filter,
  }) async {
    try {
      final response = await legacyApi(page, limit, filter);
      
      // Assuming response has items, meta similar to ItemsResEntity
      final items = (response.items as List?)
          ?.map((e) => fromJson(e as Map<String, dynamic>))
          .toList() ?? <T>[];
      
      return Result.success(ListResponse(
        items: items,
        hasMore: response.meta?.nextPage != null,
        meta: response.meta,
      ));
    } catch (e, st) {
      return Result.failure(UnknownFailure.fromException(e, st));
    }
  }

  @override
  Future<Result<T>> createItem(T item) async {
    throw UnimplementedError('createItem not supported in legacy adapter');
  }

  @override
  Future<Result<T>> updateItem(T item) async {
    throw UnimplementedError('updateItem not supported in legacy adapter');
  }

  @override
  Future<Result<void>> deleteItem(T item) async {
    throw UnimplementedError('deleteItem not supported in legacy adapter');
  }

  @override
  Future<Result<void>> deleteItems(List<T> items) async {
    throw UnimplementedError('deleteItems not supported in legacy adapter');
  }
}

/// Extension for easy repository result handling
extension RepositoryResultX<T> on Future<Result<T>> {
  /// Handle result with callbacks
  Future<void> handle({
    required void Function(T data) onSuccess,
    required void Function(Failure failure) onFailure,
  }) async {
    final result = await this;
    result.when(
      success: onSuccess,
      failure: onFailure,
    );
  }
}

/// Mixin for caching repository responses
mixin CacheableRepository<K, V> {
  final Map<K, _CachedValue<V>> _cache = {};
  
  Duration get cacheDuration => const Duration(minutes: 5);
  
  V? getCached(K key) {
    final cached = _cache[key];
    if (cached == null) return null;
    if (cached.isExpired) {
      _cache.remove(key);
      return null;
    }
    return cached.value;
  }
  
  void setCache(K key, V value) {
    _cache[key] = _CachedValue(value, DateTime.now(), cacheDuration);
  }
  
  void invalidateCache([K? key]) {
    if (key != null) {
      _cache.remove(key);
    } else {
      _cache.clear();
    }
  }
}

class _CachedValue<V> {
  final V value;
  final DateTime createdAt;
  final Duration ttl;
  
  _CachedValue(this.value, this.createdAt, this.ttl);
  
  bool get isExpired => DateTime.now().difference(createdAt) > ttl;
}
