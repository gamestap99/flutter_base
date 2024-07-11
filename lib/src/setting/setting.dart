import 'message_impl.dart';

class FlutterBaseSetting {
  static final FlutterBaseSetting _instance = FlutterBaseSetting._();

  FlutterBaseSetting._() {
    _baseMessage = FlutterBaseMessageImpl();
  }

  late FlutterBaseMessage _baseMessage;

  factory FlutterBaseSetting() {
    return _instance;
  }

  void updateBaseMessage(FlutterBaseMessage baseMessage) {
    _baseMessage = baseMessage;
  }

  FlutterBaseMessage get baseMessage => _baseMessage;
}
