import Foundation

enum TrainingPlanKind: String, Codable, CaseIterable, Identifiable {
    case gimnasio
    case cardio
    case movilidad
    case rutina

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gimnasio: return "Gimnasio"
        case .cardio: return "Cardio"
        case .movilidad: return "Movilidad"
        case .rutina: return "Rutina"
        }
    }
}

struct TrainingPlan: Codable, Identifiable, Equatable {
    let id: UUID
    var date: Date
    var kind: TrainingPlanKind
    var routineTitle: String?      // si kind == .rutina (o si quieres poner una plantilla)
    var durationMinutes: Int?      // opcional
    var note: String?              // opcional

    init(
        id: UUID = UUID(),
        date: Date,
        kind: TrainingPlanKind,
        routineTitle: String? = nil,
        durationMinutes: Int? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.date = date
        self.kind = kind
        self.routineTitle = routineTitle
        self.durationMinutes = durationMinutes
        self.note = note
    }
}
