import 'package:flutter/material.dart';

/// Horizontal spacer
class HSpacer extends SizedBox {
  const HSpacer(double size, {Key? key}) : super(key: key, width: size);
}

/// Vertical spacer
class VSpacer extends SizedBox {
  const VSpacer(double size, {Key? key}) : super(key: key, height: size);
}
