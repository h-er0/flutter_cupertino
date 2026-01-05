import Flutter
import UIKit

class LiquidView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var _channel: FlutterMethodChannel

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        messenger: FlutterBinaryMessenger
    ) {
        _view = UIView()
        // Register a unique channel for this view instance
        _channel = FlutterMethodChannel(name: "flutter_cupertino/button_\(viewId)", binaryMessenger: messenger)
        
        super.init()
        
        // Handle method calls from Flutter
        _channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handle(call, result: result)
        }
        
        createNativeView(view: _view, arguments: args)
    }

    func view() -> UIView {
        return _view
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "update" {
            // Update the view with new arguments
            createNativeView(view: _view, arguments: call.arguments)
            result(nil)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    func createNativeView(view: UIView, arguments: Any?) {
        // Clear previous subviews to avoid stacking
        view.subviews.forEach { $0.removeFromSuperview() }
        
        let args = arguments as? [String: Any] ?? [:]
        
        // Use Factory to create the content view
        let contentView = LiquidButtonFactory.create(with: args)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(contentView)
        
        // Pin content view to the platform view container
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // Helper to convert Flutter color (int) to UIColor
    func uiColor(from arg: Int64) -> UIColor {
        let a = CGFloat((arg >> 24) & 0xFF) / 255.0
        let r = CGFloat((arg >> 16) & 0xFF) / 255.0
        let g = CGFloat((arg >> 8) & 0xFF) / 255.0
        let b = CGFloat((arg) & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
