import SwiftUI

public struct BtnOpenURL: View {
    var url: String
    
    public var body: some View {
        Button("打开链接", action: {
            URL(string: url)!.openInBrowser()
        })
    }
}
