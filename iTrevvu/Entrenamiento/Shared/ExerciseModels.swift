import Foundation

enum ExerciseType: String, Codable, CaseIterable, Identifiable {
    case fuerza, calistenia, cardio, hiit, core, movilidad, rehab, deporte, rutinas

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fuerza: return "Fuerza"
        case .calistenia: return "Calistenia"
        case .cardio: return "Cardio"
        case .hiit: return "HIIT"
        case .core: return "Core"
        case .movilidad: return "Movilidad"
        case .rehab: return "Rehab"
        case .deporte: return "Deporte"
        case .rutinas: return "Rutinas"
        }
    }

    var icon: String {
        switch self {
        case .fuerza: return "dumbbell.fill"
        case .calistenia: return "figure.strengthtraining.traditional"
        case .cardio: return "figure.run"
        case .hiit: return "bolt.fill"
        case .core: return "circle.grid.cross"
        case .movilidad: return "figure.cooldown"
        case .rehab: return "cross.case.fill"
        case .deporte: return "sportscourt.fill"
        case .rutinas: return "list.bullet.rectangle"
        }
    }
}

enum MeasurementType: String, Codable, CaseIterable, Identifiable {
    case peso_reps, reps, tiempo, distancia, calorias
    var id: String { rawValue }

    var title: String {
        switch self {
        case .peso_reps: return "Peso + reps"
        case .reps: return "Reps"
        case .tiempo: return "Tiempo"
        case .distancia: return "Distancia"
        case .calorias: return "Calorías"
        }
    }
}

struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    let tipo: ExerciseType
    let nombre: String

    let aliases: [String]?
    let descripcion: String?

    let musculo_principal: String?
    let musculos_secundarios: [String]?
    let equipo: [String]?
    let patron: String?

    let tipo_medicion: MeasurementType
    let video_url: String?

    let es_publico: Bool
    let autor_id: UUID?

    let created_at: Date?
    let updated_at: Date?
}
