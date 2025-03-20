//
//  RefTrackApp.swift
//  RefTrack
//
//  Created by Michal Hájek on 19.03.2025.
//

import SwiftUI

@main
struct RefTrackApp: App {
    @State private var showLaunchScreen = true
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .opacity(showLaunchScreen ? 0 : 1)
                    .animation(.easeIn(duration: 0.3).delay(0.2), value: showLaunchScreen)
                
                if showLaunchScreen {
                    LaunchView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showLaunchScreen = false
                                }
                            }
                        }
                }
                
                if isFirstLaunch {
                    OnboardingView()
                        .transition(.opacity)
                }
            }
        }
    }
}
