import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constants/color.dart';
import '../../../constants/dimens.dart';
import '../../../widgets/range_date_widget.dart';
import '../index.dart';

enum EDateRange { from, to }

typedef TDateRange = Map<EDateRange, DateTime?>;

class WDateRange extends StatefulWidget {
  final String label;
  final String value;
  final bool space;
  final bool required;
  final bool enabled;
  final ValueChanged<TDateRange>? onChanged;
  final Widget? icon;
  final String? format;
  final bool stackedLabel;
  final TextEditingController controller;
  final SelectDateType selectDateType;
  final DateTime? start;
  final DateTime? end;

  const WDateRange({
    Key? key,
    this.label = '',
    this.value = '',
    this.onChanged,
    this.required = false,
    this.enabled = true,
    this.space = false,
    this.icon,
    this.format = 'dd/MM/yyyy',
    required this.controller,
    this.selectDateType = SelectDateType.full,
    this.stackedLabel = false,
    this.start,
    this.end,
  }) : super(key: key);

  @override
  State<WDateRange> createState() => _WDateRangeState();
}

class _WDateRangeState extends State<WDateRange> {
  FocusNode focusNode = FocusNode();
  DateTime selectedDate = DateTime.now();

  String _getValue() {
    String start = "Bắt đầu";
    String end = "Kết thúc";

    if (widget.start != null) {
      start = DateFormat(widget.format).format(widget.start!);
    }

    if (widget.end != null) {
      end = DateFormat(widget.format).format(widget.end!);
    }

    return '$start  ->  $end';
  }

  @override
  Widget build(BuildContext context) {
    return WInput(
      controller: widget.controller,
      label: widget.label,
      hintText: widget.start == null && widget.end == null ? _getValue() : null,
      value: widget.start == null && widget.end == null ? '' : _getValue(),
      space: widget.space,
      required: widget.required,
      enabled: widget.enabled,
      stackedLabel: widget.stackedLabel,
      suffix: Icon(
        Icons.calendar_month_rounded,
        color: CColor.primary,
        size: CFontSize.headline3,
      ),
      focus: true,
      focusNode: focusNode,
      onTap: () {
        focusNode.unfocus();
        return showDialog(
          context: context,
          builder: (context) => RangeDateWidget(
            start: widget.start,
            end: widget.end,
          ),
        ).then((rs) {
          if (rs is Map && rs.isNotEmpty) {
            widget.onChanged?.call({
              EDateRange.from: rs['rangeStartDate'],
              EDateRange.to: rs['rangeEndDate'],
            });
          }
        });
      },
      icon: widget.icon,
    );
  }

  @override
  void initState() {
    if (widget.value != '') {
      selectedDate = DateTime.parse(widget.value);
    }
    super.initState();
  }
}

enum SelectDateType { before, after, full }
