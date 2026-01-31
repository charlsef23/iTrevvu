import Foundation

enum TrainingSessionType: String, Codable {
    case gimnasio, cardio, movilidad, rutina, hiit, calistenia, deporte, rehab, descanso

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

enum TrainingSessionState: String, Codable {
    case en_progreso
    case finalizada
    case cancelada
}

struct TrainingSet: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var orden: Int
    var reps: Int?
    var pesoKg: Double?
    var rpe: Double?          // (si lo vas a quitar en UI, igual lo dejamos en DB por compatibilidad)
    var tiempoSeg: Int?
    var distanciaM: Double?
    var completado: Bool
}

struct TrainingSessionItem: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var orden: Int
    var ejercicioId: UUID?
    var nombreSnapshot: String
    var notas: String?
    var sets: [TrainingSet]
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
}
