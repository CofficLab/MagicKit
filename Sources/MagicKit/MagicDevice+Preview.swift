import SwiftUI

struct DevicePreview: View {
    let devices: [MagicDevice] = [
        .iPhone_15,
        .iPhone_SE,
        .iPad_mini,
        .MacBook,
        .iMac
    ]
    
    var body: some View {
        List {
            ForEach(devices, id: \.self) { device in
                VStack(alignment: .leading) {
                    Text(device.rawValue)
                        .font(.headline)
                    Text("Size: \(device.size)")
                        .font(.subheadline)
                    Text("Category: \(device.category.description)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .frame(width: 300, height: 400)
    }
}

#Preview {
    DevicePreview()
} 