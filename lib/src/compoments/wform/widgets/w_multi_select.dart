import 'package:flutter/material.dart';
import 'package:flutter_base/flutter_base.dart';
import 'package:flutter_base/src/constants/index.dart';

import '../../../constants/color.dart';
import '../../multi_select_dialog/index.dart';

class WMultiSelect<T> extends StatefulWidget {
  final String? Function(List<T>?)? validator;
  final Function(List<dynamic>?)? onChanged;
  final Widget Function(Widget Function(MultiSelectItem<T> Function(List<MultiSelectItem<T>>) itemCallback) builder)? customBuilder;
  final List<MultiSelectItem<T>>? items;
  final String label;
  final TextStyle? labelStyle;
  final bool required;
  final Color? fillColor;
  final Color? chipColor;
  final Color? requiredColor;

  const WMultiSelect({
    Key? key,
    this.onChanged,
    this.validator,
    this.items,
    required this.customBuilder,
    required this.label,
    this.labelStyle,
    required this.required,
    this.fillColor,
    this.chipColor,
    this.requiredColor,
  }) : super(key: key);

  @override
  State<WMultiSelect<T>> createState() => _WMultiSelectState<T>();
}

class _WMultiSelectState<T> extends State<WMultiSelect<T>> {
  final _multiSelectKey = GlobalKey<FormFieldState>();

  userClicked() {
    // print('User clicked');
  }

  @override
  Widget build(BuildContext context) {
    return FormField(
      validator: widget.validator,
      builder: (FormFieldState<List<String>> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.label.isNotEmpty
                ? Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          style: CStyle.paragraph1(
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          children: [
                            TextSpan(
                              text: widget.label,
                              style: widget.labelStyle,
                            ),
                            if (widget.required)
                              TextSpan(
                                  text: " *",
                                  style: TextStyle(
                                    color: widget.requiredColor ?? CColor.stateError,
                                    fontSize: CFontSize.headline3,
                                  )),
                          ],
                        ),
                      ),
                      const VSpacer(8),
                    ],
                  )
                : Container(),
            Container(
              decoration: BoxDecoration(
                color: widget.fillColor ?? CColor.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: MultiSelectDialogField<T>(
                key: _multiSelectKey,
                loading: false,
                decoration: const BoxDecoration(),
                title: Text(widget.label),
                items: widget.items ?? [],
                searchable: true,
                customBuilder: widget.customBuilder,
                onSelectionChanged: (values) {
                  widget.onChanged?.call(values);
                },
                // listType: MultiSelectListType.CHIP,
                // validator: (values) {
                //   // return widget.validator?.call(values);
                //
                //   return null;
                //
                //   // if (values == null || values.isEmpty) {
                //   //   return "Required";
                //   // }
                //   // List<String> names = values.map((e) => e?.name ?? '').toList();
                //   // if (names.contains("Frog")) {
                //   //   return "Frogs are weird!";
                //   // }
                //   // return null;
                // },
                onConfirm: (values) {
                  // setState(() {
                  //   _selectedAnimals3 = values ?? [];
                  // });
                  // _multiSelectKey.currentState?.validate();
                },
                chipDisplay: MultiSelectChipDisplay(
                  colorator: (state) => widget.chipColor,
                  onTap: (item) {
                    _multiSelectKey.currentState?.validate();
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
