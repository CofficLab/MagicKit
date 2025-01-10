import Foundation

public protocol SuperEvent {
}

public extension SuperEvent {
    var notification: NotificationCenter {
        NotificationCenter.default
    }

    var nc: NotificationCenter { NotificationCenter.default }

    func emit(_ name: Notification.Name, object: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        DispatchQueue.main.async {
            self.nc.post(name: name, object: object, userInfo: userInfo)
        }
    }

    func emit(name: Notification.Name, object: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        self.emit(name, object: object, userInfo: userInfo)
    }
}
