import SwiftUI

extension AvatarView {
    /// 头像视图的状态管理
    @MainActor final class ViewState: ObservableObject {
        /// 缩略图
        @Published var thumbnail: Image?
        
        /// 错误状态
        @Published var error: Error?
        
        /// 加载状态
        @Published var isLoading = false
        
        /// 自动下载进度
        @Published var autoDownloadProgress: Double = 0
        
        /// 重置所有状态
        func reset() {
            thumbnail = nil
            error = nil
            isLoading = false
            autoDownloadProgress = 0
        }
        
        /// 设置加载状态
        func setLoading(_ loading: Bool) {
            isLoading = loading
        }
        
        /// 设置错误状态
        func setError(_ error: Error?) {
            self.error = error
        }
        
        /// 设置缩略图
        func setThumbnail(_ image: Image?) {
            self.thumbnail = image
        }
        
        /// 设置下载进度
        func setProgress(_ progress: Double) {
            self.autoDownloadProgress = progress
        }
    }
} 