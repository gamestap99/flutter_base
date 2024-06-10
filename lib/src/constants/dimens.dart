import 'package:flutter_screenutil/flutter_screenutil.dart';

class CFontSize {
  CFontSize._();

  static double paragraph1 = 14.sp;
  static double paragraph2 = 13.sp;
  static double paragraph3 = 12.sp;
  static double paragraph4 = 10.sp;
  static double paragraph5 = 8.0.sp;
  static double headline1 = 32.0.sp;
  static double headline2 = 24.0.sp;
  static double headline3 = 20.sp;
  static double headline4 = 16.0.sp;
}

class CSpace {
  CSpace._();

  /// Size 24.0
  static const superLarge = 24.0;

  /// Size 16.0
  static const large = 16.0;

  /// Size 12.0
  static const medium = 12.0;

  /// Size 8.0
  static const mediumSmall = 8.0;

  /// Size 6.0
  static const small = 6.0;

  /// Size 4.0
  static const superSmall = 4.0;
}

class CHeight {
  CHeight._();

  static const double medium = 48.0;
  static const double mediumSmall = 40.0;
}

class CRadius {
  CRadius._();

  static const superLarge = 24.0;
  static const large = 16.0;
  static const medium = 12.0;
  static const mediumSmall = 8.0;
  static const small = 6.0;
  static const superSmall = 4.0;
}

class CIconSize {
  CIconSize._();

  /// size 40
  static double superLarge = 40.sp;

  ///size 32
  static double large = 32.sp;

  ///size 24
  static double medium = 24.0.sp;

  ///size 20
  static double mediumSmall = 20.0.sp;

  ///size 16
  static double small = 16.0.sp;

  ///size 12
  static double superSmall = 12.0.sp;

  static double customBuilder(double size) => size.sp;
}
