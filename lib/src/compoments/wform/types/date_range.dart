

import 'package:flutter_base/src/compoments/wform/index.dart';

import '../widgets/w_date_range.dart';

class MFormDateRangeItem extends BaseForm {
  final String formatDate;

  MFormDateRangeItem({
    required super.name,
    required super.label,
    TDateRange? value,
    super.labelStyle,
    super.validators,
    this.formatDate = 'dd/MM/yyyy',
  }) : super(
          value: value,
        );
}
