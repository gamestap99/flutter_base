import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenUtilHelper {

  static void init(
    BuildContext context, {
    Size designSize = const Size(360.0, 756.0),
    bool splitScreenMode = false,
    bool minTextAdapt = false,
    double Function(num, ScreenUtil)? fontSizeResolver,
  }) {
    ScreenUtil.init(
      context,
      designSize: designSize,
      splitScreenMode: splitScreenMode,
      minTextAdapt: minTextAdapt,
      fontSizeResolver: fontSizeResolver,
    );
  }


  static double font14 = 14.sp;
  static double font15 = 15.sp;
  static double font16 = 16.sp;
  static double font17 = 17.sp;
  static double font18 = 18.sp;
  static double font19 = 19.sp;
  static double font20 = 20.sp;
}
