import Flutter
import UIKit
import SwiftUI

// MARK: - Platform View

class CupertinoMenuView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private let channel: FlutterMethodChannel
    private let state = MenuState()
    private var hostingVC: UIHostingController<SwiftUIMenuView>?

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        messenger: FlutterBinaryMessenger
    ) {
        channel = FlutterMethodChannel(name: "flutter_cupertino/menu_\(viewId)", binaryMessenger: messenger)
        _view = UIView() // Initialize with dummy view to satisfy super.init requirement
        
        super.init()
        
        // Define the closure (capturing channel which is now a property, but we need weak self or weak channel)
        // Since we are now after super.init, we can use self.channel or the local channel.
        // But to be safe with captures:
        let currentChannel = channel
        let selectionCallback: ([Int]) -> Void = { path in
            currentChannel.invokeMethod("onItemSelected", arguments: path)
        }
        
        // Create the SwiftUI view wrapped in a HostingController
        let menuView = SwiftUIMenuView(state: state, onItemSelected: selectionCallback)
        let hostingVC = UIHostingController(rootView: menuView)
        hostingVC.view.backgroundColor = .clear // Ensure transparency for glass effect
        self.hostingVC = hostingVC
        self._view = hostingVC.view
        
        // Initial parse
        if let args = args as? [String: Any] {
            update(with: args)
        }
        
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }
    }

    func view() -> UIView {
        return _view
    }
    
    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "update", let args = call.arguments as? [String: Any] {
            update(with: args)
            result(nil)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    private func update(with args: [String: Any]) {
        // Run on main thread to ensure UI updates
        DispatchQueue.main.async { [weak self] in
            self?.state.update(from: args)
        }
    }
}

// MARK: - ViewModel

class MenuState: ObservableObject {
    @Published var label: String?
    @Published var systemIconName: String?
    @Published var styleIndex: Int = 5
    @Published var controlSizeIndex: Int = 2
    @Published var customColor: Color?
    @Published var customTextColor: Color?
    @Published var borderRadius: CGFloat = 8
    @Published var items: [MenuItem] = []
    
    // Explicitly process updates to trigger objectWillChange
    func update(from args: [String: Any]) {
        if let v = args["label"] as? String { label = v }
        else if args.keys.contains("label") { label = nil }
        
        if let v = args["systemIconName"] as? String, !v.isEmpty { systemIconName = v }
        else if args.keys.contains("systemIconName") { systemIconName = nil }
        
        if let v = args["style"] as? Int { styleIndex = v }
        if let v = args["controlSize"] as? Int { controlSizeIndex = v }
        
        if let c = args["color"] as? Int { customColor = Color(uiColor: UIColor(argb: c)) }
        else if args.keys.contains("color") { customColor = nil }
        
        if let c = args["textColor"] as? Int { customTextColor = Color(uiColor: UIColor(argb: c)) }
        else if args.keys.contains("textColor") { customTextColor = nil }
        
        if let r = args["borderRadius"] as? Double { borderRadius = CGFloat(r) }
        
        if let rawItems = args["items"] as? [[String: Any]] {
            self.items = parseItems(rawItems, prefix: [])
        }
    }
    
    private func parseItems(_ raw: [[String: Any]], prefix: [Int]) -> [MenuItem] {
        var results: [MenuItem] = []
        for item in raw {
            let label = item["label"] as? String ?? ""
            let icon = item["systemIconName"] as? String
            let isDestructive = item["isDestructive"] as? Bool ?? false
            let type = item["type"] as? String ?? "action"
            let index = item["index"] as? Int ?? 0
            
            let currentPath = prefix + [index]
            
            var children: [MenuItem]? = nil
            if let rawChildren = item["children"] as? [[String: Any]] {
                children = parseItems(rawChildren, prefix: currentPath)
            }
            
            results.append(MenuItem(
                label: label,
                systemIconName: icon,
                isDestructive: isDestructive,
                type: type,
                path: currentPath,
                children: children
            ))
        }
        return results
    }
}

