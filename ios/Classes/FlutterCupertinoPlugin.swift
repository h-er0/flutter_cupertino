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
        if call.method == "getPlatformVersion" {
            result("iOS " + UIDevice.current.systemVersion)
        } else if call.method == "showAlert" {
            if let args = call.arguments as? [String: Any],
               let actions = args["actions"] as? [[String: Any]] {
                
                let title = args["title"] as? String
                let message = args["message"] as? String
                
                let controller = LiquidAlertController(title: title, message: message, actions: actions) { index in
                    result(index)
                }
                
                if let root = UIApplication.shared.keyWindow?.rootViewController {
                    root.present(controller, animated: true, completion: nil)
                } else {
                    result(FlutterError(code: "NO_ROOT_VC", message: "No root view controller found", details: nil))
                }
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}
