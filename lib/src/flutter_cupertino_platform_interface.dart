import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_cupertino_method_channel.dart';

abstract class FlutterCupertinoPlatform extends PlatformInterface {
  /// Constructs a FlutterCupertinoPlatform.
  FlutterCupertinoPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterCupertinoPlatform _instance = MethodChannelFlutterCupertino();

  /// The default instance of [FlutterCupertinoPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterCupertino].
  static FlutterCupertinoPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterCupertinoPlatform] when
  /// they register themselves.
  static set instance(FlutterCupertinoPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
