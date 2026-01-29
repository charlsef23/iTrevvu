import Foundation
import Supabase

final class TrainingPlannerSupabaseService {
    let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Auth
    func currentUserId() throws -> UUID {
        guard let session = client.auth.currentSession else {
            throw NSError(domain: "TrainingPlannerSupabaseService", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"])
        }
        return session.user.id
    }

    // MARK: - Planned Sessions

    struct UpsertPlannedSessionDTO: Encodable {
        let id: String?           // nil -> insert
        let autor_id: String
        let fecha: String         // YYYY-MM-DD
        let hora: String?
        let tipo: String
        let nombre: String
        let icono: String?
        let color: String?
        let duracion_minutos: Int?
        let objetivo: String?
        let notas: String?
        let meta: SessionMeta?
    }

    func fetchPlannedSessions(autorId: UUID, from: Date, to: Date) async throws -> [DBPlannedSession] {
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withFullDate]
        let fromStr = fmt.string(from: from)
        let toStr = fmt.string(from: to)

        return try await client
            .from("plan_sesiones")
            .select()
            .eq("autor_id", value: autorId.uuidString)
            .gte("fecha", value: fromStr)
            .lte("fecha", value: toStr)
            .order("fecha", ascending: true)
            .order("hora", ascending: true)
            .execute()
            .value
    }

    func upsertPlannedSession(_ dto: UpsertPlannedSessionDTO) async throws -> DBPlannedSession {
        if dto.id != nil {
            return try await client
                .from("plan_sesiones")
                .upsert(dto, onConflict: "id", returning: .representation)
                .single()
                .execute()
                .value
        } else {
            return try await client
                .from("plan_sesiones")
                .insert(dto, returning: .representation)
                .single()
                .execute()
                .value
        }
    }

    func deletePlannedSession(id: UUID) async throws {
        _ = try await client
            .from("plan_sesiones")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }

    // MARK: - Planned Session Exercises

    struct CreatePlannedSessionExerciseDTO: Encodable {
        let sesion_id: String
        let orden: Int
        let ejercicio_id: String?
        let nombre_override: String?
        let objetivo: [String: String]?
        let notas: String?
    }

    func fetchPlannedSessionExercises(sessionId: UUID) async throws -> [DBPlannedSessionExercise] {
        try await client
            .from("plan_sesion_ejercicios")
            .select()
            .eq("sesion_id", value: sessionId.uuidString)
            .order("orden", ascending: true)
            .execute()
            .value
    }

    func replacePlannedSessionExercises(sessionId: UUID, items: [CreatePlannedSessionExerciseDTO]) async throws {
        _ = try await client
            .from("plan_sesion_ejercicios")
            .delete()
            .eq("sesion_id", value: sessionId.uuidString)
            .execute()

        guard !items.isEmpty else { return }

        _ = try await client
            .from("plan_sesion_ejercicios")
            .insert(items)
            .execute()
    }
}
