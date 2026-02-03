import Foundation
import Supabase

// MARK: - ExerciseSupabaseService

@MainActor
final class ExerciseSupabaseService {
    private let client: SupabaseClient

    init(client: SupabaseClient) { self.client = client }

    func currentUserId() throws -> UUID {
        guard let session = client.auth.currentSession else {
            throw NSError(domain: "ExerciseSupabaseService", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "No hay sesión activa"
            ])
        }
        return session.user.id
    }

    func fetchExercises(type: ExerciseType) async throws -> [Exercise] {
        try await client
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
        struct DTO: Encodable { let autor_id: String; let ejercicio_id: String }
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

// MARK: - TrainingPlannerSupabaseService

@MainActor
final class TrainingPlannerSupabaseService {
    private let client: SupabaseClient
    init(client: SupabaseClient) { self.client = client }

    func currentUserId() throws -> UUID {
        guard let session = client.auth.currentSession else {
            throw NSError(domain: "Planner", code: 401, userInfo: [NSLocalizedDescriptionKey: "No hay sesión"])
        }
        return session.user.id
    }

    // plan_repeticiones
    struct RepeatRow: Encodable {
        let autor_id: String
        let template: TrainingRepeatTemplate
        let start_date: String
        let end_date: String?
        let byweekday: [Int]
        let hora: String?
    }

    func upsertRepeatPlan(
        template: TrainingRepeatTemplate,
        startDate: Date,
        endDate: Date?,
        byweekday: [Int],
        hora: String?
    ) async {
        do {
            let autorId = try currentUserId()

            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"

            let dto = RepeatRow(
                autor_id: autorId.uuidString,
                template: template,
                start_date: df.string(from: startDate),
                end_date: endDate.map { df.string(from: $0) },
                byweekday: byweekday,
                hora: hora
            )

            _ = try await client
                .from("plan_repeticiones")
                .insert(dto)
                .execute()
        } catch {
            // opcional
        }
    }

    // plan_sesiones
    struct UpsertPlannedSessionDTO: Encodable {
        let id: String?
        let autor_id: String
        let fecha: String
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

    // plan_sesion_ejercicios
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

// MARK: - TrainingSessionSupabaseService

@MainActor
final class TrainingSessionSupabaseService {
    private let client: SupabaseClient
    init(client: SupabaseClient) { self.client = client }

    func currentUserId() throws -> UUID {
        guard let session = client.auth.currentSession else {
            throw NSError(domain: "TrainingSessionSupabaseService", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "No hay sesión activa"
            ])
        }
        return session.user.id
    }

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

    struct SessionRow: Decodable { let id: UUID }

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

    struct CreateSetDTO: Encodable {
        let sesion_item_id: String
        let orden: Int
        let reps: Int?
        let peso_kg: Double?
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
