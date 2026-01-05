import SwiftUI
import Flutter

@available(iOS 15.0, *)
struct CupertinoSwitchView: View {
    @Binding var value: Bool
    let activeColor: Color?
    let thumbColor: Color?
    let onChanged: (Bool) -> Void
    
    var body: some View {
        Toggle("", isOn: Binding(
            get: { value },
            set: { newValue in
                value = newValue
                onChanged(newValue)
            }
        ))
        .labelsHidden() // Hide the label since we want just the switch
        .tint(activeColor)
        // Note: thumbColor support in SwiftUI Toggle is limited/platform specific or requires custom styles.
        // Standard ToggleStyle doesn't easily expose thumb color modification without custom styles.
        // For now we just support tint (active color).
    }
}
