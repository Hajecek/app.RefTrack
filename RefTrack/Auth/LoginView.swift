import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @Environment(\.dismiss) var dismiss
    
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var toastIsSuccess: Bool = false
    
    @State private var isLoading: Bool = false
    @State private var userData: UserData = UserData()
    @State private var isLoggedIn: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            // Hlavní obsah
            mainContent
            
            // Toast notifikace
            if showToast {
                ToastView(
                    message: toastMessage,
                    isSuccess: toastIsSuccess,
                    isShowing: $showToast
                )
                .zIndex(1)
            }
        }
        .background(backgroundGradient)
        .ignoresSafeArea(.keyboard)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ShowToast"))) { notification in
            handleToastNotification(notification)
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("AutoSubmitOTP"))) { _ in
            login()
        }
    }
    
    // MARK: - UI Components
    
    private var mainContent: some View {
        VStack(spacing: 20) {
            // Nadpis
            Text("Přihlášení")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 40)
            
            // Email field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                TextField("Zadejte svůj email", text: $email)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
            }
            
            // Ověřovací kód field
            VStack(alignment: .leading, spacing: 8) {
                Text("Ověřovací kód")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                OTPFieldView(otpCode: $password, otpLength: 5)
                    .padding(.vertical, 8)
            }
            
            // Přihlásit se tlačítko
            Button(action: {
                login()
            }) {
                Text("Přihlásit se")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(15)
            }
            .padding(.top, 20)
            
            // Registrace
            HStack {
                Text("Nemáte účet?")
                    .foregroundColor(.white.opacity(0.8))
                
                Button(action: {
                    // TODO: Navigace na registraci
                }) {
                    Text("Zaregistrujte se")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
            }
            .padding(.top, 10)
            
            Spacer()
            
            // Zavřít tlačítko
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 30)
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.15, green: 0.2, blue: 0.35),
                Color(red: 0.1, green: 0.15, blue: 0.25)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Helper Methods
    
    private func handleToastNotification(_ notification: Notification) {
        if let message = notification.userInfo?["message"] as? String,
           let isSuccess = notification.userInfo?["isSuccess"] as? Bool {
            toastMessage = message
            toastIsSuccess = isSuccess
            
            withAnimation(.spring()) {
                showToast = true
            }
            
            // Automaticky skrýt toast po 3 sekundách
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeOut) {
                    showToast = false
                }
            }
        }
    }
    
    private func login() {
        isLoading = true
        
        guard let url = URL(string: "https://reftrack.cz/admin/api/login-api.php") else {
            showErrorToast("Neplatná URL adresa")
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Upraveno - použijeme správné parametry: login_id místo email
        let bodyData = "login_id=\(email)&password=\(password)"
        request.httpBody = bodyData.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    showErrorToast("Chyba při připojení: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    showErrorToast("Neplatná odpověď ze serveru")
                    return
                }
                
                // DEBUG: Vypíšeme odpověď pro ladění
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("JSON Response: \(jsonString)")
                }
                
                do {
                    // Nejprve zjistíme, jestli je to úspěšná odpověď nebo chybová
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let status = json["status"] as? String {
                        
                        if status == "success" {
                            // Úspěšná odpověď, dekódujeme kompletní UserInfo
                            let userInfo = try JSONDecoder().decode(UserInfo.self, from: data)
                            userData.userInfo = userInfo
                            userData.isLoggedIn = true
                            
                            // Uložíme informace o přihlášení do UserDefaults
                            UserDefaults.standard.set(true, forKey: "isLoggedIn")
                            UserDefaults.standard.set(String(userInfo.id), forKey: "user_id")
                            print("Uloženo user_id: \(userInfo.id)")
                            
                            // Synchronizace UserDefaults
                            UserDefaults.standard.synchronize()
                            
                            // Debug výpis pro kontrolu uložených hodnot
                            print("Uložené hodnoty v UserDefaults:")
                            print("isLoggedIn: \(UserDefaults.standard.bool(forKey: "isLoggedIn"))")
                            print("user_id: \(UserDefaults.standard.string(forKey: "user_id") ?? "N/A")")
                            
                            UserDefaults.standard.set(userInfo.firstName, forKey: "userFirstName")
                            UserDefaults.standard.set(userInfo.lastName, forKey: "userLastName")
                            UserDefaults.standard.set(userInfo.username, forKey: "username")
                            UserDefaults.standard.set(userInfo.email, forKey: "userEmail")
                            UserDefaults.standard.set(userInfo.birthDate, forKey: "userBirthDate")
                            UserDefaults.standard.set(userInfo.role, forKey: "userRole")
                            UserDefaults.standard.set(userInfo.pairCode, forKey: "userPairCode")
                            
                            // Uložíme také profilový obrázek a sport, pokud existují
                            if let profileImage = userInfo.profileImage {
                                UserDefaults.standard.set(profileImage, forKey: "userProfileImage")
                            }
                            if let sport = userInfo.sport {
                                UserDefaults.standard.set(sport, forKey: "userSport")
                            }
                            
                            print("UserInfo ID: \(userInfo.id), Type: \(type(of: userInfo.id))")
                            
                            showSuccessToast("Přihlášení proběhlo úspěšně")
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                isLoggedIn = true
                                // Zavřeme přihlašovací obrazovku
                                dismiss()
                                
                                // Přidáme notifikaci pro zavření profilové stránky
                                NotificationCenter.default.post(
                                    name: Notification.Name("CloseProfileView"),
                                    object: nil
                                )
                            }
                        } else {
                            // Chybová odpověď, zobrazíme pouze zprávu
                            if let message = json["message"] as? String {
                                showErrorToast(message)
                            } else {
                                showErrorToast("Neznámá chyba")
                            }
                        }
                    } else {
                        showErrorToast("Neplatný formát odpovědi")
                    }
                } catch {
                    print("Chyba zpracování odpovědi: \(error)")
                    showErrorToast("Chyba při zpracování odpovědi")
                }
            }
        }.resume()
    }
    
    private func showErrorToast(_ message: String) {
        showToast(message: message, isSuccess: false)
    }
    
    private func showSuccessToast(_ message: String) {
        showToast(message: message, isSuccess: true)
    }
    
    private func showToast(message: String, isSuccess: Bool) {
        toastMessage = message
        toastIsSuccess = isSuccess
        
        withAnimation(.spring()) {
            showToast = true
        }
        
        // Automaticky skrýt toast po 3 sekundách
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeOut) {
                showToast = false
            }
        }
    }
}

// MARK: - UserInfo Model

struct UserInfo: Codable {
    let status: String
    let message: String?
    let id: String
    let firstName: String
    let lastName: String
    let username: String
    let email: String
    let birthDate: String
    let sport: String?
    let profileImage: String?
    let role: String
    let pairCode: String
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case status, message
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case email
        case birthDate = "birth_date"
        case sport
        case profileImage = "profile_image"
        case role
        case pairCode = "pair_code"
        case createdAt = "created_at"
    }
}

// MARK: - UserData Class

class UserData: ObservableObject {
    @Published var userInfo: UserInfo?
    @Published var isLoggedIn: Bool = false
} 
