import Flutter
import UIKit
import SwiftUI

class CupertinoSwitchFactory: NSObject, FlutterPlatformViewFactory {
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
            return CupertinoSwitchController(
                frame: frame,
                viewIdentifier: viewId,
                arguments: args,
                messenger: messenger
            )
        } else {
            return LegacyCupertinoSwitchController(frame: frame, viewIdentifier: viewId)
        }
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

@available(iOS 15.0, *)
class CupertinoSwitchController: NSObject, FlutterPlatformView, ObservableObject {
    private var _hostingController: UIHostingController<CupertinoSwitchView>?
    private var _channel: FlutterMethodChannel
    
    @Published var value: Bool = false

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        messenger: FlutterBinaryMessenger
    ) {
        _channel = FlutterMethodChannel(name: "flutter_cupertino/switch_\(viewId)", binaryMessenger: messenger)
        super.init()
        
        let props = parseArguments(args)
        self.value = props.value
        
        let rootView = CupertinoSwitchView(
            value: Binding(get: { self.value }, set: { self.value = $0 }),
            activeColor: props.activeColor,
            thumbColor: props.thumbColor,
            onChanged: { [weak self] newValue in
                self?._channel.invokeMethod("onChanged", arguments: newValue)
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
            self.value = props.value
            
            _hostingController?.rootView = CupertinoSwitchView(
                value: Binding(get: { self.value }, set: { self.value = $0 }),
                activeColor: props.activeColor,
                thumbColor: props.thumbColor,
                onChanged: { [weak self] newValue in
                    self?._channel.invokeMethod("onChanged", arguments: newValue)
                }
            )
            result(nil)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    private struct SwitchProps {
        let value: Bool
        let activeColor: Color?
        let thumbColor: Color?
    }
    
    private func parseArguments(_ args: Any?) -> SwitchProps {
        let dict = args as? [String: Any] ?? [:]
        
        let value = dict["value"] as? Bool ?? false
        
        var activeColor: Color?
        if let val = dict["activeColor"] as? Int64 {
            activeColor = Color(uiColor: uiColor(from: val))
        }
        
        var thumbColor: Color?
        if let val = dict["thumbColor"] as? Int64 {
            thumbColor = Color(uiColor: uiColor(from: val))
        }
        
        return SwitchProps(
            value: value,
            activeColor: activeColor,
            thumbColor: thumbColor
        )
    }
    
    private func uiColor(from arg: Int64) -> UIColor {
        let a = CGFloat((arg >> 24) & 0xFF) / 255.0
        let r = CGFloat((arg >> 16) & 0xFF) / 255.0
        let g = CGFloat((arg >> 8) & 0xFF) / 255.0
        let b = CGFloat(arg & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

class LegacyCupertinoSwitchController: NSObject, FlutterPlatformView {
    private var _view: UIView

    init(frame: CGRect, viewIdentifier viewId: Int64) {
        _view = UIView(frame: frame)
        super.init()
        let label = UILabel()
        label.text = "iOS 15+"
        label.textColor = .red
        label.font = .systemFont(ofSize: 10)
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
