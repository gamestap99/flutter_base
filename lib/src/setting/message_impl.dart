abstract class FlutterBaseMessage {
  String get noInternet => "Không có internet";

  String get tryStepToConnect => "tryStepToConnect";

  String get checkModem => "checkModem";

  String get reconnectWifi => "textReconnectWifi";

  String get refreshPage => "textRefreshPage";

  String get error => "textError";

  String get messageConfirmError => "messageConfirmError";

  String get textTry => "textTry";
}

class FlutterBaseMessageImpl implements FlutterBaseMessage {
  @override
  String get noInternet => "Không có internet";

  @override
  String get tryStepToConnect => "tryStepToConnect";

  @override
  String get checkModem => "checkModem";

  @override
  String get reconnectWifi => "textReconnectWifi";

  @override
  String get refreshPage => "textRefreshPage";

  @override
  String get error => "textError";

  @override
  String get messageConfirmError => "messageConfirmError";

  @override
  String get textTry => "textTry";
}
