import 'package:flutter/material.dart';
import 'package:flutter_base/src/core/bloc/bloc_base_main.dart';
import 'package:flutter_base/src/core/domain/entities/entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/bloc_base_state.dart';
import '../../../core/dio/network_exceptions.dart';
import '../index.dart';

class WFormBloc<T> extends BlocBaseMain<WFormEvent, WFormState> {
  Future<ItemResEntity<T>> Function(Map<String, dynamic> values)? api;
  final void Function(Map<String, dynamic> values)? onSubmitCallBack;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  GlobalKey<FormState> get formKey => _formKey;

  // bool get isValidated => (_formKeyc) ?? false);

  WFormBloc({
    this.api,
    this.onSubmitCallBack,
  }) : super(const WFormState()) {
    on(_onChangeValue);
    on(_onChangeValues);
    on(_onFinish);
    on(_onReset);
  }

  Future<void> _onChangeValue(WFormChangeValue event, Emitter<WFormState> emit) async {
    return await safeCall(
      onCall: () async {
        Map<String, dynamic> values = Map.from(state.values);
        Map<String, dynamic> errors = Map.from(state.errors);

        if (errors.containsKey(event.name)) {
          errors.remove(event.name);
        }

        values[event.name] = event.value;

        emit(state.copyWith(
          values: values,
          errors: errors,
        ));
      },
      onError: (ex) async {},
    );
  }

  Future<void> _onChangeValues(WFormChangeValues event, Emitter<WFormState> emit) async {
    return await safeCall(
      onCall: () async {
        Map<String, dynamic> values = Map.from(state.values);
        Map<String, dynamic> errors = Map.from(state.errors);

        values = {
          ...values,
          ...event.values,
        };

        event.values.forEach((key, value) {
          if (errors.containsKey(key)) {
            errors.remove(key);
          }
        });

        emit(state.copyWith(
          values: values,
          errors: errors,
        ));
      },
      onError: (ex) async {},
    );
  }

  void _onFinish(WFormFinish event, Emitter<WFormState> emit) async {
    if (api == null) return;

    if (event.ignoreValidate || (_formKey.currentState?.validate() ?? false)) {
      return await runSafeCall<ItemResEntity<T>>(
        showDialog: event.showDialog,
        onStart: () {
          emit(state.copyWith(
            status: EBlocStateStatus.loading,
          ));
        },
        onError: (ex) {
          emit(state.copyWith(
            status: EBlocStateStatus.fail,
            exception: NetworkExceptions.getDioException(ex).networkException,
          ));
        },
        onSuccess: (data) {
          final rs = data;

          if (rs.success) {
            emit(state.copyWith(
              status: EBlocStateStatus.success,
              result: rs.data,
            ));
          } else {
            emit(state.copyWith(
              status: EBlocStateStatus.fail,
              errors: rs.error,
            ));
          }
        },
        dataApi: this.api!.call(state.values),
      );
    }
  }

  void _onReset(WFormReset event, Emitter<WFormState> emit) async {
    emit(state.copyWith(
      values: {},
    ));
    onSubmitCallBack?.call({});
  }

  void onReset() {
    add(WFormReset());
  }

  void onSubmit() {
    onSubmitCallBack?.call(state.values);
  }

  void addValue({required String name, required dynamic value}) {
    add(WFormChangeValue(
      name: name,
      value: value,
    ));
  }

  void addValues({required Map<String, dynamic> values}) {
    add(WFormChangeValues(
      values: values,
    ));
  }

  void onFinish({
    bool showDialog = false,
    bool ignoreValidate = false,
  }) {
    add(WFormFinish(
      showDialog: showDialog,
      ignoreValidate: ignoreValidate,
    ));
  }
}
