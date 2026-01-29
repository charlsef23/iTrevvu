import Foundation

// MARK: - Domain

struct TrainingSession: Identifiable, Hashable {
    let id: UUID
    let autorId: UUID
    var startedAt: Date
    var endedAt: Date?
    var titulo: String
    var tipo: TrainingSessionType
    var items: [TrainingSessionItem]

    var durationMinutes: Int? {
        guard let endedAt else { return nil }
        let sec = endedAt.timeIntervalSince(startedAt)
        return max(0, Int(sec / 60.0))
    }
}

struct TrainingSessionItem: Identifiable, Hashable {
    let id: UUID
    let sessionId: UUID
    var orden: Int

    let exerciseId: UUID?
    var nombre: String
    var tipo: ExerciseType

    var notas: String?
    var sets: [TrainingSet]
}

struct TrainingSet: Hashable {
    var orden: Int
    var reps: Int?
    var pesoKg: Double?
    var rpe: Double?
    var tiempoSeg: Int?
    var distanciaM: Double?
    var completado: Bool
}

// ✅ Compatibilidad con tu DBModels (si el archivo usa TrainingSessionSet)
typealias TrainingSessionSet = TrainingSet
