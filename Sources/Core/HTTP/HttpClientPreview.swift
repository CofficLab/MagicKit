import SwiftUI
import OSLog

/// A preview view demonstrating HttpClient functionality
public struct HttpClientPreview: View {
    @State private var responseText = "No response yet"
    @State private var isLoading = false
    @State private var client: HttpClient?
    
    public var body: some View {
        MagicThemePreview {
            VStack(spacing: 20) {
                // Response Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Response")
                        .font(.headline)
                    
                    Text(responseText)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                // Actions Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Actions")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        Button(action: performGet) {
                            HStack {
                                Image(systemName: "arrow.down.circle")
                                Text("GET Request")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        Button(action: performPost) {
                            HStack {
                                Image(systemName: "arrow.up.circle")
                                Text("POST Request")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        Button(action: performWithTimeout) {
                            HStack {
                                Image(systemName: "clock")
                                Text("Timeout Test")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        Button(action: cancelRequest) {
                            HStack {
                                Image(systemName: "xmark.circle")
                                Text("Cancel Request")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
            .padding()
            .disabled(isLoading)
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                }
            }
        }
    }
    
    private func performGet() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let client = HttpClient(url: URL(string: "https://httpbin.org/get")!)
                self.client = client
                
                responseText = try await client.get()
            } catch let error {
                responseText = "Error: \(error.localizedDescription)"
            }
        }
    }
    
    private func performPost() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let client = HttpClient(url: URL(string: "https://httpbin.org/post")!)
                    .withBody(["test": "value"])
                self.client = client
                
                responseText = try await client.post()
            } catch let error {
                responseText = "Error: \(error.localizedDescription)"
            }
        }
    }
    
    private func performWithTimeout() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let client = HttpClient(url: URL(string: "https://httpbin.org/delay/5")!)
                    .withTimeout(2) // 2 seconds timeout
                self.client = client
                
                responseText = try await client.get()
            } catch let error {
                responseText = "Error: \(error.localizedDescription)"
            }
        }
    }
    
    private func cancelRequest() {
        client?.cancel()
        responseText = "Request cancelled"
        isLoading = false
    }
    
    public init() {}
}

#Preview {
    HttpClientPreview()
} 