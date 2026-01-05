import 'src/flutter_cupertino_platform_interface.dart';
export 'src/cupertino_alert.dart';
export 'src/cupertino_button.dart';
export 'src/cupertino_slider.dart';
export 'src/cupertino_action_button.dart';

class FlutterCupertino {
  FlutterCupertino._();

  static Future<String?> getPlatformVersion() {
    return FlutterCupertinoPlatform.instance.getPlatformVersion();
  }
}
