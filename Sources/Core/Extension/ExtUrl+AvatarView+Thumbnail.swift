import SwiftUI

extension AvatarView {
    /// 缩略图显示视图组件
    struct ThumbnailImageView: View {
        let image: Image
        
        var body: some View {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
}

#Preview {
    AvatarView.ThumbnailImageView(image: Image(systemName: "photo"))
        .frame(width: 100, height: 100)
} 