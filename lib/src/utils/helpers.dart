import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartx/dartx.dart';

import 'package:intl/intl.dart';

class Helpers {
  static String printDuration(Duration duration) {
    String negativeSign = duration.isNegative ? '-' : '';
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
    return "$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  static Duration? parseDuration(String? s, {String format = "hh:mm:ss.ssssss"}) {
    if (s == null) return null;

    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    int micros = 0;

    List<String> dots = s.split(".");

    if (dots.isEmpty) return null;

    List<String> parts = dots[0].split(':');
    try {
      switch (format.toLowerCase()) {
        case "hh:mm:ss":
          hours = int.parse(parts[0]);
          minutes = int.parse(parts[1]);
          seconds = int.parse(parts[2]);
          break;
        case "hh:mm":
          hours = int.parse(parts[0]);
          minutes = int.parse(parts[1]);
          break;
      }

      micros = (double.tryParse(dots[dots.length - 1]) ?? 0 * 1000000).round();

      return Duration(hours: hours, minutes: minutes, seconds: seconds, microseconds: micros);
    } catch (ex, stackTrace) {
      return null;
    }
  }

  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width < 1300 && MediaQuery.of(context).size.width >= 650;

  static void dump(dynamic object, {bool line = true, String name = "", bool ignore = false}) {
    if (kDebugMode || ignore) {
      if (object is List) {
        if (line) {
          // ignore: avoid_print
          print("🌸🌸🌸🌸🌸 <---------🚀📖🌐🏆[$name]🚀📖🌐🏆--------|");
        }
        for (var element in object) {
          // ignore: avoid_print
          print("💡  $element");
        }

        if (line) {
          // ignore: avoid_print
          print("|-------------------->🌸🌸🌸🌸🌸");
        }
      } else {
        if (line) {
          // ignore: avoid_print
          print("🌸🌸🌸🌸🌸<-----------[$name]---------|");
        }

        print("💡 $object");

        if (line) {
          // ignore: avoid_print
          print("|-------------------->🌸🌸🌸🌸🌸");
        }
      }
    }
  }

  static void dumpErr(dynamic object, {String name = "", Object? error, Object? stackStrace}) {
    if (kDebugMode) {
      print("🐛🐛🐛🐛<----------🚀🚀🚀🚀🚀[$name]🚀🚀🚀🚀🚀 ----------|");

      print("💡$object");
      print("🐞🐞🐞[Error]:$error");
      print("🪲🪲🪲[stackStrace]:$stackStrace");

      print("|-------------------->🐛🐛🐛🐛🐛");
    }
  }

  static void dumpInitState(dynamic runtimeType) {
    Helpers.dump("--------- initState:$runtimeType ---------");
  }

  static void dumpDisposeState(dynamic runtimeType) {
    Helpers.dump("--------- dispose:$runtimeType ---------");
  }

  static String convertPhone(String phone) {
    phone = phone.replaceAll("(", "");
    phone = phone.replaceAll("+", "");
    phone = phone.replaceAll(")", "");
    phone = phone.replaceAll(".", "");
    phone = phone.replaceAll(RegExp(r"\s+"), "");

    return phone;
  }

  // static String getBaseName(String path) {
  //   return basename(path);
  // }

  static void hideKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  static bool stringToBool(String value) => value == "0" ? false : true;

  static String boolToString(bool value) => value == true ? "1" : "0";

  static Widget keyboardDismiss({BuildContext? context, Widget? child}) {
    final gesture = GestureDetector(
      onTap: () {
        FocusScope.of(context!).requestFocus(FocusNode());
      },
      child: child,
    );

    return gesture;
  }

  static String formatByte(num num, {int precision = 1}) {
    var i = 0;
    var suffix = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

    while ((num / 1024) > 1) {
      num = (num / 1024);
      i++;
    }

    return double.parse(num.toString().substring(0, num.toString().indexOf('.'))).toStringAsFixed(precision) + suffix[i];
  }

  static Map<String, dynamic> dataDio(Map<String, dynamic> data) {
    Map<String, dynamic> data = {};

    data.forEach((key, value) {
      if (value is List) {
        value.asMap().forEach((index, element) {
          if (element is List) {
            element.asMap().forEach((k, v) {
              data["$key[$index][$k]"] = v;
            });
          } else {
            data["$key[$index]"] = element;
          }
        });
      } else if (value is Map<String, dynamic>) {
        data.addAll(convertValueMap(key, value));
      } else {
        data[key] = value;
      }
    });

    return data;
  }

