import 'package:flutter/material.dart';

import '../../../constants/color.dart';
import '../../../constants/dimens.dart';
import '../../../constants/style.dart';
import '../../multi_dynamic_select_input/index.dart';
import '../../multi_select_dialog/index.dart';

class WMultiDynamicSelect extends StatefulWidget {
  final bool stackedLabel;
  final String label;
  final bool required;
  final double? botSpace;
  final void Function(List<MultiSelectItem<dynamic>> item) onChanged;
  final void Function(void Function(List<MultiSelectItem<dynamic>> Function())) onCallbackBuilder;

  const WMultiDynamicSelect({
    Key? key,
    required this.stackedLabel,
    required this.label,
    required this.onCallbackBuilder,
    required this.onChanged,
    this.required = false,
    this.botSpace,
  }) : super(key: key);

  @override
  State<WMultiDynamicSelect> createState() => _WMultiDynamicSelectState();
}

class _WMultiDynamicSelectState extends State<WMultiDynamicSelect> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.stackedLabel && widget.label.isNotEmpty
            ? Column(
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: CColor.black.shade400,
                        fontWeight: FontWeight.w500,
                        fontSize: CFontSize.paragraph1,
                      ),
                      children: [
                        TextSpan(
                          text: widget.label,
                        ),
                        if (widget.required)
                          TextSpan(
                            text: " *",
                            style: TextStyle(
                              color: CColor.stateError,
                              fontSize: CFontSize.headline3,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: CSpace.mediumSmall,
                  ),
                ],
              )
            : Container(),
        MultiDynamicSelectField<dynamic>(
          onConfirm: (List<MultiSelectItem<dynamic>> items) {
            widget.onChanged(items);
          },
          buttonText: Text(
            'Chọn tài liệu bắt buộc',
            style: CStyle.paragraph1(
              style: TextStyle(
                color: CColor.black.shade300,
              ),
            ),
          ),
          onCallbackBuilder: widget.onCallbackBuilder,
          chipDisplay: MultiSelectChipDisplay(
            chipWidth: 200,
            // icon:  Icon(Icons.close),
          ),
        ),
        SizedBox(
          height: widget.botSpace ?? CSpace.large,
        ),
      ],
    );
  }
}
