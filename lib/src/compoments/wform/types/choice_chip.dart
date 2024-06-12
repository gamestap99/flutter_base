import '../index.dart';

class MChoiceChipData {
  final dynamic value;
  final String name;

  MChoiceChipData({
    required this.value,
    required this.name,
  });
}

class MFormChoiceChipItem extends BaseForm {
  final List<MChoiceChipData> items;

  MFormChoiceChipItem({
    required super.name,
    required super.label,
    required super.value,
    super.labelStyle,
    super.validators,
    super.hint,
    required this.items,
  });
}
