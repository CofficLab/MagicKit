import Foundation

public protocol SuperEvent {
}

public extension SuperEvent {
    public var notification: NotificationCenter {
        NotificationCenter.default
    }

    public var nc: NotificationCenter { NotificationCenter.default }

    public func emit(_ name: Notification.Name, object: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        DispatchQueue.main.async {
            self.nc.post(name: name, object: object, userInfo: userInfo)
        }
    }

    public func emit(name: Notification.Name, object: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        self.emit(name, object: object, userInfo: userInfo)
    }
}
