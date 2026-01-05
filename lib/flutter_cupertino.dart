import 'src/flutter_cupertino_platform_interface.dart';
export 'src/cupertino_liquid_button.dart';

class FlutterCupertino {
  FlutterCupertino._();

  static Future<String?> getPlatformVersion() {
    return FlutterCupertinoPlatform.instance.getPlatformVersion();
  }
}
