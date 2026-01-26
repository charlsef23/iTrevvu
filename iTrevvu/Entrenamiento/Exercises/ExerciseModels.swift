import Foundation

enum ExerciseType: String, Codable, CaseIterable, Identifiable {
    case fuerza, calistenia, cardio, hiit, core, movilidad, rehab, deporte, rutinas
    var id: String { rawValue }

    var title: String {
        switch self {
        case .fuerza: return "Fuerza (Gym)"
        case .calistenia: return "Peso corporal"
        case .cardio: return "Cardio"
        case .hiit: return "HIIT / Conditioning"
        case .core: return "Core"
        case .movilidad: return "Movilidad / Estiramientos"
        case .rehab: return "Rehabilitación / Prehab"
        case .deporte: return "Deporte (Skills)"
        case .rutinas: return "Rutinas / Plantillas"
        }
    }

    var icon: String {
        switch self {
        case .fuerza: return "dumbbell"
        case .calistenia: return "figure.strengthtraining.traditional"
        case .cardio: return "heart"
        case .hiit: return "bolt"
        case .core: return "circle.grid.cross"
        case .movilidad: return "figure.cooldown"
        case .rehab: return "cross.case"
        case .deporte: return "figure.run"
        case .rutinas: return "list.bullet.rectangle"
        }
    }
}

enum ExerciseMetricType: String, Codable {
    case peso_reps, reps, tiempo, distancia, calorias

    var title: String {
        switch self {
        case .peso_reps: return "Peso + Reps"
        case .reps: return "Reps"
        case .tiempo: return "Tiempo"
        case .distancia: return "Distancia"
        case .calorias: return "Calorías"
        }
    }
}

struct Exercise: Codable, Identifiable, Hashable {
    let id: UUID
    let tipo: ExerciseType
    let nombre: String
    let aliases: [String]?
    let descripcion: String?
    let musculo_principal: String?
    let musculos_secundarios: [String]?
    let equipo: [String]?
    let patron: String?
    let tipo_medicion: ExerciseMetricType
    let video_url: String?
    let es_publico: Bool
    let autor_id: UUID?
    let created_at: Date?
    let updated_at: Date?
}

struct ExerciseFavorite: Codable, Hashable {
    let autor_id: UUID
    let ejercicio_id: UUID
    let created_at: Date?
}
