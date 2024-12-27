import SwiftUI

public struct MagicToast: View {
    var message: String = ""

    public var body: some View {
        HStack {
            Text(message)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(Color.blue.opacity(0.4))
        .shadow(color: Color.green, radius: 20, x: 1, y: 1)
        .cornerRadius(8)
    }
}

#Preview {
    MagicToast(message: "Cheers")
        .padding(.horizontal, 20)
        .frame(width: 500, height: 500)
        .background(Color.white)
}
