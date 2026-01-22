import Foundation

// MARK: - PlanMeta (⚠️ SOLO AQUÍ, NO LO DECLARES EN OTRO ARCHIVO)

struct PlanMeta: Codable, Equatable {
    var goal: String?                      // ej: "Hipertrofia", "Fuerza", "Resistencia"
    var rpe: Int?                          // 1...10
    var scheduledTime: String?             // "HH:mm"
    var checklist: [String: Bool]?         // ej: ["Warm-up": true, "Creatina": false]

    init(
        goal: String? = nil,
        rpe: Int? = nil,
        scheduledTime: String? = nil,
        checklist: [String: Bool]? = nil
    ) {
        self.goal = goal
        self.rpe = rpe
        self.scheduledTime = scheduledTime
        self.checklist = checklist
    }
}

// MARK: - Training plan

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
