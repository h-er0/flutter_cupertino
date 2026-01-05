import Flutter
import UIKit
import SwiftUI

class CupertinoSegmentedControlFactory: NSObject, FlutterPlatformViewFactory {
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
            return CupertinoSegmentedControlController(
                frame: frame,
                viewIdentifier: viewId,
                arguments: args,
                messenger: messenger
            )
        } else {
            return LegacyCupertinoSegmentedControlController(frame: frame, viewIdentifier: viewId)
        }
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

@available(iOS 15.0, *)
class CupertinoSegmentedControlController: NSObject, FlutterPlatformView, ObservableObject {
    private var _hostingController: UIHostingController<CupertinoSegmentedControlView>?
    private var _channel: FlutterMethodChannel
    
    @Published var selectedIndex: Int = 0

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        messenger: FlutterBinaryMessenger
    ) {
        _channel = FlutterMethodChannel(name: "flutter_cupertino/segmented_\(viewId)", binaryMessenger: messenger)
        super.init()
        
        let props = parseArguments(args)
        self.selectedIndex = props.selectedIndex
        
        let rootView = CupertinoSegmentedControlView(
            selectedIndex: Binding(get: { self.selectedIndex }, set: { self.selectedIndex = $0 }),
            values: props.values,
            activeColor: props.activeColor,
            backgroundColor: props.backgroundColor,
            textColor: props.textColor,
            onChanged: { [weak self] newValue in
                self?._channel.invokeMethod("onValueChanged", arguments: newValue)
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
            self.selectedIndex = props.selectedIndex
            
            _hostingController?.rootView = CupertinoSegmentedControlView(
                selectedIndex: Binding(get: { self.selectedIndex }, set: { self.selectedIndex = $0 }),
                values: props.values,
                activeColor: props.activeColor,
                backgroundColor: props.backgroundColor,
                textColor: props.textColor,
                onChanged: { [weak self] newValue in
                    self?._channel.invokeMethod("onValueChanged", arguments: newValue)
                }
            )
            result(nil)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    private struct SegmentedProps {
        let values: [String]
        let selectedIndex: Int
        let activeColor: Color?
        let backgroundColor: Color?
        let textColor: Color?
    }
    
    private func parseArguments(_ args: Any?) -> SegmentedProps {
        let dict = args as? [String: Any] ?? [:]
        
        let values = dict["values"] as? [String] ?? []
        let selectedIndex = dict["selectedIndex"] as? Int ?? 0
        
        var activeColor: Color?
        if let val = dict["activeColor"] as? Int64 {
            activeColor = Color(uiColor: uiColor(from: val))
        }
        
        var backgroundColor: Color?
        if let val = dict["backgroundColor"] as? Int64 {
            backgroundColor = Color(uiColor: uiColor(from: val))
        }
        
        var textColor: Color?
        if let val = dict["textColor"] as? Int64 {
            textColor = Color(uiColor: uiColor(from: val))
        }
        
        return SegmentedProps(
            values: values,
            selectedIndex: selectedIndex,
            activeColor: activeColor,
            backgroundColor: backgroundColor,
            textColor: textColor
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

class LegacyCupertinoSegmentedControlController: NSObject, FlutterPlatformView {
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
