import Foundation
import Combine

@MainActor
final class TrainingSessionStore: ObservableObject {

    // Sesión en vivo (simple pero consistente)
    @Published private(set) var sessionId: UUID? = nil

    @Published var title: String = "Sesión"
    @Published var startedAt: Date = .now
    @Published var items: [TrainingSessionItem] = []
    @Published var isRunning: Bool = false

    // MARK: - Lifecycle

    func start(title: String? = nil) {
        // nueva sesión
        sessionId = UUID()
        items.removeAll()

        let t = (title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = t.isEmpty ? "Sesión" : t

        startedAt = .now
        isRunning = true
    }

    func stop() {
        isRunning = false
    }

    // MARK: - Items

    func addExercise(_ exercise: Exercise) {
        guard let sid = sessionId else {
            // si intentan añadir sin iniciar, iniciamos una sesión rápida
            start(title: "Sesión")
            guard let sid2 = sessionId else { return }
            addExerciseInternal(exercise, sid: sid2)
            return
        }

        addExerciseInternal(exercise, sid: sid)
    }

    private func addExerciseInternal(_ exercise: Exercise, sid: UUID) {
        let itemOrden = items.count

        // primer set por defecto
        let firstSet = TrainingSet(
            orden: 0,
            reps: nil,
            pesoKg: nil,
            rpe: nil,
            tiempoSeg: nil,
            distanciaM: nil,
            completado: false
        )

        let item = TrainingSessionItem(
            id: UUID(),
            sessionId: sid,
            orden: itemOrden,
            exerciseId: exercise.id,
            nombre: exercise.nombre,
            tipo: exercise.tipo,
            sets: [firstSet]
        )

        items.append(item)
    }

    func removeItem(_ itemId: UUID) {
        items.removeAll { $0.id == itemId }
        // re-ordenar
        for i in items.indices {
            items[i].orden = i
        }
    }

    // MARK: - Sets

    func addSet(to itemId: UUID) {
        guard let idx = items.firstIndex(where: { $0.id == itemId }) else { return }
        let nextOrden = items[idx].sets.count

        let newSet = TrainingSet(
            orden: nextOrden,
            reps: nil,
            pesoKg: nil,
            rpe: nil,
            tiempoSeg: nil,
            distanciaM: nil,
            completado: false
        )

        items[idx].sets.append(newSet)
    }

    func toggleSetDone(itemId: UUID, setIndex: Int) {
        guard let idx = items.firstIndex(where: { $0.id == itemId }) else { return }
        guard items[idx].sets.indices.contains(setIndex) else { return }
        items[idx].sets[setIndex].completado.toggle()
    }
}
