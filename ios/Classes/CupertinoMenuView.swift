import Flutter
import SwiftUI
import UIKit

class CupertinoMenuView: NSObject, FlutterPlatformView {
    private var _view: UIView

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        messenger: FlutterBinaryMessenger
    ) {
        let channel = FlutterMethodChannel(name: "flutter_cupertino/menu_\(viewId)", binaryMessenger: messenger)
        
        var label: String?
        var systemIconName: String = ""
        var items: [[String: Any]] = []
        var styleIndex: Int = 5 // glass default
        var color: Int?
        var textColor: Int?
        var borderRadius: Double?
        var usePopover: Bool = false

        if let args = args as? [String: Any] {
            label = args["label"] as? String
            systemIconName = args["systemIconName"] as? String ?? "list.bullet"
            items = args["items"] as? [[String: Any]] ?? []
            styleIndex = args["style"] as? Int ?? 5
            color = args["color"] as? Int
            textColor = args["textColor"] as? Int
            borderRadius = args["borderRadius"] as? Double
            usePopover = args["usePopover"] as? Bool ?? false
        }

        let menuView = MenuView(
            label: label,
            systemIconName: systemIconName,
            styleIndex: styleIndex,
            color: color,
            textColor: textColor,
            borderRadius: borderRadius,
            usePopover: usePopover,
            items: items,
            onItemSelected: { indexPath in
                channel.invokeMethod("onItemSelected", arguments: indexPath)
            }
        )

        let controller = UIHostingController(rootView: menuView)
        _view = controller.view
        _view.backgroundColor = .clear
        super.init()
    }

    func view() -> UIView {
        return _view
    }
}

struct MenuView: View {
    let label: String?
    let systemIconName: String
    let styleIndex: Int
    let color: Int?
    let textColor: Int?
    let borderRadius: Double?
    let usePopover: Bool
    let items: [[String: Any]]
    let onItemSelected: ([Int]) -> Void
    
    @State private var isPopoverPresented = false

    var body: some View {
        // We use Menu for all cases because SwiftUI's .popover() renders as a full-screen sheet 
        // on iPhone (compact horizontal size class), which is not the desired "popup" behavior.
        // The native implementation referenced uses UIMenu (showsMenuAsPrimaryAction),
        // which corresponds to SwiftUI's Menu view.
        Menu {
            MenuContent(items: items, parentPath: [], onItemSelected: onItemSelected)
        } label: {
            labelView
        }
    }
    
    var labelView: some View {
        HStack(spacing: 4) {
            if let label = label {
                Text(label)
                    .font(.body)
            }
            Image(systemName: systemIconName)
            if label == nil {
                // If only icon, no chevron needed usually, or maybe imply it's a menu
            } else {
                 Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(backgroundView)
        .clipShape(RoundedRectangle(cornerRadius: borderRadius ?? 8))
        .foregroundColor(resolveTextColor())
    }

    @ViewBuilder
    private var backgroundView: some View {
        if let color = color {
            Color(int: color)
        } else {
            // Default styling based on styleIndex
            // 0: automatic, 1: filled, 2: tinted, 3: gray, 4: plain, 5: glass, 6: glassProminent
            if styleIndex == 5 { // Glass
                if #available(iOS 16.0, *) {
                    Rectangle().fill(.ultraThinMaterial)
                } else {
                    Color(UIColor.systemFill)
                }
            } else if styleIndex == 6 { // Glass Prominent
                if #available(iOS 16.0, *) {
                     Rectangle().fill(.thickMaterial)
                } else {
                    Color(UIColor.secondarySystemFill)
                }
            } else if styleIndex == 1 { // Filled
                Color.blue // Default filled color
            } else if styleIndex == 2 { // Tinted
                Color.blue.opacity(0.15)
            } else if styleIndex == 3 { // Gray
                Color(UIColor.systemGray5)
            } else if styleIndex == 4 { // Plain
                Color.clear
            } else { // Automatic
                 if #available(iOS 16.0, *) {
                    Rectangle().fill(.ultraThinMaterial)
                } else {
                    Color(UIColor.systemFill)
                }
            }
        }
    }
    
    private func resolveTextColor() -> Color {
        if let textColor = textColor {
            return Color(int: textColor)
        }
        if styleIndex == 1 { // Filled
            return .white
        }
        if styleIndex == 2 { // Tinted
            return .blue
        }
        if styleIndex == 5 || styleIndex == 6 {
             return .primary
        }
        return .primary
    }
}

extension Color {
    init(int: Int) {
        let red = Double((int >> 16) & 0xFF) / 255.0
        let green = Double((int >> 8) & 0xFF) / 255.0
        let blue = Double(int & 0xFF) / 255.0
        let alpha = Double((int >> 24) & 0xFF) / 255.0 // Dart Color is ARGB
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

struct MenuContent: View {
    let items: [[String: Any]]
    let parentPath: [Int]
    let onItemSelected: ([Int]) -> Void

    var body: some View {
        ForEach(0..<items.count, id: \.self) { i in
            let item = items[i]
            let type = item["type"] as? String ?? "action"
            
            if type == "divider" {
                Divider()
            } else {
                let label = item["label"] as? String ?? ""
                let icon = item["systemIconName"] as? String
                let isDestructive = item["isDestructive"] as? Bool ?? false
                let index = item["index"] as? Int ?? i
                let children = item["children"] as? [[String: Any]]
                let currentPath = parentPath + [index]

                if let children = children, !children.isEmpty {
                    // Nested Menu
                    Menu {
                        MenuContent(items: children, parentPath: currentPath, onItemSelected: onItemSelected)
                    } label: {
                        HStack {
                            if let icon = icon {
                                Label(label, systemImage: icon)
                            } else {
                                Text(label)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    // Standard Action Item
                    Button(role: isDestructive ? .destructive : nil) {
                        onItemSelected(currentPath)
                    } label: {
                        if let icon = icon {
                            Label(label, systemImage: icon)
                        } else {
                            Text(label)
                        }
                    }
                }
            }
        }
    }
}
