import Foundation
import Supabase

@MainActor
final class TrainingSessionSupabaseService {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func currentUserId() throws -> UUID {
        guard let session = client.auth.currentSession else {
            throw NSError(domain: "TrainingSessionSupabaseService", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "No hay sesión activa"
            ])
        }
        return session.user.id
    }

    // MARK: - sesiones_entrenamiento

    struct CreateSessionDTO: Encodable {
        let autor_id: String
        let fecha: String
        let tipo: String
        let plan_sesion_id: String?
        let titulo: String?
        let notas: String?
        let duracion_minutos: Int?
        let estado: String
        let started_at: String
    }

    struct UpdateSessionDTO: Encodable {
        let titulo: String?
        let notas: String?
        let duracion_minutos: Int?
        let estado: String
        let ended_at: String?
    }

    struct SessionRow: Decodable {
        let id: UUID
    }

    func createSession(dto: CreateSessionDTO) async throws -> UUID {
        let inserted: [SessionRow] = try await client
            .from("sesiones_entrenamiento")
            .insert(dto)
            .select("id")
            .execute()
            .value

        guard let id = inserted.first?.id else {
            throw NSError(domain: "TrainingSessionSupabaseService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "No se pudo crear la sesión"
            ])
        }
        return id
    }

    func updateSession(sessionId: UUID, dto: UpdateSessionDTO) async throws {
        _ = try await client
            .from("sesiones_entrenamiento")
            .update(dto)
            .eq("id", value: sessionId.uuidString)
            .execute()
    }

    // MARK: - sesion_items

    struct CreateItemDTO: Encodable {
        let sesion_id: String
        let orden: Int
        let ejercicio_id: String?
        let nombre_snapshot: String
        let notas: String?
    }

    struct ItemRow: Decodable { let id: UUID }

    func createItem(dto: CreateItemDTO) async throws -> UUID {
        let inserted: [ItemRow] = try await client
            .from("sesion_items")
            .insert(dto)
            .select("id")
            .execute()
            .value

        guard let id = inserted.first?.id else {
            throw NSError(domain: "TrainingSessionSupabaseService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "No se pudo crear el item"
            ])
        }
        return id
    }

    // MARK: - sesion_sets

    struct CreateSetDTO: Encodable {
        let sesion_item_id: String
        let orden: Int
        let reps: Int?
        let peso_kg: Double?
        let rpe: Double?
        let tiempo_seg: Int?
        let distancia_m: Double?
        let completado: Bool
    }

    struct SetRow: Decodable { let id: UUID }

    func createSet(dto: CreateSetDTO) async throws -> UUID {
        let inserted: [SetRow] = try await client
            .from("sesion_sets")
            .insert(dto)
            .select("id")
            .execute()
            .value

        guard let id = inserted.first?.id else {
            throw NSError(domain: "TrainingSessionSupabaseService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "No se pudo crear el set"
            ])
        }
        return id
    }

    struct UpdateSetDTO: Encodable {
        let reps: Int?
        let peso_kg: Double?
        let rpe: Double?
        let tiempo_seg: Int?
        let distancia_m: Double?
        let completado: Bool
    }

    func updateSet(setId: UUID, dto: UpdateSetDTO) async throws {
        _ = try await client
            .from("sesion_sets")
            .update(dto)
            .eq("id", value: setId.uuidString)
            .execute()
    }
}
