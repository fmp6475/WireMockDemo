//

import SwiftUI

struct ContentView: View {
    @State private var userName: String = ""
    @State private var responseMsg: String = ""
    
#if DEBUG
    let url = "http://localhost:1234/login"
#else
    let url = "http://real_backend_host/login"
#endif
    
    var body: some View {
        VStack {
            TextField("User name", text: $userName)
            Button("Login") {
                Task {
                    let message = await sendLoginRequest(userName: userName)
                    self.responseMsg = message
                }
            }
            Text(responseMsg)
        }
        .padding()
    }
    
    func sendLoginRequest(userName: String) async -> String {
        // Encode user data
        let user = User(name: userName)
        guard let encoded = try? JSONEncoder().encode(user) else {
            print("Failed to encode user")
            return ""
        }
        
        // Construct POST request to login url
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        // Send POST request to login url and handle the response
        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            let response = String(data: data, encoding: .utf8)!
            return response
        } catch {
            print("Login failed: \(error.localizedDescription)")
            return ""
        }
    }
}

struct User: Encodable {
    let name: String
}

#Preview {
    ContentView()
}
