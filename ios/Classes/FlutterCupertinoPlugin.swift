import Flutter
import UIKit
import SwiftUI

public class FlutterCupertinoPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_cupertino", binaryMessenger: registrar.messenger())
    let instance = FlutterCupertinoPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    let factory = CupertinoButtonFactory(messenger: registrar.messenger())
    registrar.register(factory, withId: "flutter_cupertino/view")
    
    let textFieldFactory = CupertinoTextFieldFactory(messenger: registrar.messenger())
    registrar.register(textFieldFactory, withId: "flutter_cupertino/textfield")

    let sliderFactory = CupertinoSliderFactory(messenger: registrar.messenger())
    registrar.register(sliderFactory, withId: "flutter_cupertino/slider")
  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getPlatformVersion" {
            result("iOS " + UIDevice.current.systemVersion)
        } else if call.method == "showAlert" {
            if let args = call.arguments as? [String: Any],
               let actions = args["actions"] as? [[String: Any]] {
                
                let title = args["title"] as? String
                let message = args["message"] as? String
                
                if #available(iOS 15.0, *) {
                    // Use SwiftUI Alert
                    let controller = AlertHostingController(title: title, message: message, actions: actions) { index in
                        // Dismiss the hosting controller after action
                        if let root = UIApplication.shared.keyWindow?.rootViewController {
                            root.dismiss(animated: true) {
                                result(index)
                            }
                        }
                    }
                    
                    if let root = UIApplication.shared.keyWindow?.rootViewController {
                        root.present(controller, animated: false, completion: nil)
                    } else {
                        result(FlutterError(code: "NO_ROOT_VC", message: "No root view controller found", details: nil))
                    }
                } else {
                    // Fallback to UIAlertController for iOS < 15
                    let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    
                    for (index, action) in actions.enumerated() {
                        let actionTitle = action["text"] as? String ?? "Action"
                        let alertAction = UIAlertAction(title: actionTitle, style: .default) { _ in
                            result(index)
                        }
                        controller.addAction(alertAction)
                    }
                    
                    if let root = UIApplication.shared.keyWindow?.rootViewController {
                        root.present(controller, animated: true, completion: nil)
                    } else {
                        result(FlutterError(code: "NO_ROOT_VC", message: "No root view controller found", details: nil))
                    }
                }
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}
