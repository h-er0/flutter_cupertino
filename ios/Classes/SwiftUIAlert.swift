import SwiftUI
import Flutter

@available(iOS 15.0, *)
struct AlertWrapper: View {
    @State private var isPresented = false
    let title: String?
    let message: String?
    let actions: [[String: Any]]
    let onAction: (Int?) -> Void
    
    @State private var hasActionBeenTaken = false
    
    var body: some View {
        // Empty view that just holds the alert state
        Color.clear
            .onAppear {
                isPresented = true
            }
            .alert(title ?? "", isPresented: $isPresented) {
                ForEach(Array(actions.enumerated()), id: \.offset) { index, action in
                    let text = action["text"] as? String ?? "Action"
                    // Check for explicit role or infer from color/text
                    let role = determineRole(action)
                    
                    Button(text, role: role) {
                        hasActionBeenTaken = true
                        onAction(index)
                    }
                }
            } message: {
                if let msg = message {
                    Text(msg)
                }
            }
            .onChange(of: isPresented) { presented in
                if !presented && !hasActionBeenTaken {
                    // System dismissed it (e.g. system cancel button)
                    onAction(nil)
                }
            }
    }
    
    func determineRole(_ action: [String: Any]) -> ButtonRole? {
        // 1. Check explicit style/role passed from Dart
        if let style = action["style"] as? String {
            if style == "destructive" { return .destructive }
            if style == "cancel" { return .cancel }
            // "default" returns nil, which is correct for standard buttons
        }
        
        // 2. Infer from text (common convention)
        if let text = action["text"] as? String {
            let lower = text.lowercased()
            if lower == "cancel" { return .cancel }
            if lower == "delete" || lower == "remove" { return .destructive }
        }
        
        // 3. Infer from color (Red = Destructive)
        // Check background color
        if let colorVal = action["color"] as? Int64 {
            if isRed(colorVal) { return .destructive }
        }
        // Check text color
        if let textColorVal = action["textColor"] as? Int64 {
            if isRed(textColorVal) { return .destructive }
        }
        
        return nil
    }
    
    private func isRed(_ colorVal: Int64) -> Bool {
        let color = uiColor(from: colorVal)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        // Red > 0.8, Green < 0.5, Blue < 0.5 seems like a safe bet for "Red-ish"
        return r > 0.8 && g < 0.5 && b < 0.5
    }
    
    private func uiColor(from arg: Int64) -> UIColor {
        let a = CGFloat((arg >> 24) & 0xFF) / 255.0
        let r = CGFloat((arg >> 16) & 0xFF) / 255.0
        let g = CGFloat((arg >> 8) & 0xFF) / 255.0
        let b = CGFloat(arg & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

@available(iOS 15.0, *)
class AlertHostingController: UIHostingController<AlertWrapper> {
    init(title: String?, message: String?, actions: [[String: Any]], onAction: @escaping (Int?) -> Void) {
        let rootView = AlertWrapper(
            title: title,
            message: message,
            actions: actions,
            onAction: onAction
        )
        super.init(rootView: rootView)
        modalPresentationStyle = .overCurrentContext
        view.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
