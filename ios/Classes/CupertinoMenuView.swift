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
    @Published var borderRadius: CGFloat = 8
    @Published var isCircle: Bool = false
    @Published var items: [MenuItem] = []
    @Published var sections: [MenuSection] = []
    @Published var headerActions: [MenuItem] = []
    
    // Explicitly process updates to trigger objectWillChange
    func update(from args: [String: Any]) {
        if let v = args["label"] as? String { label = v }
        else if args.keys.contains("label") { label = nil }
        
        if let v = args["systemIconName"] as? String, !v.isEmpty { systemIconName = v }
        else if args.keys.contains("systemIconName") { systemIconName = nil }
        
        if let v = args["style"] as? Int { styleIndex = v }
        if let v = args["controlSize"] as? Int { controlSizeIndex = v }
        
        if let r = args["borderRadius"] as? Double { borderRadius = CGFloat(r) }
        
        // Populate Header
        if let rawHeader = args["header"] as? [[String: Any]] {
             // Headers are parsed with path prefix [-1]
             self.headerActions = parseItems(rawHeader, prefix: [-1])
        } else {
             self.headerActions = []
        }
        
        // Populate Sections or Items
        if let rawSections = args["sections"] as? [[String: Any]] {
            self.sections = parseSections(rawSections)
            self.items = [] // Clear flat items if sections exist
        } else if let rawItems = args["items"] as? [[String: Any]] {
            self.items = parseItems(rawItems, prefix: [])
            self.sections = []
        }
        
        // Calculate isCircle default if not provided
        if let c = args["isCircle"] as? Bool {
            isCircle = c
        } else {
             let hasLabel = (label != nil && !label!.isEmpty)
             let hasIcon = (systemIconName != nil && !systemIconName!.isEmpty)
             
             // "if only icon is provided or no icon provided, isCircle is by default on true"
             if (hasIcon && !hasLabel) || (!hasIcon) {
                 isCircle = true
             } else {
                 isCircle = false
             }
        }
    }
    
    private func parseSections(_ raw: [[String: Any]]) -> [MenuSection] {
        var results: [MenuSection] = []
        for (index, sectionDict) in raw.enumerated() {
            let title = sectionDict["title"] as? String
            let rawItems = sectionDict["items"] as? [[String: Any]] ?? []
            // Section path prefix: [index]
            let items = parseItems(rawItems, prefix: [index])
            results.append(MenuSection(title: title, items: items))
        }
        return results
    }
    
    // Modified parseItems to handle new fields
    private func parseItems(_ raw: [[String: Any]], prefix: [Int]) -> [MenuItem] {
        var results: [MenuItem] = []
        for item in raw {
            let label = item["label"] as? String ?? ""
            let icon = item["systemIconName"] as? String
            let isDestructive = item["isDestructive"] as? Bool ?? false
            let isEnabled = item["isEnabled"] as? Bool ?? true
            let trailingIcon = item["trailingIconName"] as? String
            let type = item["type"] as? String ?? "action"
            let index = item["index"] as? Int ?? 0
            
            // Path construction
            // If prefix starts with -1 (header), path is [-1, index]
            // If prefix is [sectionIndex], path is [sectionIndex, index]
            // If prefix is empty (flat items), path is [index] (Wait, we need to be handled carefully in Dart)
            // The Dart side expects:
            // Sections: [sectionIndex, itemIndex]
            // Flat: [itemIndex]
            
            // Here 'prefix' is the parent path.
            // But 'index' coming from Dart might handle order.
            // If parseItems is called for a Section, prefix=[sectionIndex].
            // If we use 'index' from Dart map, that is the index in the list.
            
            let currentPath = prefix + [index]
            
            var children: [MenuItem]? = nil
            if let rawChildren = item["children"] as? [[String: Any]] {
                children = parseItems(rawChildren, prefix: currentPath)
            }
            
            results.append(MenuItem(
                label: label,
                systemIconName: icon,
                isDestructive: isDestructive,
                isEnabled: isEnabled,
                trailingIconName: trailingIcon,
                type: type,
                path: currentPath,
                children: children
            ))
        }
        return results
    }
}

