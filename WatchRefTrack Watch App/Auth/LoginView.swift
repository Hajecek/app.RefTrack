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
    @State private var showHelpInfo: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorAlertMessage: String = ""
    
    // Nová proměnná pro maximální délku kódu
    private let maxCodeLength = 8
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                HStack {
                    Text("Zadejte párovací kód")
                        .font(.headline)
                    
                    Button(action: {
                        showHelpInfo = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 10)
                
                // Zobrazení zadaného kódu jako tečky
                HStack(spacing: 6) {
                    ForEach(0..<maxCodeLength, id: \.self) { index in
                        Circle()
                            .fill(index < pairCode.count ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.vertical, 10)
                
                // Číselník
                LazyVGrid(columns: [
                    GridItem(.flexible()), 
                    GridItem(.flexible()), 
                    GridItem(.flexible())
                ], spacing: 10) {
                    ForEach(1...9, id: \.self) { number in
                        digitButton(String(number))
                    }
                    
                    // Prázdné místo pro estetiku
                    Color.clear
                        .frame(height: 40)
                    
                    digitButton("0")
                    
                    // Tlačítko smazat
                    Button(action: {
                        if !pairCode.isEmpty {
                            pairCode.removeLast()
                        }
                    }) {
                        Image(systemName: "delete.left")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                    }
                }
                .padding(.vertical, 10)
                
                Button(action: login) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Přihlásit")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(pairCode.isEmpty || isLoading)
                
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
            .padding(.horizontal)
        }
        .alert("Informace", isPresented: $showHelpInfo) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Párovací kód najdete v nastavení iOS aplikace RefTrack v sekci 'Párování kód'.")
        }
        .alert("Chyba", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorAlertMessage)
        }
    }
    
    // Pomocná funkce pro vytvoření tlačítek číselníku
    private func digitButton(_ digit: String) -> some View {
        Button(action: {
            if pairCode.count < maxCodeLength {
                pairCode.append(digit)
            }
        }) {
            Text(digit)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.gray.opacity(0.3)))
        }
        .disabled(pairCode.count >= maxCodeLength)
    }
    
    private func login() {
        isLoading = true
        
        guard let url = URL(string: "https://reftrack.cz/admin/api/login_watch-api.php") else {
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
                
                // Nejdříve zkusíme dekódovat jako jednoduchý objekt se statusem a zprávou
                if let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let status = jsonObj["status"] as? String {
                    if status == "error" {
                        if let message = jsonObj["message"] as? String {
                            handleError(.invalidPairCode)
                            print("Chyba přihlášení: \(message)")
                        } else {
                            handleError(.invalidPairCode)
                        }
                        return
                    }
                }
                
                // Pokud to není chyba nebo chybová struktura je jiná, zkusíme dekódovat jako UserInfo
                do {
                    let decodedResponse = try JSONDecoder().decode(UserInfo.self, from: data)
                    
                    if decodedResponse.status == "success" {
                        if let encoded = try? JSONEncoder().encode(decodedResponse) {
                            UserDefaults.standard.set(encoded, forKey: "userInfo")
                        }
                        
                        userInfo = decodedResponse
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        
                        UserDefaults.standard.set(String(decodedResponse.id), forKey: "user_id")
                        
                        print("Uživatel ID: \(decodedResponse.id)")
                        print("Uložené hodnoty v UserDefaults:")
                        print("isLoggedIn: \(UserDefaults.standard.bool(forKey: "isLoggedIn"))")
                        print("user_id: \(UserDefaults.standard.string(forKey: "user_id") ?? "N/A")")
                        
                        UserDefaults.standard.synchronize()
                        
                        showSuccessToast(decodedResponse.message)
                        isLoggedIn = true
                    } else {
                        handleError(.serverError(decodedResponse.message))
                    }
                } catch {
                    // Dekódování jako UserInfo selhalo
                    handleError(.invalidPairCode)
                    print("Chyba dekódování: \(error)")
                }
            }
        }.resume()
    }
    
    private func handleError(_ error: LoginError) {
        errorAlertMessage = error.errorDescription ?? "Neznámá chyba"
        pairCode = "" // Reset párovacího kódu při chybě
        showErrorAlert = true
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
