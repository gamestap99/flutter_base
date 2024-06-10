import 'package:flutter/material.dart';

import '../../../constants/color.dart';
import '../../../constants/dimens.dart';
import '../../../constants/style.dart';
import '../index.dart';

class WSelect extends StatefulWidget {
  final String name;
  final String label;
  final String value;
  final bool space;
  final int maxLines;
  final bool required;
  final bool enabled;
  final ValueChanged<dynamic> onChanged;
  final Widget? icon;
  final Function? format;
  final Function(dynamic content, int index) itemSelect;
  final bool showSearch;
  final Function selectLabel;
  final Function selectValue;
  final TextEditingController controller;
  final List<MWSelect> items;
  final String? hintText;

  const WSelect({
    super.key,
    this.label = '',
    this.value = '',
    required this.onChanged,
    this.required = false,
    this.enabled = true,
    this.space = false,
    this.maxLines = 1,
    this.icon,
    this.format,
    this.hintText,
    required this.itemSelect,
    this.showSearch = true,
    required this.selectLabel,
    required this.selectValue,
    required this.controller,
    required this.items,
    this.name = '',
  });

  @override
  State<WSelect> createState() => _WSelectState();
}

class _WSelectState extends State<WSelect> {
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return WInput(
      controller: widget.controller,
      label: widget.label,
      value: widget.value,
      space: widget.space,
      maxLines: widget.maxLines,
      required: widget.required,
      enabled: widget.enabled,
      icon: widget.icon,
      suffix: const Icon(Icons.arrow_drop_down),
      // suffix: CIcon.arrowDown,
      focus: true,
      stackedLabel: true,
      focusNode: focusNode,
      hintText: widget.hintText,
      onTap: () {
        focusNode.unfocus();
        showModalBottomSheet<void>(
          context: context,
          useSafeArea: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          )),
          builder: (_) {
            return _Build(
              title: widget.hintText ?? widget.label,
              value: widget.value,
              items: widget.items,
              onChanged: widget.onChanged,
            );
          },
        );
      },
    );
  }
}

class _Build extends StatelessWidget {
  final List<MWSelect> items;
  final ValueChanged<dynamic> onChanged;
  final dynamic value;
  final String title;

  const _Build({
    required this.items,
    required this.onChanged,
    required this.value,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: CStyle.headline4(
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: CSpace.medium),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    if (value == items[index].name) {
                      onChanged(null);
                    } else {
                      onChanged(items[index].value);
                    }
                  },
                  child: Ink(
                    color: value == items[index].name ? CColor.primaryAccent.withOpacity(0.2) : null,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(items[index].name),
                        ),
                        if (value == items[index].name)
                          const Icon(
                            Icons.check,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  height: 0,
                );
              },
              itemCount: items.length,
            ),
          ),
        ],
      ),
    );
  }
}
