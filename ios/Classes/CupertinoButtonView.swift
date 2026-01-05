import SwiftUI
import Flutter

@available(iOS 15.0, *)
struct CupertinoButtonView: View {
    let text: String?
    let systemIconName: String?
    let iconBytes: FlutterStandardTypedData?
    let color: Color?
    let textColor: Color?
    let fontSize: CGFloat
    let fontWeight: Font.Weight
    let cornerRadius: CGFloat?
    let style: String // "filled", "tinted", "gray", "plain"
    let onPressed: () -> Void
    
    var body: some View {
        let button = Button(action: onPressed) {
            HStack(spacing: 8) {
                if let bytes = iconBytes, let uiImage = UIImage(data: bytes.data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                } else if let iconName = systemIconName {
                    Image(systemName: iconName)
                }
                
                if let t = text {
                    Text(t)
                        .font(.system(size: fontSize, weight: fontWeight))
                }
            }
            .padding(.horizontal, 4)
        }
        
        // Apply Native Styles
        switch style {
        case "filled":
            button.buttonStyle(.borderedProminent)
                .tint(color)
                .foregroundColor(textColor)
                .applyCornerRadius(cornerRadius)
        case "tinted":
            button.buttonStyle(.bordered)
                .tint(color)
                .foregroundColor(textColor)
                .applyCornerRadius(cornerRadius)
        case "gray":
            // .bordered with gray tint is the closest to a "gray" style
            button.buttonStyle(.bordered)
                .tint(.gray)
                .foregroundColor(textColor)
                .applyCornerRadius(cornerRadius)
        case "plain":
            button.buttonStyle(.borderless)
                .tint(color) // For plain buttons, tint affects text color
                .foregroundColor(textColor)
        case "glass":
            button.buttonStyle(GlassButtonStyle(color: color, textColor: textColor, cornerRadius: cornerRadius))
        case "glassProminent":
            button.buttonStyle(GlassButtonStyle(color: color, textColor: textColor, cornerRadius: cornerRadius, isProminent: true))
        default:
            button.buttonStyle(.automatic)
                .tint(color)
                .applyCornerRadius(cornerRadius)
        }
    }
}

@available(iOS 15.0, *)
struct GlassButtonStyle: ButtonStyle {
    let color: Color?
    let textColor: Color?
    let cornerRadius: CGFloat?
    var isProminent: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                ZStack {
                    if isProminent {
                        // Prominent Glass: Stronger blur + tint
                        Rectangle()
                            .fill((color ?? Color.blue).opacity(0.3))
                            .background(.ultraThinMaterial)
                    } else {
                        // Standard Glass: Subtle blur + light tint
                        Rectangle()
                            .fill((color ?? Color.white).opacity(0.1))
                            .background(.thinMaterial)
                    }
                }
            )
            .foregroundColor(textColor ?? (isProminent ? .white : .primary))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius ?? 16))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

@available(iOS 15.0, *)
extension View {
    @ViewBuilder
    func applyCornerRadius(_ radius: CGFloat?) -> some View {
        if let r = radius {
            self.clipShape(RoundedRectangle(cornerRadius: r))
        } else {
            self
        }
    }
}
