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
    let controlSize: String
    let isCircle: Bool
    let onPressed: () -> Void
    
    var controlSizeValue: ControlSize {
        switch controlSize {
        case "mini": return .mini
        case "small": return .small
        case "regular": return .regular
        case "large": return .large
        case "extraLarge":
            if #available(iOS 17.0, *) {
                return .extraLarge
            } else {
                return .large
            }
        default: return .regular
        }
    }
    
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
        Group {
            switch style {
            case "filled":
                button.buttonStyle(.borderedProminent)
                    .tint(color)
                    .foregroundColor(textColor)
                    .applyCornerRadius(cornerRadius, isCircle: isCircle)
            case "tinted":
                button.buttonStyle(.bordered)
                    .tint(color)
                    .foregroundColor(textColor)
                    .applyCornerRadius(cornerRadius, isCircle: isCircle)
            case "gray":
                // .bordered with gray tint is the closest to a "gray" style
                button.buttonStyle(.bordered)
                    .tint(.gray)
                    .foregroundColor(textColor)
                    .applyCornerRadius(cornerRadius, isCircle: isCircle)
            case "plain":
                button.buttonStyle(.borderless)
                    .tint(color) // For plain buttons, tint affects text color
                    .foregroundColor(textColor)
            case "glass":
                if #available(iOS 26.0, *) {
                    button.buttonStyle(.glass)
                        .tint(color)
                        .foregroundColor(textColor)
                        .applyCornerRadius(cornerRadius, isCircle: isCircle)
                } else {
                    let b = button
                        .buttonStyle(.borderless)
                        .padding()
                        .background(color?.opacity(0.2) ?? Color.clear)
                        .background(.thinMaterial)
                        .foregroundColor(textColor ?? .primary)
                    
                    if isCircle {
                        b.clipShape(Circle())
                    } else {
                        b.clipShape(RoundedRectangle(cornerRadius: cornerRadius ?? 16))
                    }
                }
            case "glassProminent":
                if #available(iOS 26.0, *) {
                    button.buttonStyle(.glassProminent)
                        .tint(color)
                        .foregroundColor(textColor)
                        .applyCornerRadius(cornerRadius, isCircle: isCircle)
                } else {
                    let b = button
                        .buttonStyle(.borderless)
                        .padding()
                        .background(color?.opacity(0.4) ?? Color.clear)
                        .background(.ultraThinMaterial)
                        .foregroundColor(textColor ?? .primary)
                    
                    if isCircle {
                        b.clipShape(Circle())
                    } else {
                        b.clipShape(RoundedRectangle(cornerRadius: cornerRadius ?? 16))
                    }
                }
            default:
                button.buttonStyle(.automatic)
                    .tint(color)
                    .applyCornerRadius(cornerRadius, isCircle: isCircle)
            }
        }
        .controlSize(controlSizeValue)
        .applyButtonShape(isCircle: isCircle)
    }
}

@available(iOS 15.0, *)
extension View {
    @ViewBuilder
    func applyCornerRadius(_ radius: CGFloat?, isCircle: Bool) -> some View {
        if !isCircle, let r = radius {
            self.clipShape(RoundedRectangle(cornerRadius: r))
        } else {
            self
        }
    }

    @ViewBuilder
    func applyButtonShape(isCircle: Bool) -> some View {
        if #available(iOS 17.0, *) {
            self.buttonBorderShape(isCircle ? .circle : .automatic)
        } else {
            self.buttonBorderShape(.automatic)
        }
    }
}
