import SwiftUI

/// A slider setting component
public struct SettingSlider<V: BinaryFloatingPoint>: View where V.Stride: BinaryFloatingPoint {
    let title: String
    let description: String?
    @Binding var value: V
    let range: ClosedRange<V>
    let step: V.Stride
    
    public init(
        title: String,
        description: String? = nil,
        value: Binding<V>,
        range: ClosedRange<V>,
        step: V.Stride = 1
    ) {
        self.title = title
        self.description = description
        self._value = value
        self.range = range
        self.step = step
    }
    
    public var body: some View {
        MagicSettingRow(title: title, description: description) {
            Slider(value: $value, in: range, step: step)
                .frame(width: 200)
        }
    }
}

// MARK: - Preview
#Preview {
    MagicThemePreview {
        VStack(spacing: 0) {
            SettingSlider(
                title: "Volume",
                description: "Adjust the playback volume",
                value: .constant(0.7),
                range: 0...1,
                step: 0.1
            )
            
            Divider()
            
            SettingSlider(
                title: "Opacity",
                value: .constant(50),
                range: 0...100,
                step: 5
            )
        }
        .padding()
        .frame(width: 400)
    }
}
