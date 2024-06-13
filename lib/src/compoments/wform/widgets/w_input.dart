import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../constants/color.dart';
import '../../../constants/dimens.dart';
import '../../../constants/style.dart';
import '../../../widgets/spacer.dart';

class WInput extends StatefulWidget {
  final String label;
  final String name;
  final String value;
  final bool space;
  final int maxLines;
  final int? minLines;
  final bool required;
  final bool enabled;
  final bool password;
  final bool number;
  final bool stackedLabel;
  final bool focus;
  final ValueChanged<String>? onChanged;
  final Function? onTap;
  final Widget? icon;
  final String? errorText;
  final Widget? suffix;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final TextStyle? labelStyle;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final String? hintText;
  final InputBorder? enabledBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedBorder;
  final InputBorder? disabledBorder;
  final Color? fillColor;
  final Color? iconColor;
  final Color? requiredColor;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const WInput({
    Key? key,
    this.label = '',
    this.value = '',
    this.minLines = 1,
    this.maxLines = 1,
    this.required = false,
    this.enabled = true,
    this.password = false,
    this.number = false,
    this.stackedLabel = false,
    this.focus = false,
    this.onChanged,
    this.onTap,
    this.icon,
    this.suffix,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.space = false,
    required this.controller,
    this.focusNode,
    this.errorText,
    this.hintText,
    this.labelStyle,
    this.style,
    this.hintStyle,
    this.name = '',
    this.enabledBorder,
    this.errorBorder,
    this.focusedBorder,
    this.disabledBorder,
    this.fillColor,
    this.iconColor,
    this.requiredColor,
    this.inputFormatters,
  }) : super(key: key);

  @override
  State<WInput> createState() => _WInputState();
}

class _WInputState extends State<WInput> {
  FocusNode focusNode = FocusNode();
  bool visible = false;
  final _formState = GlobalKey<FormFieldState>();
  late final TextEditingController controller;

  @override
  void initState() {
    visible = widget.password;
    if (widget.focusNode != null) focusNode = widget.focusNode!;
    focusNode.addListener(() {
      if (widget.focus && focusNode.hasFocus && widget.onTap != null) {
        widget.onTap!();
      }
    });

    controller = widget.controller;

    controller.value = TextEditingValue(
      text: widget.value,
      selection: TextSelection.collapsed(offset: widget.value.length),
    );

    super.initState();
  }

  @override
  void didUpdateWidget(covariant WInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    scheduleMicrotask(() {
      if (widget.value != controller.text) {
        controller.value = TextEditingValue(
          text: widget.value,
          selection: TextSelection.collapsed(offset: widget.value.length),
        );
      }
    });
  }

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
        TextFormField(
          key: _formState,
          focusNode: focusNode,
          controller: controller,
          onTap: () {
            if (!widget.focus && widget.onTap != null) {
              widget.onTap!();
            }
          },
          readOnly: widget.onTap != null,
          textInputAction: widget.textInputAction ?? TextInputAction.next,
          style: widget.style ?? CStyle.paragraph1(),
          onChanged: (String text) {
            if (widget.number && !widget.name.toLowerCase().contains('phone')) {
              text = text.replaceAll('.', '');
            }
            widget.onChanged?.call(text);
          },
          validator: widget.validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          obscureText: visible,
          keyboardType: widget.number ? TextInputType.number : widget.keyboardType,
          decoration: InputDecoration(
            hintText: widget.hintText,
            errorText: widget.errorText,
            labelText: !widget.stackedLabel ? (widget.hintText ?? widget.label) : null,
            hintStyle: widget.hintStyle ??
                CStyle.paragraph1(
                    style: const TextStyle(
                  color: CColor.textDark3,
                )),
            labelStyle: widget.labelStyle ??
                TextStyle(
                  color: CColor.black.shade400,
                  fontSize: CFontSize.paragraph1,
                ),
            prefixIcon: widget.icon,
            suffixIcon: widget.password
                ? GestureDetector(
                    onTap: () => setState(() {
                      visible = !visible;
                    }),
                    child: Icon(
                      visible ? Icons.visibility : Icons.visibility_off,
                      color: widget.iconColor ?? CColor.black.shade300,
                    ),
                  )
                : widget.suffix,
            enabled: widget.enabled,
            focusedBorder: widget.focusedBorder ??
                const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(CSpace.medium)),
                  borderSide: BorderSide(color: CColor.primary, width: 0),
                ),
            disabledBorder: widget.disabledBorder ??
                const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(CSpace.medium)),
                  borderSide: BorderSide(color: CColor.primary, width: 0),
                ),
            enabledBorder: widget.enabledBorder ??
                OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(CSpace.medium)),
                  borderSide: BorderSide(color: CColor.primary.withOpacity(widget.value != '' ? 0.3 : 0), width: 0),
                ),
            errorBorder: widget.errorBorder ??
                const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(CSpace.medium)),
                  borderSide: BorderSide(color: CColor.stateError, width: 0),
                ),
            focusedErrorBorder: widget.errorBorder ??
                const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(CSpace.medium)),
                  borderSide: BorderSide(color: CColor.stateError, width: 0),
                ),
            fillColor: widget.fillColor ?? Colors.white,
            contentPadding: EdgeInsets.symmetric(
              vertical: widget.maxLines > 1 ? CSpace.medium : 15,
              horizontal: widget.icon != null ? 0 : 20,
            ),
            filled: true,
          ),
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          inputFormatters: widget.inputFormatters ?? (widget.number && !widget.name.toLowerCase().contains('phone') ? [ThousandFormatter()] : null),
        ),
        SizedBox(height: widget.space ? CSpace.large : 0),
      ],
    );
  }
}

class ThousandFormatter extends TextInputFormatter {
  static const separator = '.';

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String newValueText = newValue.text.replaceAll(separator, '');

    if (oldValue.text.endsWith(separator) && oldValue.text.length == newValue.text.length + 1) {
      newValueText = newValueText.substring(0, newValueText.length - 1);
    }

    int selectionIndex = newValue.text.length - newValue.selection.extentOffset;
    final chars = newValueText.split('');
    String newString = '';
    for (int i = chars.length - 1; i >= 0; i--) {
      if ((chars.length - 1 - i) % 3 == 0 && i != chars.length - 1) {
        newString = separator + newString;
      }
      newString = chars[i] + newString;
    }

    return TextEditingValue(
      text: newString.toString(),
      selection: TextSelection.collapsed(
        offset: newString.length - selectionIndex,
      ),
    );
  }
}
