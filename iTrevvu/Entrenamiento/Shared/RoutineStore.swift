import Foundation
import Combine
import Supabase

struct Routine: Identifiable, Hashable {
    let id: UUID
    let title: String
    let description: String?
    let tags: [String]
    let durationMinutes: Int?
}

struct RoutineItem: Identifiable, Hashable {
    let id: UUID
    let routineId: UUID
    let order: Int
    let exerciseId: UUID?            // global
    let userExerciseId: UUID?        // custom
    let nameOverride: String?
    let notes: String?
    let targetSets: Int?
    let targetRepRange: String?
    let restSeconds: Int?
}

@MainActor
final class RoutineStore: ObservableObject {

    @Published private(set) var routines: [Routine] = []
    @Published private(set) var itemsByRoutine: [UUID: [RoutineItem]] = [:]

    private let service: TrainingSupabaseService
    private var autorId: UUID?

    init(client: SupabaseClient) {
        self.service = TrainingSupabaseService(client: client)
    }

    func bootstrap() async {
        do { autorId = try service.currentUserId() } catch { }
    }

    func refreshRoutines() async {
        guard let autorId else { return }
        do {
            let rows = try await service.fetchRoutines(autorId: autorId)
            routines = rows.map { .init(id: $0.id, title: $0.titulo, description: $0.descripcion, tags: $0.tags, durationMinutes: $0.duracion_minutos) }
        } catch { }
    }

    func loadItems(routineId: UUID) async {
        do {
            let rows = try await service.fetchRoutineItems(routineId: routineId)
            itemsByRoutine[routineId] = rows.map {
                RoutineItem(
                    id: $0.id,
                    routineId: $0.rutina_id,
                    order: $0.orden,
                    exerciseId: $0.ejercicio_id,
                    userExerciseId: $0.ejercicio_usuario_id,
                    nameOverride: $0.nombre_override,
                    notes: $0.notas,
                    targetSets: $0.sets_objetivo,
                    targetRepRange: $0.rep_range_objetivo,
                    restSeconds: $0.descanso_segundos
                )
            }
        } catch { }
    }
}
