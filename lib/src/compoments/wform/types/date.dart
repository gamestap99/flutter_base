import '../index.dart';

class MFormDateItem extends BaseForm {
  final String format;
  final DateTime? initValue;

  MFormDateItem({
    this.initValue,
    this.format = 'dd/MM/yyyy',
    required super.name,
    required super.label,
    super.value,
    super.labelStyle,
    super.validators,
    super.minLines,
    super.maxLines,
    super.fillColor,
    super.stackedLabel,
    super.icon,
    super.hint,
    super.textInputAction,
    super.keyboardType,
    super.suffix,
  }) : assert(value is DateTime?);
}
