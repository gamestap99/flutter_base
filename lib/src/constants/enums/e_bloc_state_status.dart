enum EBlocStateStatus {
  idle,
  loading,
  success,
  fail,
  warning,
  loadingMore,
  loadMoreFailure,
  loadMoreSuccess,
  loadingRefresh,
  loadRefreshFailure,
  loadRefreshSuccess,
}

extension EBlocStateStatusX on EBlocStateStatus {
  bool get isSuccess => this == EBlocStateStatus.success;

  bool get isLoading => this == EBlocStateStatus.loading;

  bool get isFail => this == EBlocStateStatus.fail;
}
