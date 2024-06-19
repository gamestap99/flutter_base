import '../index.dart';

class MFormDateItem extends BaseForm {
  final String format;

  MFormDateItem({
    this.format = 'dd/MM/yyyy',
    required super.name,
    required super.label,
    required super.value,
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
