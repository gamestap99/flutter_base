import 'package:flutter/material.dart';
import 'package:flutter_base/flutter_base.dart';

abstract class BaseForm {
  final String name;
  final String label;
  final dynamic value;
  final String? hint;
  final List<MValidateFormItem>? validators;
  final TextStyle? labelStyle;
  final bool stackedLabel;
  final bool Function(WFormState state)? enabled;
  final Widget? icon;
  final Color Function(WFormState state)? fillColor;
  final int? minLines;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final InputDecoration? decoration;
  final InputBorder? disabledBorder;
  final bool Function(WFormState, WFormState)? buildWhen;
  final TextInputType? keyboardType;
  final Widget? suffix;

  BaseForm({
    required this.name,
    required this.label,
    this.validators,
    this.hint,
    this.minLines,
    this.maxLines,
    required this.value,
    this.labelStyle,
    this.icon,
    this.fillColor,
    this.textInputAction,
    this.stackedLabel = true,
    this.enabled,
    this.decoration,
    this.disabledBorder,
    this.buildWhen,
    this.keyboardType,
    this.suffix,
  });
}

class MValidateFormItem {
  final bool? require;
  final int? min;
  final int? max;
  final String message;
  final bool Function(String? text, Map<String, dynamic> values)? customCheck;

  MValidateFormItem({
    this.require,
    this.min,
    this.customCheck,
    this.max,
    required this.message,
  });
}
