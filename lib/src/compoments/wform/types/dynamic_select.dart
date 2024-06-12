import 'base_form.dart';

class MFormDynamicSelectItem extends BaseForm {
  final Function(void Function(dynamic) onChanged, dynamic value) apiBuilder;

  ///
  /// Custom value display from value save to db
  ///
  final Function(dynamic value) valueBuilder;

  MFormDynamicSelectItem({
    super.fillColor,
    super.labelStyle,
    super.validators,
    required this.apiBuilder,
    required this.valueBuilder,
    required super.name,
    required super.label,
    required super.value,
    super.enabled,
  });
}
