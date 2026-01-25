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

enum PlanGoal: String, Codable, CaseIterable, Identifiable {
    case fuerza
    case hipertrofia
    case resistencia
    case tecnica
    case recuperacion
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .fuerza: return "Fuerza"
        case .hipertrofia: return "Hipertrofia"
        case .resistencia: return "Resistencia"
        case .tecnica: return "Técnica"
        case .recuperacion: return "Recuperación"
        }
    }
    
    var systemImage: String {
        switch self {
        case .fuerza: return "bolt.fill"
        case .hipertrofia: return "flame.fill"
        case .resistencia: return "heart.fill"
        case .tecnica: return "target"
        case .recuperacion: return "leaf.fill"
        }
    }
}

/// Meta extra para planificar mejor.
struct PlanMeta: Codable, Equatable {
    var goal: PlanGoal?
    var rpeTarget: Double?     // 1...10
}

struct TrainingPlan: Codable, Identifiable, Equatable {
    let id: UUID
    var date: Date
    var kind: TrainingPlanKind

    var routineTitle: String?
    var durationMinutes: Int?
    var note: String?

    var meta: PlanMeta?

    init(
        id: UUID = UUID(),
        date: Date,
        kind: TrainingPlanKind,
        routineTitle: String? = nil,
        durationMinutes: Int? = nil,
        note: String? = nil,
        meta: PlanMeta? = nil
    ) {
        self.id = id
        self.date = date
        self.kind = kind
        self.routineTitle = routineTitle
        self.durationMinutes = durationMinutes
        self.note = note
        self.meta = meta
    }
}
