import Foundation

public protocol SuperThread {
    
}

extension SuperThread {
    public var main: DispatchQueue {
        .main
    }
    
    public var bg: DispatchQueue {
        .global()
    }
    
    public var background: DispatchQueue {
        .global(qos: .background)
    }
    
    public var f: FileManager {
        FileManager.default
    }
    
    public func makeQueue(name: String) -> DispatchQueue {
        DispatchQueue(label: name, qos: .background)
    }
}

extension SuperThread {
    public var threadName: String {
        "\(Thread.isMainThread ? "[🔥]" : "")"
    }
}
