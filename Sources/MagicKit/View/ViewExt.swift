import Foundation
import SwiftUI

extension View {
    public func when(_ v: Bool) -> some View {
        ZStack {
            if !v {
                self.hidden()
                    .frame(width: 0)
                    .frame(height: 0)
            } else {
                self
            }
        }
        .opacity(v ? 1 : 0)
    }
}

#Preview {
    VStack {
        Spacer()

        Button("x", action: {
            print("HI")
        })
        .when(true)

        Spacer()

        // when对右键菜单不生效
        Text("ContextMenu")
            .contextMenu(menuItems: {
                Text("Menu Item 1")
                Text("Menu Item 2")
                    .when(true)
                Text("Menu Item 3")
                    .when(false)

                Button(action: {
                    print("Menu Item 4")
                }) {
                    Text("Menu Item 4")
                        .when(true) // 使用 when 方法
                }
            })

        Spacer()
    }
    .frame(width: 100)
    .frame(height: 600)
}
