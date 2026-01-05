import SwiftUI
import Flutter

@available(iOS 15.0, *)
struct CupertinoSliderView: View {
    @Binding var value: Double
    let min: Double
    let max: Double
    let step: Double?
    let activeColor: Color?
    let thumbColor: Color?
    let onChanged: (Double) -> Void
    
    init(value: Binding<Double>, min: Double, max: Double, divisions: Int?, activeColor: Color?, thumbColor: Color?, onChanged: @escaping (Double) -> Void) {
        self._value = value
        self.min = min
        self.max = max
        self.activeColor = activeColor
        self.thumbColor = thumbColor
        self.onChanged = onChanged
        
        if let divs = divisions, divs > 0 {
            self.step = (max - min) / Double(divs)
        } else {
            self.step = nil
        }
    }
    
    var body: some View {
        // We use a binding proxy to intercept changes
        let binding = Binding<Double>(
            get: { value },
            set: { newValue in
                value = newValue
                onChanged(newValue)
            }
        )
        
        if let s = step {
            Slider(value: binding, in: min...max, step: s)
                .tint(activeColor)
        } else {
            Slider(value: binding, in: min...max)
                .tint(activeColor)
        }
    }
}
