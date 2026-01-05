import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_cupertino_platform_interface.dart';

/// An implementation of [FlutterCupertinoPlatform] that uses method channels.
class MethodChannelFlutterCupertino extends FlutterCupertinoPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_cupertino');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
