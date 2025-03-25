import SwiftUI
import WatchConnectivity

// Nejdřív přidáme strukturu UserInfo
struct UserInfo: Codable {
    let status: String
    let message: String?
    let id: String
    let firstName: String
    let lastName: String
    
    enum CodingKeys: String, CodingKey {
        case status, message
        case id
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

struct LoginView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(spacing: 15) {
            if isLoading {
                ProgressView()
                Text("Čekám na potvrzení...")
                    .font(.caption)
            } else {
                Text("Přihlášení")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("Potvrďte přihlášení na iPhone")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                
                if showToast {
                    Text(toastMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .padding()
        .onAppear {
            requestLoginConfirmation()
        }
    }
    
    private func requestLoginConfirmation() {
        guard WCSession.isSupported() else {
            showError("Watch Connectivity není podporováno")
            return
        }
        
        let session = WCSession.default
        if session.activationState != .activated {
            session.delegate = WatchSessionDelegate.shared
            session.activate()
        }
        
        isLoading = true
        
        // Pošleme zprávu do iPhone
        session.sendMessage(["request": "loginConfirmation"], replyHandler: { response in
            DispatchQueue.main.async {
                isLoading = false
                if let success = response["success"] as? Bool {
                    if success {
                        // Uložíme přihlášení
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        if let userId = response["userId"] as? String {
                            UserDefaults.standard.set(userId, forKey: "userId")
                        }
                        dismiss()
                    } else {
                        showError(response["message"] as? String ?? "Přihlášení se nezdařilo")
                    }
                }
            }
        }, errorHandler: { error in
            DispatchQueue.main.async {
                isLoading = false
                showError("Chyba komunikace: \(error.localizedDescription)")
            }
        })
    }
    
    private func showError(_ message: String) {
        toastMessage = message
        showToast = true
    }
}

// Singleton pro WatchConnectivity delegate
class WatchSessionDelegate: NSObject, WCSessionDelegate {
    static let shared = WatchSessionDelegate()
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Zde můžeme zpracovat příchozí zprávy
    }
} 