import Foundation
import Combine
import Supabase

struct SessionDraft {
    var tipo: TrainingPlanKind
    var planId: UUID?
    var title: String?
    var durationMinutes: Int?
    var notes: String?
}

struct SessionExerciseDraft {
    var order: Int
    var exerciseId: UUID?        // global
    var userExerciseId: UUID?    // custom
    var nameSnapshot: String?
    var notes: String?
}

struct SessionSetDraft {
    var order: Int
    var reps: Int?
    var weightKg: Double?
    var rpe: Double?
    var timeSec: Int?
    var distanceM: Double?
}

@MainActor
final class SessionStore: ObservableObject {

    @Published private(set) var recent: [DBSession] = []

    private let service: TrainingSupabaseService
    private var autorId: UUID?

    init(client: SupabaseClient) {
        self.service = TrainingSupabaseService(client: client)
    }

    func bootstrap() async {
        do { autorId = try service.currentUserId() } catch { }
    }

    func refreshRecent(limit: Int = 20) async {
        guard let autorId else { return }
        do {
            recent = try await service.fetchRecentSessions(autorId: autorId, limit: limit)
        } catch { }
    }

    /// Crea sesión + items + sets en Supabase
    func saveSession(
        draft: SessionDraft,
        exercises: [SessionExerciseDraft],
        setsByExerciseOrder: [Int: [SessionSetDraft]]
    ) async throws {

        guard let autorId else { throw NSError(domain: "SessionStore", code: 401) }

        // ✅ DTO Encodable
        let sessionDTO = TrainingSupabaseService.CreateSessionDTO(
            autor_id: autorId.uuidString,
            fecha: ISO8601DateFormatter().string(from: Date()),
            tipo: draft.tipo.rawValue,
            plan_id: draft.planId?.uuidString,
            titulo: draft.title,
            duracion_minutos: draft.durationMinutes,
            notas: draft.notes
        )

        let session = try await service.createSession(sessionDTO)

        for ex in exercises.sorted(by: { $0.order < $1.order }) {

            let itemDTO = TrainingSupabaseService.CreateSessionItemDTO(
                sesion_id: session.id.uuidString,
                orden: ex.order,
                ejercicio_id: ex.exerciseId?.uuidString,
                ejercicio_usuario_id: ex.userExerciseId?.uuidString,
                nombre_snapshot: ex.nameSnapshot,
                notas: ex.notes
            )

            let item = try await service.createSessionItem(itemDTO)

            let sets = setsByExerciseOrder[ex.order] ?? []
            for s in sets.sorted(by: { $0.order < $1.order }) {

                let setDTO = TrainingSupabaseService.CreateSessionSetDTO(
                    sesion_item_id: item.id.uuidString,
                    orden: s.order,
                    reps: s.reps,
                    peso_kg: s.weightKg,
                    rpe: s.rpe,
                    tiempo_seg: s.timeSec,
                    distancia_m: s.distanceM,
                    completado: true
                )

                _ = try await service.createSessionSet(setDTO)
            }
        }
    }
}
