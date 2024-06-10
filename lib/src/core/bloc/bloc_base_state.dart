
import 'package:equatable/equatable.dart';

import '../dio/network_exceptions.dart';

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
}

abstract class BlocBaseState extends Equatable {
  final EBlocStateStatus status;
  final dynamic error;
  final NetworkException? exception;

  const BlocBaseState({
    required this.status,
    this.error,
    this.exception,
  });
}
