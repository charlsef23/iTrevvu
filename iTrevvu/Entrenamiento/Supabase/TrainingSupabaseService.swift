import Foundation
import Supabase
import PostgREST

final class TrainingSupabaseService {

    let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Auth / User

    func currentUserId() throws -> UUID {
        guard let session = client.auth.currentSession else {
            throw NSError(
                domain: "TrainingSupabaseService",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"]
            )
        }
        return session.user.id
    }

    // MARK: - Exercises (global + user)

    func fetchGlobalExercises() async throws -> [DBExercise] {
        try await client
            .from("ejercicios")
            .select()
            .order("nombre", ascending: true)
            .execute()
            .value
    }

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

    struct FavoriteDTO: Encodable {
        let autor_id: String
        let ejercicio_id: String?
        let ejercicio_usuario_id: String?
    }

    func fetchFavorites(autorId: UUID) async throws -> [DBFavorite] {
        try await client
            .from("ejercicios_favoritos")
            .select()
            .eq("autor_id", value: autorId.uuidString)
            .execute()
            .value
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
        // ✅ Evitamos .is(null) para no depender de overloads/versiones
        var q = client
            .from("ejercicios_favoritos")
            .delete()
            .eq("autor_id", value: autorId.uuidString)

        if let ejercicioId {
            q = q.eq("ejercicio_id", value: ejercicioId.uuidString)
        }
        if let ejercicioUsuarioId {
            q = q.eq("ejercicio_usuario_id", value: ejercicioUsuarioId.uuidString)
        }

        _ = try await q.execute()
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

    // MARK: - Routines

    struct CreateRoutineDTO: Encodable {
        let autor_id: String
        let titulo: String
        let descripcion: String?
        let tags: [String]
        let duracion_minutos: Int?
    }

    struct CreateRoutineItemDTO: Encodable {
        let rutina_id: String
        let orden: Int
        let ejercicio_id: String?
        let ejercicio_usuario_id: String?
        let nombre_override: String?
        let notas: String?
        let sets_objetivo: Int?
        let rep_range_objetivo: String?
        let descanso_segundos: Int?
    }

    func fetchRoutines(autorId: UUID) async throws -> [DBRoutine] {
        try await client
            .from("rutinas")
            .select()
            .eq("autor_id", value: autorId.uuidString)
            .order("updated_at", ascending: false)
            .execute()
            .value
    }

    func fetchRoutineItems(routineId: UUID) async throws -> [DBRoutineItem] {
        try await client
            .from("rutina_items")
            .select()
            .eq("rutina_id", value: routineId.uuidString)
            .order("orden", ascending: true)
            .execute()
            .value
    }

    func createRoutine(_ dto: CreateRoutineDTO) async throws -> DBRoutine {
        try await client
            .from("rutinas")
            .insert(dto, returning: .representation)
            .single()
            .execute()
            .value
    }

    func createRoutineItem(_ dto: CreateRoutineItemDTO) async throws -> DBRoutineItem {
        try await client
            .from("rutina_items")
            .insert(dto, returning: .representation)
            .single()
            .execute()
            .value
    }

    // MARK: - Sessions (historial + sets)

    struct CreateSessionDTO: Encodable {
        let autor_id: String
        let fecha: String?            // opcional, si no se manda, default now()
        let tipo: String
        let plan_id: String?
        let titulo: String?
        let duracion_minutos: Int?
        let notas: String?
    }

    struct CreateSessionItemDTO: Encodable {
        let sesion_id: String
        let orden: Int
        let ejercicio_id: String?
        let ejercicio_usuario_id: String?
        let nombre_snapshot: String?
        let notas: String?
    }

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

    func createSession(_ dto: CreateSessionDTO) async throws -> DBSession {
        try await client
            .from("sesiones_entrenamiento")
            .insert(dto, returning: .representation)
            .single()
            .execute()
            .value
    }

    func createSessionItem(_ dto: CreateSessionItemDTO) async throws -> DBSessionItem {
        try await client
            .from("sesion_items")
            .insert(dto, returning: .representation)
            .single()
            .execute()
            .value
    }

    func createSessionSet(_ dto: CreateSessionSetDTO) async throws -> DBSessionSet {
        try await client
            .from("sesion_sets")
            .insert(dto, returning: .representation)
            .single()
            .execute()
            .value
    }

    func fetchRecentSessions(autorId: UUID, limit: Int = 30) async throws -> [DBSession] {
        try await client
            .from("sesiones_entrenamiento")
            .select()
            .eq("autor_id", value: autorId.uuidString)
            .order("fecha", ascending: false)
            .limit(limit)
            .execute()
            .value
    }
}
