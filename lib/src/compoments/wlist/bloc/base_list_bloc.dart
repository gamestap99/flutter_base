import 'package:flutter_base/flutter_base.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BaseListBloc<T, F> extends BlocBaseMain<BaseListEvent, BaseListState<T>> {
  Future<ItemsResEntity<T>> Function(int page, int limmit, F? filter)? api;

  BaseListBloc({this.api, int limit = 12}) : super(BaseListState<T>(limit: limit)) {
    on<BaseListUpdate<T>>(_onUpdateItems, transformer: sequential());
    on<BaseListAddInitItem<T>>(_onUpdateAddInit, transformer: sequential());
    on<BaseListLoadStarted<F>>(_onLoadStarted);
    on<BaseListSearchStarted<F>>(_onSearchStarted);
    on<BaseListLoadMoreStarted<F>>(_onLoadMoreStarted);
    on<BaseListLoadRefresh<F>>(_onLoadRefresh);
  }

  Map<String, dynamic> cacheSearch = {};
  F? filter;

  Future<void> _onLoadStarted(BaseListLoadStarted<F> event, Emitter<BaseListState<T>> emit) async {
    if (api == null) return;
    await runSafeCall<ItemsResEntity<T>>(
      onStart: () {
        emit(state.asLoading());
      },
      onError: (error) {
        emit(state.asLoadFail(error: error));
      },
      onSuccess: (rs) {
        final data = rs;

        if (data.success) {
          cacheSearch = {
            ...cacheSearch,
            '': {
              "items": data.items ?? [],
              "oLinks": data.links,
              "oMeta": data.meta,
            },
          };

          filter = event.queryParameters;

          emit(state.asLoadSuccess(
            items: data.items ?? [],
            oLinks: data.links,
            oMeta: data.meta,
          ));
        }
      },
      dataApi: this.api!.call(1, state.limit, event.queryParameters),
    );
  }

  Future<void> _onSearchStarted(BaseListSearchStarted<F> event, Emitter<BaseListState<T>> emit) async {
    if (api == null) return;

    await safeCall(
      onCall: () async {
        emit(state.asLoading());

        if (cacheSearch.containsKey(event.keySearch) && filter != event.queryParameters) {
          final data = cacheSearch[event.keySearch];

          return emit(state.asLoadSuccess(
            items: data['items'] ?? [],
            oLinks: data['oLinks'],
            oMeta: data['oMeta'],
          ));
        } else {
          final data = await this.api!.call(1, state.limit, event.queryParameters);

          if (data.success) {
            cacheSearch = {
              ...cacheSearch,
              event.keySearch: {
                "items": data.items ?? [],
                "oLinks": data.links,
                "oMeta": data.meta,
              },
            };

            filter = event.queryParameters;

            emit(state.asLoadSuccess(
              items: data.items ?? [],
              oLinks: data.links,
              oMeta: data.meta,
            ));
          }
        }
      },
      onError: (ex) async {
        emit(state.asLoadFail(error: ex));
      },
    );
  }

  Future<void> _onLoadRefresh(BaseListLoadRefresh<F> event, Emitter<BaseListState<T>> emit) async {
    if (api == null) return;

    await runSafeCall<ItemsResEntity<T>>(
      onStart: () {
        emit(state.asLoadingRefresh());
      },
      onError: (error) {
        emit(state.asLoadRefreshFail(error: error));
      },
      onSuccess: (rs) {
        final data = rs;

        if (data.success) {
          emit(state.asLoadRefreshSuccess(
            items: List<T>.from(data.items ?? []),
            oLinks: data.links,
            oMeta: data.meta,
          ));
        }
      },
      dataApi: this.api!.call(1, state.limit, event.queryParameters),
    );
  }

  Future<void> _onLoadMoreStarted(BaseListLoadMoreStarted<F> event, Emitter<BaseListState<T>> emit) async {
    if (api == null) {
      return;
    }

    if (!state.isNextPageAvailable) {
      return;
    }

    await runSafeCall<ItemsResEntity<T>>(
      onStart: () {
        emit(state.asLoadingMore());
      },
      onError: (error) {
        emit(state.asLoadMoreFailure(error));
      },
      onSuccess: (rs) {
        final data = rs;

        if (data.success) {
          emit(state.asLoadMoreSuccess(
            items: data.items ?? [],
            oLinks: data.links,
            oMeta: data.meta,
          ));
        }
      },
      dataApi: this.api!.call((state.items.length ~/ state.limit) + 1, state.limit, event.queryParameters),
    );
  }

  void _onUpdateItems(BaseListUpdate<T> event, Emitter<BaseListState<T>> emit) {
    emit(state.copyWith(
      items: List<T>.from(event.items),
    ));
  }

  void _onUpdateAddInit(BaseListAddInitItem<T> event, Emitter<BaseListState<T>> emit) {
    emit(state.copyWith(
      initItem: event.item,
    ));
  }

  void setItems({required List<T> items}) {
    add(
      BaseListUpdate(
        items: items,
      ),
    );
  }

  void setInitItem({required T item}) {
    add(
      BaseListAddInitItem<T>(
        item: item,
      ),
    );
  }

  void onInit(F filter) {
    add(BaseListLoadStarted<F>(
      queryParameters: filter,
    ));
  }

  void onLoadMore(F filter) {
    add(BaseListLoadMoreStarted<F>(
      queryParameters: filter,
    ));
  }

  void onRefresh(F filter) {
    add(BaseListLoadRefresh<F>(
      queryParameters: filter,
    ));
  }
}
