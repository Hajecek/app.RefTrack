//
//  ContentView.swift
//  WatchRefTrack Watch App
//
//  Created by Michal Hájek on 20.03.2025.
//

import SwiftUI

struct UserInfo: Codable {
    let status: String
    let message: String
    let id: String
    let pairCode: String
    let firstName: String
    let lastName: String
    let profileImage: String?
    
    enum CodingKeys: String, CodingKey {
        case status, message, id
        case pairCode = "pair_code"
        case firstName = "first_name"
        case lastName = "last_name"
        case profileImage = "profile_image"
    }
}

struct ContentView: View {
    @State private var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
    @State private var userInfo: UserInfo? = {
        if let savedData = UserDefaults.standard.data(forKey: "userInfo"),
           let decodedInfo = try? JSONDecoder().decode(UserInfo.self, from: savedData) {
            return decodedInfo
        }
        return nil
    }()
    
    var body: some View {
        NavigationView {
            if isLoggedIn, let user = userInfo {
                VStack(alignment: .leading, spacing: 0) {
                    NavigationLink(destination: ProfileView(isLoggedIn: $isLoggedIn, userInfo: $userInfo)) {
                        HStack(alignment: .center, spacing: 8) {
                            if let profileImage = user.profileImage, 
                               let imageUrl = URL(string: "http://10.0.0.15/reftrack/auth/images/\(profileImage)"),
                               imageUrl.scheme != nil {
                                
                                AsyncImage(url: imageUrl) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 30, height: 30)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 30, height: 30)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                            )
                                    case .failure:
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.gray)
                            }
                            
                            Text("\(user.firstName) \(user.lastName)")
                                .font(.system(size: 16, weight: .medium))
                                .lineLimit(1)
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.5)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                    )
                    .padding(.top, 5)
                    
                    Spacer(minLength: 10)
                    
                    ScrollView {
                        UpcomingEventsView()
                            .padding(.bottom, 8)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                LoginView(isLoggedIn: $isLoggedIn, userInfo: $userInfo)
            }
        }
    }
}

#Preview {
    ContentView()
}
