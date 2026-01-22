import Foundation

// MARK: - DB rows (DTO) para Supabase

struct DBExercise: Codable, Identifiable {
    let id: UUID
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
    let created_at: Date?
}

struct DBUserExercise: Codable, Identifiable {
    let id: UUID
    let autor_id: UUID
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
    let created_at: Date?
    let updated_at: Date?
}

struct DBFavorite: Codable, Identifiable {
    let id: UUID
    let autor_id: UUID
    let ejercicio_id: UUID?
    let ejercicio_usuario_id: UUID?
    let created_at: Date?
}

struct DBRoutine: Codable, Identifiable {
    let id: UUID
    let autor_id: UUID
    let titulo: String
    let descripcion: String?
    let tags: [String]
    let duracion_minutos: Int?
    let created_at: Date?
    let updated_at: Date?
}

struct DBRoutineItem: Codable, Identifiable {
    let id: UUID
    let rutina_id: UUID
    let orden: Int
    let ejercicio_id: UUID?
    let ejercicio_usuario_id: UUID?
    let nombre_override: String?
    let notas: String?
    let sets_objetivo: Int?
    let rep_range_objetivo: String?
    let descanso_segundos: Int?
    let created_at: Date?
}

struct DBPlan: Codable, Identifiable {
    let id: UUID
    let autor_id: UUID
    let fecha: String                 // "YYYY-MM-DD"
    let tipo: String                  // gimnasio/cardio/movilidad/rutina
    let rutina_id: UUID?
    let rutina_titulo: String?
    let duracion_minutos: Int?
    let nota: String?

    // ✅ viene del TrainingPlan.swift (PlanMeta)
    let meta: PlanMeta?

    let created_at: Date?
    let updated_at: Date?
}

struct DBSession: Codable, Identifiable {
    let id: UUID
    let autor_id: UUID
    let fecha: Date
    let tipo: String
    let plan_id: UUID?
    let titulo: String?
    let duracion_minutos: Int?
    let notas: String?
    let created_at: Date?
}

struct DBSessionItem: Codable, Identifiable {
    let id: UUID
    let sesion_id: UUID
    let orden: Int
    let ejercicio_id: UUID?
    let ejercicio_usuario_id: UUID?
    let nombre_snapshot: String?
    let notas: String?
    let created_at: Date?
}

struct DBSessionSet: Codable, Identifiable {
    let id: UUID
    let sesion_item_id: UUID
    let orden: Int
    let reps: Int?
    let peso_kg: Double?
    let rpe: Double?
    let tiempo_seg: Int?
    let distancia_m: Double?
    let completado: Bool
    let created_at: Date?
}
