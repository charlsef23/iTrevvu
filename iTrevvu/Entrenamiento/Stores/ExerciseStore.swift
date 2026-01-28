import Foundation
import Combine
import Supabase

@MainActor
final class ExerciseStore: ObservableObject {

    @Published private(set) var byType: [ExerciseType: [Exercise]] = [:]
    @Published private(set) var favorites: Set<UUID> = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil

    private let client: SupabaseClient

    // ✅ sin default param (evita acceso a SupabaseManager.shared en contexto no aislado)
    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Public

    /// ✅ Tu SDK no soporta .ilike/.or/.filter => search se filtra en local en la UI
    func load(type: ExerciseType, search: String? = nil) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let list = try await fetchExercises(type: type)
            byType[type] = list
            try await loadFavorites()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func isFavorite(_ id: UUID) -> Bool {
        favorites.contains(id)
    }

    func toggleFavorite(exerciseId: UUID) async {
        do {
            if favorites.contains(exerciseId) {
                try await removeFavorite(exerciseId: exerciseId)
                favorites.remove(exerciseId)
            } else {
                try await addFavorite(exerciseId: exerciseId)
                favorites.insert(exerciseId)
            }
        } catch {
            // no bloqueamos UI
        }
    }

    // MARK: - Supabase

    private func currentUserId() throws -> UUID {
        guard let session = client.auth.currentSession else {
            throw NSError(
                domain: "ExerciseStore",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"]
            )
        }
        return session.user.id
    }

    private func fetchExercises(type: ExerciseType) async throws -> [Exercise] {
        try await client
            .from("ejercicios")
            .select()
            .eq("tipo", value: type.rawValue)
            .order("nombre", ascending: true)
            .execute()
            .value
    }

    private func loadFavorites() async throws {
        let autorId = try currentUserId()

        struct Row: Codable { let ejercicio_id: UUID }

        let rows: [Row] = try await client
            .from("ejercicios_favoritos")
            .select("ejercicio_id")
            .eq("autor_id", value: autorId.uuidString)
            .execute()
            .value

        favorites = Set(rows.map { $0.ejercicio_id })
    }

    private func addFavorite(exerciseId: UUID) async throws {
        let autorId = try currentUserId()

        struct DTO: Encodable {
            let autor_id: String
            let ejercicio_id: String
        }

        let dto = DTO(
            autor_id: autorId.uuidString,
            ejercicio_id: exerciseId.uuidString
        )

        _ = try await client
            .from("ejercicios_favoritos")
            .upsert(dto, onConflict: "autor_id,ejercicio_id", returning: .minimal)
            .execute()
    }

    private func removeFavorite(exerciseId: UUID) async throws {
        let autorId = try currentUserId()

        _ = try await client
            .from("ejercicios_favoritos")
            .delete()
            .eq("autor_id", value: autorId.uuidString)
            .eq("ejercicio_id", value: exerciseId.uuidString)
            .execute()
    }
}
