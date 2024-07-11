import 'package:flutter_base/flutter_base.dart';
import 'package:flutter_base/src/core/dio/network_exceptions.dart';

class BaseItemState<T> extends BlocBaseState {
  final T? item;
  final int? ignoreRebuild;

  const BaseItemState({
    this.item,
    this.ignoreRebuild,
    super.status = EBlocStateStatus.idle,
    super.exception,
    super.error,
  });

  BaseItemState<T> asLoading() {
    return copyWith(
      status: EBlocStateStatus.loading,
    );
  }

  BaseItemState<T> asLoadSuccess({
    required T? item,
  }) {
    return copyWith(
      status: EBlocStateStatus.success,
      item: item,
    );
  }

  BaseItemState<T> asLoadFail({
    T? item,
    dynamic error,
  }) {
    return copyWith(
      status: EBlocStateStatus.fail,
      item: item,
      error: error,
      exception: NetworkExceptions.getDioException(error).networkException,
    );
  }

  BaseItemState<T> asLoadingRefresh() {
    return copyWith(
      status: EBlocStateStatus.loadingRefresh,
    );
  }

  BaseItemState<T> asLoadRefreshSuccess({
    required T? item,
  }) {
    return copyWith(
      status: EBlocStateStatus.loadRefreshSuccess,
      item: item,
    );
  }

  BaseItemState<T> asLoadRefreshFail({
    T? item,
    dynamic error,
  }) {
    return copyWith(
      status: EBlocStateStatus.loadRefreshFailure,
      item: item,
      error: error,
      exception: NetworkExceptions.getDioException(error).networkException,
    );
  }

  BaseItemState<T> copyWith({
    T? item,
    int? ignoreRebuild,
    EBlocStateStatus? status,
    dynamic error,
    NetworkException? exception,
  }) {
    return BaseItemState<T>(
      item: item ?? this.item,
      ignoreRebuild: ignoreRebuild ?? this.ignoreRebuild,
      status: status ?? this.status,
      error: error ?? this.error,
      exception: exception ?? this.exception,
    );
  }

  @override
  List<Object?> get props => [
        ignoreRebuild,
        item,
        status,
        exception,
        error,
      ];
}
