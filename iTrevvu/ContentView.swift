import SwiftUI

struct ContentView: View {
    @StateObject private var auth = AuthService.shared

    var body: some View {
        Group {
            if auth.isLoadingSession {
                ProgressView()
            } else if auth.isLoggedIn {
                MainTabView()
            } else {
                WelcomeView()
            }
        }
        .task {
            await auth.loadSession()
        }
        .environmentObject(auth)
    }
}
