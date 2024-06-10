import 'package:flutter/material.dart';

import '../../multi_select_dialog/index.dart';
import '../index.dart';

class MFormItem extends BaseForm {
  final Function(void Function(dynamic) onChanged, dynamic value)? apiBuilder;
  final Function(dynamic value)? valueBuilder;
  final void Function(List<MultiSelectItem<dynamic>> item)? onChanged;
  final Widget Function(Widget Function(MultiSelectItem<dynamic> Function(List<MultiSelectItem<dynamic>>) itemCallback) builder)? customBuilder;
  final void Function(void Function(List<MultiSelectItem<dynamic>> Function() onChanged) callback)? customDynamicBuilder;
  final List<MultiSelectItem<dynamic>>? itemsMulti;
  final EFormItem type;
  final bool isPassword;
  final MFormOptions? options;

  MFormItem({
    required String name,
    required String label,
    dynamic value,
    TextStyle? labelStyle,
    List<MValidateFormItem>? validators,
    this.itemsMulti,
    this.apiBuilder,
    this.valueBuilder,
    this.onChanged,
    this.customBuilder,
    this.customDynamicBuilder,
    this.options,
    this.type = EFormItem.text,
    this.isPassword = false,
    super.stackedLabel,
    super.icon,
    super.hint,
  }) : super(
          name: name,
          label: label,
          value: value,
          validators: validators,
          labelStyle: labelStyle,
        );
}

class MFormOptions {
  final InputBorder? enabledBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedBorder;
  final InputBorder? disabledBorder;
  final Color? fillColor;
  final Color? iconColor;
  final Color? requiredColor;
  final TextStyle? style;
  final TextStyle? hintStyle;

  MFormOptions({
    this.enabledBorder,
    this.errorBorder,
    this.focusedBorder,
    this.disabledBorder,
    this.fillColor,
    this.iconColor,
    this.requiredColor,
    this.style,
    this.hintStyle,
  });
}
