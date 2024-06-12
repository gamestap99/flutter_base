import 'package:flutter/material.dart';

abstract class BaseForm {
  final String name;
  final String label;
  final dynamic value;
  final String? hint;
  final List<MValidateFormItem>? validators;
  final TextStyle? labelStyle;
  final bool stackedLabel;
  final Widget? icon;
  final Color? fillColor;
  final int? minLines;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final InputDecoration? decoration;
  final bool enabled;

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
    this.decoration,
    this.enabled = true,
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
