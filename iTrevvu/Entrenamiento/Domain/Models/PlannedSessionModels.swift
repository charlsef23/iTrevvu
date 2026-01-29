import Foundation

struct SessionMeta: Codable, Hashable {
    var goal: String?
    var rpeTarget: Double?
    var tags: [String]?
}

struct PlannedSession: Identifiable, Hashable {
    var id: UUID?                // nil -> create
    var autorId: UUID?           // opcional en UI (normalmente no lo necesitas)
    var date: Date               // día
    var hora: String?            // "HH:mm:ss" o nil

    var tipo: TrainingSessionType
    var nombre: String

    var icono: String?
    var color: String?

    var duracionMinutos: Int?
    var objetivo: String?
    var notas: String?
    var meta: SessionMeta?

    var createdAt: Date?
    var updatedAt: Date?

    var fechaKey: String {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", comps.year ?? 0, comps.month ?? 0, comps.day ?? 0)
    }

    var sortKey: String {
        (hora?.isEmpty == false ? hora! : "99:99:99")
    }
}

struct PlannedSessionExercise: Identifiable, Hashable {
    var id: UUID? = nil
    var sesionId: UUID? = nil
    var orden: Int = 0

    var ejercicioId: UUID?
    var nombreOverride: String?

    var objetivo: [String: String]?
    var notas: String?
}
