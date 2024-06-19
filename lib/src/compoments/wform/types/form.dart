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


  MFormItem({
    super.minLines,
    super.maxLines,
    super.fillColor,
    required super.name,
    required super.label,
    super.value,
    super.labelStyle,
    super.validators,
    this.itemsMulti,
    this.apiBuilder,
    this.valueBuilder,
    this.onChanged,
    this.customBuilder,
    this.customDynamicBuilder,
    this.type = EFormItem.text,
    this.isPassword = false,
    super.options,
    super.stackedLabel,
    super.icon,
    super.hint,
    super.textInputAction,
    super.keyboardType,
    super.suffix,
  });
}
