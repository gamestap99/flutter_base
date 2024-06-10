import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'color.dart';
import 'dimens.dart';


class CStyle {
  static double s14LH17_5 = 1.25;
  static double s12LH15 = 1.25;

  /// FontSize 32.0
  static TextStyle headline1({TextStyle? style}) =>  TextStyle(
        color: CColor.textDark1,
        fontSize: CFontSize.headline1,
        fontWeight: FontWeight.w400,
      ).merge(style);

  /// FontSize 24.0
  static TextStyle headline2({TextStyle? style}) =>  TextStyle(
        color: CColor.textDark1,
        fontSize: CFontSize.headline2,
        fontWeight: FontWeight.w400,
      ).merge(style);

  /// FontSize 20.0
  static TextStyle headline3({TextStyle? style}) => builder(TextStyle(
        color: CColor.textDark1,
        fontSize: CFontSize.headline3,
        fontWeight: FontWeight.w400,
      ).merge(style));

  /// FontSize 16.0
  static TextStyle headline4({TextStyle? style}) => builder( TextStyle(
        height: 1.25,
        color: CColor.textDark1,
        fontSize: CFontSize.headline4,
        fontWeight: FontWeight.w400,
        letterSpacing: .5,
      ).merge(style));

  /// FontSize 14.0
  static TextStyle paragraph1({TextStyle? style}) => builder(TextStyle(
        color: CColor.neutral1,
        fontSize: CFontSize.paragraph1,
        height: 1.14285714286, // in css: Line height = 16
        fontWeight: FontWeight.w400,
      ).merge(style));

  /// FontSize 13.0
  static TextStyle paragraph2({TextStyle? style}) => builder(TextStyle(
        color: CColor.neutral1,
        fontSize: CFontSize.paragraph2,
        height: 1.25,
        fontWeight: FontWeight.w400,
      ).merge(style));

  /// FontSize 12.0
  static TextStyle paragraph3({TextStyle? style}) => builder(TextStyle(
        color: CColor.neutral1,
        fontSize: CFontSize.paragraph3,
        fontWeight: FontWeight.w400,
      ).merge(style));

  /// FontSize 10.0
  static TextStyle paragraph4({TextStyle? style}) => builder(TextStyle(
        color: CColor.neutral1,
        fontSize: CFontSize.paragraph4,
        fontWeight: FontWeight.w400,
      ).merge(style));

  /// FontSize 8.0
  static TextStyle paragraph5({TextStyle? style}) => builder(TextStyle(
        color: CColor.neutral1,
        fontSize: CFontSize.paragraph5,
        fontWeight: FontWeight.w400,
      ).merge(style));

  static TextStyle builder(TextStyle? style) => GoogleFonts.roboto(
        textStyle: style,
      );
}
