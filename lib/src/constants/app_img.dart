part of flutter_base;

const String _directory = "assets/image";

class _Image extends AssetImage {
  const _Image(String fileName) : super('$_directory/$fileName');
}

class AppImage {
  AppImage._();

  // logo
  static String appAtl = "assets/image/app_atl.png";
  static String bwSafari = "assets/image/safari.png";
  static String bwEdge = "assets/image/edge.png";
  static String bwChrome = "assets/image/chrome.png";
  static String monitorAndroid = "assets/image/monitor_android.png";
  static String monitorIos = "assets/image/monitor_ios.png";
  static String monitorMac = "assets/image/monitor_mac.png";
  static String monitorWindow = "assets/image/monitor_window.png";
  static String monitorLinux = "assets/image/monitor_linux.png";
  static String logoAuto = "assets/image/logo_auto.png";
  static String logoAtl2 = "assets/image/logo_atl_2.png";
  static const atlLogoWhite = _Image("atl_logo_white.png");
  static const atlLogoLogin = _Image("logo_login.png");
  static const bgMain1 = _Image("bg_main_1.png");
  static const bgNews = _Image("bg_news.png");
  static const errInternet = _Image("error_internet.png");
  static const errBug = _Image("error_bug.png");
  static const appLoader = _Image("app_loader.png");
  static const bgTimelapse = _Image("bg_timelapse.png");
  static const bgLogin2 = _Image("bg_login.jpg");
  static const nBgLogin = _Image("nw_bg_login.png");
  static const openDebug = _Image("open_debug.png");
  static const fixPerCamera = _Image("fix_per_camera.png");
  static const fixPerCameraAdr = _Image("fix_per_camera_adr.png");
  static const fixPerCameraAdrStep2 = _Image("fix_per_camera_step2.png");
  static const fixPerCameraAdrStep3 = _Image("fix_per_camera_step3.png");
  static const fixPerAdr = _Image("fix_per_adr.png");
  static const fixPerPhotoIos = _Image("fix_per_photo_ios.png");
  static const fixPerPhotoIos2 = _Image("fix_per_photo_ios_2.png");
  static const fixPerPhotoAdr = _Image("fix_per_photo_adr.png");
  static const fixPerPhotoAdr2 = _Image("fix_per_photo_adr_2.png");
  static const fixPerLocationIos = _Image("fix_per_location_ios.png");
  static const fixPerLocationIos2 = _Image("fix_per_location_ios_2.png");
  static const fixPerLocationAdr = _Image("fix_per_location_adr.png");
  static const fixPerLocationAdr2 = _Image("fix_per_location_adr_2.png");

  // background
  static String bgMain = "assets/image/bg_main.png";
  static String bgLoginPng = "assets/image/bg_login.png";

  // image
  static String noImage = "assets/image/no_image.png";
  static String noAvatar = "assets/image/no_avatar.jpg";
  static String noBackground = "assets/image/no_background.jpg";
  static String noBackGround32 = "assets/image/no_background_3-2.jpg";
  static String noVideo = "assets/image/no_video.png";
  static String comingSoon = "assets/image/coming_soon.png";
  static String emptyImage = "assets/image/empty_image.png";
  static String loading48 = "assets/image/loading_48.gif";
  static String loading200 = "assets/image/loading_200.gif";

  static String background = "assets/image/background.jpg";
  static String bgLoginContact = "assets/image/bg_login_contact.jpg";
  static String bgLogin = "assets/image/bg_login.jpeg";
  static String logoLogin = "assets/image/logo_login.png";
  static String bgInfo = "assets/image/bg_info.jpg";

  // flag
  static String flagVn = "assets/flags/vn.svg";
  static String flagGb = "assets/flags/gb.svg";
  static String flagCn = "assets/flags/cn.svg";
}
