import SwiftUI

/// A picker setting component
public struct MagicSettingPicker<T: Hashable>: View {
    let title: String
    let description: String?
    let options: [T]
    let optionToString: (T) -> String
    @Binding var selection: T
    
    public init(
        title: String,
        description: String? = nil,
        options: [T],
        selection: Binding<T>,
        optionToString: @escaping (T) -> String
    ) {
        self.title = title
        self.description = description
        self.options = options
        self._selection = selection
        self.optionToString = optionToString
    }
    
    public var body: some View {
        MagicSettingRow(title: title, description: description) {
            Picker("", selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(optionToString(option))
                        .tag(option)
                }
            }
            .labelsHidden()
            .frame(width: 200)
        }
    }
}

// MARK: - Preview
#Preview {
    MagicThemePreview {
        VStack(spacing: 0) {
            MagicSettingPicker(
                title: "Theme",
                description: "Choose your preferred app theme",
                options: ["System", "Light", "Dark"],
                selection: .constant("System")
            ) { $0 }
            
            Divider()
            
            MagicSettingPicker(
                title: "Quality",
                options: ["Low", "Medium", "High"],
                selection: .constant("High")
            ) { $0 }
        }
        .frame(width: 600)
        .padding()
    }
}
