import Foundation

struct DBPlannedSession: Codable, Identifiable {
    let id: UUID
    let autor_id: UUID

    let fecha: String          // "YYYY-MM-DD"
    let hora: String?          // "HH:mm:ss"

    let tipo: String
    let nombre: String

    let icono: String?
    let color: String?

    let duracion_minutos: Int?
    let objetivo: String?
    let notas: String?

    let meta: SessionMeta?

    let created_at: Date?
    let updated_at: Date?

    var fechaKey: String { fecha }
}

struct DBPlannedSessionExercise: Codable, Identifiable {
    let id: UUID
    let sesion_id: UUID
    let orden: Int

    let ejercicio_id: UUID?
    let nombre_override: String?

    let objetivo: [String: String]?
    let notas: String?

    let created_at: Date?
}

extension DBPlannedSession {
    func toPlannedSession() -> PlannedSession {
        let date = ISO8601DateFormatter().date(from: fecha + "T00:00:00Z") ?? Date()

        return PlannedSession(
            id: id,
            autorId: autor_id,
            date: date,
            hora: hora,
            tipo: TrainingSessionType(rawValue: tipo) ?? .gimnasio,
            nombre: nombre,
            icono: icono,
            color: color,
            duracionMinutos: duracion_minutos,
            objetivo: objetivo,
            notas: notas,
            meta: meta,
            createdAt: created_at,
            updatedAt: updated_at
        )
    }
}

extension DBPlannedSessionExercise {
    func toPlannedSessionExercise() -> PlannedSessionExercise {
        PlannedSessionExercise(
            id: id,
            sesionId: sesion_id,
            orden: orden,
            ejercicioId: ejercicio_id,
            nombreOverride: nombre_override,
            objetivo: objetivo,
            notas: notas
        )
    }
}
