import 'package:flutter_base/src/utils/util_loading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/entity.dart';
import 'bloc_base_event.dart';
import 'bloc_base_state.dart';

abstract class BlocBaseMain<E extends BlocBaseEvent, S extends BlocBaseState> extends Bloc<E, S> {
  BlocBaseMain(super.state) {
    // on<E>(onMapEvents, transformer: restartable());
  }

  Future<void> runSafeCall<T extends ResEntity>({
    required void Function() onStart,
    required void Function(dynamic ex) onError,
    required void Function(T data) onSuccess,
    required Future<T> dataApi,
    bool showDialog = false,
  }) async {
    if (showDialog) {
      UtilLoading.instance.showLoading();
    }

    onStart();
    try {
      final data = await dataApi;

      if (data.status == ResStatus.success) {
        onSuccess(data);

        if (showDialog && (data.error == null)) {
          UtilLoading.instance.showSuccess();
        }

        if (showDialog && data.error != null) {
          UtilLoading.instance.showError(content: data.error["warning"] ?? "Vui lòng kiểm tra lại dữ liệu gửi đi");
        }
      } else {
        onError.call(data.error);

        if (showDialog) {
          UtilLoading.instance.showError();
        }
      }
    } catch (ex) {
      onError.call(ex);

      if (showDialog) {
        UtilLoading.instance.showError();
      }
    }

    if (showDialog) {
      UtilLoading.instance.hide();
    }
  }

  Future<void> safeCall<T>({
    required Future<void> Function() onCall,
    required Future<void> Function(dynamic ex) onError,
    bool showDialog = false,
  }) async {
    try {
      await onCall();
    } catch (ex) {
      await onError.call(ex);
    }
  }
}
