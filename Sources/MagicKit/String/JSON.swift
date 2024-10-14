import Foundation
import OSLog

extension String {    
    public func getIntFromJSON(for keyPath: String) -> Int? {
        self.getValueFromJSON(for: keyPath) as? Int
    }

    public func getStringFromJSON(for keyPath: String) -> String? {
        self.getValueFromJSON(for: keyPath) as? String
    }

    public func getArrayFromJSON(for keyPath: String) -> [String: Any]? {
        self.getValueFromJSON(for: keyPath) as? [String: Any]
    }
    
    /*
    示例使用
    let jsonString = """
    {
        "ref": "refs/heads/master",
        "node_id": "MDM6UmVmMjgyOTA1MjA2OnJlZnMvaGVhZHMvbWFzdGVy",
        "url": "https://api.github.com/repos/nookery/nookery.github.io/git/refs/heads/master",
        "object": {
            "sha": "f14ed6bd9bb8e0f1ea5e384ff57ee7e1e11dcc59",
            "type": "commit",
            "url": "https://api.github.com/repos/nookery/nookery.github.io/git/commits/f14ed6bd9bb8e0f1ea5e384ff57ee7e1e11dcc59"
        }
    }
    """

    if let shaValue = getValue(from: jsonString, for: "object.sha") {
        print("SHA: \(shaValue)") // 输出: SHA: f14ed6bd9bb8e0f1ea5e384ff57ee7e1e11dcc59
    } else {
        print("Key not found.")
    }
    */
    public func getValueFromJSON(for keyPath: String) -> Any? {
        let jsonString = self
        
        // 将 JSON 字符串转换为 Data
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Invalid JSON string.")
            return nil
        }
        
        do {
            // 解析 JSON
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                // 分割键路径
                let keys = keyPath.split(separator: ".").map(String.init)
                var currentObject: Any = jsonObject
                
                // 遍历键路径，逐层获取值
                for key in keys {
                    if let dict = currentObject as? [String: Any], let value = dict[key] {
                        currentObject = value
                    } else if let array = currentObject as? [[String: Any]], let firstItem = array.first, let value = firstItem[key] {
                        currentObject = value
                    } else {
                        return nil
                    }
                }
                return currentObject
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
        
        return nil
    }
}