struct MenuItem: Identifiable {
    let id = UUID()
    let label: String
    let systemIconName: String?
    let isDestructive: Bool
    let type: String
    let path: [Int]
    let children: [MenuItem]?
}

// MARK: - SwiftUI Views

struct SwiftUIMenuView: View {
    @ObservedObject var state: MenuState
    var onItemSelected: ([Int]) -> Void
    
    var body: some View {
        Menu {
            MenuContent(items: state.items, onItemSelected: onItemSelected)
        } label: {
            // Trigger Button
            // We apply the specific style based on the index, but leveraging the clean .glass style
            Group {
                if state.styleIndex == 5 || state.styleIndex == 6 {
                    Button(action: {}) {
                       labelContent
                    }
                    .buttonStyle(.cupertinoGlass)
                } else {
                    Button(action: {}) {
                       labelContent
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(backgroundView)
                    }
                    .buttonStyle(.plain) // No extra padding/background from style
                }
            }
            .foregroundColor(state.customTextColor ?? defaultTextColor(style: state.styleIndex))
            .font(fontForSize(state.controlSizeIndex))
            .applyCornerRadius(state.borderRadius)
            .allowsHitTesting(false)
        }
    }
    
    @ViewBuilder
    var labelContent: some View {
        HStack(spacing: 6) {
            // If specific icon provided
            if let icon = state.systemIconName {
                Image(systemName: icon)
            }
            
            // Label
            if let text = state.label {
                Text(text)
            }
            
            // Fallback if neither
            if state.label == nil && state.systemIconName == nil {
               Image(systemName: "chevron.up.chevron.down")
            }
        }
    }
    
    @ViewBuilder
    var backgroundView: some View {
        if let custom = state.customColor {
            custom
        } else {
            switch state.styleIndex {
            case 1: Color.blue
            case 2: Color.blue.opacity(0.2)
            case 3: Color.gray.opacity(0.2)
            default: Color.clear
            }
        }
    }
    
    func defaultTextColor(style: Int) -> Color {
        if style == 1 { return .white } // Filled
        if style == 2 { return .blue } // Tinted
        return .primary
    }
    
    func fontForSize(_ index: Int) -> Font {
        switch index {
        case 0: return .caption
        case 1: return .callout
        case 2: return .body
        case 3: return .title3
        default: return .body
        }
    }
}


// MARK: - Extensions & Styles

struct NativeGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.regularMaterial)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

extension ButtonStyle where Self == NativeGlassButtonStyle {
    static var cupertinoGlass: NativeGlassButtonStyle { NativeGlassButtonStyle() }
}

extension View {
    func applyCornerRadius(_ radius: CGFloat) -> some View {
        // Use a continuous curve if available (iOS 13+ has RoundedRectangle, iOS 15 prefers containerShape?)
        // Standard clipShape is fine.
        self.clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}



struct MenuContent: View {
    let items: [MenuItem]
    let onItemSelected: ([Int]) -> Void
    
    var body: some View {
        ForEach(items) { item in
            if item.type == "divider" {
                Divider()
            } else if let children = item.children, !children.isEmpty {
                Menu {
                    MenuContent(items: children, onItemSelected: onItemSelected)
                } label: {
                    Label(item.label, systemImage: item.systemIconName ?? "")
                }
            } else {
                Button(role: item.isDestructive ? .destructive : nil) {
                    onItemSelected(item.path)
                } label: {
                    if let icon = item.systemIconName {
                        Label(item.label, systemImage: icon)
                    } else {
                        Text(item.label)
                    }
                }
            }
        }
    }
}

// Helper Extension for UIColor handling
extension UIColor {
    convenience init(argb: Int) {
        let a = CGFloat((argb >> 24) & 0xFF) / 255.0
        let r = CGFloat((argb >> 16) & 0xFF) / 255.0
        let g = CGFloat((argb >> 8) & 0xFF) / 255.0
        let b = CGFloat(argb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
