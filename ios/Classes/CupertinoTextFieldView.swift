import SwiftUI
import Flutter

@available(iOS 15.0, *)
struct CupertinoTextFieldView: View {
    @State private var text: String
    let placeholder: String
    let obscureText: Bool
    let decoration: String // "roundedBorder", "plain", "automatic"
    let keyboardType: UIKeyboardType
    let textColor: Color?
    let placeholderColor: Color?
    let fontSize: CGFloat
    let fontWeight: Font.Weight
    
    let onChanged: (String) -> Void
    let onSubmitted: (String) -> Void
    
    init(
        text: String,
        placeholder: String,
        obscureText: Bool,
        decoration: String,
        keyboardType: UIKeyboardType,
        textColor: Color?,
        placeholderColor: Color?,
        fontSize: CGFloat,
        fontWeight: Font.Weight,
        onChanged: @escaping (String) -> Void,
        onSubmitted: @escaping (String) -> Void
    ) {
        _text = State(initialValue: text)
        self.placeholder = placeholder
        self.obscureText = obscureText
        self.decoration = decoration
        self.keyboardType = keyboardType
        self.textColor = textColor
        self.placeholderColor = placeholderColor
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.onChanged = onChanged
        self.onSubmitted = onSubmitted
    }
    
    var body: some View {
        Group {
            if obscureText {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .font(.system(size: fontSize, weight: fontWeight))
        .foregroundColor(textColor ?? .primary)
        .keyboardType(keyboardType)
        .applyTextFieldStyle(decoration)
        .onChange(of: text) { newValue in
            onChanged(newValue)
        }
        .onSubmit {
            onSubmitted(text)
        }
        .ignoresSafeArea() // Prevent SwiftUI from reacting to keyboard/safe area changes
    }
}

@available(iOS 15.0, *)
extension View {
    @ViewBuilder
    func applyTextFieldStyle(_ style: String) -> some View {
        switch style {
        case "roundedBorder":
            self.textFieldStyle(.roundedBorder)
        case "plain":
            self.textFieldStyle(.plain)
        case "squareBorder":
            self.textFieldStyle(.plain)
                .padding(8)
                .overlay(
                    Rectangle()
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
        default:
            self.textFieldStyle(.automatic)
        }
    }
}
