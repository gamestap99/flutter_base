/// BaseListPro BLoC - List management with Pro features
/// Part of BLoC Pro VIP Architecture
library;

import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/bloc_pro_observer.dart';
import '../../../core/cache/lru_cache.dart';
import '../../../core/domain/use_case.dart';
import '../../../core/failure/failure.dart';
import '../../../core/repository/repository.dart';
import '../../../core/result/result.dart';
import '../../../core/retry/retry_config.dart';
import 'base_list_pro_event.dart';
import 'base_list_pro_state.dart';

/// BaseListProBloc with advanced features:
/// - Smart caching with LRU + TTL
/// - Retry mechanism with exponential backoff
/// - Optimistic updates with rollback
/// - Analytics hooks
/// - Simplified state management
class BaseListProBloc<T, F> extends Bloc<BaseListProEvent, BaseListProState<T>> {
  /// Repository for data operations (full interface)
  final ListRepository<T, F>? repository;

  /// Fetch UseCase - for Clean Architecture pattern
  /// Priority: fetchUseCase > repository > legacyApi
  final GetListUseCase<T, F>? fetchUseCase;

  /// Legacy API function (for backward compatibility)
  final Future<Result<ListResponse<T>>> Function(int page, int limit, F? filter)? legacyApi;

  /// Items per page
  final int pageSize;

  /// Smart cache for list data
  final LRUCache<String, ListCacheEntry<T>> _cache;

  /// Retry configuration
  final RetryConfig retryConfig;

  /// Analytics callback
  final void Function(ListAnalyticsEvent)? onAnalytics;

  /// Cache key builder
  final String Function(F? filter)? cacheKeyBuilder;

  /// Current filter
  F? _currentFilter;

  /// Search debouncer
  Timer? _searchDebouncer;

  BaseListProBloc({
    this.repository,
    this.fetchUseCase,
    this.legacyApi,
    this.pageSize = 20,
    int cacheSize = 10,
    Duration cacheTTL = const Duration(minutes: 5),
    this.retryConfig = const RetryConfig(),
    this.onAnalytics,
    this.cacheKeyBuilder,
  })  : _cache = LRUCache(maxSize: cacheSize, defaultTtl: cacheTTL),
        super(const ListInitial()) {
    // Register event handlers
    on<ListLoad<F>>(_onLoad, transformer: restartable());
    on<ListRefresh<F>>(_onRefresh, transformer: droppable());
    on<ListLoadMore<F>>(_onLoadMore, transformer: droppable());
    on<ListSearch<F>>(_onSearch, transformer: restartable());
    on<ListRetry>(_onRetry);
    on<ListUpdateItem<T>>(_onUpdateItem);
    on<ListDeleteItem<T>>(_onDeleteItem);
    on<ListAddItem<T>>(_onAddItem);
    on<ListUpdateItems<T>>(_onUpdateItems);
    on<ListSetItems<T>>(_onSetItems);
    on<ListClearCache>(_onClearCache);
    on<ListReset>(_onReset);
  }

  /// Build cache key from filter
  String _buildCacheKey(F? filter) {
    if (cacheKeyBuilder != null) {
      return cacheKeyBuilder!(filter);
    }
    return filter?.toString() ?? '_default_';
  }

  /// Fetch data using useCase, repository, or legacy API
  /// Priority: fetchUseCase > repository > legacyApi
  Future<Result<ListResponse<T>>> _fetchData(int page, F? filter) async {
    // Priority 1: UseCase (Clean Architecture)
    if (fetchUseCase != null) {
      return fetchUseCase!.call(ListParams(
        page: page,
        limit: pageSize,
        filter: filter,
      ));
    }
    // Priority 2: Repository
    if (repository != null) {
      return repository!.getItems(page: page, limit: pageSize, filter: filter);
    }
    // Priority 3: Legacy API
    if (legacyApi != null) {
      return legacyApi!(page, pageSize, filter);
    }
    return Result.failure(const UnknownFailure(
      message: 'No data source configured',
      code: 'NO_DATA_SOURCE',
    ));
  }

