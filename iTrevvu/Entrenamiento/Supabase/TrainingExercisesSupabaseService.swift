import Foundation
import Supabase

final class TrainingExercisesSupabaseService {
    static let shared = TrainingExercisesSupabaseService()
    private init() {}

    private var client: SupabaseClient { SupabaseManager.shared.client }

    // MARK: - DTO para inserts (Encodable)
    struct CreateExerciseDTO: Encodable {
        let tipo: String
        let nombre: String
        let aliases: [String]
        let descripcion: String?
        let musculo_principal: String?
        let musculos_secundarios: [String]
        let equipo: [String]
        let patron: String?
        let tipo_medicion: String
        let video_url: String?
        let es_publico: Bool
        let autor_id: String?
    }

    // MARK: - Fetch exercises by type (search local)
    func fetchExercises(type: ExerciseType, search: String? = nil) async throws -> [Exercise] {
        let items: [Exercise] = try await client
            .from("ejercicios")
            .select()
            .eq("tipo", value: type.rawValue)
            .order("nombre", ascending: true)
            .execute()
            .value

        guard let search, !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return items
        }

        let needle = search
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()

        return items.filter { ex in
            let name = ex.nombre
                .folding(options: .diacriticInsensitive, locale: .current)
                .lowercased()

            if name.contains(needle) { return true }

            let aliases = (ex.aliases ?? []).map {
                $0.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            }
            return aliases.contains(where: { $0.contains(needle) })
        }
    }

    // MARK: - Favorites
    func fetchFavorites(for autorId: UUID) async throws -> Set<UUID> {
        let rows: [ExerciseFavorite] = try await client
            .from("ejercicios_favoritos")
            .select()
            .eq("autor_id", value: autorId.uuidString)
            .execute()
            .value

        return Set(rows.map { $0.ejercicio_id })
    }

    func addFavorite(autorId: UUID, ejercicioId: UUID) async throws {
        try await client
            .from("ejercicios_favoritos")
            .insert([
                "autor_id": autorId.uuidString,
                "ejercicio_id": ejercicioId.uuidString
            ])
            .execute()
    }

    func removeFavorite(autorId: UUID, ejercicioId: UUID) async throws {
        try await client
            .from("ejercicios_favoritos")
            .delete()
            .eq("autor_id", value: autorId.uuidString)
            .eq("ejercicio_id", value: ejercicioId.uuidString)
            .execute()
    }

    // MARK: - Create custom exercise
    func createCustomExercise(_ dto: CreateExerciseDTO) async throws {
        try await client
            .from("ejercicios")
            .insert(dto)
            .execute()
    }
}
