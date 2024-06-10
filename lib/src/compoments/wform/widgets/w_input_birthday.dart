import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../constants/color.dart';
import '../../../constants/dimens.dart';
import '../../../utils/helpers.dart';
import '../index.dart';

class WInputBirthday extends StatefulWidget {
  final String label;
  final String name;
  final String value;
  final bool space;
  final bool required;
  final bool enabled;
  final ValueChanged<dynamic>? onChanged;
  final Widget? icon;
  final String? format;
  final bool stackedLabel;
  final TextEditingController controller;
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
  final String? errorText;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const WInputBirthday({
    super.key,
    required this.label,
    required this.value,
    required this.space,
    required this.required,
    required this.enabled,
    this.onChanged,
    this.icon,
    this.format,
    required this.stackedLabel,
    required this.controller,
    required this.name,
    this.labelStyle,
    this.style,
    this.hintStyle,
    this.hintText,
    this.enabledBorder,
    this.errorBorder,
    this.focusedBorder,
    this.disabledBorder,
    this.fillColor,
    this.iconColor,
    this.requiredColor,
    this.textInputAction,
    this.errorText,
    this.suffix,
    this.validator,
  });

  @override
  State<WInputBirthday> createState() => _WInputBirthdayState();
}

class _WInputBirthdayState extends State<WInputBirthday> {
  @override
  Widget build(BuildContext context) {
    return WInput(
      name: widget.name,
      number: true,
      controller: widget.controller,
      label: widget.label,
      labelStyle: widget.labelStyle,
      hintText: 'DD/MM/YYYY',
      value: widget.value,
      space: widget.space,
      required: widget.required,
      enabled: widget.enabled,
      stackedLabel: widget.stackedLabel,
      onChanged: widget.onChanged,
      suffix: InkWell(
        onTap: () {
          showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(DateTime.now().year - 20),
            lastDate: DateTime(DateTime.now().year + 20),
          ).then((value) {
            if (value != null) {
              widget.onChanged?.call(Helpers.formatDate(value, format: 'dd/MM/yyyy'));
            }
          });
        },
        child: Icon(
          Icons.calendar_month_rounded,
          color: CColor.primary,
          size: CFontSize.headline3,
        ),
      ),
      focus: true,
      icon: widget.icon,
      inputFormatters: [BirthTextInputFormatter()],
      enabledBorder: widget.enabledBorder,
      errorBorder: widget.errorBorder,
      focusedBorder: widget.focusedBorder,
      disabledBorder: widget.disabledBorder,
      fillColor: widget.fillColor,
      iconColor: widget.iconColor,
      requiredColor: widget.requiredColor,
      style: widget.style,
      hintStyle: widget.hintStyle,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
    );
  }
}

class BirthTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (oldValue.text.length >= newValue.text.length) {
      return newValue;
    }
    var dateText = _addSeparator(newValue.text, '/');
    return newValue.copyWith(text: dateText, selection: updateCursorPosition(dateText));
  }

  String _addSeparator(String value, String separator) {
    value = _validateDate(value.replaceAll('/', ''));
    var newString = '';
    for (int i = 0; i < value.length; i++) {
      newString += value[i];
      if (i == 1) {
        newString += separator;
      }
      if (i == 3) {
        newString += separator;
      }
    }
    return newString;
  }

  String _validateDate(String value) {
    List<String> newString = [];

    for (int i = 0; i < value.length; i++) {
      if (i == 1) {
        if ((int.parse(value[i - 1]) == 3 && int.parse(value[i]) > 1) || (int.parse(value[i - 1]) > 3)) {
          newString[i - 1] = '0';
        }
      }

      if (i == 3) {
        if ((int.parse(value[i - 1]) == 1 && int.parse(value[i]) > 2) || (int.parse(value[i - 1]) > 1)) {
          newString[i - 1] = '0';
        }

        if (int.parse(value[i - 1]) == 0 && int.parse(value[i]) == 2 && int.parse(value[0]) == 3) {
          newString[0] = '0';
        }
      }

      if (i == 5) {
        if (int.parse(value[i - 1]) < 1 || int.parse(value[i - 1]) > 2) {
          newString[i - 1] = '1';
        }
      }

      newString.add(value[i]);
    }

    if (newString.length > 8) {
      newString.removeRange(8, newString.length);
    }

    return newString.join('');
  }

  TextSelection updateCursorPosition(String text) {
    return TextSelection.fromPosition(TextPosition(offset: text.length));
  }
}
