import SwiftUI

/// A toggle setting component
public struct MagicSettingToggle: View {
    let title: String
    let description: String?
    @Binding var isOn: Bool
    
    public init(
        title: String,
        description: String? = nil,
        isOn: Binding<Bool>
    ) {
        self.title = title
        self.description = description
        self._isOn = isOn
    }
    
    public var body: some View {
        MagicSettingRow(title: title, description: description) {
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
        }
    }
}

// MARK: - Preview
#Preview {
    MagicThemePreview {
        VStack(spacing: 0) {
            MagicSettingToggle(
                title: "Enable Feature",
                description: "Turn this on to enable the awesome feature",
                isOn: .constant(true)
            )
            
            Divider()
            
            MagicSettingToggle(
                title: "Simple Toggle",
                isOn: .constant(false)
            )
        }
        .padding()
        .frame(width: 400)
    }
}
