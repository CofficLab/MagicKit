import SwiftUI
import MagicUI

struct MediaPickerButton: View {
    let formats: [SupportedFormat]
    let selectedName: String?
    let onSelect: (MagicAsset) -> Void
    
    var body: some View {
        Menu {
            ForEach(formats.filter { !$0.samples.isEmpty }, id: \.name) { format in
                Section(format.name) {
                    ForEach(format.samples, id: \.name) { sample in
                        Button {
                            onSelect(sample.asset)
                        } label: {
                            Label(
                                sample.name,
                                systemImage: format.type == .audio ? "music.note" : "film"
                            )
                        }
                    }
                }
            }
        } label: {
            HStack {
                Image(systemName: currentAssetIcon)
                Text(selectedName ?? "Select Media")
                Image(systemName: "chevron.down")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        }
    }
    
    private var currentAssetIcon: String {
        selectedName != nil ? "music.note" : "play.circle"
    }
} 

#Preview {
    MediaPickerButton(
        formats: [
            .init(
                name: "Audio",
                extensions: ["mp3", "m4a", "wav"],
                mimeTypes: ["audio/mpeg", "audio/mp4", "audio/wav"],
                samples: [
                    .init(
                        name: "Test Song",
                        asset: .init(
                            url: .documentsDirectory,
                            metadata: .init(
                                title: "Test Song",
                                artist: "Test Artist",
                                album: "Test Album"
                            )
                        )
                    )
                ]
            )
        ],
        selectedName: "Test Song",
        onSelect: { _ in }
    )
    .padding()
    .background(.ultraThinMaterial)
} 
