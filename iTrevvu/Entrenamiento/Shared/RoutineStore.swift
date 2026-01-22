import Foundation
import Combine

/// ✅ STUB temporal (Fase 1: Planificador)
/// Rutinas todavía NO sincronizadas con Supabase.
/// Este store existe para que compile y para mantener UI funcionando.
@MainActor
final class RoutineStore: ObservableObject {

    struct Routine: Identifiable, Equatable {
        let id: UUID
        let title: String
        let subtitle: String
        let tag: String?
    }

    struct RoutineItem: Identifiable, Equatable {
        let id: UUID
        let order: Int
        let name: String
        let sets: Int
        let repRange: String
        let restSeconds: Int
    }

    @Published private(set) var routines: [Routine] = []
    @Published private(set) var itemsByRoutineId: [UUID: [RoutineItem]] = [:]
    @Published private(set) var isLoading: Bool = false

    init() {}

    func bootstrap() async {
        // Nada por ahora
        await refresh()
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        // ✅ Mock temporal (puedes modificar títulos/tags)
        let r1 = Routine(id: UUID(), title: "Fuerza · Parte superior", subtitle: "6 ejercicios · 45 min", tag: "Recomendada")
        let r2 = Routine(id: UUID(), title: "Hipertrofia · Pierna", subtitle: "7 ejercicios · 55 min", tag: "Popular")
        let r3 = Routine(id: UUID(), title: "Full Body · Express", subtitle: "5 ejercicios · 30 min", tag: "Rápida")

        routines = [r1, r2, r3]

        itemsByRoutineId[r1.id] = [
            .init(id: UUID(), order: 0, name: "Press banca", sets: 3, repRange: "6–10", restSeconds: 120),
            .init(id: UUID(), order: 1, name: "Dominadas", sets: 3, repRange: "6–10", restSeconds: 120),
            .init(id: UUID(), order: 2, name: "Remo", sets: 3, repRange: "8–12", restSeconds: 90)
        ]

        itemsByRoutineId[r2.id] = [
            .init(id: UUID(), order: 0, name: "Sentadilla", sets: 4, repRange: "6–10", restSeconds: 150),
            .init(id: UUID(), order: 1, name: "Peso muerto rumano", sets: 3, repRange: "8–12", restSeconds: 120),
            .init(id: UUID(), order: 2, name: "Extensión cuádriceps", sets: 3, repRange: "10–15", restSeconds: 75)
        ]

        itemsByRoutineId[r3.id] = [
            .init(id: UUID(), order: 0, name: "Press militar", sets: 3, repRange: "8–12", restSeconds: 90),
            .init(id: UUID(), order: 1, name: "Sentadilla goblet", sets: 3, repRange: "10–15", restSeconds: 90),
            .init(id: UUID(), order: 2, name: "Plancha", sets: 3, repRange: "30–60s", restSeconds: 60)
        ]
    }

    func routineItems(for routineId: UUID) -> [RoutineItem] {
        itemsByRoutineId[routineId] ?? []
    }
}
