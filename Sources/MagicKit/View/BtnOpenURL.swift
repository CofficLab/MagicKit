import SwiftUI

public struct BtnOpenURL: View {
    public var url: String
    
    public init(url: String) {
        self.url = url
    }
    
    public var body: some View {
        Button("打开链接", action: {
            URL(string: url)!.openInBrowser()
        })
    }
}
