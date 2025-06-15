import SwiftUI

/// A container view that groups related settings together
public struct MagicSettingSection<Content: View>: View {
    let title: String?
    let content: Content

    public init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                if let title {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.leading, 4)
                }

                content
                    .padding(.leading, 4)
            }
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Preview

#Preview {
    MagicContainer {
        MagicSettingSection(title: "General") {
            VStack(spacing: 8) {
                Text("Setting Item 1")
                Text("Setting Item 2")
                Text("Setting Item 3")
            }
        }
        .padding()
        .frame(width: 400)
    }
}
