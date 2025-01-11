import SwiftUI

/// An example view demonstrating the usage of setting components
public struct SettingExampleView: View {
    @State private var notifications = true
    @State private var theme = "System"
    @State private var volume: Double = 0.7
    @State private var developerMode = false
    @State private var quality = "High"
    
    public init() {}
    
    public var body: some View {
        MagicThemePreview {
            VStack(alignment: .leading, spacing: 24) {
                SettingSection(title: "General") {
                    VStack(spacing: 0) {
                        SettingToggle(
                            title: "Enable Notifications",
                            description: "Show notifications when new updates are available",
                            isOn: $notifications
                        )
                        
                        Divider()
                        
                        MagicSettingPicker(
                            title: "Theme",
                            description: "Choose your preferred app theme",
                            options: ["System", "Light", "Dark"],
                            selection: $theme
                        ) { $0 }
                        
                        Divider()
                        
                        SettingSlider(
                            title: "Volume",
                            description: "Adjust the default playback volume",
                            value: $volume,
                            range: 0...1,
                            step: 0.1
                        )
                    }
                }
                
                SettingSection(title: "Advanced") {
                    VStack(spacing: 0) {
                        SettingToggle(
                            title: "Developer Mode",
                            description: "Enable advanced features and debugging tools",
                            isOn: $developerMode
                        )
                        
                        Divider()
                        
                        MagicSettingPicker(
                            title: "Quality",
                            description: "Set the audio quality for playback",
                            options: ["Low", "Medium", "High"],
                            selection: $quality
                        ) { $0 }
                    }
                }
            }
            .padding()
            .frame(width: 600)
        }
    }
}

// MARK: - Preview Provider
#Preview {
    SettingExampleView()
}
