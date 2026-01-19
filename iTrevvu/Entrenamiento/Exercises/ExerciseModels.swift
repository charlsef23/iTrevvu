import Foundation

enum MuscleGroup: String, Codable, CaseIterable, Identifiable {
    case pecho, espalda, hombro, biceps, triceps, core, gluteo, cuadriceps, femoral, gemelo
    case fullBody
    case cardio
    case movilidad

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pecho: return "Pecho"
        case .espalda: return "Espalda"
        case .hombro: return "Hombro"
        case .biceps: return "Bíceps"
        case .triceps: return "Tríceps"
        case .core: return "Core"
        case .gluteo: return "Glúteo"
        case .cuadriceps: return "Cuádriceps"
        case .femoral: return "Femoral"
        case .gemelo: return "Gemelo"
        case .fullBody: return "Full body"
        case .cardio: return "Cardio"
        case .movilidad: return "Movilidad"
        }
    }
}

enum ExerciseCategory: String, Codable, CaseIterable, Identifiable {
    case fuerza
    case cardio
    case movilidad

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fuerza: return "Fuerza"
        case .cardio: return "Cardio"
        case .movilidad: return "Movilidad"
        }
    }
}

enum Equipment: String, Codable, CaseIterable, Identifiable {
    case pesoCorporal
    case barra
    case mancuernas
    case kettlebell
    case maquina
    case polea
    case banda
    case banco
    case smith
    case trapBar
    case cardioMachine
    case otros

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pesoCorporal: return "Peso corporal"
        case .barra: return "Barra"
        case .mancuernas: return "Mancuernas"
        case .kettlebell: return "Kettlebell"
        case .maquina: return "Máquina"
        case .polea: return "Polea"
        case .banda: return "Banda"
        case .banco: return "Banco"
        case .smith: return "Smith"
        case .trapBar: return "Trap bar"
        case .cardioMachine: return "Máquina cardio"
        case .otros: return "Otros"
        }
    }
}

enum MovementPattern: String, Codable, CaseIterable, Identifiable {
    case empuje
    case tiron
    case sentadilla
    case bisagra
    case carry
    case core
    case aislamiento
    case locomocion
    case movilidad

    var id: String { rawValue }

    var title: String {
        switch self {
        case .empuje: return "Empuje"
        case .tiron: return "Tirón"
        case .sentadilla: return "Sentadilla"
        case .bisagra: return "Bisagra"
        case .carry: return "Cargas"
        case .core: return "Core"
        case .aislamiento: return "Aislamiento"
        case .locomocion: return "Locomoción"
        case .movilidad: return "Movilidad"
        }
    }
}

struct Exercise: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var category: ExerciseCategory
    var primary: MuscleGroup
    var secondary: [MuscleGroup]
    var equipment: [Equipment]
    var pattern: MovementPattern

    // Opcional (para guiar UI)
    var isUnilateral: Bool
    var isBodyweight: Bool
    var defaultRepRange: String?    // "6-10", "8-12", "30-60s", etc
    var tips: String?

    // Si es creado por el usuario
    var isCustom: Bool

    init(
        id: UUID = UUID(),
        name: String,
        category: ExerciseCategory,
        primary: MuscleGroup,
        secondary: [MuscleGroup] = [],
        equipment: [Equipment] = [],
        pattern: MovementPattern,
        isUnilateral: Bool = false,
        isBodyweight: Bool = false,
        defaultRepRange: String? = nil,
        tips: String? = nil,
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.primary = primary
        self.secondary = secondary
        self.equipment = equipment
        self.pattern = pattern
        self.isUnilateral = isUnilateral
        self.isBodyweight = isBodyweight
        self.defaultRepRange = defaultRepRange
        self.tips = tips
        self.isCustom = isCustom
    }
}
