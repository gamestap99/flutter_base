import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_base/src/constants/color.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../constants/dimens.dart';
import '../index.dart';

class WDate extends StatefulWidget {
  final String label;
  final DateTime? initValue;
  final DateTime? value;
  final bool space;
  final int maxLines;
  final int minLines;
  final bool required;
  final bool enabled;
  final ValueChanged<DateTime>? onChanged;
  final Widget? icon;
  final String? format;
  final String? errorText;
  final bool stackedLabel;
  final TextEditingController controller;
  final SelectDateType selectDateType;
  final InputBorder? enabledBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedBorder;
  final InputBorder? disabledBorder;
  final Color? fillColor;
  final Color? iconColor;
  final Color? requiredColor;
  final String? hintText;
  final TextStyle? labelStyle;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final TextStyle? hintStyle;
  final TextStyle? style;

  const WDate({
    super.key,
    this.label = '',
    this.initValue,
    this.value,
    this.onChanged,
    this.errorText,
    this.stackedLabel = true,
    this.required = false,
    this.enabled = true,
    this.space = false,
    this.maxLines = 1,
    this.minLines = 1,
    this.icon,
    this.hintText,
    this.format = 'dd/MM/yyyy',
    required this.controller,
    this.selectDateType = SelectDateType.full,
    this.enabledBorder,
    this.errorBorder,
    this.focusedBorder,
    this.disabledBorder,
    this.fillColor,
    this.iconColor,
    this.requiredColor,
    this.labelStyle,
    this.validator,
    this.textInputAction,
    this.hintStyle,
    this.style,
  });

  @override
  State<WDate> createState() => _WDateState();
}

class _WDateState extends State<WDate> {
  FocusNode focusNode = FocusNode();
  DateTime selectedDate = DateTime.now();
  String format = '';

  @override
  void initState() {
    if (widget.initValue != null) {
      selectedDate = widget.initValue!;

      format = DateFormat(widget.format).format(widget.initValue!);
      widget.onChanged?.call(widget.initValue!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WInput(
      controller: widget.controller,
      label: widget.label,
      value: format,
      space: widget.space,
      maxLines: widget.maxLines,
      required: widget.required,
      enabled: widget.enabled,
      stackedLabel: widget.stackedLabel,
      enabledBorder: widget.enabledBorder,
      errorBorder: widget.errorBorder,
      focusedBorder: widget.focusedBorder,
      disabledBorder: widget.disabledBorder,
      fillColor: widget.fillColor,
      iconColor: widget.iconColor,
      hintText: widget.hintText,
      labelStyle: widget.labelStyle,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      hintStyle: widget.hintStyle,
      style: widget.style,
      suffix: Icon(
        Icons.calendar_month_rounded,
        color: CColor.primary,
        size: CFontSize.headline3,
      ),
      focus: true,
      focusNode: focusNode,
      onTap: () {
        focusNode.unfocus();
        return showDialog<void>(
          context: context,
          // barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              content: SingleChildScrollView(
                  child: SizedBox(
                      width: 250,
                      child: SfDateRangePicker(
                        maxDate: widget.selectDateType == SelectDateType.before ? DateTime.now() : null,
                        minDate: widget.selectDateType == SelectDateType.after ? DateTime.now() : null,
                        initialSelectedDate: selectedDate,
                        // headerStyle: DateRangePickerHeaderStyle(textStyle: CStyle.headline4()),
                        view: DateRangePickerView.month,
                        selectionMode: DateRangePickerSelectionMode.single,
                        onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                          SchedulerBinding.instance.addPostFrameCallback((duration) async {
                            if (widget.onChanged != null) {
                              selectedDate = args.value;
                              initializeDateFormatting();
                              widget.controller.text = DateFormat(widget.format).format(args.value);
                              format = DateFormat(widget.format).format(args.value);
                              widget.onChanged!(args.value);
                              await Future.delayed(const Duration(milliseconds: 100));
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                setState(() {});
                              }
                            }
                          });
                        },
                      ))),
              contentPadding: const EdgeInsets.all(8),
            );
          },
        );
      },
      icon: widget.icon,
    );
  }
}

enum SelectDateType { before, after, full }
