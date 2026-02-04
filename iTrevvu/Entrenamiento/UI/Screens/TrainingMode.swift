import Foundation

enum TrainingMode: String, CaseIterable, Identifiable, Codable {
    case gimnasio = "Gimnasio"
    case cardio = "Cardio"
    case movilidad = "Movilidad"
    var id: String { rawValue }
}
