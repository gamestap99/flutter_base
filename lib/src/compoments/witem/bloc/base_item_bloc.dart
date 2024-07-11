import 'package:flutter_base/flutter_base.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'index.dart';

class BaseItemBloc<T, F> extends BlocBaseMain<BaseItemEvent, BaseItemState<T>> {
  Future<ItemResEntity<T>> Function(F? filter)? api;

  BaseItemBloc({
    this.api,
  }) : super(BaseItemState<T>()) {
    on(_onLoadStarted);
    on(_onLoadRefresh);
    on(_onUpdateItem);
  }

  Future<void> _onLoadStarted(BaseItemLoadStarted<F> event, Emitter<BaseItemState<T>> emit) async {
    if (api == null) return;
    if (state.status.isLoading) return;

    await runSafeCall<ItemResEntity<T>>(
      onStart: () {
        emit(state.asLoading());
      },
      onError: (error) {
        emit(state.asLoadFail(error: error));
      },
      onSuccess: (rs) {
        final data = rs;

        // if (data.success) {
        //
        // }else{
        //   emit(state.asLoadFail(error: []));
        // }

        emit(state.asLoadSuccess(
          item: data.data,
        ));
      },
      dataApi: this.api!.call(event.queryParameters),
    );
  }

  Future<void> _onLoadRefresh(BaseItemLoadRefresh<F> event, Emitter<BaseItemState<T>> emit) async {
    if (api == null) return;

    await runSafeCall<ItemResEntity<T>>(
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
            item: data.data,
          ));
        }
      },
      dataApi: this.api!.call(event.queryParameters),
    );
  }

  Future<void> _onUpdateItem(BaseItemUpdate<T> event, Emitter<BaseItemState<T>> emit) async {
    await safeCall(
      onCall: () async {
        emit(state.copyWith(
          status: event.item != null ? EBlocStateStatus.success : null,
          item: event.item,
          ignoreRebuild: event.ignoreRebuild,
        ));
      },
      onError: (ex) async {},
    );
  }

  void onUpdateItem(T? item, {int? ignoreRebuild}) {
    add(BaseItemUpdate<T>(
      item: item,
      ignoreRebuild: ignoreRebuild,
    ));
  }

  void onInit() {
    add(BaseItemLoadStarted<F>());
  }
}
