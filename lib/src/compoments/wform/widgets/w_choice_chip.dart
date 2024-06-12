import 'package:flutter/material.dart';

import '../../../constants/color.dart';
import '../../../constants/dimens.dart';
import '../../../constants/style.dart';
import '../../../widgets/index.dart';
import '../types/choice_chip.dart';

class WChoiceChip extends StatefulWidget {
  final String name;
  final String label;
  final String value;
  final bool space;
  final int maxLines;
  final bool required;
  final bool enabled;
  final void Function(dynamic value) onChanged;
  final Widget? icon;
  final Function? format;
  final bool showSearch;
  final TextEditingController controller;
  final List<MChoiceChipData> items;
  final String? hintText;
  final TextStyle? labelStyle;
  final Color? requiredColor;
  final String? Function(String?)? validator;

  const WChoiceChip({
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
    this.labelStyle,
    this.requiredColor,
    this.showSearch = true,
    required this.controller,
    required this.items,
    required this.validator,
    this.name = '',
  });

  @override
  State<WChoiceChip> createState() => _WChoiceChipState();
}

class _WChoiceChipState extends State<WChoiceChip> {
  dynamic _value;

  @override
  void initState() {
    setState(() {
      _value = widget.value;
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant WChoiceChip oldWidget) {
    setState(() {
      _value = widget.value;
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
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
        ),
        Wrap(
          spacing: 6.0,
          children: widget.items
              .map((e) => ChoiceChip(
                    label: Text(e.name),
                    labelStyle: widget.labelStyle,
                    selected: _value == e.value,
                    onSelected: (bool selected) {
                      setState(() {
                        _value = selected ? e.value : null;
                        widget.onChanged(_value);
                      });
                    },
                  ))
              .toList(),
        ),
        SizedBox(height: widget.space ? CSpace.large : 0),
      ],
    );
  }
}
