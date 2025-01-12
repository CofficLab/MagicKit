import Foundation

extension Thread {
    public static var currentQosDescription: String {
        current.qualityOfService.description(withName: false)
    }
}
