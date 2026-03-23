# Flutter Cupertino Architecture

## Native Adaptive Menu (First Component)

This document outlines the architecture for the native adaptive menu component, designed to be the foundation for a suite of SwiftUI-backed Flutter plugins.

### 1. Philosophy: SwiftUI First
All iOS UI components are built using **SwiftUI** as the primary technology.
- **Why?** Apple's frameworks (ChartKit, Weather, internal tools) are moving to SwiftUI. UIKit is legacy for new feature development.
- **Escape Hatch:** UIKit is used only as a hosting container (`UIHostingController`) for the PlatformView encapsulation.

### 2. Module Structure

#### A. Dart Layer (API Surface)
- **`CupertinoAdaptiveMenu`**: A `StatefulWidget` that wraps a transparent PlatformView.
- **`CupertinoAdaptiveMenuItem`**: A pure data class (struct-like) describing the menu hierarchy.
- **Communication**: Uses standard Flutter `MethodChannel` for actions. The PlatformView is used for *hosting* the native gesture area and menu rendering, not just for display.

#### B. The Bridge (glue)
- **`CupertinoAdaptiveMenuViewFactory`**: Standard boilerplate to create the view.
- **`CupertinoAdaptiveMenuView`**: The `FlutterPlatformView` implementation.
  - **Responsibility**: 
    - Deserializes Dart arguments.
    - Manages the `UIHostingController`.
    - Routes callbacks (`onAction`) back to Flutter via MethodChannel.
  - **Constraint**: Keeps logic minimal. It just passes data to SwiftUI.

#### C. SwiftUI Layer (The Core)
- **`AdaptiveMenuView`**: Pure SwiftUI view.
- **`AdaptiveMenuItemData`**: Swift struct mirroring the Dart model.
- **`Menu`**: Uses the standard `Menu` primitive.
- **Adaptability**:
  - Uses `primaryAction` to support Context Menu behavior (Tap vs Long Press) if needed.
  - Uses `menuOrder(.fixed)` (iOS 16+) to prevent system reordering, ensuring WYSIWYG from Flutter.
  - Supports Sections and Submenus recursively.

### 3. Progressive Enhancement Strategy
- **Base Target**: iOS 13+ (technically), but features are optimized for iOS 15/16+.
- **Availability Checks**: `@available(iOS 15.0, *)` guards the SwiftUI implementation.
- **Fallback**: While not implemented in this MVP, a UIKit fallback could be swapped in `CupertinoAdaptiveMenuView` if running on very old iOS, but the mandate is "Never downgrade architecture".

### 4. Scalability
This architecture scales effectively:
- **New Components**: Create a new SwiftUI View and a corresponding PlatformView factory.
- **Complex State**: SwiftUI's `State` and `Environment` handle declarative updates much better than manual UIKit constraints.
- **Maintenance**: The UI logic is completely decoupled from the Flutter bridge. You can preview `AdaptiveMenuView` in Xcode Previews with dummy data without running Flutter.

### 5. Future Components
Next steps for the suite:
- **Native Pickers**: `Picker` styled with `.menu` or `.wheel`.
- **Sheets**: `sheet` modifier on the root view.
- **Alerts**: Native SwiftUI alerts.

---
*Created by GitHub Copilot*
