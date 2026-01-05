import Flutter
import UIKit
import SwiftUI

class CupertinoTextFieldFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        if #available(iOS 15.0, *) {
            return CupertinoTextFieldController(
                frame: frame,
                viewIdentifier: viewId,
                arguments: args,
                messenger: messenger
            )
        } else {
            return LegacyCupertinoTextFieldController(frame: frame, viewIdentifier: viewId)
        }
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

@available(iOS 15.0, *)
class CupertinoTextFieldController: NSObject, FlutterPlatformView {
    private var _hostingController: UIHostingController<CupertinoTextFieldView>?
    private var _channel: FlutterMethodChannel

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        messenger: FlutterBinaryMessenger
    ) {
        _channel = FlutterMethodChannel(name: "flutter_cupertino/textfield_\(viewId)", binaryMessenger: messenger)
        super.init()
        
        let props = parseArguments(args)
        let rootView = createView(props: props)
        
        _hostingController = UIHostingController(rootView: rootView)
        _hostingController?.disableSafeArea() // Helper to disable safe area on the controller
        _hostingController?.view.frame = frame
        _hostingController?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _hostingController?.view.backgroundColor = .clear
        
        _channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handle(call, result: result)
        }
    }
    
    private func createView(props: TextFieldProps) -> CupertinoTextFieldView {
        return CupertinoTextFieldView(
            text: props.text,
            placeholder: props.placeholder,
            obscureText: props.obscureText,
            decoration: props.decoration,
            keyboardType: props.keyboardType,
            textColor: props.textColor,
            placeholderColor: props.placeholderColor,
            fontSize: props.fontSize,
            fontWeight: props.fontWeight,
            onChanged: { [weak self] text in
                self?._channel.invokeMethod("onChanged", arguments: text)
            },
            onSubmitted: { [weak self] text in
                self?._channel.invokeMethod("onSubmitted", arguments: text)
            }
        )
    }

    func view() -> UIView {
        return _hostingController?.view ?? UIView()
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "update" {
            let props = parseArguments(call.arguments)
            _hostingController?.rootView = createView(props: props)
            result(nil)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    private struct TextFieldProps {
        let text: String
        let placeholder: String
        let obscureText: Bool
        let decoration: String
        let keyboardType: UIKeyboardType
        let textColor: Color?
        let placeholderColor: Color?
        let fontSize: CGFloat
        let fontWeight: Font.Weight
    }
    
    private func parseArguments(_ args: Any?) -> TextFieldProps {
        let dict = args as? [String: Any] ?? [:]
        
        let text = dict["text"] as? String ?? ""
        let placeholder = dict["placeholder"] as? String ?? ""
        let obscureText = dict["obscureText"] as? Bool ?? false
        let decoration = dict["decoration"] as? String ?? "roundedBorder"
        
        let keyboardTypeStr = dict["keyboardType"] as? String ?? "default"
        let keyboardType = uiKeyboardType(from: keyboardTypeStr)
        
        var textColor: Color? = nil
        if let val = dict["textColor"] as? Int64 {
            textColor = Color(uiColor: uiColor(from: val))
        }
        
        var placeholderColor: Color? = nil
        if let val = dict["placeholderColor"] as? Int64 {
            placeholderColor = Color(uiColor: uiColor(from: val))
        }
        
        let fontSize = dict["fontSize"] as? CGFloat ?? 17.0
        let fontWeightVal = dict["fontWeight"] as? Int ?? 400
        let fontWeight = uiFontWeight(from: fontWeightVal)
        
        return TextFieldProps(
            text: text,
            placeholder: placeholder,
            obscureText: obscureText,
            decoration: decoration,
            keyboardType: keyboardType,
            textColor: textColor,
            placeholderColor: placeholderColor,
            fontSize: fontSize,
            fontWeight: fontWeight
        )
    }
    
    private func uiKeyboardType(from val: String) -> UIKeyboardType {
        switch val {
        case "numberPad": return .numberPad
        case "phonePad": return .phonePad
        case "namePhonePad": return .namePhonePad
        case "emailAddress": return .emailAddress
        case "decimalPad": return .decimalPad
        case "twitter": return .twitter
        case "webSearch": return .webSearch
        case "asciiCapable": return .asciiCapable
        case "numbersAndPunctuation": return .numbersAndPunctuation
        case "URL": return .URL
        default: return .default
        }
    }
    
    private func uiColor(from arg: Int64) -> UIColor {
        let a = CGFloat((arg >> 24) & 0xFF) / 255.0
        let r = CGFloat((arg >> 16) & 0xFF) / 255.0
        let g = CGFloat((arg >> 8) & 0xFF) / 255.0
        let b = CGFloat(arg & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    private func uiFontWeight(from val: Int) -> Font.Weight {
        switch val {
        case 100: return .thin
        case 200: return .ultraLight
        case 300: return .light
        case 400: return .regular
        case 500: return .medium
        case 600: return .semibold
        case 700: return .bold
        case 800: return .heavy
        case 900: return .black
        default: return .regular
        }
    }
}

extension UIHostingController {
    func disableSafeArea() {
        if #available(iOS 16.4, *) {
            self.safeAreaRegions = []
        } else {
            self._disableSafeArea()
        }
    }
    
    private func _disableSafeArea() {
        guard let viewClass = object_getClass(view) else { return }
        
        let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoreSafeArea")
        if let viewSubclass = NSClassFromString(viewSubclassName) {
            object_setClass(view, viewSubclass)
        } else {
            guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
            guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }
            
            if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
                let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in
                    return .zero
                }
                class_addMethod(viewSubclass, #selector(getter: UIView.safeAreaInsets), imp_implementationWithBlock(safeAreaInsets), method_getTypeEncoding(method))
            }
            
            objc_registerClassPair(viewSubclass)
            object_setClass(view, viewSubclass)
        }
    }
}

class LegacyCupertinoTextFieldController: NSObject, FlutterPlatformView {
    private var _view: UIView

    init(frame: CGRect, viewIdentifier viewId: Int64) {
        _view = UIView(frame: frame)
        super.init()
        
        let label = UILabel(frame: _view.bounds)
        label.text = "iOS 15+ Required"
        label.textAlignment = .center
        label.textColor = .red
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _view.addSubview(label)
    }

    func view() -> UIView {
        return _view
    }
}
