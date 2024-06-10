import 'package:flutter/material.dart';

import 'w_input.dart';

class WApiSelect extends StatefulWidget {
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
  final Color? fillColor;
  final TextEditingController controller;
  final Function(ValueChanged<dynamic> onChanged) onTap;
  final TextStyle? labelStyle;
  final String? Function(String?)? validator;

  const WApiSelect({
    Key? key,
    this.label = '',
    this.value = '',
    required this.onChanged,
    required this.onTap,
    this.required = false,
    this.enabled = true,
    this.space = false,
    this.maxLines = 1,
    this.icon,
    this.fillColor,
    this.format,
    this.labelStyle,
    required this.itemSelect,
    this.showSearch = true,
    required this.controller,
    this.name = '',
    this.validator,
  }) : super(key: key);

  @override
  State<WApiSelect> createState() => _WApiSelectState();
}

class _WApiSelectState extends State<WApiSelect> {
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return WInput(
      controller: widget.controller,
      validator: widget.validator,
      label: widget.label,
      labelStyle: widget.labelStyle,
      value: widget.value,
      space: widget.space,
      maxLines: widget.maxLines,
      required: widget.required,
      enabled: widget.enabled,
      icon: widget.icon,
      fillColor: widget.fillColor,
      suffix: InkWell(
        onTap: () {
          if (widget.value.isNotEmpty) {
            focusNode.unfocus();
            widget.controller.value = const TextEditingValue();

            return widget.onChanged.call('');
          } else {
            focusNode.unfocus();

            widget.onTap.call(widget.onChanged);
          }
        },
        child: Icon(
          widget.value.isNotEmpty ? Icons.close : Icons.arrow_drop_down,
          size: 20,
          color: Colors.grey.shade600,
        ),
      ),
      focus: true,
      stackedLabel: true,
      focusNode: focusNode,
      onTap: () {
        focusNode.unfocus();

        return widget.onTap.call(widget.onChanged);
      },
    );
  }
}
