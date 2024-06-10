import 'package:flutter/material.dart';
import 'package:flutter_base/src/core/bloc/bloc_base_event.dart';

abstract class WFormEvent extends BlocBaseEvent {}

class WFormChangeValue extends WFormEvent {
  final String name;
  final dynamic value;

  WFormChangeValue({
    required this.name,
    required this.value,
  });

  @override
  List<Object?> get props => [
        name,
        value,
      ];
}

class WFormAddKey extends WFormEvent {
  final GlobalKey<FormState> formKey;

  WFormAddKey({
    required this.formKey,
  });

  @override
  List<Object?> get props => [
        formKey,
      ];
}

class WFormReset extends WFormEvent {
  @override
  List<Object?> get props => [];
}

class WFormFinish extends WFormEvent {
  final bool ignoreValidate;
  final bool showDialog;

  WFormFinish({
    required this.showDialog,
    required this.ignoreValidate,
  });

  @override
  List<Object?> get props => [showDialog, ignoreValidate];
}
