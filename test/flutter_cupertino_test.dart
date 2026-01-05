import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_cupertino/flutter_cupertino.dart';
import 'package:flutter_cupertino/src/flutter_cupertino_platform_interface.dart';
import 'package:flutter_cupertino/src/flutter_cupertino_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterCupertinoPlatform
    with MockPlatformInterfaceMixin
    implements FlutterCupertinoPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterCupertinoPlatform initialPlatform =
      FlutterCupertinoPlatform.instance;

  test('$MethodChannelFlutterCupertino is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterCupertino>());
  });

  test('getPlatformVersion', () async {
    MockFlutterCupertinoPlatform fakePlatform = MockFlutterCupertinoPlatform();
    FlutterCupertinoPlatform.instance = fakePlatform;

    expect(await FlutterCupertino.getPlatformVersion(), '42');
  });
}
