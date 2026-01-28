import Foundation

enum TrainingSessionType: String, Codable, CaseIterable, Identifiable {
    case gimnasio, cardio, movilidad, rutina, hiit, calistenia, deporte, rehab, descanso
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
