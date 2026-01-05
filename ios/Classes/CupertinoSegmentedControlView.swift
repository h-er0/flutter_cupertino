import SwiftUI
import Flutter

@available(iOS 15.0, *)
struct CupertinoSegmentedControlView: View {
    @Binding var selectedIndex: Int
    let values: [String]
    let activeColor: Color?
    let backgroundColor: Color?
    let textColor: Color?
    let onChanged: (Int) -> Void
    
    var body: some View {
        Picker("", selection: Binding(
            get: { selectedIndex },
            set: { newValue in
                selectedIndex = newValue
                onChanged(newValue)
            }
        )) {
            ForEach(0..<values.count, id: \.self) { index in
                Text(values[index]).tag(index)
            }
        }
        .pickerStyle(.segmented)
        // Basic styling attempts. Note that SegmentedControl is resistant to standard SwiftUI styling.
        .background(backgroundColor) 
        
        // This is a workaround to apply custom text color if possible, 
        // though SwiftUI Picker doesn't always respect it for unselected state.
        .onAppear {
             // In a real production app we might use introspection or appearance proxies here
             // to set exact Update colors.
        }
    }
}
