import SwiftUI
import MagicUI

struct FormatInfoView: View {
    let formats: [SupportedFormat]
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Supported Formats")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                MagicButton(
                    icon: "xmark",
                    style: .secondary,
                    size: .small,
                    shape: .circle,
                    action: onDismiss
                )
            }
            
            HStack(spacing: 16) {
                FormatSection(title: "Audio", formats: formats.filter { $0.type == .audio })
                FormatSection(title: "Video", formats: formats.filter { $0.type == .video })
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    private struct FormatSection: View {
        let title: String
        let formats: [SupportedFormat]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                ForEach(formats, id: \.name) { format in
                    HStack(spacing: 6) {
                        Image(systemName: format.type == .audio ? "music.note" : "film")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(format.name.uppercased())
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
} 