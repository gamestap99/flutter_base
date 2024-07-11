import 'package:flutter/material.dart';
import 'package:flutter_base/flutter_base.dart';
import 'package:flutter_base/src/constants/app_img.dart';
import 'package:flutter_base/src/constants/color.dart';
import 'package:flutter_base/src/constants/style.dart';
import 'package:flutter_base/src/core/dio/network_exceptions.dart';
import 'package:flutter_base/src/setting/setting.dart';

enum ErrorWidgetTheme { inLight, inColor }

class AppErrorWidget extends StatelessWidget {
  final NetworkException? networkException;
  final VoidCallback onRefresh;
  final String? error;
  final String? warning;
  final ErrorWidgetTheme theme;

  const AppErrorWidget({
    super.key,
    this.networkException,
    required this.onRefresh,
    this.error,
    this.warning,
    this.theme = ErrorWidgetTheme.inLight,
  });

  @override
  Widget build(BuildContext context) {
    if (warning != null) {
      return _ErrorWarning(
        message: warning ?? '',
        theme: theme,
        onPressed: onRefresh,
      );
    } else if (networkException != null && networkException == NetworkException.noInternetConnection) {
      return _ErrorInternet(
        onPressed: onRefresh,
        theme: theme,
      );
    } else {
      return _ErrorBug(
        // error ?? "",
        onPressed: onRefresh,
        theme: theme,
      );
    }
  }
}

class _ErrorInternet extends StatelessWidget {
  const _ErrorInternet({
    required this.onPressed,
    required this.theme,
  });

  final void Function() onPressed;
  final ErrorWidgetTheme theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Image(
          image: AppImage.errInternet,
          filterQuality: FilterQuality.medium,
        ),
        const VSpacer(40),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    FlutterBaseSetting().baseMessage.noInternet,
                    style: CStyle.headline3(
                      style: TextStyle(
                        color: theme == ErrorWidgetTheme.inLight ? CColor.textDark2 : CColor.white,
                      ),
                    ),
                  ),
                ),
                const VSpacer(20),
                Flexible(
                  child: Text(
                    FlutterBaseSetting().baseMessage.tryStepToConnect,
                    style: CStyle.paragraph1(
                      style: TextStyle(
                        color: theme == ErrorWidgetTheme.inLight ? CColor.textDark2 : CColor.white,
                      ),
                    ),
                  ),
                ),
                const VSpacer(8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 24,
                      color: theme == ErrorWidgetTheme.inLight ? CColor.textDark2 : CColor.white,
                    ),
                    const HSpacer(4),
                    Flexible(
                      child: Text(
                        FlutterBaseSetting().baseMessage.checkModem,
                        style: CStyle.paragraph1(
                          style: TextStyle(
                            color: theme == ErrorWidgetTheme.inLight ? CColor.textDark2 : CColor.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const VSpacer(4),
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 24,
                        color: theme == ErrorWidgetTheme.inLight ? CColor.textDark2 : CColor.white,
                      ),
                      const HSpacer(4),
                      Flexible(
                        child: Text(
                          FlutterBaseSetting().baseMessage.reconnectWifi,
                          style: CStyle.paragraph1(
                            style: TextStyle(
                              color: theme == ErrorWidgetTheme.inLight ? CColor.textDark2 : CColor.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const VSpacer(56),
                CustomButton.fullWidth(
                  label: FlutterBaseSetting().baseMessage.refreshPage,
                  onPressed: onPressed,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBug extends StatelessWidget {
  const _ErrorBug({
    required this.onPressed,
    required this.theme,
  });

  final void Function() onPressed;
  final ErrorWidgetTheme theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Image(
          image: AppImage.errBug,
          filterQuality: FilterQuality.medium,
        ),
        const VSpacer(40),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'Oops! ${FlutterBaseSetting().baseMessage.error}',
                    style: CStyle.paragraph1(
                      style: TextStyle(
                        color: theme == ErrorWidgetTheme.inLight ? CColor.textDark2 : CColor.white,
                      ),
                    ),
                  ),
                ),
                const VSpacer(20),
                Text(
                  FlutterBaseSetting().baseMessage.messageConfirmError,
                  textAlign: TextAlign.center,
                  style: CStyle.paragraph1(
                    style: TextStyle(
                      color: theme == ErrorWidgetTheme.inLight ? CColor.textDark2 : CColor.white,
                    ),
                  ),
                ),
                const VSpacer(52),
                Flexible(
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton.large(
                          label: FlutterBaseSetting().baseMessage.textTry,
                          onPressed: onPressed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _ErrorWarning extends StatelessWidget {
  const _ErrorWarning({
    required this.onPressed,
    required this.theme,
    required this.message,
  });

  final String message;
  final void Function() onPressed;
  final ErrorWidgetTheme theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Image(
          image: AppImage.errBug,
          filterQuality: FilterQuality.medium,
        ),
        const VSpacer(40),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    message,
                    style: CStyle.paragraph1(
                      style: TextStyle(
                        color: theme == ErrorWidgetTheme.inLight ? CColor.textDark2 : CColor.white,
                      ),
                    ),
                  ),
                ),
                const VSpacer(52),
                Flexible(
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton.large(
                          label: FlutterBaseSetting().baseMessage.textTry,
                          onPressed: onPressed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
