import SwiftUI

public struct BtnOpenURL: View {
    var url: String
    
    var body: some View {
        Button("打开链接", action: {
            URL(string: url)!.openInBrowser()
        })
    }
}
