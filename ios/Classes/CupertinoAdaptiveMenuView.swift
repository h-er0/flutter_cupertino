import Flutter
import SwiftUI
import UIKit

class CupertinoAdaptiveMenuView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var methodChannel: FlutterMethodChannel
    private var hostingController: UIViewController?

    // State
    private var menuItems: [AdaptiveMenuItemData] = []
    private var hasPrimaryAction: Bool = false

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        messenger: FlutterBinaryMessenger
    ) {
        // Container view
        _view = UIView(frame: frame)
        _view.backgroundColor = .clear

        methodChannel = FlutterMethodChannel(
            name: "flutter_cupertino/adaptive_menu_\(viewId)", binaryMessenger: messenger)

        super.init()

        if let argsMap = args as? [String: Any] {
            parseArgs(argsMap)
        }

        setupSwiftUI(viewId: viewId)
        methodChannel.setMethodCallHandler(handle)
    }

    private func parseArgs(_ args: [String: Any]) {
        if let items = args["items"] as? [Any] {
            self.menuItems = items.compactMap { $0 as? [String: Any] }.map {
                AdaptiveMenuItemData.from(map: $0)
            }
        }
        if let hasPrimary = args["hasPrimaryAction"] as? Bool {
            self.hasPrimaryAction = hasPrimary
        }
    }

    private func setupSwiftUI(viewId: Int64) {
        // We require iOS 15.0 for the modern SwiftUI Menu components used in AdaptiveMenuView
        guard #available(iOS 15.0, *) else {
            print("AdaptiveMenu requires iOS 15.0+")
            return
        }

        let swiftUIView = AdaptiveMenuView(
            items: menuItems,
            hasPrimaryAction: hasPrimaryAction,
            onAction: { [weak self] id in
                self?.methodChannel.invokeMethod("onAction", arguments: id)
            },
            onPrimaryAction: { [weak self] in
                self?.methodChannel.invokeMethod("performPrimaryAction", arguments: nil)
            }
        )

        let host = UIHostingController(rootView: swiftUIView)
        host.view.backgroundColor = .clear
        host.view.frame = _view.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        _view.addSubview(host.view)
        hostingController = host
    }

    private func updateSwiftUI() {
        guard #available(iOS 15.0, *) else { return }

        let swiftUIView = AdaptiveMenuView(
            items: menuItems,
            hasPrimaryAction: hasPrimaryAction,
            onAction: { [weak self] id in
                self?.methodChannel.invokeMethod("onAction", arguments: id)
            },
            onPrimaryAction: { [weak self] in
                self?.methodChannel.invokeMethod("performPrimaryAction", arguments: nil)
            }
        )

        if let host = hostingController as? UIHostingController<AdaptiveMenuView> {
            host.rootView = swiftUIView
        }
    }

    func view() -> UIView {
        return _view
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "updateMenu":
            if let args = call.arguments as? [String: Any] {
                parseArgs(args)
                updateSwiftUI()
                result(nil)
            } else {
                result(
                    FlutterError(
                        code: "INVALID_ARGS", message: "Arguments must be a map", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
