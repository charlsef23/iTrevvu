import Foundation

// MARK: - SessionMeta (jsonb)

/// Representa `meta jsonb` en Supabase.
/// Si luego quieres estructura más compleja, ampliamos aquí.
struct SessionMeta: Codable, Hashable {
    var values: [String: String] = [:]

    init(values: [String: String] = [:]) {
        self.values = values
    }
}

// MARK: - PlannedSession (plan_sesiones)

struct PlannedSession: Identifiable, Codable, Hashable {

    let id: UUID

    let date: Date          // día
    let hora: String?       // "HH:mm:ss"

    let tipo: TrainingSessionType
    var nombre: String

    var icono: String?
    var color: String?

    var duracionMinutos: Int?
    var objetivo: String?
    var notas: String?
    var meta: SessionMeta?

    var createdAt: Date?
    var updatedAt: Date?

    init(
        id: UUID = UUID(),
        date: Date,
        hora: String? = nil,
        tipo: TrainingSessionType,
        nombre: String,
        icono: String? = nil,
        color: String? = nil,
        duracionMinutos: Int? = nil,
        objetivo: String? = nil,
        notas: String? = nil,
        meta: SessionMeta? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.date = date
        self.hora = hora
        self.tipo = tipo
        self.nombre = nombre
        self.icono = icono
        self.color = color
        self.duracionMinutos = duracionMinutos
        self.objetivo = objetivo
        self.notas = notas
        self.meta = meta
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Helpers

    var fechaKey: String {
        let cal = Calendar.current
        let c = cal.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    var sortKey: String {
        let hh = (hora ?? "99:99:99")
        return "\(fechaKey)|\(hh)"
    }
}

// MARK: - PlannedSessionExercise (plan_sesion_ejercicios)

struct PlannedSessionExercise: Identifiable, Codable, Hashable {

    let id: UUID
    let sesionId: UUID
    let orden: Int

    var ejercicioId: UUID?
    var nombreOverride: String?

    var objetivo: [String: String]?
    var notas: String?

    init(
        id: UUID = UUID(),
        sesionId: UUID,
        orden: Int,
        ejercicioId: UUID? = nil,
        nombreOverride: String? = nil,
        objetivo: [String: String]? = nil,
        notas: String? = nil
    ) {
        self.id = id
        self.sesionId = sesionId
        self.orden = orden
        self.ejercicioId = ejercicioId
        self.nombreOverride = nombreOverride
        self.objetivo = objetivo
        self.notas = notas
    }
}
