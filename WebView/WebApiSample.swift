import Foundation

// 如需扩充API，直接在APP目录中建一个文件，内容像下面这样

extension WebContent {
    @objc func ping() {
        run("window.api.ping()")
    }
}
