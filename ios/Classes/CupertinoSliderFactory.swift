import Flutter
import UIKit
import SwiftUI

class CupertinoSliderFactory: NSObject, FlutterPlatformViewFactory {
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
            return CupertinoSliderController(
                frame: frame,
                viewIdentifier: viewId,
                arguments: args,
                messenger: messenger
            )
        } else {
            return LegacyCupertinoSliderController(frame: frame, viewIdentifier: viewId)
        }
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

@available(iOS 15.0, *)
class CupertinoSliderController: NSObject, FlutterPlatformView, ObservableObject {
    private var _hostingController: UIHostingController<CupertinoSliderView>?
    private var _channel: FlutterMethodChannel
    
    // Observable state to pass as binding
    @Published var value: Double = 0.0

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        messenger: FlutterBinaryMessenger
    ) {
        _channel = FlutterMethodChannel(name: "flutter_cupertino/slider_\(viewId)", binaryMessenger: messenger)
        super.init()
        
        let props = parseArguments(args)
        self.value = props.value
        
        let rootView = CupertinoSliderView(
            value: Binding(get: { self.value }, set: { self.value = $0 }),
            min: props.min,
            max: props.max,
            divisions: props.divisions,
            activeColor: props.activeColor,
            thumbColor: props.thumbColor,
            onChanged: { [weak self] newValue in
                self?._channel.invokeMethod("onChanged", arguments: newValue)
            }
        )
        
        _hostingController = UIHostingController(rootView: rootView)
        _hostingController?.view.frame = frame
        _hostingController?.view.backgroundColor = .clear
        _hostingController?.view.clipsToBounds = false
        
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
            // Update the state
            self.value = props.value
            
            _hostingController?.rootView = CupertinoSliderView(
                value: Binding(get: { self.value }, set: { self.value = $0 }),
                min: props.min,
                max: props.max,
                divisions: props.divisions,
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
    
    private struct SliderProps {
        let value: Double
        let min: Double
        let max: Double
        let divisions: Int?
        let activeColor: Color?
        let thumbColor: Color?
    }
    
    private func parseArguments(_ args: Any?) -> SliderProps {
        let dict = args as? [String: Any] ?? [:]
        
        let value = dict["value"] as? Double ?? 0.0
        let min = dict["min"] as? Double ?? 0.0
        let max = dict["max"] as? Double ?? 1.0
        let divisions = dict["divisions"] as? Int
        
        var activeColor: Color?
        if let val = dict["activeColor"] as? Int64 {
            activeColor = Color(uiColor: uiColor(from: val))
        }
        
        var thumbColor: Color?
        if let val = dict["thumbColor"] as? Int64 {
            thumbColor = Color(uiColor: uiColor(from: val))
        }
        
        return SliderProps(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
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

class LegacyCupertinoSliderController: NSObject, FlutterPlatformView {
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
