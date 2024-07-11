import 'dart:async';

import 'package:flutter/material.dart';

class Debouncer {
  Debouncer({
    required this.milliseconds,
    this.context,
  });

  final int milliseconds;
  final BuildContext? context;
  Timer? _timer;

  run(VoidCallback action) {
    if (_timer != null && _timer!.isActive) {
      _timer?.cancel();
    }

    if (context == null || (context != null && (context?.mounted ?? false))) {
      _timer = Timer(Duration(milliseconds: milliseconds), action);
    }
  }

  destroy() {
    _timer?.cancel();
  }
}
