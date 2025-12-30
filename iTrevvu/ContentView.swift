import SwiftUI

struct ContentView: View {
    @StateObject private var auth = AuthService.shared

    var body: some View {
        Group {
            if auth.isLoadingSession {
                ProgressView()
            } else if auth.isLoggedIn {
                LoggedInPlaceholderView()
            } else {
                WelcomeView()
            }
        }
        .task { await auth.loadSession() }
        .environmentObject(auth)
    }
}

struct LoggedInPlaceholderView: View {
    @EnvironmentObject private var auth: AuthService

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("✅ Sesión iniciada")
                    .font(.title.bold())

                Text(auth.sessionUserId?.uuidString ?? "")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("Cerrar sesión") {
                    Task { await auth.signOut() }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}
