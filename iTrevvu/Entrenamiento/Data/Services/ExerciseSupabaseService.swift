import Foundation
import Supabase

@MainActor
final class ExerciseSupabaseService {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func currentUserId() throws -> UUID {
        guard let session = client.auth.currentSession else {
            throw NSError(domain: "ExerciseSupabaseService", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "No hay sesión activa"
            ])
        }
        return session.user.id
    }

    func fetchExercises(type: ExerciseType) async throws -> [Exercise] {
        // Nota: sin ilike/or/filter (porque tu SDK no lo soporta). Búsqueda local en UI.
        return try await client
            .from("ejercicios")
            .select()
            .eq("tipo", value: type.rawValue)
            .order("nombre", ascending: true)
            .execute()
            .value
    }

    func fetchFavoriteIds(autorId: UUID) async throws -> [UUID] {
        struct Row: Codable { let ejercicio_id: UUID }
        let rows: [Row] = try await client
            .from("ejercicios_favoritos")
            .select("ejercicio_id")
            .eq("autor_id", value: autorId.uuidString)
            .execute()
            .value
        return rows.map { $0.ejercicio_id }
    }

    func addFavorite(autorId: UUID, exerciseId: UUID) async throws {
        struct DTO: Encodable {
            let autor_id: String
            let ejercicio_id: String
        }
        let dto = DTO(autor_id: autorId.uuidString, ejercicio_id: exerciseId.uuidString)

        _ = try await client
            .from("ejercicios_favoritos")
            .upsert(dto, onConflict: "autor_id,ejercicio_id", returning: .minimal)
            .execute()
    }

    func removeFavorite(autorId: UUID, exerciseId: UUID) async throws {
        _ = try await client
            .from("ejercicios_favoritos")
            .delete()
            .eq("autor_id", value: autorId.uuidString)
            .eq("ejercicio_id", value: exerciseId.uuidString)
            .execute()
    }
}
