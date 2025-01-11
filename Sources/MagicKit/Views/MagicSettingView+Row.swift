import SwiftUI

/// A basic setting row that displays a title and optional description
public struct MagicSettingRow<Content: View>: View {
    let title: String
    let description: String?
    let icon: String?
    let content: Content
    
    public init(
        title: String,
        description: String? = nil,
        icon: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.content = content()
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 16) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                
                if let description = description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            content
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview
#Preview {
    MagicThemePreview {
        VStack(spacing: 0) {
            // Basic row with text content
            MagicSettingRow(
                title: "Basic Setting",
                description: "A simple setting row with text content",
                icon: "gear"
            ) {
                Text("Value")
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Row with button
            MagicSettingRow(
                title: "Action Setting",
                icon: "arrow.up.circle"
            ) {
                Button("Open") {
                    // Action
                }
            }
            
            Divider()
            
            // Row with image
            MagicSettingRow(
                title: "Image Setting",
                description: "Setting with system image",
                icon: "star"
            ) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
            
            Divider()
            
            // Row with custom control
            MagicSettingRow(
                title: "Custom Control",
                description: "Setting with custom control",
                icon: "dot.circle"
            ) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(.blue)
                        .frame(width: 12, height: 12)
                    Text("Active")
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Row with multiple controls
            MagicSettingRow(
                title: "Multiple Controls",
                icon: "person.circle"
            ) {
                HStack(spacing: 12) {
                    Button("Edit") {
                        // Action
                    }
                    Button("Delete") {
                        // Action
                    }
                    .foregroundColor(.red)
                }
            }
        }.padding()
    }
}
