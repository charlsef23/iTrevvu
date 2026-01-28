import Foundation

enum PlanGoal: String, CaseIterable, Identifiable {
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
        case .fuerza: return "dumbbell.fill"
        case .hipertrofia: return "flame.fill"
        case .resistencia: return "heart.fill"
        case .tecnica: return "scope"
        case .recuperacion: return "bandage.fill"
        }
    }
}
