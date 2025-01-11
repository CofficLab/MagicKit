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
                MagicSettingSection(title: "General") {
                    VStack(spacing: 0) {
                        MagicSettingToggle(
                            title: "Enable Notifications",
                            description: "Show notifications when new updates are available",
                            icon: "bell.badge",
                            isOn: $notifications
                        )
                        
                        Divider()
                        
                        MagicSettingPicker(
                            title: "Theme",
                            description: "Choose your preferred app theme",
                            icon: "paintbrush",
                            options: ["System", "Light", "Dark"],
                            selection: $theme
                        ) { $0 }
                        
                        Divider()
                        
                        MagicSettingSlider(
                            title: "Volume",
                            description: "Adjust the default playback volume",
                            icon: "speaker.wave.3",
                            value: $volume,
                            range: 0...1,
                            step: 0.1
                        )
                    }
                }
                
                MagicSettingSection(title: "Advanced") {
                    VStack(spacing: 0) {
                        MagicSettingToggle(
                            title: "Developer Mode",
                            description: "Enable advanced features and debugging tools",
                            icon: "hammer",
                            isOn: $developerMode
                        )
                        
                        Divider()
                        
                        MagicSettingPicker(
                            title: "Quality",
                            description: "Set the audio quality for playback",
                            icon: "dial.high",
                            options: ["Low", "Medium", "High"],
                            selection: $quality
                        ) { $0 }
                    }
                }
                
                MagicSettingSection(title: "Custom Row Examples") {
                    VStack(spacing: 0) {
                        // Basic row with text
                        MagicSettingRow(
                            title: "Status",
                            description: "Current application status",
                            icon: "circle.fill"
                        ) {
                            Text("Running")
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        // Row with button
                        MagicSettingRow(
                            title: "Cache",
                            description: "Clear temporary files to free up space",
                            icon: "trash"
                        ) {
                            Button("Clear Cache") {
                                // Action
                            }
                        }
                        
                        Divider()
                        
                        // Row with indicator
                        MagicSettingRow(
                            title: "Connection",
                            description: "Server connection status",
                            icon: "network"
                        ) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 8, height: 8)
                                Text("Connected")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        // Row with multiple actions
                        MagicSettingRow(
                            title: "Account",
                            description: "Manage your account settings",
                            icon: "person.circle"
                        ) {
                            HStack(spacing: 12) {
                                Button("Edit") {
                                    // Action
                                }
                                Button("Sign Out") {
                                    // Action
                                }
                                .foregroundColor(.red)
                            }
                        }
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
