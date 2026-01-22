import Foundation
import Supabase
import PostgREST

final class TrainingExercisesSupabaseService {

    let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Auth

    func currentUserId() throws -> UUID {
        guard let session = client.auth.currentSession else {
            throw NSError(
                domain: "TrainingExercisesSupabaseService",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"]
            )
        }
        return session.user.id
    }

    // MARK: - Exercises (global)

    func fetchGlobalExercises() async throws -> [DBExercise] {
        try await client
            .from("ejercicios")
            .select()
            .order("nombre", ascending: true)
            .execute()
            .value
    }

    // MARK: - Exercises (user/custom)

    func fetchUserExercises(autorId: UUID) async throws -> [DBUserExercise] {
        try await client
            .from("ejercicios_usuario")
            .select()
            .eq("autor_id", value: autorId.uuidString)
            .order("nombre", ascending: true)
            .execute()
            .value
    }

    struct CreateUserExerciseDTO: Encodable {
        let autor_id: String
        let nombre: String
        let categoria: String
        let musculo_principal: String
        let musculos_secundarios: [String]
        let equipo: [String]
        let patron: String
        let is_unilateral: Bool
        let is_bodyweight: Bool
        let rep_range_default: String?
        let tips: String?
    }

    func createUserExercise(_ dto: CreateUserExerciseDTO) async throws -> DBUserExercise {
        try await client
            .from("ejercicios_usuario")
            .insert(dto, returning: .representation)
            .single()
            .execute()
            .value
    }

    func deleteUserExercise(id: UUID) async throws {
        _ = try await client
            .from("ejercicios_usuario")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }

    // MARK: - Favorites

    func fetchFavorites(autorId: UUID) async throws -> [DBFavorite] {
        try await client
            .from("ejercicios_favoritos")
            .select()
            .eq("autor_id", value: autorId.uuidString)
            .execute()
            .value
    }

    struct FavoriteDTO: Encodable {
        let autor_id: String
        let ejercicio_id: String?
        let ejercicio_usuario_id: String?
    }

    func addFavorite(autorId: UUID, ejercicioId: UUID?, ejercicioUsuarioId: UUID?) async throws {
        let dto = FavoriteDTO(
            autor_id: autorId.uuidString,
            ejercicio_id: ejercicioId?.uuidString,
            ejercicio_usuario_id: ejercicioUsuarioId?.uuidString
        )

        _ = try await client
            .from("ejercicios_favoritos")
            .upsert(dto, onConflict: "autor_id,ejercicio_id,ejercicio_usuario_id", returning: .minimal)
            .execute()
    }

    func removeFavorite(autorId: UUID, ejercicioId: UUID?, ejercicioUsuarioId: UUID?) async throws {
        // Borrado robusto: encontrar favorito y borrar por id
        let keyColumn = (ejercicioId == nil) ? "ejercicio_usuario_id" : "ejercicio_id"
        let keyValue = (ejercicioId ?? ejercicioUsuarioId)?.uuidString ?? ""

        let rows: [DBFavorite] = try await client
            .from("ejercicios_favoritos")
            .select()
            .eq("autor_id", value: autorId.uuidString)
            .eq(keyColumn, value: keyValue)
            .limit(1)
            .execute()
            .value

        guard let fav = rows.first else { return }

        _ = try await client
            .from("ejercicios_favoritos")
            .delete()
            .eq("id", value: fav.id.uuidString)
            .execute()
    }
}
