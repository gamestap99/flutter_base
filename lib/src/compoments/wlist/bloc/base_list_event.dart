import 'package:flutter_base/flutter_base.dart';

abstract class BaseListEvent extends BlocBaseEvent {}

class BaseListLoadStarted<F> extends BaseListEvent {
  final F? queryParameters;

  BaseListLoadStarted({this.queryParameters});

  @override
  List<Object?> get props => [queryParameters];
}

class BaseListSearchStarted<F> extends BaseListEvent {
  final String keySearch;
  final F? queryParameters;

  BaseListSearchStarted({required this.keySearch, this.queryParameters});

  @override
  List<Object?> get props => [keySearch, queryParameters];
}

class BaseListLoadMoreStarted<F> extends BaseListEvent {
  final F? queryParameters;

  BaseListLoadMoreStarted({this.queryParameters});

  @override
  List<Object?> get props => [queryParameters];
}

class BaseListLoadRefresh<F> extends BaseListEvent {
  final F? queryParameters;

  BaseListLoadRefresh({this.queryParameters});

  @override
  List<Object?> get props => [queryParameters];
}

class BaseListUpdate<T> extends BaseListEvent {
  final List<T> items;

  BaseListUpdate({required this.items}) : super();

  @override
  List<Object?> get props => [items];
}

class BaseListAddInitItem<T> extends BaseListEvent {
  final T? item;

  BaseListAddInitItem({required this.item}) : super();

  @override
  List<Object?> get props => [item];
}
