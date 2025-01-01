import SwiftUI
import MagicUI

public struct MagicPlayModeButton: View {
    @Binding var mode: PlayMode
    var size: CGFloat = 40
    var iconSize: CGFloat = 15
    var onChange: ((PlayMode) -> Void)?
    
    public init(
        mode: Binding<PlayMode>,
        size: CGFloat = 40,
        iconSize: CGFloat = 15,
        onChange: ((PlayMode) -> Void)? = nil
    ) {
        self._mode = mode
        self.size = size
        self.iconSize = iconSize
        self.onChange = onChange
    }
    
    public var body: some View {
        MagicPlayerButton(
            icon: mode.icon,
            size: size,
            iconSize: iconSize,
            action: {
                mode.toggle()
                onChange?(mode)
            }
        )
    }
}

#Preview("MagicPlayModeButton") {
    struct PreviewWrapper: View {
        @State private var playMode = PlayMode.sequence
        
        var body: some View {
            HStack {
                VStack(spacing: 20) {
                    Text("Light Mode")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        ForEach([PlayMode.sequence, .single, .random], id: \.self) { mode in
                            MagicPlayerButton(
                                icon: mode.icon,
                                size: 40,
                                iconSize: 15,
                                action: {}
                            )
                        }
                        
                        Divider()
                            .frame(height: 40)
                        
                        MagicPlayModeButton(
                            mode: $playMode,
                            onChange: { newMode in
                                print("Mode changed to: \(newMode)")
                            }
                        )
                    }
                }
                .padding()
                .background(.background)
                .environment(\.colorScheme, .light)
                
                VStack(spacing: 20) {
                    Text("Dark Mode")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        ForEach([PlayMode.sequence, .single, .random], id: \.self) { mode in
                            MagicPlayerButton(
                                icon: mode.icon,
                                size: 40,
                                iconSize: 15,
                                action: {}
                            )
                        }
                        
                        Divider()
                            .frame(height: 40)
                        
                        MagicPlayModeButton(
                            mode: $playMode,
                            onChange: { newMode in
                                print("Mode changed to: \(newMode)")
                            }
                        )
                    }
                }
                .padding()
                .background(.background)
                .environment(\.colorScheme, .dark)
            }
            .previewLayout(.sizeThatFits)
        }
    }
    
    return PreviewWrapper()
} 