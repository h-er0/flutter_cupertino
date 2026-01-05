import Flutter
import UIKit

public class FlutterCupertinoPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_cupertino", binaryMessenger: registrar.messenger())
    let instance = FlutterCupertinoPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    let factory = LiquidViewFactory(messenger: registrar.messenger())
    registrar.register(factory, withId: "flutter_cupertino/view")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
