import 'package:flutter/material.dart';
import 'package:flutter_base/src/constants/style.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../flutter_base.dart';
import '../compoments/custom_button.dart';
import '../constants/color.dart';

class RangeDateWidget extends StatefulWidget {
  final DateTime? start;
  final DateTime? end;
  final String outputFormat;
  final bool Function(DateTime)? selectableDayPredicate;
  final Widget iconClose;
  final String helperText;
  final String labelStart;
  final String labelEnd;
  final String okText;
  final TextStyle? helperStyle;

  const RangeDateWidget({
    super.key,
    this.start,
    this.end,
    this.helperStyle,
    this.selectableDayPredicate,
    this.outputFormat = "dd-MM-yyyy",
    this.helperText = "Chọn ngày",
    this.labelStart = "Ngày bắt đầu",
    this.labelEnd = "Ngày kết thúc",
    this.okText = "Đồng ý",
    this.iconClose = const Icon(
      Icons.close,
      size: 24,
      color: CColor.primary,
    ),
  });

  @override
  State<RangeDateWidget> createState() => _RangeDateWidgetState();
}

class _RangeDateWidgetState extends State<RangeDateWidget> {
  final controller = DateRangePickerController();
  final ValueNotifier<String?> startDate = ValueNotifier(null);
  final ValueNotifier<String?> endDate = ValueNotifier(null);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.selectedRange = PickerDateRange(widget.start, widget.end);
    });
    super.initState();
  }

  @override
  void dispose() {
    startDate.dispose();
    endDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle helperStyle = widget.helperStyle ??
        CStyle.paragraph1(
          style: const TextStyle(
            color: CColor.primary,
          ),
        );

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 20, 0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: widget.iconClose,
                    ),
                  ),
                  const HSpacer(4),
                  Text(
                    widget.helperText,
                    style: helperStyle,
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                color: CColor.textDark4,
              ),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ValueListenableBuilder<String?>(
                valueListenable: endDate,
                builder: (context, date, child) => Row(
                  children: [
                    _RowDate(
                      label: widget.labelStart,
                      notifier: startDate,
                      active: date == null,
                    ),
                    _RowDate(
                      label: widget.labelEnd,
                      notifier: endDate,
                      active: date != null,
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SfDateRangePicker(
                  controller: controller,
                  enableMultiView: true,
                  maxDate: DateTime(DateTime.now().year, DateTime.now().month + 1),
                  initialDisplayDate: DateTime(DateTime.now().year, DateTime.now().month - 1),
                  navigationMode: DateRangePickerNavigationMode.snap,
                  selectionTextStyle: CStyle.paragraph1(
                    style: const TextStyle(
                      color: CColor.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  selectionColor: CColor.primary,
                  startRangeSelectionColor: CColor.primary,
                  endRangeSelectionColor: CColor.primary,
                  rangeSelectionColor: CColor.primaryAccent.withOpacity(0.2),
                  rangeTextStyle: CStyle.paragraph1(
                    style: const TextStyle(
                      color: CColor.darker,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  monthViewSettings: const DateRangePickerMonthViewSettings(
                    enableSwipeSelection: false,
                  ),
                  headerStyle: DateRangePickerHeaderStyle(
                    textAlign: TextAlign.start,
                    textStyle: CStyle.headline4(
                      style: const TextStyle(
                        color: CColor.textDark1,
                      ),
                    ),
                  ),
                  navigationDirection: DateRangePickerNavigationDirection.vertical,
                  monthCellStyle: const DateRangePickerMonthCellStyle(),
                  selectableDayPredicate: widget.selectableDayPredicate,
                  onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                    try {
                      if (args.value is PickerDateRange) {
                        if ((args.value as PickerDateRange).startDate != null) {
                          startDate.value = DateFormat(widget.outputFormat).format((args.value as PickerDateRange).startDate!);
                        }

                        if ((args.value as PickerDateRange).endDate != null) {
                          endDate.value = DateFormat(widget.outputFormat).format((args.value as PickerDateRange).endDate!);
                        }
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
                  selectionMode: DateRangePickerSelectionMode.range,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: CustomButton.fullWidth(
                onPressed: () {
                  Navigator.pop(context, {
                    'date': {
                      "start": startDate.value,
                      "end": endDate.value,
                    },
                  });
                },
                label: widget.okText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowDate extends StatelessWidget {
  final ValueNotifier<String?> notifier;
  final String label;
  final bool active;

  const _RowDate({
    required this.notifier,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: active ? CColor.white : Colors.transparent,
          borderRadius: const BorderRadius.all(
            Radius.circular(4.0),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style:CStyle.paragraph1(
                style:  TextStyle(
                  color: active ? CColor.primary : CColor.textDark3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ValueListenableBuilder<String?>(
              valueListenable: notifier,
              builder: (context, date, child) {
                return Text(
                  date ?? "",
                  style: CStyle.paragraph1(
                    style:  TextStyle(
                      color: active ? CColor.textDark2 : CColor.textDark3,
                      fontWeight: FontWeight.w600,
                    ),
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
