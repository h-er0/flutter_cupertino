import SwiftUI

/// A SwiftUI view that renders a native menu, adapting to the environment.
///
/// - Architecture: Uses `Menu` as the core primitive.
/// - Progressive Enhancement: Adopts `menuOrder` on iOS 16+.
/// - Integration: Designed to be hosted in a `UIHostingController` and overlay a Flutter view.
@available(iOS 15.0, *)
struct AdaptiveMenuView: View {
    let items: [AdaptiveMenuItemData]
    let hasPrimaryAction: Bool
    let onAction: (Int) -> Void
    let onPrimaryAction: (() -> Void)?

    var body: some View {
        // The root menu acts as the transparent overlay.
        // It fills the entire space allocated to the PlatformView.
        GeometryReader { proxy in
            menuView
                .frame(width: proxy.size.width, height: proxy.size.height)
                .contentShape(Rectangle())  // Ensure the whole area is tappable
        }
    }

    @ViewBuilder
    var menuView: some View {
        if hasPrimaryAction {
            Menu {
                buildMenuContent(items: items)
            } label: {
                // Invisible hit target that matches the frame
                Color.black.opacity(0.0001)
            } primaryAction: {
                onPrimaryAction?()
            }
            .menuStyleCompatibility()
        } else {
            Menu {
                buildMenuContent(items: items)
            } label: {
                // Invisible hit target
                Color.black.opacity(0.0001)
            }
            .menuStyleCompatibility()
        }
    }

    /// Recursively builds the menu content based on the data model.
    @ViewBuilder
    func buildMenuContent(items: [AdaptiveMenuItemData]) -> some View {
        ForEach(items) { item in
            switch item.type {
            case 0:  // Action
                buildActionItem(item)
            case 1:  // Submenu
                buildSubmenuItem(item)
            case 2:  // Section
                buildSectionItem(item)
            default:
                EmptyView()
            }
        }
    }

    @ViewBuilder
    func buildActionItem(_ item: AdaptiveMenuItemData) -> some View {
        Button(role: item.isDestructive ? .destructive : nil) {
            onAction(item.id)
        } label: {
            itemLabel(item)
        }
        .disabled(!item.isEnabled)
    }

    @ViewBuilder
    func buildSubmenuItem(_ item: AdaptiveMenuItemData) -> some View {
        Menu {
            if let children = item.children {
                buildMenuContent(items: children)
            }
        } label: {
            itemLabel(item)
        }
        .disabled(!item.isEnabled)
    }

    @ViewBuilder
    func buildSectionItem(_ item: AdaptiveMenuItemData) -> some View {
        Section {
            if let children = item.children {
                buildMenuContent(items: children)
            }
        } header: {
            if !item.label.isEmpty {
                Text(item.label)
            }
        }
    }

    @ViewBuilder
    func itemLabel(_ item: AdaptiveMenuItemData) -> some View {
        if let icon = item.icon, !icon.isEmpty {
            Label(item.label, systemImage: icon)
        } else {
            Text(item.label)
        }
    }
}

@available(iOS 15.0, *)
extension View {
    @ViewBuilder
    func menuStyleCompatibility() -> some View {
        if #available(iOS 16.0, *) {
            self.menuOrder(.fixed)
        } else {
            self
        }
    }
}
