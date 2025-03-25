import SwiftUI

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    @Binding var userInfo: UserInfo?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let user = userInfo {
                    if let profileImage = user.profileImage,
                       let imageUrl = URL(string: "http://10.0.0.15/reftrack/auth/images/\(profileImage)") {
                        AsyncImage(url: imageUrl) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 80, height: 80)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            case .failure:
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    
                    Text("\(user.firstName) \(user.lastName)")
                        .font(.headline)
                    
                    Button(action: logout) {
                        Text("Odhlásit se")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                }
            }
            .padding()
        }
        .navigationTitle("Profil")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userInfo")
        isLoggedIn = false
        userInfo = nil
        presentationMode.wrappedValue.dismiss()
    }
} 