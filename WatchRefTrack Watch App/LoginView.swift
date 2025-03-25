import SwiftUI

enum LoginError: LocalizedError {
    case invalidURL
    case networkError
    case noData
    case missingPairCode
    case invalidPairCode
    case databaseError
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Nelze se připojit k serveru"
        case .networkError:
            return "Zkontrolujte připojení k internetu"
        case .noData:
            return "Server neodpovídá"
        case .missingPairCode:
            return "Zadejte párovací kód"
        case .invalidPairCode:
            return "Neplatný párovací kód"
        case .databaseError:
            return "Chyba připojení k databázi"
        case .serverError(let message):
            return message
        }
    }
}

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @Binding var userInfo: UserInfo?
    @State private var pairCode: String = ""
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var toastIsSuccess: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Zadejte párovací kód")
                .font(.footnote)
            
            TextField("Kód", text: $pairCode)
                .multilineTextAlignment(.center)
                .frame(height: 40)
                .background(Color(.darkGray).opacity(0.3))
                .cornerRadius(8)
            
            Button(action: login) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Přihlásit")
                }
            }
            
            if showToast {
                Text(toastMessage)
                    .font(.footnote)
                    .foregroundColor(toastIsSuccess ? Color.green : Color.red)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(toastIsSuccess ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    )
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }
        }
        .padding()
    }
    
    private func login() {
        isLoading = true
        
        guard let url = URL(string: "http://10.0.0.15/reftrack/admin/api/login_watch-api.php") else {
            handleError(.invalidURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyData = "pair_code=\(pairCode)"
        request.httpBody = bodyData.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    handleError(.networkError)
                    print(error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    handleError(.noData)
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(UserInfo.self, from: data)
                    
                    if decodedResponse.status == "success" {
                        if let encoded = try? JSONEncoder().encode(decodedResponse) {
                            UserDefaults.standard.set(encoded, forKey: "userInfo")
                        }
                        
                        userInfo = decodedResponse
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        
                        showSuccessToast(decodedResponse.message)
                        isLoggedIn = true
                    } else {
                        handleError(.serverError(decodedResponse.message))
                    }
                } catch {
                    handleError(.serverError("Neočekávaná chyba. Zkuste to prosím znovu."))
                    print(error)
                }
            }
        }.resume()
    }
    
    private func handleError(_ error: LoginError) {
        showErrorToast(error.errorDescription ?? "Neznámá chyba")
    }
    
    private func showErrorToast(_ message: String) {
        withAnimation {
            toastMessage = message
            toastIsSuccess = false
            showToast = true
            hideToastAfterDelay()
        }
    }
    
    private func showSuccessToast(_ message: String) {
        withAnimation {
            toastMessage = message
            toastIsSuccess = true
            showToast = true
            hideToastAfterDelay()
        }
    }
    
    private func hideToastAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showToast = false
        }
    }
} 