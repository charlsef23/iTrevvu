import Foundation

// MARK: - DB Rows (DTO) para Supabase
// Ajusta nombres de tabla/columnas si los tuyos difieren.
// Esto está diseñado para mapear a los modelos Domain de arriba.

struct DBTrainingSession: Codable, Identifiable {
    let id: UUID
    let autor_id: UUID

    let started_at: Date
    let ended_at: Date?

    let titulo: String
    let tipo: String

    let created_at: Date?
    let updated_at: Date?
}

struct DBTrainingSessionItem: Codable, Identifiable {
    let id: UUID
    let sesion_id: UUID
    let orden: Int

    let ejercicio_id: UUID?
    let nombre_snapshot: String?
    let tipo: String

    let notas: String?

    let created_at: Date?
    let updated_at: Date?
}

struct DBTrainingSessionSet: Codable, Identifiable {
    let id: UUID
    let sesion_item_id: UUID
    let orden: Int

    let reps: Int?
    let peso_kg: Double?
    let rpe: Double?
    let tiempo_seg: Int?
    let distancia_m: Double?
    let completado: Bool

    let created_at: Date?
    let updated_at: Date?
}

// MARK: - Mapping DB -> Domain

extension DBTrainingSession {

    func toDomain(items: [TrainingSessionItem] = []) -> TrainingSession {
        TrainingSession(
            id: id,
            autorId: autor_id,
            startedAt: started_at,
            endedAt: ended_at,
            titulo: titulo,
            tipo: TrainingSessionType(rawValue: tipo) ?? .gimnasio,
            items: items
        )
    }
}

extension DBTrainingSessionItem {

    /// Convierte un row item + sus sets (rows) a dominio.
    func toDomain(sets: [DBTrainingSessionSet] = []) -> TrainingSessionItem {
        let exType = ExerciseType(rawValue: tipo) ?? .fuerza

        let mappedSets: [TrainingSet] = sets
            .sorted(by: { $0.orden < $1.orden })
            .map {
                TrainingSet(
                    orden: $0.orden,
                    reps: $0.reps,
                    pesoKg: $0.peso_kg,
                    rpe: $0.rpe,
                    tiempoSeg: $0.tiempo_seg,
                    distanciaM: $0.distancia_m,
                    completado: $0.completado
                )
            }

        return TrainingSessionItem(
            id: id,
            sessionId: sesion_id,
            orden: orden,
            exerciseId: ejercicio_id,
            nombre: (nombre_snapshot?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isEmpty ? nil : $0 } ?? "Ejercicio",
            tipo: exType,
            notas: notas,
            sets: mappedSets
        )
    }
}
