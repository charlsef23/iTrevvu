import Foundation

struct QuickWorkoutType: Identifiable, Codable, Hashable {
    let id: UUID
    let nombre: String
    let slug: String
    let icono: String
    let color: String
    let orden: Int
    let tipo: String
}

struct QuickWorkoutSession: Identifiable, Codable, Hashable {
    let id: UUID
    let autor_id: UUID
    let entrenamiento_rapido_id: UUID
    let started_at: Date
    var ended_at: Date?
    var duracion_segundos: Int
    var calorias: Int?
    var distancia_m: Float?
    var notas: String?
}
