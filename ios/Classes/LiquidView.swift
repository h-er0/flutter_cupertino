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
        _channel = FlutterMethodChannel(name: "flutter_cupertino/liquid_button_\(viewId)", binaryMessenger: messenger)
        
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
        
        // Simulating iOS 26 check / Liquid enablement
        var useLiquid = false
        if let enableArg = args["enableLiquid"] as? Bool {
            useLiquid = enableArg
        } else {
             if #available(iOS 13.0, *) {
                useLiquid = true 
            }
        }

        if useLiquid {
             setupLiquidGlass(view: view, args: args)
        } else {
             setupLegacy(view: view, args: args)
        }
    }
    
    func setupLiquidGlass(view: UIView, args: [String: Any]) {
        // Liquid Glass styling: Blur, translucency, rounded corners
        view.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Custom border radius
        let radius = args["borderRadius"] as? CGFloat ?? 20.0
        blurView.layer.cornerRadius = radius
        blurView.clipsToBounds = true
        
        // Custom background color (tinting the glass)
        if let colorVal = args["color"] as? Int64 {
            let color = uiColor(from: colorVal)
            blurView.contentView.backgroundColor = color.withAlphaComponent(0.3)
        }
        
        // Add a subtle border/glow
        blurView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        blurView.layer.borderWidth = 1.0
        
        view.addSubview(blurView)
        
        addContent(to: view, args: args)
    }

    func setupLegacy(view: UIView, args: [String: Any]) {
        // Legacy styling: Solid colors, standard UIKit look
        if let colorVal = args["color"] as? Int64 {
            view.backgroundColor = uiColor(from: colorVal)
        } else {
            view.backgroundColor = UIColor.systemBlue
        }
        
        let radius = args["borderRadius"] as? CGFloat ?? 8.0
        view.layer.cornerRadius = radius
        view.clipsToBounds = true
        
        addContent(to: view, args: args)
    }
    
    func addContent(to view: UIView, args: [String: Any]) {
        let text = args["text"] as? String
        let systemIconName = args["systemIconName"] as? String
        
        var textColor: UIColor = .white
        if let colorVal = args["textColor"] as? Int64 {
            textColor = uiColor(from: colorVal)
        } else {
             // dynamic default could be better, but sticking to white/label for now
             if #available(iOS 13.0, *) {
                 textColor = .label
             }
        }

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon
        if let iconName = systemIconName {
            if #available(iOS 13.0, *) {
                let image = UIImage(systemName: iconName)
                let imageView = UIImageView(image: image)
                imageView.tintColor = textColor
                imageView.contentMode = .scaleAspectFit
                // maintain a reasonable size constraint if needed, or let content hug
                stackView.addArrangedSubview(imageView)
            }
        }
        
        // Text
        if let labelText = text {
            let label = UILabel()
            label.text = labelText
            label.textColor = textColor
            label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            stackView.addArrangedSubview(label)
        }
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
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
