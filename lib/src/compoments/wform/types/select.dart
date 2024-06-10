import '../index.dart';

class MWSelect {
  final dynamic value;
  final String name;

  MWSelect({
    required this.value,
    required this.name,
  });
}

class MFormSelectItem extends BaseForm {
  final List<MWSelect>? items;

  MFormSelectItem({
    required super.name,
    required super.label,
    required super.value,
    super.labelStyle,
    super.validators,
    super.hint,
    this.items,
  });
}
