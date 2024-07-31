import 'package:flutter/material.dart';
import 'package:flutter_base/src/constants/color.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class UtilLoading {
  static final UtilLoading _instance = UtilLoading._();

  UtilLoading._();

  static UtilLoading get instance => _instance;

  configLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.light
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.yellow
      ..backgroundColor = Colors.green
      ..indicatorColor = Colors.yellow
      ..textColor = Colors.yellow
      ..maskColor = Colors.blue.withOpacity(0.5)
      ..userInteractions = true
      ..successWidget = const Icon(
        Icons.check_circle,
        color: CColor.stateSuccess,
      )
      ..errorWidget = const Icon(
        Icons.error,
        color: CColor.stateError,
      )
      ..dismissOnTap = false;
  }

  showSuccess({String? content}) async {
    await EasyLoading.showSuccess(
      content ?? 'Great Success!',
    );
  }

  showError({String? content}) async {
    await EasyLoading.showError(
      content ?? 'Không tải được dữ liệu!',
      maskType: EasyLoadingMaskType.black,
    );
  }

  show({String? status}) async {
    await EasyLoading.show(
      status: status ?? 'Loading...',
    );
  }

  showInfo({
    required String content,
    Duration? duration,
    EasyLoadingMaskType? maskType,
    bool? dismissOnTap,
  }) async {
    await EasyLoading.showInfo(
      content,
      duration: duration,
      maskType: maskType,
      dismissOnTap: dismissOnTap,
    );
  }

  showLoading({String? status}) async {
    await EasyLoading.show(
      indicator: const SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(),
      ),
      status: status ?? 'Loading...',
    );
  }

  hide({String? status}) async {
    await EasyLoading.dismiss();
  }
}
