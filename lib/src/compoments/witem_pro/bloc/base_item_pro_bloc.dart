/// BaseItemPro BLoC - Item management with Pro features
/// Part of BLoC Pro VIP Architecture
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/bloc_pro_observer.dart';
import '../../../core/failure/failure.dart';
import '../../../core/repository/repository.dart';
import '../../../core/result/result.dart';
import '../../../core/retry/retry_config.dart';
import 'base_item_pro_event.dart';
import 'base_item_pro_state.dart';

/// BaseItemProBloc with advanced features:
/// - Smart refresh (only if stale)
/// - Optimistic updates with rollback
/// - Retry mechanism
/// - Analytics hooks
class BaseItemProBloc<T, F> extends Bloc<BaseItemProEvent, BaseItemProState<T>> {
  /// Repository for data operations
  final ItemRepository<T, F>? repository;

  /// Legacy API function (for backward compatibility)
  final Future<Result<T>> Function(F? filter)? legacyApi;

  /// Retry configuration
  final RetryConfig retryConfig;

  /// Analytics callback
  final void Function(ItemAnalyticsEvent)? onAnalytics;

  /// Stale duration (how long before data is considered stale)
  final Duration staleDuration;

  /// Current filter
  F? _currentFilter;

  BaseItemProBloc({
    this.repository,
    this.legacyApi,
    this.retryConfig = const RetryConfig(),
    this.onAnalytics,
    this.staleDuration = const Duration(minutes: 5),
  }) : super(const ItemInitial()) {
    on<ItemLoad<F>>(_onLoad);
    on<ItemRefresh<F>>(_onRefresh);
    on<ItemRetry>(_onRetry);
    on<ItemUpdate<T>>(_onUpdate);
    on<ItemOptimisticUpdate<T>>(_onOptimisticUpdate);
    on<ItemPatch<T>>(_onPatch);
    on<ItemDelete>(_onDelete);
    on<ItemSet<T>>(_onSet);
    on<ItemReset>(_onReset);
  }

