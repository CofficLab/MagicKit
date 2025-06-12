import SwiftUI

/// Toast容器视图
struct MagicToastContainerView: View {
    @ObservedObject var toastManager: MagicToastManager
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(toastManager.toasts) { toast in
                    MagicToastView(toast: toast, onDismiss: toastManager.dismiss)
                        .frame(maxWidth: 400)
                        .padding(.horizontal, 16)
                        .positioned(for: toast.displayMode, in: geometry)
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: toastManager.toasts)
        }
    }
}

// MARK: - Position Extension

extension View {
    @ViewBuilder
    func positioned(for displayMode: MagicToastDisplayMode, in geometry: GeometryProxy) -> some View {
        switch displayMode {
        case .overlay:
            self
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
        case .banner:
            VStack {
                self
                Spacer()
            }
            .padding(.top, 60)
            
        case .bottom:
            VStack {
                Spacer()
                self
            }
            .padding(.bottom, 40)
            
        case .corner:
            VStack {
                HStack {
                    Spacer()
                    self
                        .frame(maxWidth: 300)
                }
                Spacer()
            }
            .padding(.top, 60)
            .padding(.trailing, 20)
        }
    }
} 

#if DEBUG
#Preview {
    MagicRootView {
        MagicToastExampleView()
    }
    .frame(width: 400, height: 600)
}
#endif
