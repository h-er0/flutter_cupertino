import Flutter
import UIKit
import SwiftUI

class CupertinoButtonFactory: NSObject, FlutterPlatformViewFactory {
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
            return CupertinoButtonController(
                frame: frame,
                viewIdentifier: viewId,
                arguments: args,
                messenger: messenger
            )
        } else {
            // Fallback for iOS < 15
            // Since we are using SwiftUI features only available in iOS 15+,
            // we return a simple UIView or a legacy controller if implemented.
            // For now, returning an empty view to prevent crash.
            return LegacyCupertinoButtonController(frame: frame, viewIdentifier: viewId)
        }
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

@available(iOS 15.0, *)
class CupertinoButtonController: NSObject, FlutterPlatformView {
    private var _hostingController: UIHostingController<CupertinoButtonView>?
    private var _channel: FlutterMethodChannel

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        messenger: FlutterBinaryMessenger
    ) {
        _channel = FlutterMethodChannel(name: "flutter_cupertino/button_\(viewId)", binaryMessenger: messenger)
        super.init()
        
        let props = parseArguments(args)
        let rootView = CupertinoButtonView(
            text: props.text,
            systemIconName: props.systemIconName,
            iconBytes: props.iconBytes,
            color: props.color,
            textColor: props.textColor,
            fontSize: props.fontSize,
            fontWeight: props.fontWeight,
            cornerRadius: props.cornerRadius,
            style: props.style,
            onPressed: { [weak self] in
                self?._channel.invokeMethod("onPressed", arguments: nil)
            }
        )
        
        _hostingController = UIHostingController(rootView: rootView)
        _hostingController?.view.frame = frame
        _hostingController?.view.backgroundColor = .clear
        
        _channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handle(call, result: result)
        }
    }

    func view() -> UIView {
        return _hostingController?.view ?? UIView()
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "update" {
            let props = parseArguments(call.arguments)
            _hostingController?.rootView = CupertinoButtonView(
                text: props.text,
                systemIconName: props.systemIconName,
                iconBytes: props.iconBytes,
                color: props.color,
                textColor: props.textColor,
                fontSize: props.fontSize,
                fontWeight: props.fontWeight,
                cornerRadius: props.cornerRadius,
                style: props.style,
                onPressed: { [weak self] in
                    self?._channel.invokeMethod("onPressed", arguments: nil)
                }
            )
            result(nil)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    private struct ButtonProps {
        let text: String?
        let systemIconName: String?
        let iconBytes: FlutterStandardTypedData?
        let color: Color?
        let textColor: Color?
        let fontSize: CGFloat
        let fontWeight: Font.Weight
        let cornerRadius: CGFloat?
        let style: String
    }
    
    private func parseArguments(_ args: Any?) -> ButtonProps {
        let dict = args as? [String: Any] ?? [:]
        
        let text = dict["text"] as? String
        let systemIconName = dict["systemIconName"] as? String
        let iconBytes = dict["iconBytes"] as? FlutterStandardTypedData
        
        var color: Color?
        if let val = dict["color"] as? Int64 {
            color = Color(uiColor: uiColor(from: val))
        }
        
        var textColor: Color?
        if let val = dict["textColor"] as? Int64 {
            textColor = Color(uiColor: uiColor(from: val))
        }
        
        let fontSize = dict["fontSize"] as? CGFloat ?? 17.0
        let fontWeightVal = dict["fontWeight"] as? Int ?? 400
        let fontWeight = uiFontWeight(from: fontWeightVal)
        
        let cornerRadius = dict["borderRadius"] as? CGFloat
        
        let style = dict["style"] as? String ?? "automatic"
        
        return ButtonProps(
            text: text,
            systemIconName: systemIconName,
            iconBytes: iconBytes,
            color: color,
            textColor: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
            cornerRadius: cornerRadius,
            style: style
        )
    }
    
    private func uiColor(from arg: Int64) -> UIColor {
        let a = CGFloat((arg >> 24) & 0xFF) / 255.0
        let r = CGFloat((arg >> 16) & 0xFF) / 255.0
        let g = CGFloat((arg >> 8) & 0xFF) / 255.0
        let b = CGFloat(arg & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    private func uiFontWeight(from value: Int) -> Font.Weight {
        switch value {
        case 100: return .ultraLight
        case 200: return .thin
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

class LegacyCupertinoButtonController: NSObject, FlutterPlatformView {
    private var _view: UIView

    init(frame: CGRect, viewIdentifier viewId: Int64) {
        _view = UIView(frame: frame)
        super.init()
        
        let label = UILabel()
        label.text = "iOS 15+ Required"
        label.textColor = .red
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        _view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: _view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: _view.centerYAnchor)
        ])
    }

    func view() -> UIView {
        return _view
    }
}
