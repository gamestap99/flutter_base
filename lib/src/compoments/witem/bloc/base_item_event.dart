import 'package:flutter_base/flutter_base.dart';

abstract class BaseItemEvent extends BlocBaseEvent {}

class BaseItemLoadStarted<F> extends BaseItemEvent {
  final F? queryParameters;

  BaseItemLoadStarted({this.queryParameters});

  @override
  List<Object?> get props => [queryParameters];
}

class BaseItemLoadRefresh<F> extends BaseItemEvent {
  final F? queryParameters;

  BaseItemLoadRefresh({this.queryParameters});

  @override
  List<Object?> get props => [queryParameters];
}

class BaseItemUpdate<T> extends BaseItemEvent {
  final T? item;
  final int? ignoreRebuild;

  BaseItemUpdate({
    this.item,
    this.ignoreRebuild,
  });

  @override
  List<Object?> get props => [
        item,
        ignoreRebuild,
      ];
}