  /// Execute with retry logic
  Future<Result<R>> _executeWithRetry<R>(
    Future<Result<R>> Function() action,
  ) async {
    int attempts = 0;
    Result<R>? lastResult;
    Duration delay = retryConfig.initialDelay;

    while (attempts < retryConfig.maxAttempts) {
      lastResult = await action();

      if (lastResult.isSuccess) return lastResult;

      // Check if should retry
      final failure = lastResult.failureOrNull;
      if (failure != null && !failure.isRetryable) {
        return lastResult;
      }

      attempts++;
      if (attempts < retryConfig.maxAttempts) {
        onAnalytics?.call(ListAnalyticsEvent.retry(attempts));
        await Future.delayed(delay);
        delay = Duration(
          milliseconds: (delay.inMilliseconds * retryConfig.multiplier).round(),
        );
        if (delay > retryConfig.maxDelay) delay = retryConfig.maxDelay;
      }
    }

    return lastResult ??
        Result.failure(const NetworkFailure(
          message: 'Đã vượt quá số lần thử lại',
          code: 'MAX_RETRIES_EXCEEDED',
        ));
  }

  /// Handle load event
  Future<void> _onLoad(ListLoad<F> event, Emitter<BaseListProState<T>> emit) async {
    _currentFilter = event.filter;
    final cacheKey = _buildCacheKey(event.filter);

    // Check cache first (unless force refresh)
    if (!event.forceRefresh) {
      final cached = _cache.get(cacheKey);
      if (cached != null && !cached.isExpired) {
        emit(ListLoaded(
          items: cached.items,
          hasMore: cached.hasMore,
          meta: cached.meta,
          loadedAt: cached.createdAt,
        ));
        onAnalytics?.call(ListAnalyticsEvent.cacheHit(cacheKey));
        return;
      }
    }

    onAnalytics?.call(ListAnalyticsEvent.cacheMiss(cacheKey));

    // Get previous items for loading state
    final previousItems = state.items;
    emit(ListLoading(previousItems: previousItems, isRefresh: false));

    // Fetch data with retry
    final result = await _executeWithRetry(() => _fetchData(1, event.filter));

    result.when(
      success: (response) {
        // Cache the result
        _cache.put(
          cacheKey,
          ListCacheEntry(
            items: response.items,
            hasMore: response.hasMore,
            meta: response.meta,
          ),
        );

        emit(ListLoaded(
          items: response.items,
          hasMore: response.hasMore,
          meta: response.meta,
          loadedAt: DateTime.now(),
          currentPage: 1,
        ));
        onAnalytics?.call(ListAnalyticsEvent.loadSuccess(response.items.length));
      },
      failure: (failure) {
        emit(ListError(
          failure: failure,
          previousItems: previousItems,
        ));
        onAnalytics?.call(ListAnalyticsEvent.loadError(failure));
      },
    );
  }

  /// Handle refresh event
  Future<void> _onRefresh(ListRefresh<F> event, Emitter<BaseListProState<T>> emit) async {
    final filter = event.filter ?? _currentFilter;
    final previousItems = state.items;

    // Emit refreshing state
    if (state is ListLoaded<T>) {
      emit((state as ListLoaded<T>).copyWith(isRefreshing: true));
    } else {
      emit(ListLoading(previousItems: previousItems, isRefresh: true));
    }

    onAnalytics?.call(ListAnalyticsEvent.refresh());

    // Fetch fresh data
    final result = await _fetchData(1, filter);

    result.when(
      success: (response) {
        // Update cache
        final cacheKey = _buildCacheKey(filter);
        _cache.put(
          cacheKey,
          ListCacheEntry(
            items: response.items,
            hasMore: response.hasMore,
            meta: response.meta,
          ),
        );

        emit(ListLoaded(
          items: response.items,
          hasMore: response.hasMore,
          meta: response.meta,
          loadedAt: DateTime.now(),
          currentPage: 1,
        ));
      },
      failure: (failure) {
        emit(ListError(
          failure: failure,
          previousItems: previousItems,
          isRefreshError: true,
        ));
      },
    );
  }