  /// Fetch data using repository or legacy API
  Future<Result<T>> _fetchData(F? filter) async {
    if (repository != null) {
      return repository!.getItem(filter as F);
    }
    if (legacyApi != null) {
      return legacyApi!(filter);
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

      final failure = lastResult.failureOrNull;
      if (failure != null && !failure.isRetryable) {
        return lastResult;
      }

      attempts++;
      if (attempts < retryConfig.maxAttempts) {
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
  Future<void> _onLoad(ItemLoad<F> event, Emitter<BaseItemProState<T>> emit) async {
    _currentFilter = event.filter;

    // Get previous item for loading state
    final previousItem = state.item;
    emit(ItemLoading(previousItem: previousItem, isRefresh: false));

    // Fetch data with retry
    final result = await _executeWithRetry(() => _fetchData(event.filter));

    result.when(
      success: (item) {
        emit(ItemLoaded(item: item, loadedAt: DateTime.now()));
        onAnalytics?.call(ItemAnalyticsEvent.loadSuccess());
      },
      failure: (failure) {
        emit(ItemError(failure: failure, previousItem: previousItem));
        onAnalytics?.call(ItemAnalyticsEvent.loadError(failure));
      },
    );
  }

  /// Handle refresh event (smart refresh)
  Future<void> _onRefresh(ItemRefresh<F> event, Emitter<BaseItemProState<T>> emit) async {
    final filter = event.filter ?? _currentFilter;

    // Smart refresh: skip if data is fresh and not forced
    if (!event.force && state is ItemLoaded<T>) {
      final loaded = state as ItemLoaded<T>;
      if (!loaded.isStale) {
        return; // Data is fresh, skip refresh
      }
    }

    final previousItem = state.item;
    emit(ItemLoading(previousItem: previousItem, isRefresh: true));

    final result = await _fetchData(filter);

    result.when(
      success: (item) {
        emit(ItemLoaded(item: item, loadedAt: DateTime.now()));
        onAnalytics?.call(ItemAnalyticsEvent.loadSuccess());
      },
      failure: (failure) {
        emit(ItemError(failure: failure, previousItem: previousItem));
        onAnalytics?.call(ItemAnalyticsEvent.loadError(failure));
      },
    );
  }

  /// Handle retry event
  Future<void> _onRetry(ItemRetry event, Emitter<BaseItemProState<T>> emit) async {
    if (state is ItemError<T>) {
      final errorState = state as ItemError<T>;
      emit(errorState.copyWith(retryCount: errorState.retryCount + 1));
      add(ItemLoad<F>(filter: _currentFilter, forceRefresh: true));
    }
  }

  /// Handle update event
  void _onUpdate(ItemUpdate<T> event, Emitter<BaseItemProState<T>> emit) {
    emit(ItemLoaded(item: event.item, loadedAt: DateTime.now()));
  }

  /// Handle optimistic update with rollback
  Future<void> _onOptimisticUpdate(
    ItemOptimisticUpdate<T> event,
    Emitter<BaseItemProState<T>> emit,
  ) async {
    if (state is! ItemLoaded<T>) return;
    final currentState = state as ItemLoaded<T>;

    // Optimistic update
    emit(currentState.copyWith(item: event.updatedItem, isUpdating: true));
    onAnalytics?.call(ItemAnalyticsEvent.optimisticUpdate());

    if (event.persistToServer && repository != null) {
      final result = await repository!.updateItem(event.updatedItem);

      result.when(
        success: (updatedItem) {
          emit(ItemLoaded(item: updatedItem, loadedAt: DateTime.now()));
          onAnalytics?.call(ItemAnalyticsEvent.updateSuccess());
        },
        failure: (failure) {
          // Rollback
          emit(currentState);
          onAnalytics?.call(ItemAnalyticsEvent.rollback());
          onAnalytics?.call(ItemAnalyticsEvent.updateError(failure));
        },
      );
    } else {
      emit(currentState.copyWith(item: event.updatedItem, isUpdating: false));
    }
  }

  /// Handle patch event
  Future<void> _onPatch(ItemPatch<T> event, Emitter<BaseItemProState<T>> emit) async {
    if (state is! ItemLoaded<T>) return;
    final currentState = state as ItemLoaded<T>;

    // Apply changes locally
    final patchedItem = event.applyChanges(currentState.item, event.changes);

    // Optimistic update
    emit(currentState.copyWith(item: patchedItem, isUpdating: true));

    if (repository != null) {
      final result = await repository!.patchItem(currentState.item, event.changes);

      result.when(
        success: (updatedItem) {
          emit(ItemLoaded(item: updatedItem, loadedAt: DateTime.now()));
        },
        failure: (failure) {
          // Rollback
          emit(currentState);
        },
      );
    } else {
      emit(currentState.copyWith(item: patchedItem, isUpdating: false));
    }
  }

  /// Handle delete event
  Future<void> _onDelete(ItemDelete event, Emitter<BaseItemProState<T>> emit) async {
    if (state is! ItemLoaded<T>) return;
    final currentState = state as ItemLoaded<T>;

    if (repository != null) {
      emit(currentState.copyWith(isUpdating: true));

      final result = await repository!.deleteItem(currentState.item);

      result.when(
        success: (_) {
          emit(const ItemInitial());
        },
        failure: (failure) {
          emit(currentState.copyWith(isUpdating: false));
        },
      );
    }
  }

  /// Handle set event
  void _onSet(ItemSet<T> event, Emitter<BaseItemProState<T>> emit) {
    emit(ItemLoaded(item: event.item, loadedAt: DateTime.now()));
  }

  /// Handle reset event
  void _onReset(ItemReset event, Emitter<BaseItemProState<T>> emit) {
    _currentFilter = null;
    emit(const ItemInitial());
  }

  // ========== Public Helper Methods ==========

  /// Load item
  void load({F? filter, bool forceRefresh = false}) {
    add(ItemLoad<F>(filter: filter, forceRefresh: forceRefresh));
  }

  /// Refresh item (smart refresh)
  void refresh({F? filter, bool force = false}) {
    add(ItemRefresh<F>(filter: filter, force: force));
  }

  /// Retry after error
  void retry() {
    add(const ItemRetry());
  }

  /// Update item
  void updateItem(T item) {
    add(ItemUpdate<T>(item: item));
  }

  /// Optimistic update
  void optimisticUpdate(T item, {bool persistToServer = true}) {
    add(ItemOptimisticUpdate<T>(updatedItem: item, persistToServer: persistToServer));
  }

  /// Patch item
  void patch(
    Map<String, dynamic> changes, {
    required T Function(T current, Map<String, dynamic> changes) applyChanges,
  }) {
    add(ItemPatch<T>(changes: changes, applyChanges: applyChanges));
  }

  /// Delete item
  void delete() {
    add(const ItemDelete());
  }

  /// Set item directly
  void setItem(T item) {
    add(ItemSet<T>(item: item));
  }

  /// Reset to initial state
  void reset() {
    add(const ItemReset());
  }
}
