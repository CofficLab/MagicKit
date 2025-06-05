import MagicCore
import SwiftUI

struct MediaPickerButton: View {
    let man: MagicPlayMan
    let selectedName: String?
    let onSelect: (URL) -> Void

    var body: some View {
        Menu {
            ForEach(man.samples, id: \.self) { sample in
                Button {
                    onSelect(sample)
                } label: {
                    Label(
                        sample.title,
                        systemImage: sample.systemIcon
                    )
                }
            }
        } label: {
            HStack {
                Image(systemName: .iconPlay)
                Text(selectedName ?? "Select Media")
                Image(systemName: "chevron.down")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        }
    }
}

// MARK: - Preview

#Preview("MagicPlayMan") {
    
        MagicPlayMan.PreviewView()
        .inMagicContainer()
}
