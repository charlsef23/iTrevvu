import Foundation
import Supabase
import PostgREST

final class TrainingPlannerSupabaseService {

    let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Auth

    func currentUserId() throws -> UUID {
        guard let session = client.auth.currentSession else {
            throw NSError(
                domain: "TrainingPlannerSupabaseService",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"]
            )
        }
        return session.user.id
    }

    // MARK: - Plan (calendar)

    struct UpsertPlanDTO: Encodable {
        let autor_id: String
        let fecha: String              // YYYY-MM-DD
        let tipo: String               // gimnasio/cardio/movilidad/rutina
        let rutina_id: String?
        let rutina_titulo: String?
        let duracion_minutos: Int?
        let nota: String?
    }

    func fetchPlans(autorId: UUID, from: Date, to: Date) async throws -> [DBPlan] {
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withFullDate]
        let fromStr = fmt.string(from: from)
        let toStr = fmt.string(from: to)

        return try await client
            .from("plan_entrenamiento")
            .select()
            .eq("autor_id", value: autorId.uuidString)
            .gte("fecha", value: fromStr)
            .lte("fecha", value: toStr)
            .execute()
            .value
    }

    func upsertPlan(_ dto: UpsertPlanDTO) async throws -> DBPlan {
        try await client
            .from("plan_entrenamiento")
            .upsert(dto, onConflict: "autor_id,fecha", returning: .representation)
            .single()
            .execute()
            .value
    }

    func deletePlan(autorId: UUID, dateKey: String) async throws {
        _ = try await client
            .from("plan_entrenamiento")
            .delete()
            .eq("autor_id", value: autorId.uuidString)
            .eq("fecha", value: dateKey)
            .execute()
    }
}
