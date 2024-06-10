import 'package:flutter/material.dart';

import '../../../constants/color.dart';
import '../../multi_select_dialog/index.dart';

class WMultiSelect<T> extends StatefulWidget {
  final String? Function(List<T>?)? validator;
  final Function(List<dynamic>?)? onChanged;
  final Widget Function(Widget Function(MultiSelectItem<T> Function(List<MultiSelectItem<T>>) itemCallback) builder)? customBuilder;
  final List<MultiSelectItem<T>>? items;

  const WMultiSelect({
    Key? key,
    this.onChanged,
    this.validator,
    this.items,
    required this.customBuilder,
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
          children: [
            Container(
              color: CColor.white,
              child: MultiSelectDialogField<T>(
                key: _multiSelectKey,
                loading: false,
                decoration: const BoxDecoration(),
                title: const Text("Animals"),
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
