import 'package:flutter/material.dart';

import '../index.dart';

class WSearch extends StatefulWidget {
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
  final bool showSearch;
  final TextEditingController controller;

  const WSearch({
    Key? key,
    this.label = '',
    this.value = '',
    required this.onChanged,
    this.required = false,
    this.enabled = true,
    this.space = false,
    this.maxLines = 1,
    this.icon,
    this.format,
    this.showSearch = true,
    required this.controller,
    this.name = '',
  }) : super(key: key);

  @override
  State<WSearch> createState() => _WSearchState();
}

class _WSearchState extends State<WSearch> {
  FocusNode focusNode = FocusNode();
  String value = '';

  @override
  void initState() {
    setState(() {
      value = widget.value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WInput(
      controller: widget.controller,
      label: widget.label,
      value: value,
      space: widget.space,
      maxLines: widget.maxLines,
      required: widget.required,
      enabled: widget.enabled,
      icon: widget.icon,
      suffix: InkWell(
        onTap: () {
          if (value.isNotEmpty) {
            setState(() {
              value = '';
            });
            // widget.controller.

            return widget.onChanged.call('');
          }
        },
        child: Icon(
          value.isNotEmpty ? Icons.close : Icons.search,
        ),
      ),
      focus: true,
      stackedLabel: true,
      focusNode: focusNode,
      onChanged: (val) {
        widget.onChanged.call(val);
        setState(() {
          value = val;
        });
      },
    );
  }
}
