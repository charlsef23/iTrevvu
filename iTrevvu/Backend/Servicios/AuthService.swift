import Foundation
import Supabase
import Combine

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()
    private let supabase = SupabaseManager.shared.client

    @Published var sessionUserId: UUID? = nil
    @Published var isLoadingSession: Bool = true

    var isLoggedIn: Bool { sessionUserId != nil }

    private init() {}

    func loadSession() async {
        defer { isLoadingSession = false }
        do {
            let session = try await supabase.auth.session
            sessionUserId = session.user.id
        } catch {
            sessionUserId = nil
        }
    }

    func signIn(email: String, password: String) async throws {
        let session = try await supabase.auth.signIn(
            email: email,
            password: password
        )
        sessionUserId = session.user.id
    }

    func signUp(email: String, password: String, username: String) async throws {
        let session = try await supabase.auth.signUp(
            email: email,
            password: password
        )

        let uid = session.user.id

        struct PerfilInsert: Encodable {
            let id: UUID
            let username: String
            let nombre: String?
            let presentacion: String?
            let enlaces: [String: String]?
            let avatar_url: String?
        }

        let perfil = PerfilInsert(
            id: uid,
            username: username.lowercased(),
            nombre: nil,
            presentacion: nil,
            enlaces: nil,
            avatar_url: nil
        )

        try await supabase
            .from("perfil")
            .insert(perfil)
            .execute()

        sessionUserId = uid
    }

    func signOut() async {
        do {
            try await supabase.auth.signOut()
        } catch {}
        sessionUserId = nil
    }
}
