import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @Environment(\.dismiss) var dismiss
    
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var toastIsSuccess: Bool = false
    
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
                // TODO: Přihlašovací logika
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
} 