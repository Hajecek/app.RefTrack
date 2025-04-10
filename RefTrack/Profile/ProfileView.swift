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
    @State private var showPairCodeInfo = false
    @Environment(\.presentationMode) var presentationMode
    
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
        return "Nejsi přihlášen"
    }
    
    private var email: String {
        return userData.userInfo?.email ?? "Přihlas se a získej přístup k informacím o svém účtu"
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
                            AsyncImage(url: URL(string: "https://reftrack.cz/auth/images/\(profileImage!)")) { phase in
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
                    
                    if !isLoggedIn {
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
                        HStack {
                            Text("Párovací kód")
                            Spacer()
                            Text(userInfo.pairCode)
                                .foregroundColor(.gray)
                            Button(action: {
                                showPairCodeInfo = true
                            }) {
                                Image(systemName: "questionmark.circle")
                                    .foregroundColor(.blue)
                            }
                            .alert("Párovací kód", isPresented: $showPairCodeInfo) {
                                Button("OK", role: .cancel) { }
                            } message: {
                                Text("Tento kód slouží k propojení vašeho účtu s Apple Watch. Nikde jej nesdílejte a chraňte jako heslo.")
                            }
                        }
                    }
                    
                    Section {
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
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("CloseProfileView"))) { _ in
                // Zavřeme profilovou stránku
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    // Metoda pro kontrolu přihlášení při zobrazení profilu
    private func checkLoginStatus() {
        // Zjištění, zda je uživatel přihlášen z UserDefaults
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            userData.isLoggedIn = true
            
            // Načtení dat uživatele z UserDefaults
            loadUserDataFromDefaults()
        }
    }
    
    // Metoda pro načtení dat uživatele z UserDefaults
    private func loadUserDataFromDefaults() {
        guard UserDefaults.standard.bool(forKey: "isLoggedIn") else {
            return
        }
        
        // Načteme všechna data z UserDefaults
        let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
        let firstName = UserDefaults.standard.string(forKey: "userFirstName") ?? ""
        let lastName = UserDefaults.standard.string(forKey: "userLastName") ?? ""
        let username = UserDefaults.standard.string(forKey: "username") ?? ""
        let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        let birthDate = UserDefaults.standard.string(forKey: "userBirthDate") ?? ""
        let sport = UserDefaults.standard.string(forKey: "userSport") ?? ""
        let profileImage = UserDefaults.standard.string(forKey: "userProfileImage")
        let role = UserDefaults.standard.string(forKey: "userRole") ?? "Uživatel"
        let pairCode = UserDefaults.standard.string(forKey: "userPairCode") ?? "Nic"
        
        // Vytvoříme objekt UserInfo z načtených dat
        userData.userInfo = UserInfo(
            status: "success",
            message: nil,
            id: userId,
            firstName: firstName,
            lastName: lastName,
            username: username,
            email: email,
            birthDate: birthDate,
            sport: sport,
            profileImage: profileImage,
            role: role,
            pairCode: pairCode,
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
        UserDefaults.standard.removeObject(forKey: "userPairCode")
        
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "dd.MM.yyyy"
            return dateFormatter.string(from: date)
        }
        
        return dateString
    }
}

#Preview {
    return ProfileView()
} 
