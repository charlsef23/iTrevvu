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

    var defaultIcon: String {
        switch self {
        case .gimnasio: return "dumbbell.fill"
        case .cardio: return "figure.run"
        case .movilidad: return "figure.cooldown"
        case .rutina: return "list.bullet.rectangle"
        case .hiit: return "bolt.fill"
        case .calistenia: return "figure.strengthtraining.traditional"
        case .deporte: return "sportscourt.fill"
        case .rehab: return "cross.case.fill"
        case .descanso: return "bed.double.fill"
        }
    }
}

/// ✅ Meta flexible (va a jsonb `meta`)
struct SessionMeta: Codable, Hashable {
    var goal: String?
    var rpeTarget: Double?
    var tags: [String]?
}

/// ✅ Modelo “UI” para una sesión planificada
struct PlannedSession: Identifiable, Hashable {
    var id: UUID?                  // nil -> create
    var date: Date                 // día
    var hora: String?              // "HH:mm:ss" o nil

    var tipo: TrainingSessionType
    var nombre: String

    var icono: String?
    var color: String?

    var duracionMinutos: Int?
    var objetivo: String?
    var notas: String?
    var meta: SessionMeta?

    // Helpers
    var fechaKey: String {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", comps.year ?? 0, comps.month ?? 0, comps.day ?? 0)
    }

    /// Ordenación: hora primero (si existe), si no, al final
    var sortKey: String {
        // "00:00:00" .. "23:59:59" ; nil -> "99:99:99"
        (hora?.isEmpty == false ? hora! : "99:99:99")
    }
}

/// ✅ Ejercicio dentro de una sesión
struct PlannedSessionExercise: Identifiable, Hashable {
    var id: UUID? = nil
    var orden: Int = 0
    var ejercicioId: UUID?
    var nombreOverride: String?
    var objetivo: [String: String]? // sets/reps/peso/tiempo... flexible
    var notas: String?
}
