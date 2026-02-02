import Foundation

// MARK: - Live session enums

enum TrainingSessionState: String, Codable {
    case en_progreso
    case finalizada
    case cancelada
}

enum TrainingSessionType: String, Codable, CaseIterable, Identifiable {
    case gimnasio
    case cardio
    case movilidad
    case rutina
    case hiit
    case calistenia
    case deporte
    case rehab
    case descanso

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gimnasio: return "Gimnasio"
        case .cardio: return "Cardio"
        case .movilidad: return "Movilidad"
        case .rutina: return "Rutina"
        case .hiit: return "HIIT"
        case .calistenia: return "Calistenia"
        case .deporte: return "Deporte"
        case .rehab: return "Rehab"
        case .descanso: return "Descanso"
        }
    }
}

// MARK: - Live session models (sin RPE)

struct TrainingSet: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var orden: Int

    var reps: Int?
    var pesoKg: Double?
    var tiempoSeg: Int?
    var distanciaM: Double?

    var completado: Bool

    init(
        id: UUID = UUID(),
        orden: Int,
        reps: Int? = nil,
        pesoKg: Double? = nil,
        tiempoSeg: Int? = nil,
        distanciaM: Double? = nil,
        completado: Bool = false
    ) {
        self.id = id
        self.orden = orden
        self.reps = reps
        self.pesoKg = pesoKg
        self.tiempoSeg = tiempoSeg
        self.distanciaM = distanciaM
        self.completado = completado
    }
}

struct TrainingSessionItem: Identifiable, Codable, Hashable {
    var id: UUID = UUID()            // local id (UI)
    var sessionId: UUID              // DB session id
    var orden: Int

    var ejercicioId: UUID?
    var nombreSnapshot: String
    var notas: String?

    var sets: [TrainingSet]

    init(
        id: UUID = UUID(),
        sessionId: UUID,
        orden: Int,
        ejercicioId: UUID? = nil,
        nombreSnapshot: String,
        notas: String? = nil,
        sets: [TrainingSet] = []
    ) {
        self.id = id
        self.sessionId = sessionId
        self.orden = orden
        self.ejercicioId = ejercicioId
        self.nombreSnapshot = nombreSnapshot
        self.notas = notas
        self.sets = sets
    }
}

struct TrainingSession: Identifiable, Codable, Hashable {
    var id: UUID
    var autorId: UUID
    var fecha: Date
    var tipo: TrainingSessionType

    var planSesionId: UUID?
    var titulo: String?
    var notas: String?

    var duracionMinutos: Int?
    var estado: TrainingSessionState

    var startedAt: Date
    var endedAt: Date?

    var items: [TrainingSessionItem]

    init(
        id: UUID,
        autorId: UUID,
        fecha: Date,
        tipo: TrainingSessionType,
        planSesionId: UUID? = nil,
        titulo: String? = nil,
        notas: String? = nil,
        duracionMinutos: Int? = nil,
        estado: TrainingSessionState = .en_progreso,
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        items: [TrainingSessionItem] = []
    ) {
        self.id = id
        self.autorId = autorId
        self.fecha = fecha
        self.tipo = tipo
        self.planSesionId = planSesionId
        self.titulo = titulo
        self.notas = notas
        self.duracionMinutos = duracionMinutos
        self.estado = estado
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.items = items
    }
}
