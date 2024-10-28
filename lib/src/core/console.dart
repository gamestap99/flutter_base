import 'package:flutter/foundation.dart';

class AppConsole {
  static void dump(dynamic object, {bool line = true, String name = ""}) {
    if (!kReleaseMode) {
      if (object is List) {
        for (var element in object) {
          if (line) {
            // ignore: avoid_print
            print("<--------------------|");
          }

          if (name != "") {
            // ignore: avoid_print
            print("$name: $element");
          } else {
            // ignore: avoid_print
            print(element);
          }

          if (line) {
            // ignore: avoid_print
            print("|-------------------->");
          }
        }
      } else {
        if (line) {
          // ignore: avoid_print
          print("<--------------------|");
        }

        if (name != "") {
          // ignore: avoid_print
          print("$name: $object");
        } else {
          // ignore: avoid_print
          print(object);
        }

        if (line) {
          // ignore: avoid_print
          print("|-------------------->");
        }
      }
    }
  }

  static void dumpInitState(dynamic runtimeType) {
    AppConsole.dump("--------- initState:$runtimeType ---------");
  }

  static void dumpDisposeState(dynamic runtimeType) {
    AppConsole.dump("--------- dispose:$runtimeType ---------");
  }
}
