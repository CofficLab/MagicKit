import SwiftUI

struct Loading: View {
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                ProgressView()
            }
            .padding(.vertical, 40)
            .padding(.horizontal, 40)
            .background(Color.blue.opacity(0.1))
            .shadow(color: Color.green, radius: 12, x: 0, y: 2)
        }
        .background(.yellow.opacity(0.3))
        .cornerRadius(8)
        .shadow(color: Color.gray, radius: 12, x: 2, y: 2)
    }
}

struct Loading_Previews: PreviewProvider {
    static var previews: some View {
        Loading().frame(width: 500, height: 500)
    }
}