struct MenuSection: Identifiable {
    let id = UUID()
    let title: String?
    let items: [MenuItem]
}

struct MenuItem: Identifiable {
    let id = UUID()
    let label: String
    let systemIconName: String?
    let isDestructive: Bool
    let isEnabled: Bool
    let trailingIconName: String?
    let type: String
    let path: [Int]
    let children: [MenuItem]?
}

// MARK: - SwiftUI Views

struct SwiftUIMenuView: View {
    @ObservedObject var state: MenuState
    var onItemSelected: ([Int]) -> Void
    
    var body: some View {
        if #available(iOS 26.0, *) {
            // Check for glass vs glassProminent
            if state.styleIndex == 6 { // glassProminent
                menuStructure
                    .buttonStyle(.glassProminent) // Hypothetical
                    .controlSize(controlSize)
                    .isCircle(state.isCircle)
            } else {
                menuStructure
                    .buttonStyle(.glass)
                    .controlSize(controlSize)
                    .isCircle(state.isCircle)
            }
        } else {
            // iOS 15+ Fallback
            if #available(iOS 15.0, *) {
                menuStructure
                    .buttonStyle(.plain)
                    .controlSize(controlSize)
                    .isCircle(state.isCircle)
            } else {
                menuStructure
                    .buttonStyle(.plain)
                    .isCircle(state.isCircle)
            }
        }
    }
    
    @available(iOS 15.0, *)
    var controlSize: ControlSize {
        switch state.controlSizeIndex {
        case 0: return .mini
        case 1: return .small
        case 2: return .regular
        case 3: return .large
        case 4:
            if #available(iOS 17.0, *) {
                return .extraLarge
            } else {
                return .large
            }
        default: return .regular
        }
    }

    var menuStructure: some View {
        Menu {
            // Header Action Row
            if !state.headerActions.isEmpty {
                ControlGroup {
                    ForEach(state.headerActions) { action in
                        Button(role: action.isDestructive ? .destructive : nil) {
                           onItemSelected(action.path)
                        } label: {
                           if let icon = action.systemIconName {
                              Label(action.label, systemImage: icon)
                           } else {
                              Text(action.label)
                           }
                        }
                        .disabled(!action.isEnabled)
                    }
                }
            }
            
            // Sections
            if !state.sections.isEmpty {
                ForEach(state.sections) { section in
                    Section {
                         MenuContent(items: section.items, onItemSelected: onItemSelected)
                    } header: {
                        if let title = section.title, !title.isEmpty {
                            Text(title)
                        }
                    }
                }
            } else {
                // Fallback for flat items
                MenuContent(items: state.items, onItemSelected: onItemSelected)
            }
        } label: {
                labelContent
           
        }
    }
    
    @ViewBuilder
    var labelContent: some View {
        HStack(spacing: 6) {
            if let icon = state.systemIconName {
                Image(systemName: icon)
            }
            if let text = state.label {
                Text(text)
            }
            if state.label == nil && state.systemIconName == nil {
               Image(systemName: "chevron.up.chevron.down")
            }
        }
    }
}

// MARK: - Content Helpers
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
                    HStack {
                       if let icon = item.systemIconName {
                           Image(systemName: icon)
                       }
                       Text(item.label)
                       Spacer()
                       
                       // Suffix Icon
                       if let trailing = item.trailingIconName {
                          Image(systemName: trailing)
                       }
                    }
                }
                .disabled(!item.isEnabled)
            }
        }
    }
}

// MARK: - Extensions

extension View {
    @ViewBuilder
    func isCircle(_ isActive: Bool) -> some View {
        if isActive {
            self.clipShape(Circle())
        } else {
            self
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
