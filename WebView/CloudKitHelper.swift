import CloudKit
import OSLog

struct CloudKitHelper {
    static func hasLogged(_ callback: @escaping (_ hasLoggedIn: Bool) -> Void) {
        Logger.app.debug("\(Thread.isMainThread ? "[主]" : "[后]") 检查是否已经登录 iCloud")
        CKContainer.default().accountStatus { status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    Logger.app.debug("\(Thread.isMainThread ? "[主]" : "[后]") 检查iCloud状态-> 已登录")
                    callback(true)
                default:
                    Logger.app.debug("\(Thread.isMainThread ? "[主]" : "[后]") 检查iCloud状态-> 未登录")
                    callback(false)
                }
                if let error = error {
                    Logger.app.debug("\(Thread.isMainThread ? "[主]" : "[后]") 检查iCloud状态-> 出现错误 \(error)")
                }
            }
        }
    }
    
    static func checkAccountStatus() {
        Logger.app.debug("\(Thread.isMainThread ? "[主]" : "[后]") ☁️ 检查iCloud状态")
        CKContainer.default().accountStatus { status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    Logger.app.debug("\(Thread.isMainThread ? "[主]" : "[后]") ☁️ 检查iCloud状态-> 已登录")
                default:
                    Logger.app.debug("\(Thread.isMainThread ? "[主]" : "[后]") ☁️ 检查iCloud状态-> 未登录")
                }
                if let error = error {
                    Logger.app.debug("\(Thread.isMainThread ? "[主]" : "[后]") 检查iCloud状态-> 出现错误 \(error)")
                }
            }
        }

        getCloudKitUserId { id in
            Logger.app.debug("\(Thread.isMainThread ? "[主]" : "[后]") ☁️☁️☁️ User Record ID: \(id)")
        }
    }

    static func getCloudKitUserId(_ callback: @escaping (_ id: String) -> Void) {
        Logger.app.debug("\(Thread.isMainThread ? "[主]" : "[后]") 获取 iCloud 用户 ID")
        CKContainer.default().fetchUserRecordID { recordID, error in
            if let error = error {
                Logger.app.error("\(Thread.isMainThread ? "[主]" : "[后]") Failed to fetch user record ID: \(error)")
                return
            }

            if let recordID = recordID {
                Logger.app.debug("\(Thread.isMainThread ? "[主]" : "[后]") recordID 为 \(recordID.recordName)")
                callback(recordID.recordName)
            } else {
                Logger.app.error("\(Thread.isMainThread ? "[主]" : "[后]") recordID 为 nil")
                callback("")
            }
        }
    }
}