  /// Handle load more event
  Future<void> _onLoadMore(ListLoadMore<F> event, Emitter<BaseListProState<T>> emit) async {
    // Only load more if in loaded state and has more
    if (state is! ListLoaded<T>) return;
    final currentState = state as ListLoaded<T>;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    final filter = event.filter ?? _currentFilter;
    final nextPage = currentState.currentPage + 1;

    // Emit loading more state
    emit(currentState.copyWith(isLoadingMore: true));
    onAnalytics?.call(ListAnalyticsEvent.loadMore(nextPage));

    // Fetch next page
    final result = await _fetchData(nextPage, filter);

    result.when(
      success: (response) {
        emit(currentState.copyWith(
          items: [...currentState.items, ...response.items],
          hasMore: response.hasMore,
          isLoadingMore: false,
          meta: response.meta,
          loadedAt: DateTime.now(),
          currentPage: nextPage,
        ));
      },
      failure: (failure) {
        emit(ListError(
          failure: failure,
          previousItems: currentState.items,
          isLoadMoreError: true,
        ));
      },
    );
  }

  /// Handle search event with debounce
  Future<void> _onSearch(ListSearch<F> event, Emitter<BaseListProState<T>> emit) async {
    _searchDebouncer?.cancel();

    final completer = Completer<void>();
    _searchDebouncer = Timer(Duration(milliseconds: event.debounceMs), () async {
      // Perform search
      add(ListLoad<F>(filter: event.filter, forceRefresh: true));
      completer.complete();
    });

    await completer.future;
  }

  /// Handle retry event
  Future<void> _onRetry(ListRetry event, Emitter<BaseListProState<T>> emit) async {
    if (state is ListError<T>) {
      final errorState = state as ListError<T>;
      add(ListLoad<F>(filter: _currentFilter, forceRefresh: true));
      emit(errorState.copyWith(retryCount: errorState.retryCount + 1));
    }
  }

  /// Handle update item event
  void _onUpdateItem(ListUpdateItem<T> event, Emitter<BaseListProState<T>> emit) {
    if (state is! ListLoaded<T>) return;
    final currentState = state as ListLoaded<T>;

    final updatedItems = currentState.items.map((item) {
      return event.predicate(item) ? event.item : item;
    }).toList();

    emit(currentState.copyWith(items: updatedItems));

    // Invalidate cache
    _cache.clear();
  }

  /// Handle delete item event (with optimistic update)
  Future<void> _onDeleteItem(ListDeleteItem<T> event, Emitter<BaseListProState<T>> emit) async {
    if (state is! ListLoaded<T>) return;
    final currentState = state as ListLoaded<T>;

    // Find and remove item
    final updatedItems = currentState.items.where((item) => !event.predicate(item)).toList();

    if (event.optimistic) {
      // Optimistic update - emit immediately
      emit(currentState.copyWith(items: updatedItems));
      onAnalytics?.call(ListAnalyticsEvent.deleteSuccess());

      // Call API to delete
      if (repository != null) {
        final result = await repository!.deleteItem(event.item);

        result.whenFailure((failure) {
          // Rollback on failure
          emit(currentState);
          onAnalytics?.call(ListAnalyticsEvent.deleteError(failure));
        });
      }
    } else {
      // Non-optimistic - wait for API response
      if (repository != null) {
        final result = await repository!.deleteItem(event.item);

        result.when(
          success: (_) {
            emit(currentState.copyWith(items: updatedItems));
            onAnalytics?.call(ListAnalyticsEvent.deleteSuccess());
          },
          failure: (failure) {
            onAnalytics?.call(ListAnalyticsEvent.deleteError(failure));
          },
        );
      }
    }

    // Invalidate cache
    _cache.clear();
  }