  static Map<String, dynamic> convertValueMap(key, Map<String, dynamic> value) {
    Map<String, dynamic> data = {};

    value.forEach((k, v) {
      if (v is List) {
        v.asMap().forEach((index, element) {
          if (element is List) {
            element.asMap().forEach((i, e) {
              data["$key[$k][$index][$i]"] = e;
            });
          } else {
            data["$key[$k][$index]"] = element;
          }
        });
      } else if (v is Map<String, dynamic>) {
        String newKey = "$key" "[$k]";
        data.addAll(convertValueMap(newKey, v));
      } else {
        data.addAll({
          "$key[$k]": v,
        });
      }
    });

    return data;
  }

  static Future<void> copyText(String? text) async {
    return await Clipboard.setData(ClipboardData(text: text ?? ''));
  }

  static String? dateFromString(String? date, {required String inputFormat, String format = 'dd-MM-yyyy HH:mm:ss'}) {
    try {
      if (date == null || date.isEmpty) return null;
      return DateFormat(format).format(DateFormat(inputFormat).parse(date)).toString();
    } catch (ex) {
      return null;
    }
  }

  static DateTime? parseToDate(String? date, {required String inputFormat}) {
    try {
      if (date == null || date.isEmpty) return null;
      return DateFormat(inputFormat).parse(date);
    } catch (ex) {
      return null;
    }
  }

  static DateTime? parseToDateUTC(String? date, {String input = "yyyy-MM-ddTHH:mm:ssZ"}) {
    try {
      if (date == null || date.isEmpty) return null;
      return DateFormat(input).parseUTC(date).toLocal();
    } catch (ex) {
      return null;
    }
  }

  static String? formatDate(DateTime? date, {String format = 'dd-MM-yyyy HH:mm:ss', String? locale}) {
    try {
      if (date == null) return null;
      return DateFormat(format, locale).format(date).toString();
    } catch (ex) {
      return null;
    }
  }

  static detectBrowserCallback(
    String browser, {
    void Function()? onChrome,
    void Function()? onEdge,
    void Function()? onSafari,
  }) {
    browser = browser.toUpperCase();
    if (browser.matches(RegExp(r'CHROME'))) {
      onChrome?.call();
    } else if (browser.matches(RegExp(r'EDGE'))) {
      onEdge?.call();
    } else if (browser.matches(RegExp(r'SAFARI'))) {
      onSafari?.call();
    }
  }

  static String detectBrowserUserAgent(String browser) {
    String name = '';
    browser = browser.toUpperCase();

    if (browser.matches(RegExp(r'CHROME'))) {
      name = 'Google Chrome';
    } else if (browser.matches(RegExp(r'EDGE'))) {
      name = 'Microsoft Edge';
    } else if (browser.matches(RegExp(r'SAFARI'))) {
      name = 'Safari';
    }

    return name;
  }

  static detectPlatformUserAgent(
    String platform, {
    required void Function() onWindow,
    required void Function() onMac,
    required void Function() onLinux,
    required void Function() onIos,
    required void Function() onAndroid,
    required void Function() onUnknown,
  }) {
    if (platform.toUpperCase().matches(RegExp(r'WINDOWS'))) {
      onWindow();
    } else if (platform.toUpperCase().matches(RegExp(r'OS X'))) {
      onMac();
    } else if (platform.toUpperCase().matches(RegExp(r'LINUX'))) {
      onLinux();
    } else if (platform.toUpperCase().matches(RegExp(r'IOS'))) {
      onIos();
    } else if (platform.toUpperCase().matches(RegExp(r'ANDROID'))) {
      onAndroid();
    } else {
      onUnknown();
    }
  }

  static detectDeviceUserAgent(
    String userAgent, {
    required void Function() onWindow,
    required void Function() onMac,
    required void Function() onLinux,
    required void Function() onIos,
    required void Function() onAndroid,
    required void Function() onApp,
    required void Function() onUnknown,
  }) {
    if (userAgent.toUpperCase().matches(RegExp(r'WINDOWS NT'))) {
      onWindow();
    } else if (userAgent.toUpperCase().matches(RegExp(r'MACINTOSH'))) {
      onMac();
    } else if (userAgent.toUpperCase().matches(RegExp(r'LINUX'))) {
      onLinux();
    } else if (userAgent.toUpperCase().matches(RegExp(r'IPAD|IPHONE|IPOD'))) {
      onIos();
    } else if (userAgent.toUpperCase().matches(RegExp(r'ANDROID'))) {
      onAndroid();
    } else if (userAgent.toUpperCase().matches(RegExp(r'APP'))) {
      onApp();
    } else {
      onUnknown();
    }
  }

  static String formatTimeTPS(int seconds) {
    if (seconds < 0) {
      seconds = seconds.abs();
    }

    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    String result = '';
    if (hours > 0) result += '${hours}t ';
    if (minutes > 0) result += '${minutes}p ';
    if (remainingSeconds > 0) result += '${remainingSeconds}s';

    return result.trim();
  }
}
