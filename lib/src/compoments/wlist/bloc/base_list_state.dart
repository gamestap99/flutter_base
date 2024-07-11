
import 'package:flutter_base/flutter_base.dart';
import 'package:flutter_base/src/core/dio/network_exceptions.dart';


class BaseListState<T> extends BlocBaseState {
  final List<T> items;
  final bool isNextPageAvailable;
  final PaginateLinksEntity? oLinks;
  final PaginateMetaEntity? oMeta;
  final int limit;
  final T? initItem;

  const BaseListState({
    this.items = const [],
    this.isNextPageAvailable = false,
    this.oLinks,
    this.oMeta,
    this.initItem,
    this.limit = 12,
    super.status = EBlocStateStatus.idle,
    super.exception,
    super.error,
  });

  BaseListState<T> asLoading() {
    return copyWith(
      status: EBlocStateStatus.loading,
    );
  }

  BaseListState<T> asLoadSuccess({
    required List<T> items,
    bool? isNextPageAvailable,
    PaginateLinksEntity? oLinks,
    PaginateMetaEntity? oMeta,
  }) {
    return copyWith(
      status: EBlocStateStatus.success,
      items: items,
      isNextPageAvailable: isNextPageAvailable ?? (oMeta != null && oMeta.nextPage != null),
      oLinks: oLinks,
      oMeta: oMeta,
      limit: oMeta?.perPage,
    );
  }

  BaseListState<T> asLoadFail({
    List<T>? items,
    dynamic error,
  }) {
    return copyWith(
      status: EBlocStateStatus.fail,
      items: items,
      error: error,
      exception: NetworkExceptions.getDioException(error).networkException,
    );
  }

  BaseListState<T> asLoadingMore() {
    return copyWith(
      status: EBlocStateStatus.loadingMore,
    );
  }

  BaseListState<T> asLoadMoreFailure(dynamic error) {
    return copyWith(
      status: EBlocStateStatus.loadMoreFailure,
      error: error,
      exception: NetworkExceptions.getDioException(error).networkException,
    );
  }

  BaseListState<T> asLoadMoreSuccess({
    required List<T> items,
    bool? isNextPageAvailable,
    PaginateLinksEntity? oLinks,
    PaginateMetaEntity? oMeta,
  }) {
    return copyWith(
      status: EBlocStateStatus.loadMoreSuccess,
      items: [...this.items, ...items],
      isNextPageAvailable: isNextPageAvailable ?? (oMeta != null && oMeta.nextPage != null),
      oLinks: oLinks,
      oMeta: oMeta,
      limit: oMeta?.perPage,
    );
  }

  BaseListState<T> asLoadingRefresh() {
    return copyWith(
      status: EBlocStateStatus.loadingRefresh,
    );
  }

  BaseListState<T> asLoadRefreshSuccess({
    required List<T> items,
    bool? isNextPageAvailable,
    PaginateLinksEntity? oLinks,
    PaginateMetaEntity? oMeta,
  }) {
    return copyWith(
      status: EBlocStateStatus.loadRefreshSuccess,
      items: items,
      isNextPageAvailable: isNextPageAvailable ?? (oMeta != null && oMeta.nextPage != null),
      oLinks: oLinks,
      oMeta: oMeta,
      limit: oMeta?.perPage,
    );
  }

  BaseListState<T> asLoadRefreshFail({
    List<T>? items,
    dynamic error,
  }) {
    return copyWith(
      status: EBlocStateStatus.loadRefreshFailure,
      items: items,
      error: error,
      exception: NetworkExceptions.getDioException(error).networkException,
    );
  }

  BaseListState<T> copyWith({
    List<T>? items,
    EBlocStateStatus? status,
    T? initItem,
    bool? isNextPageAvailable,
    int? limit,
    PaginateLinksEntity? oLinks,
    PaginateMetaEntity? oMeta,
    dynamic error,
    NetworkException? exception,
  }) {
    return BaseListState<T>(
      items: items ?? this.items,
      status: status ?? this.status,
      initItem: initItem ?? this.initItem,
      isNextPageAvailable: isNextPageAvailable ?? this.isNextPageAvailable,
      limit: limit ?? this.limit,
      oLinks: oLinks ?? this.oLinks,
      oMeta: oMeta ?? this.oMeta,
      error: error ?? this.error,
      exception: exception ?? this.exception,
    );
  }

  @override
  List<Object?> get props => [
        items,
        status,
        initItem,
        isNextPageAvailable,
        limit,
        oLinks,
        oMeta,
        error,
        exception,
      ];
}