  /// Handle add item event (with optimistic update)
  Future<void> _onAddItem(ListAddItem<T> event, Emitter<BaseListProState<T>> emit) async {
    if (state is! ListLoaded<T>) return;
    final currentState = state as ListLoaded<T>;

    // Add item at position
    final updatedItems = List<T>.from(currentState.items);
    if (event.position == 0) {
      updatedItems.insert(0, event.item);
    } else if (event.position == -1 || event.position >= updatedItems.length) {
      updatedItems.add(event.item);
    } else {
      updatedItems.insert(event.position, event.item);
    }

    if (event.optimistic) {
      // Optimistic update
      emit(currentState.copyWith(items: updatedItems));

      // Call API to create
      if (repository != null) {
        final result = await repository!.createItem(event.item);

        result.whenFailure((failure) {
          // Rollback on failure
          emit(currentState);
        });
      }
    } else {
      // Non-optimistic
      if (repository != null) {
        final result = await repository!.createItem(event.item);

        result.when(
          success: (createdItem) {
            final items = List<T>.from(currentState.items);
            if (event.position == 0) {
              items.insert(0, createdItem);
            } else {
              items.add(createdItem);
            }
            emit(currentState.copyWith(items: items));
          },
          failure: (_) {},
        );
      }
    }

    // Invalidate cache
    _cache.clear();
  }

  /// Handle update items event
  void _onUpdateItems(ListUpdateItems<T> event, Emitter<BaseListProState<T>> emit) {
    if (state is! ListLoaded<T>) return;
    final currentState = state as ListLoaded<T>;

    emit(currentState.copyWith(items: event.items));
    _cache.clear();
  }

  /// Handle set items event
  void _onSetItems(ListSetItems<T> event, Emitter<BaseListProState<T>> emit) {
    emit(ListLoaded(
      items: event.items,
      hasMore: event.hasMore,
      meta: event.meta,
      loadedAt: DateTime.now(),
    ));
  }

  /// Handle clear cache event
  void _onClearCache(ListClearCache event, Emitter<BaseListProState<T>> emit) {
    if (event.cacheKey != null) {
      _cache.remove(event.cacheKey!);
    } else {
      _cache.clear();
    }
  }

  /// Handle reset event
  void _onReset(ListReset event, Emitter<BaseListProState<T>> emit) {
    _cache.clear();
    _currentFilter = null;
    emit(const ListInitial());
  }

  // ========== Public Helper Methods ==========

  /// Load with filter
  void load({F? filter, bool forceRefresh = false}) {
    add(ListLoad<F>(filter: filter, forceRefresh: forceRefresh));
  }

  /// Refresh list
  void refresh({F? filter}) {
    add(ListRefresh<F>(filter: filter));
  }

  /// Load more items
  void loadMore({F? filter}) {
    add(ListLoadMore<F>(filter: filter));
  }

  /// Search with keyword
  void search(String keyword, {F? filter, int debounceMs = 300}) {
    add(ListSearch<F>(keyword: keyword, filter: filter, debounceMs: debounceMs));
  }

  /// Retry after error
  void retry() {
    add(const ListRetry());
  }

  /// Update single item
  void updateItem(T item, {required bool Function(T) predicate}) {
    add(ListUpdateItem<T>(item: item, predicate: predicate));
  }

  /// Delete single item
  void deleteItem(T item, {required bool Function(T) predicate, bool optimistic = true}) {
    add(ListDeleteItem<T>(item: item, predicate: predicate, optimistic: optimistic));
  }

  /// Add item to list
  void addItem(T item, {int position = 0, bool optimistic = true}) {
    add(ListAddItem<T>(item: item, position: position, optimistic: optimistic));
  }

  /// Update all items
  void setItems(List<T> items, {bool hasMore = false, dynamic meta}) {
    add(ListSetItems<T>(items: items, hasMore: hasMore, meta: meta));
  }

  /// Clear cache
  void clearCache({String? cacheKey}) {
    add(ListClearCache(cacheKey: cacheKey));
  }

  /// Reset to initial state
  void reset() {
    add(const ListReset());
  }

  @override
  Future<void> close() {
    _searchDebouncer?.cancel();
    _cache.clear();
    return super.close();
  }
}
