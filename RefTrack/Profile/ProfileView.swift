//
//  ProfileView.swift
//  RefTrack
//

import SwiftUI

struct ProfileView: View {
    // ObservableObject pro sledování přihlášení uživatele
    @StateObject private var userData = UserData()
    @State private var notifications = true
    @State private var showLoginView = false
    
    // Nastavit výchozí hodnotu pro isLoggedIn
    var initialIsLoggedIn: Bool = false
    
    // Odvodit údaje z userData
    private var isLoggedIn: Bool {
        return userData.isLoggedIn
    }
    
    private var fullName: String {
        if let userInfo = userData.userInfo {
            return "\(userInfo.firstName) \(userInfo.lastName)"
        }
        return "Nepřihlášený uživatel"
    }
    
    private var email: String {
        return userData.userInfo?.email ?? "Pro zobrazení emailu se přihlaste"
    }
    
    private var profileImage: String? {
        return userData.userInfo?.profileImage
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Osobní údaje")) {
                    HStack {
                        // Zobrazení profilového obrázku z URL nebo použití zástupné ikony
                        if isLoggedIn && profileImage != nil {
                            AsyncImage(url: URL(string: "http://10.0.0.15/reftrack/auth/images/\(profileImage!)")) { phase in
                                switch phase {
                                case .empty:
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(.blue)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                case .failure:
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(.blue)
                                @unknown default:
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(.blue)
                                }
                            }
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(fullName)
                                .font(.title2)
                                .bold()
                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.leading)
                    }
                    .padding(.vertical, 10)
                    
                    if isLoggedIn {
                        NavigationLink(destination: Text("Úprava profilu")) {
                            Text("Upravit profil")
                        }
                    } else {
                        Button(action: {
                            showLoginView = true
                        }) {
                            Text("Přihlásit se")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                if isLoggedIn, let userInfo = userData.userInfo {
                    Section(header: Text("Další informace")) {
                        HStack {
                            Text("Uživatelské jméno")
                            Spacer()
                            Text(userInfo.username)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Sport")
                            Spacer()
                            Text(userInfo.sport ?? "Neurčeno")
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Datum narození")
                            Spacer()
                            Text(formatDate(userInfo.birthDate))
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Role")
                            Spacer()
                            Text(userInfo.role)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Section(header: Text("Nastavení")) {
                        Toggle("Oznámení", isOn: $notifications)
                        
                        NavigationLink(destination: Text("Nastavení soukromí")) {
                            Text("Soukromí")
                        }
                        
                        NavigationLink(destination: Text("Zabezpečení")) {
                            Text("Zabezpečení")
                        }
                    }
                    
                    Section(header: Text("Aplikace")) {
                        NavigationLink(destination: Text("O aplikaci")) {
                            Text("O aplikaci")
                        }
                        
                        NavigationLink(destination: Text("Nápověda a podpora")) {
                            Text("Nápověda a podpora")
                        }
                        
                        Button(action: {
                            // Akce pro odhlášení
                            logout()
                        }) {
                            Text("Odhlásit se")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Profil")
            .sheet(isPresented: $showLoginView) {
                LoginView()
                    .onDisappear {
                        // Kontrola, zda se uživatel přihlásil
                        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
                            checkLoginStatus()
                            
                            // Pošleme notifikaci o změně stavu přihlášení
                            NotificationCenter.default.post(
                                name: Notification.Name("LoginStatusChanged"),
                                object: nil
                            )
                        }
                    }
            }
            .onAppear {
                userData.isLoggedIn = initialIsLoggedIn
                checkLoginStatus()
            }
        }
    }
    
    // Metoda pro kontrolu přihlášení při zobrazení profilu
    private func checkLoginStatus() {
        // Zjištění, zda je uživatel přihlášen z UserDefaults
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            userData.isLoggedIn = true
            
            // Načtení dat uživatele ze serveru nebo z lokálního úložiště
            fetchUserData()
        }
    }
    
    // Metoda pro získání dat uživatele ze serveru
    private func fetchUserData() {
        guard let url = URL(string: "http://10.0.0.15/reftrack/admin/api/get_user_info.php") else {
            print("Neplatná URL adresa")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Přidáme autentizační token nebo session ID, pokud je to potřeba
        // request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Chyba při načítání dat uživatele: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Žádná data nebyla přijata")
                return
            }
            
            // DEBUG: Vypíšeme odpověď pro ladění
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON Response (user data): \(jsonString)")
            }
            
            do {
                let userInfo = try JSONDecoder().decode(UserInfo.self, from: data)
                
                // Aktualizujeme userData na hlavním vlákně
                DispatchQueue.main.async {
                    self.userData.userInfo = userInfo
                }
            } catch {
                print("Chyba dekódování dat uživatele: \(error)")
                
                // Pokud se nepodaří načíst data ze serveru, zkusíme načíst uložená data
                loadUserDataFromDefaults()
            }
        }.resume()
    }
    
    // Metoda pro načtení dat uživatele z UserDefaults
    private func loadUserDataFromDefaults() {
        // Vytvoříme dočasné placeholder údaje
        userData.userInfo = UserInfo(
            status: "success",
            message: nil,
            id: UserDefaults.standard.string(forKey: "userId") ?? "",
            firstName: UserDefaults.standard.string(forKey: "userFirstName") ?? "Přihlášený",
            lastName: UserDefaults.standard.string(forKey: "userLastName") ?? "Uživatel",
            username: UserDefaults.standard.string(forKey: "username") ?? "",
            email: UserDefaults.standard.string(forKey: "userEmail") ?? "",
            birthDate: UserDefaults.standard.string(forKey: "userBirthDate") ?? "",
            sport: UserDefaults.standard.string(forKey: "userSport") ?? "Neurčeno",
            profileImage: UserDefaults.standard.string(forKey: "userProfileImage"),
            role: UserDefaults.standard.string(forKey: "userRole") ?? "Uživatel",
            createdAt: nil
        )
    }
    
    // Metoda pro odhlášení uživatele
    private func logout() {
        // Odhlášení - vymazání všech dat uživatele
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userProfileImage")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "userFirstName")
        UserDefaults.standard.removeObject(forKey: "userLastName")
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userBirthDate")
        UserDefaults.standard.removeObject(forKey: "userSport")
        UserDefaults.standard.removeObject(forKey: "userRole")
        
        // Aktualizace stavu
        userData.isLoggedIn = false
        userData.userInfo = nil
        
        // Pošleme notifikaci o změně stavu přihlášení
        NotificationCenter.default.post(
            name: Notification.Name("LoginStatusChanged"),
            object: nil
        )
        
        // Zobrazíme oznámení o odhlášení
        NotificationCenter.default.post(
            name: Notification.Name("ShowToast"),
            object: nil,
            userInfo: ["message": "Byli jste úspěšně odhlášeni", "isSuccess": true]
        )
    }
    
    // Pomocná funkce pro formátování data
    private func formatDate(_ dateString: String) -> String {
        // Zde můžete implementovat formátování data dle potřeby
        return dateString
    }
}

#Preview {
    return ProfileView()
} 