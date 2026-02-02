import Foundation

// MARK: - Rows (DB -> Swift) aligned with Supabase tables
// Tablas:
// - sesiones_entrenamiento
// - sesion_items
// - sesion_sets

// sesiones_entrenamiento
struct DBTrainingSession: Codable, Identifiable {
    let id: UUID
    let autor_id: UUID

    let fecha: String                 // "YYYY-MM-DD"
    let tipo: String                  // enum rawValue
    let plan_sesion_id: UUID?

    let titulo: String?
    let notas: String?
    let duracion_minutos: Int?

    let estado: String                // "en_progreso" | "finalizada" | "cancelada"
    let started_at: Date?
    let ended_at: Date?

    let created_at: Date?
    let updated_at: Date?
}

// sesion_items
struct DBTrainingSessionItem: Codable, Identifiable {
    let id: UUID
    let sesion_id: UUID
    let orden: Int

    let ejercicio_id: UUID?
    let nombre_snapshot: String
    let notas: String?

    let created_at: Date?
}

// sesion_sets
struct DBTrainingSet: Codable, Identifiable {
    let id: UUID
    let sesion_item_id: UUID
    let orden: Int

    let reps: Int?
    let peso_kg: Double?
    let tiempo_seg: Int?
    let distancia_m: Double?
    let completado: Bool

    let created_at: Date?
    let updated_at: Date?
}


// MARK: - Mapping helpers (DB -> Domain)

extension DBTrainingSession {

    /// OJO: tu `TrainingSession` NO acepta createdAt/updatedAt → los quitamos.
    func toDomain() -> TrainingSession {
        let day = Self.parseDay(fecha)

        return TrainingSession(
            id: id,
            autorId: autor_id,
            fecha: day,
            tipo: TrainingSessionType(rawValue: tipo) ?? .gimnasio,
            planSesionId: plan_sesion_id,
            titulo: titulo,
            notas: notas,
            duracionMinutos: duracion_minutos,
            estado: TrainingSessionState(rawValue: estado) ?? .en_progreso,
            startedAt: started_at ?? Date(),
            endedAt: ended_at
        )
    }

    /// "YYYY-MM-DD" -> Date (UTC midnight)
    private static func parseDay(_ yyyyMMdd: String) -> Date {
        let parts = yyyyMMdd.split(separator: "-")
        guard parts.count == 3,
              let y = Int(parts[0]),
              let m = Int(parts[1]),
              let d = Int(parts[2]) else { return Date() }

        var comps = DateComponents()
        comps.calendar = Calendar(identifier: .gregorian)
        comps.timeZone = TimeZone(secondsFromGMT: 0)
        comps.year = y
        comps.month = m
        comps.day = d
        return comps.date ?? Date()
    }
}

extension DBTrainingSessionItem {

    /// OJO: tu `TrainingSessionItem` exige `sessionId` → lo pasamos aquí.
    func toDomain(sets: [TrainingSet]) -> TrainingSessionItem {
        TrainingSessionItem(
            id: id,
            sessionId: sesion_id,
            orden: orden,
            ejercicioId: ejercicio_id,
            nombreSnapshot: nombre_snapshot,
            notas: notas,
            sets: sets
        )
    }
}

extension DBTrainingSet {

    /// OJO: `TrainingSet` ya NO tiene rpe → lo quitamos.
    func toDomain() -> TrainingSet {
        TrainingSet(
            id: id,
            orden: orden,
            reps: reps,
            pesoKg: peso_kg,
            tiempoSeg: tiempo_seg,
            distanciaM: distancia_m,
            completado: completado
        )
    }
}
