import Foundation
import Supabase
import PostgREST

final class TrainingSessionSupabaseService {

    let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func currentUserId() throws -> UUID {
        guard let session = client.auth.currentSession else {
            throw NSError(domain: "TrainingSessionSupabaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"])
        }
        return session.user.id
    }

    // MARK: - Create session

    struct CreateSessionDTO: Encodable {
        let autor_id: String
        let fecha: String  // YYYY-MM-DD
        let tipo: String
        let plan_sesion_id: String?
        let titulo: String?
        let notas: String?
        let duracion_minutos: Int?
        let estado: String?
    }

    func createSession(_ dto: CreateSessionDTO) async throws -> DBTrainingSession {
        try await client
            .from("sesiones_entrenamiento")
            .insert(dto, returning: .representation)
            .single()
            .execute()
            .value
    }

    // MARK: - Session items

    struct CreateSessionItemDTO: Encodable {
        let sesion_id: String
        let orden: Int
        let ejercicio_id: String?
        let nombre_snapshot: String
        let notas: String?
    }

    func insertSessionItems(_ items: [CreateSessionItemDTO]) async throws -> [DBTrainingSessionItem] {
        guard !items.isEmpty else { return [] }

        return try await client
            .from("sesion_items")
            .insert(items, returning: .representation)
            .execute()
            .value
    }

    // MARK: - Session sets

    struct CreateSessionSetDTO: Encodable {
        let sesion_item_id: String
        let orden: Int
        let reps: Int?
        let peso_kg: Double?
        let rpe: Double?
        let tiempo_seg: Int?
        let distancia_m: Double?
        let completado: Bool?
    }

    func insertSessionSets(_ items: [CreateSessionSetDTO]) async throws -> [DBTrainingSessionSet] {
        guard !items.isEmpty else { return [] }

        return try await client
            .from("sesion_sets")
            .insert(items, returning: .representation)
            .execute()
            .value
    }

    struct UpdateSessionSetDTO: Encodable {
        let reps: Int?
        let peso_kg: Double?
        let rpe: Double?
        let tiempo_seg: Int?
        let distancia_m: Double?
        let completado: Bool?
    }

    func updateSet(setId: UUID, dto: UpdateSessionSetDTO) async throws -> DBTrainingSessionSet {
        try await client
            .from("sesion_sets")
            .update(dto, returning: .representation)
            .eq("id", value: setId.uuidString)
            .single()
            .execute()
            .value
    }

    func deleteSet(setId: UUID) async throws {
        _ = try await client
            .from("sesion_sets")
            .delete()
            .eq("id", value: setId.uuidString)
            .execute()
    }

    // MARK: - Load session (resume)

    func fetchActiveSession(autorId: UUID) async throws -> DBTrainingSession? {
        let rows: [DBTrainingSession] = try await client
            .from("sesiones_entrenamiento")
            .select()
            .eq("autor_id", value: autorId.uuidString)
            .eq("estado", value: "en_progreso")
            .order("started_at", ascending: false)
            .limit(1)
            .execute()
            .value

        return rows.first
    }

    func fetchSessionItems(sessionId: UUID) async throws -> [DBTrainingSessionItem] {
        try await client
            .from("sesion_items")
            .select()
            .eq("sesion_id", value: sessionId.uuidString)
            .order("orden", ascending: true)
            .execute()
            .value
    }

    func fetchSetsForItem(itemId: UUID) async throws -> [DBTrainingSessionSet] {
        try await client
            .from("sesion_sets")
            .select()
            .eq("sesion_item_id", value: itemId.uuidString)
            .order("orden", ascending: true)
            .execute()
            .value
    }

    // MARK: - Finish session

    struct FinishSessionDTO: Encodable {
        let estado: String
        let ended_at: Date
        let duracion_minutos: Int?
    }

    func finishSession(sessionId: UUID, minutes: Int?) async throws -> DBTrainingSession {
        let dto = FinishSessionDTO(estado: "finalizada", ended_at: Date(), duracion_minutos: minutes)

        return try await client
            .from("sesiones_entrenamiento")
            .update(dto, returning: .representation)
            .eq("id", value: sessionId.uuidString)
            .single()
            .execute()
            .value
    }
}

private extension Date {
    var ymd: String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        return f.string(from: self)
    }
}
