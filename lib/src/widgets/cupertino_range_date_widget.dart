import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../flutter_base.dart';
import '../constants/color.dart';

class CupertinoRangeDateWidget extends StatefulWidget {
  final DateTime? start;
  final DateTime? end;
  final DateTime? minDate;
  final DateTime? maxDate;
  final String outputFormat;
  final bool Function(DateTime)? selectableDayPredicate;
  final String helperText;
  final String labelStart;
  final String labelEnd;
  final String okText;
  final TextStyle? helperStyle;
  final TextStyle? selectionTextStyle;
  final TextStyle? rangeTextStyle;
  final DateRangePickerHeaderStyle? dateRangePickerHeaderStyle;
  final Widget Function(DateTime? start, DateTime? end) actionBottom;

  const CupertinoRangeDateWidget({
    super.key,
    required this.actionBottom,
    this.start,
    this.end,
    this.helperStyle,
    this.selectionTextStyle,
    this.rangeTextStyle,
    this.selectableDayPredicate,
    this.dateRangePickerHeaderStyle,
    this.outputFormat = "dd-MM-yyyy",
    this.helperText = "Chọn ngày",
    this.labelStart = "Ngày bắt đầu",
    this.labelEnd = "Ngày kết thúc",
    this.okText = "Đồng ý",
    this.minDate,
    this.maxDate,
  });

  @override
  State<CupertinoRangeDateWidget> createState() => _CupertinoRangeDateWidgetState();
}

class _CupertinoRangeDateWidgetState extends State<CupertinoRangeDateWidget> {
  final controller = DateRangePickerController();
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.selectedRange = PickerDateRange(widget.start, widget.end);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CupertinoThemeData theme = CupertinoTheme.of(context);
    final TextStyle textStyle = theme.textTheme.textStyle.copyWith(color: CupertinoDynamicColor.maybeResolve(theme.textTheme.textStyle.color, context));

    return ColoredBox(
      color: CupertinoColors.secondarySystemBackground,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: CupertinoColors.white,
            ),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                _RowDate(
                  outputFormat: widget.outputFormat,
                  label: widget.labelStart,
                  date: startDate,
                  active: endDate == null,
                ),
                _RowDate(
                  outputFormat: widget.outputFormat,
                  label: widget.labelEnd,
                  date: endDate,
                  active: endDate != null,
                ),
              ],
            ),
          ),
          const VSpacer(20),
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: SfDateRangePicker(
                controller: controller,
                backgroundColor: CupertinoColors.white,
                selectionMode: DateRangePickerSelectionMode.range,
                navigationMode: DateRangePickerNavigationMode.scroll,
                navigationDirection: DateRangePickerNavigationDirection.vertical,
                enableMultiView: true,
                minDate: widget.minDate,
                maxDate: widget.maxDate ?? DateTime(DateTime.now().year, DateTime.now().month + 1),
                initialDisplayDate: DateTime(DateTime.now().year, DateTime.now().month - 1),
                selectionTextStyle: widget.selectionTextStyle ?? textStyle,
                selectionColor: CColor.primary,
                startRangeSelectionColor: CColor.primary,
                endRangeSelectionColor: CColor.primary,
                rangeSelectionColor: CColor.primaryAccent.withValues(alpha: 0.2),
                rangeTextStyle: widget.rangeTextStyle ??
                    textStyle.copyWith(
                      color: CColor.darker,
                      fontWeight: FontWeight.w600,
                    ),
                headerStyle: widget.dateRangePickerHeaderStyle ??
                    DateRangePickerHeaderStyle(
                      backgroundColor: CupertinoColors.white,
                      textAlign: TextAlign.start,
                      textStyle: textStyle.copyWith(
                        fontSize: 16,
                      ),
                    ),
                selectableDayPredicate: widget.selectableDayPredicate,
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  try {
                    if (args.value is PickerDateRange) {
                      setState(() {
                        startDate = (args.value as PickerDateRange).startDate;
                        endDate = (args.value as PickerDateRange).endDate;
                      });
                    } else if (args.value is DateTime) {
                      //
                    } else if (args.value is List<DateTime>) {
                      //
                    } else {
                      //
                    }
                  } catch (ex) {
                    ///
                  }
                },
              ),
            ),
          ),
          widget.actionBottom(startDate, endDate),
        ],
      ),
    );
  }
}

class _RowDate extends StatelessWidget {
  final DateTime? date;
  final String label;
  final bool active;
  final String outputFormat;

  const _RowDate({
    required this.date,
    required this.label,
    required this.active,
    required this.outputFormat,
  });

  @override
  Widget build(BuildContext context) {
    final CupertinoThemeData theme = CupertinoTheme.of(context);
    final TextStyle textStyle = theme.textTheme.textStyle.copyWith(color: CupertinoDynamicColor.maybeResolve(theme.textTheme.textStyle.color, context));

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: active ? CupertinoColors.secondarySystemBackground : Colors.transparent,
          borderRadius: const BorderRadius.all(
            Radius.circular(4.0),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: textStyle.copyWith(
                color: active ? CColor.primary : CColor.textDark3,
                fontWeight: FontWeight.w600,
              ),
            ),
            Builder(
              builder: (context) {
                String txt = '';

                if (date != null) {
                  txt = DateFormat(outputFormat).format(date!);
                }

                return Text(
                  txt,
                  style: textStyle.copyWith(
                    color: active ? CColor.textDark2 : CColor.textDark3,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
